import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../data/models/lesson.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final transactionsAsync = ref.watch(currentMonthTransactionsProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      data: (profile) {
        final salary = profile?.monthlySalary ?? 700000.0;
        final currency = profile?.currency ?? 'BIF';
        final name = profile?.name ?? 'Utilisateur';

        return transactionsAsync.when(
          loading: () => _buildScaffold(
            name: name,
            salary: salary,
            currency: currency,
            expenses: 0,
            savings: 0,
            transactions: [],
            ref: ref,
            context: context,
          ),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
          data: (transactions) {
            final expenses = transactions
                .where((t) => t.type == 'expense')
                .fold(0.0, (s, t) => s + t.amount);
            final savings = transactions
                .where((t) => t.category == 'epargne')
                .fold(0.0, (s, t) => s + t.amount);
            return _buildScaffold(
              name: name,
              salary: salary,
              currency: currency,
              expenses: expenses,
              savings: savings,
              transactions: transactions,
              ref: ref,
              context: context,
            );
          },
        );
      },
    );
  }

  Widget _buildScaffold({
    required String name,
    required double salary,
    required String currency,
    required double expenses,
    required double savings,
    required List<Transaction> transactions,
    required WidgetRef ref,
    required BuildContext context,
  }) {
    final balance = salary - expenses;
    final firstName = name.split(' ').first;

    // Calcul 50/30/20
    final needs = salary * 0.50;
    final wants = salary * 0.30;
    final savingsTarget = salary * 0.20;

    // Dépenses réelles par bucket (approximatif — l'utilisateur configure sa catégorisation)
    final needsSpent = transactions
        .where((t) =>
            t.type == 'expense' &&
            ['loyer', 'food', 'transport', 'charges'].contains(t.category))
        .fold(0.0, (s, t) => s + t.amount);
    final wantsSpent = transactions
        .where((t) => t.type == 'expense' && t.category == 'divers')
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── HEADER VERT ───
            _buildHeader(
              context: context,
              firstName: firstName,
              balance: balance,
              currency: currency,
            ),

            // ─── CORPS SCROLLABLE ───
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  children: [
                    // Boutons d'action rapide
                    _buildQuickActions(context),
                    const SizedBox(height: AppTheme.gapLarge),

                    // Cards stats côte à côte
                    _buildStatsRow(
                      expenses: expenses,
                      savings: savings,
                      currency: currency,
                    ),
                    const SizedBox(height: AppTheme.gapLarge),

                    // Règle 50/30/20
                    _build502030(
                      needs: needs,
                      wants: wants,
                      savingsTarget: savingsTarget,
                      needsSpent: needsSpent,
                      wantsSpent: wantsSpent,
                      savingsActual: savings,
                      currency: currency,
                    ),
                    const SizedBox(height: AppTheme.gapLarge),

                    // Leçon du jour
                    _buildLessonCard(context),
                    const SizedBox(height: AppTheme.gapLarge),

                    // Transactions récentes
                    SectionHeader(
                      title: 'Transactions récentes',
                      actionLabel: 'Tout voir',
                      onAction: () => context.go('/budget'),
                    ),
                    const SizedBox(height: AppTheme.gapMedium),
                    if (transactions.isEmpty)
                      EmptyStateWidget(
                        icon: Icons.receipt_long_rounded,
                        title: 'Aucune transaction',
                        subtitle:
                            'Commence à enregistrer tes dépenses pour suivre ton budget.',
                        actionLabel: 'Ajouter',
                        onAction: () =>
                            context.push('/budget/add?type=expense'),
                      )
                    else
                      ...transactions.take(5).map(
                            (t) => _TransactionTile(
                                transaction: t, currency: currency),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required String firstName,
    required double balance,
    required String currency,
  }) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row — greeting + avatar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Muraho, $firstName 👋',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.formatDateLong(now),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar initiales
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.accent,
                  child: Text(
                    firstName.isNotEmpty
                        ? firstName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Solde disponible
          Text(
            'Solde disponible',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.formatAmount(balance, currency: currency),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            balance >= 0 ? 'Heza 💚 Tu es dans le vert !' : '⚠️ Budget dépassé',
            style: AppTextStyles.bodySmall.copyWith(
              color: balance >= 0
                  ? AppColors.accent
                  : AppColors.alert,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        QuickActionButton(
          icon: Icons.add_rounded,
          label: 'Ajouter',
          onTap: () => context.push('/budget/add?type=income'),
          backgroundColor: AppColors.action,
          iconColor: Colors.white,
        ),
        QuickActionButton(
          icon: Icons.remove_rounded,
          label: 'Dépense',
          onTap: () => context.push('/budget/add?type=expense'),
          backgroundColor: AppColors.primaryLight,
          iconColor: AppColors.primary,
        ),
        QuickActionButton(
          icon: Icons.flag_rounded,
          label: 'Objectif',
          onTap: () => context.push('/goals'),
          backgroundColor: Color(0xFFFFF3E0),
          iconColor: AppColors.alert,
        ),
        QuickActionButton(
          icon: Icons.school_rounded,
          label: 'Investir',
          onTap: () => context.go('/invest'),
          backgroundColor: AppColors.primaryLight,
          iconColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildStatsRow({
    required double expenses,
    required double savings,
    required String currency,
  }) {
    return Row(
      children: [
        Expanded(
          child: HezaCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_downward_rounded,
                          color: AppColors.error, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text('Dépenses',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppFormatters.formatNumber(expenses),
                  style: AppTextStyles.amountMedium.copyWith(fontSize: 18),
                ),
                Text(currency,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppTheme.gapMedium),
        Expanded(
          child: HezaCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.action.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.savings_rounded,
                          color: AppColors.action, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text('Épargne',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppFormatters.formatNumber(savings),
                  style: AppTextStyles.amountMedium
                      .copyWith(fontSize: 18, color: AppColors.action),
                ),
                Text(currency,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _build502030({
    required double needs,
    required double wants,
    required double savingsTarget,
    required double needsSpent,
    required double wantsSpent,
    required double savingsActual,
    required String currency,
  }) {
    return HezaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Règle 50/30/20', style: AppTextStyles.headlineSmall),
              const Spacer(),
              const HezaBadge(label: 'Ce mois'),
            ],
          ),
          const SizedBox(height: 16),
          _BudgetBucketRow(
            label: '50% Besoins',
            spent: needsSpent,
            target: needs,
            color: AppColors.action,
            currency: currency,
          ),
          const SizedBox(height: 12),
          _BudgetBucketRow(
            label: '30% Envies',
            spent: wantsSpent,
            target: wants,
            color: AppColors.alert,
            currency: currency,
          ),
          const SizedBox(height: 12),
          _BudgetBucketRow(
            label: '20% Épargne',
            spent: savingsActual,
            target: savingsTarget,
            color: AppColors.primary,
            currency: currency,
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context) {
    final lesson = LessonsData.all.first;
    return GestureDetector(
      onTap: () => context.push('/invest/lesson/${lesson.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '📚 Leçon du jour',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: Colors.white.withOpacity(0.7)),
                ),
                const Spacer(),
                HezaBadge(
                  label: lesson.level,
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  textColor: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              lesson.title,
              style: AppTextStyles.headlineSmall
                  .copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 14, color: Colors.white.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  lesson.duration,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Colors.white.withOpacity(0.6)),
                ),
                const Spacer(),
                Text(
                  'Lire →',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne de bucket 50/30/20
class _BudgetBucketRow extends StatelessWidget {
  final String label;
  final double spent;
  final double target;
  final Color color;
  final String currency;

  const _BudgetBucketRow({
    required this.label,
    required this.spent,
    required this.target,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (spent / target).clamp(0.0, 1.0) : 0.0;
    final pct = (ratio * 100).toStringAsFixed(0);
    final isOver = spent > target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.titleSmall),
            ),
            Text(
              '$pct%',
              style: AppTextStyles.labelMedium.copyWith(
                color: isOver ? AppColors.error : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        HezaProgressBar(
          value: ratio,
          color: isOver ? AppColors.error : color,
          height: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '${AppFormatters.formatNumber(spent)} / ${AppFormatters.formatNumber(target)} $currency',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

/// Tuile de transaction
class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final String currency;

  const _TransactionTile({required this.transaction, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CategoryIcon(category: transaction.category, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _categoryLabel(transaction.category),
                  style: AppTextStyles.titleSmall,
                ),
                Text(
                  transaction.note?.isNotEmpty == true
                      ? transaction.note!
                      : AppFormatters.formatRelativeDate(transaction.date),
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${AppFormatters.formatNumber(transaction.amount)} $currency',
            style: AppTextStyles.amountSmall.copyWith(
              color: isIncome ? AppColors.action : AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String cat) {
    const labels = {
      'transport': 'Transport',
      'food': 'Alimentation',
      'loyer': 'Loyer',
      'charges': 'Charges',
      'epargne': 'Épargne',
      'divers': 'Divers',
      'revenu': 'Revenu',
      'income': 'Revenu',
    };
    return labels[cat.toLowerCase()] ?? cat;
  }
}
