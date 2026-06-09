import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../data/models/lesson.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Redirect to onboarding if no profile exists (first launch)
    ref.listen(userProfileProvider, (_, next) {
      if (next.hasValue && next.value == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go('/onboarding');
        });
      }
    });

    final profileAsync = ref.watch(userProfileProvider);
    final transAsync   = ref.watch(currentMonthTransactionsProvider);

    return profileAsync.when(
      loading: () => const _LoadingScreen(),
      error: (e, _) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      data: (profile) {
        final salary   = profile?.monthlySalary ?? 700000.0;
        final currency = profile?.currency ?? 'BIF';
        final name     = profile?.name ?? 'Utilisateur';

        return transAsync.when(
          loading: () => _buildScreen(context, ref, name, salary, currency, 0, 0, []),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
          data: (transactions) {
            final expenses = transactions
                .where((t) => t.type == 'expense')
                .fold(0.0, (s, t) => s + t.amount);
            final savings = transactions
                .where((t) => t.category == 'epargne')
                .fold(0.0, (s, t) => s + t.amount);
            return _buildScreen(context, ref, name, salary, currency, expenses, savings, transactions);
          },
        );
      },
    );
  }

  Widget _buildScreen(
    BuildContext context,
    WidgetRef ref,
    String name,
    double salary,
    String currency,
    double expenses,
    double savings,
    List<Transaction> transactions,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final extraIncome = transactions
        .where((t) => t.type == 'income')
        .fold<double>(0.0, (s, t) => s + t.amount);
    final balance   = salary + extraIncome - expenses;
    final firstName = name.split(' ').first;

    // Calcul 50/30/20
    final needsTarget   = salary * 0.50;
    final wantsTarget   = salary * 0.30;
    final savingsTarget = salary * 0.20;
    final needsSpent = transactions
        .where((t) => t.type == 'expense' && ['loyer','food','transport','charges'].contains(t.category))
        .fold(0.0, (s, t) => s + t.amount);
    final wantsSpent = transactions
        .where((t) => t.type == 'expense' && t.category == 'divers')
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: isDark ? HezaColors.darkBg : HezaColors.lightBg,
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // ─── HERO HEADER ───────────────────────────────────────────────
          _HeroHeader(
            firstName: firstName,
            balance: balance,
            salary: salary,
            expenses: expenses,
            currency: currency,
            onAvatarTap: () => context.go('/profile'),
          ),

          // ─── CONTENU SCROLLABLE ────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: HezaColors.primary,
              onRefresh: () async {
                ref.invalidate(currentMonthTransactionsProvider);
                ref.invalidate(userProfileProvider);
                await Future.delayed(const Duration(milliseconds: 300));
              },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                // Boutons d'action rapide
                _QuickActions(context: context),
                const SizedBox(height: 16),

                // Stats côte à côte
                Row(
                  children: [
                    Expanded(
                      child: GlassStatCard(
                        label: 'Dépenses',
                        value: AppFormatters.formatNumber(expenses),
                        unit: currency,
                        icon: Icons.arrow_downward_rounded,
                        iconColor: HezaColors.error,
                        valueColor: HezaColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassStatCard(
                        label: 'Épargne',
                        value: AppFormatters.formatNumber(savings),
                        unit: currency,
                        icon: Icons.savings_rounded,
                        iconColor: HezaColors.success,
                        valueColor: HezaColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Règle 50/30/20
                _Rule502030(
                  needsSpent: needsSpent,    needsTarget: needsTarget,
                  wantsSpent: wantsSpent,    wantsTarget: wantsTarget,
                  savings: savings,           savingsTarget: savingsTarget,
                  currency: currency,
                ),
                const SizedBox(height: 16),

                // Tendance des dépenses 6 mois
                _SpendingTrend(currency: currency),
                const SizedBox(height: 16),

                // Leçon du jour
                _DynamicLessonCard(onTap: (id) => context.push('/invest/lesson/$id')),
                const SizedBox(height: 16),

                // Transactions récentes
                SectionHeader(
                  title: 'Transactions récentes',
                  actionLabel: 'Tout voir',
                  onAction: () => context.go('/budget'),
                ),
                const SizedBox(height: 12),

                if (transactions.isEmpty)
                  EmptyStateWidget(
                    icon: Icons.receipt_long_rounded,
                    title: 'Aucune transaction',
                    subtitle: 'Commence à enregistrer tes dépenses pour suivre ton budget.',
                    actionLabel: 'Ajouter',
                    onAction: () => context.push('/budget/add?type=expense'),
                  )
                else
                  ...transactions.take(5).map(
                    (t) => _TransactionTile(transaction: t, currency: currency),
                  ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── LOADING SCREEN ──────────────────────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HezaColors.darkBg : HezaColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Chargement...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HERO HEADER ─────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String firstName;
  final double balance;
  final double salary;
  final double expenses;
  final String currency;
  final VoidCallback onAvatarTap;

  const _HeroHeader({
    required this.firstName,
    required this.balance,
    required this.salary,
    required this.expenses,
    required this.currency,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final now = DateTime.now();

    return GlassGradientHeader(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting + avatar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muraho, $firstName',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppFormatters.formatDateLong(now),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(
                            child: Text(
                              firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Solde disponible
              Text(
                'Solde disponible',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppFormatters.formatAmount(balance, currency: currency),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 6),

              // Indicateur positif/négatif
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(HezaRadius.full),
                ),
                child: Text(
                  isPositive ? 'Heza — tu es dans le vert !' : 'Budget dépassé',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPositive
                        ? HezaColors.accentSoft
                        : HezaColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── QUICK ACTIONS ───────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final BuildContext context;
  const _QuickActions({required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        QuickActionButton(
          icon: Icons.add_rounded,
          label: 'Revenu',
          backgroundColor: HezaColors.primary,
          iconColor: Colors.white,
          onTap: () => context.push('/budget/add?type=income'),
        ),
        QuickActionButton(
          icon: Icons.remove_rounded,
          label: 'Dépense',
          backgroundColor: HezaColors.error,
          iconColor: Colors.white,
          onTap: () => context.push('/budget/add?type=expense'),
        ),
        QuickActionButton(
          icon: Icons.flag_rounded,
          label: 'Objectif',
          backgroundColor: HezaColors.warning,
          iconColor: Colors.white,
          onTap: () => context.push('/goals'),
        ),
        QuickActionButton(
          icon: Icons.school_rounded,
          label: 'Investir',
          backgroundColor: HezaColors.primaryLight,
          iconColor: Colors.white,
          onTap: () => context.go('/invest'),
        ),
      ],
    );
  }
}

// ─── RÈGLE 50/30/20 ──────────────────────────────────────────────────────────
class _Rule502030 extends StatelessWidget {
  final double needsSpent, needsTarget;
  final double wantsSpent, wantsTarget;
  final double savings, savingsTarget;
  final String currency;

  const _Rule502030({
    required this.needsSpent, required this.needsTarget,
    required this.wantsSpent, required this.wantsTarget,
    required this.savings, required this.savingsTarget,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return HezaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Règle 50/30/20',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HezaTheme.of(context).text,
                  ),
                ),
              ),
              const HezaBadge(label: 'Ce mois'),
            ],
          ),
          const SizedBox(height: 16),
          _BucketRow(label: '50% Besoins', spent: needsSpent, target: needsTarget,   color: HezaColors.primary,     currency: currency),
          const SizedBox(height: 12),
          _BucketRow(label: '30% Envies',  spent: wantsSpent, target: wantsTarget,   color: HezaColors.warning,     currency: currency),
          const SizedBox(height: 12),
          _BucketRow(label: '20% Épargne', spent: savings,    target: savingsTarget, color: HezaColors.primaryLight, currency: currency),
        ],
      ),
    );
  }
}

class _BucketRow extends StatelessWidget {
  final String label;
  final double spent, target;
  final Color color;
  final String currency;

  const _BucketRow({
    required this.label, required this.spent, required this.target,
    required this.color, required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final ratio  = target > 0 ? (spent / target).clamp(0.0, 1.0) : 0.0;
    final pct    = (ratio * 100).toStringAsFixed(0);
    final isOver = spent > target;
    final barColor = isOver ? HezaColors.error : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.text),
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: barColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        HezaProgressBar(value: ratio, color: barColor, height: 7),
        const SizedBox(height: 4),
        Text(
          '${AppFormatters.formatNumber(spent)} / ${AppFormatters.formatNumber(target)} $currency',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: t.textMuted),
        ),
      ],
    );
  }
}

// ─── LEÇON DU JOUR (dynamique — prochaine leçon non complétée) ───────────────
class _DynamicLessonCard extends ConsumerWidget {
  final void Function(String id) onTap;
  const _DynamicLessonCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(lessonProgressProvider);
    final completedIds  = progressAsync.value?.where((p) => p.completed).map((p) => p.lessonId).toSet() ?? {};
    final lesson        = LessonsData.all.firstWhere(
      (l) => !completedIds.contains(l.id),
      orElse: () => LessonsData.all.last,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _LessonCardBody(lesson: lesson, isDark: isDark, onTap: () => onTap(lesson.id));
  }
}

class _LessonCardBody extends StatelessWidget {
  final Lesson lesson;
  final bool isDark;
  final VoidCallback onTap;
  const _LessonCardBody({required this.lesson, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HezaRadius.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: HezaBlur.normal, sigmaY: HezaBlur.normal),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [HezaColors.darkSurface, const Color(0xFF1E3A2B)]
                    : [HezaColors.primary, HezaColors.primaryLight],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(HezaRadius.lg),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Leçon du jour',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(HezaRadius.full),
                      ),
                      child: Text(
                        lesson.level,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: Colors.white.withValues(alpha: 0.65)),
                    const SizedBox(width: 4),
                    Text(
                      lesson.duration,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Lire la leçon',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HezaColors.accentSoft,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: HezaColors.accentSoft),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TRANSACTION TILE ────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final String currency;

  const _TransactionTile({required this.transaction, required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
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
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: t.text),
                ),
                Text(
                  transaction.note?.isNotEmpty == true
                      ? transaction.note!
                      : AppFormatters.formatRelativeDate(transaction.date),
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${AppFormatters.formatNumber(transaction.amount)} $currency',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isIncome ? HezaColors.success : t.text,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String cat) {
    const labels = {
      'transport': 'Transport', 'food': 'Alimentation', 'loyer': 'Loyer',
      'charges': 'Charges',    'epargne': 'Épargne',    'divers': 'Divers',
      'revenu': 'Revenu',      'income': 'Revenu',
    };
    return labels[cat.toLowerCase()] ?? cat;
  }
}

// ─── GRAPHIQUE DE TENDANCE 6 MOIS ────────────────────────────────────────────
class _SpendingTrend extends ConsumerWidget {
  final String currency;
  const _SpendingTrend({required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t        = HezaTheme.of(context);
    final dataAsync = ref.watch(sixMonthExpensesProvider);

    return HezaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text('Tendance 6 mois', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: t.text)),
            ),
            const HezaBadge(label: 'Dépenses'),
          ]),
          const SizedBox(height: 4),
          Text('Évolution de tes dépenses', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub)),
          const SizedBox(height: 20),
          dataAsync.when(
            loading: () => SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: t.primary, strokeWidth: 2))),
            error: (_, __) => const SizedBox.shrink(),
            data: (data) {
              if (data.isEmpty || data.values.every((v) => v == 0)) {
                return SizedBox(
                  height: 80,
                  child: Center(child: Text('Ajoute des transactions pour voir ta tendance', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textMuted), textAlign: TextAlign.center)),
                );
              }

              final keys    = data.keys.toList();
              final values  = data.values.toList();
              final maxVal  = values.reduce((a, b) => a > b ? a : b);
              final spots   = List.generate(keys.length, (i) => FlSpot(i.toDouble(), values[i]));

              return SizedBox(
                height: 120,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxVal * 1.2,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(color: t.border.withValues(alpha: 0.4), strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (val, _) {
                            final idx = val.toInt();
                            if (idx < 0 || idx >= keys.length) return const SizedBox.shrink();
                            final parts = keys[idx].split('-');
                            final month = int.tryParse(parts[1]) ?? 0;
                            const abbr = ['', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
                            return Text(abbr[month], style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: t.textMuted));
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: HezaColors.primary,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                            radius: 3.5,
                            color: HezaColors.primary,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [HezaColors.primary.withValues(alpha: 0.25), HezaColors.primary.withValues(alpha: 0.0)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
