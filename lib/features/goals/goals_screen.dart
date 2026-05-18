import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

/// Écran des objectifs d'épargne
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final currency = profileAsync.value?.currency ?? 'BIF';
    final salary = profileAsync.value?.monthlySalary ?? 700000.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectifs d\'épargne'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/goals/add'),
            tooltip: 'Nouvel objectif',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/add'),
        label: const Text('Nouvel objectif'),
        icon: const Icon(Icons.flag_rounded),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (goals) {
          return CustomScrollView(
            slivers: [
              // Widget fonds d'urgence
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _EmergencyFundCard(
                      salary: salary, currency: currency),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: SectionHeader(
                    title: 'Mes objectifs (${goals.length})',
                  ),
                ),
              ),

              if (goals.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.flag_rounded,
                    title: 'Aucun objectif',
                    subtitle:
                        'Définis un objectif d\'épargne pour rester motivé.',
                    actionLabel: 'Créer un objectif',
                    onAction: () => context.push('/goals/add'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GoalCard(
                            goal: goals[i], currency: currency),
                      ),
                      childCount: goals.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Card d'un objectif d'épargne
class _GoalCard extends ConsumerWidget {
  final Goal goal;
  final String currency;
  const _GoalCard({required this.goal, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio =
        goal.targetAmount > 0
            ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
            : 0.0;
    final pct = (ratio * 100).toStringAsFixed(0);
    final remaining = goal.targetAmount - goal.currentAmount;
    final monthsLeft = AppFormatters.monthsUntil(goal.deadline);
    final monthlyNeeded =
        monthsLeft > 0 ? remaining / monthsLeft : remaining;
    final color = _parseColor(goal.color);

    return HezaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.flag_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.title, style: AppTextStyles.titleMedium),
                  Text(
                    'Échéance : ${AppFormatters.formatDateMedium(goal.deadline)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            if (goal.isCompleted)
              const HezaBadge(
                label: '✓ Atteint',
                backgroundColor: Color(0xFFE8F5E9),
                textColor: AppColors.action,
              )
            else
              Text(
                '$pct%',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: color),
              ),
          ]),
          const SizedBox(height: 14),

          // Barre de progression
          HezaProgressBar(value: ratio, color: color, height: 10),
          const SizedBox(height: 8),

          Row(children: [
            Text(
              AppFormatters.formatNumber(goal.currentAmount),
              style: AppTextStyles.titleSmall.copyWith(color: color),
            ),
            Text(' / ${AppFormatters.formatAmount(goal.targetAmount, currency: currency)}',
                style: AppTextStyles.bodySmall),
          ]),

          if (!goal.isCompleted && monthsLeft > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 Il te faut ${AppFormatters.formatAmount(monthlyNeeded, currency: currency)}/mois pendant $monthsLeft mois',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Bouton ajouter des fonds
          if (!goal.isCompleted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _showAddFundsDialog(context, ref, goal, currency),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Ajouter des fonds'),
              ),
            ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(
          int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.action;
    }
  }

  Future<void> _showAddFundsDialog(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
    String currency,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter des fonds', style: AppTextStyles.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objectif : ${goal.title}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '0',
                suffixText: currency,
                labelText: 'Montant',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.isNotEmpty) {
      final amount = double.tryParse(controller.text);
      if (amount != null && amount > 0) {
        final newAmount = goal.currentAmount + amount;
        await ref.read(goalsDaoProvider).updateCurrentAmount(goal.id, newAmount);

        // Enregistre aussi comme transaction épargne
        final now = DateTime.now();
        final monthKey =
            '${now.year}-${now.month.toString().padLeft(2, '0')}';
        await ref.read(transactionsDaoProvider).addTransaction(
              TransactionsCompanion(
                amount: Value(amount),
                category: const Value('epargne'),
                type: const Value('expense'),
                note: Value('Épargne : ${goal.title}'),
                date: Value(now),
                monthKey: Value(monthKey),
              ),
            );

        // Badge fonds d'urgence si objectif atteint
        if (newAmount >= goal.targetAmount) {
          await ref.read(earnedBadgesDaoProvider).awardBadge('independence');
        }
      }
    }
  }
}

/// Widget fonds d'urgence recommandé
class _EmergencyFundCard extends StatelessWidget {
  final double salary;
  final String currency;
  const _EmergencyFundCard(
      {required this.salary, required this.currency});

  @override
  Widget build(BuildContext context) {
    final loyer = salary * 0.30; // approximation loyer = 30% salaire
    final recommended = loyer * 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.alert.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.alert.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Text('🛡️', style: TextStyle(fontSize: 30)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fonds d\'urgence recommandé',
                  style: AppTextStyles.titleSmall),
              const SizedBox(height: 4),
              Text(
                AppFormatters.formatAmount(recommended,
                    currency: currency),
                style: AppTextStyles.amountSmall
                    .copyWith(color: AppColors.alert),
              ),
              const Text(
                '= 3 mois de loyer estimé',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
