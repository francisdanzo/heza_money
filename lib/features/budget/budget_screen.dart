import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

/// Écran Budget — liste des transactions + graphique + règle 50/30/20
class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  String _selectedCategory = 'Tout';

  static const List<String> _categories = [
    'Tout',
    'Loyer',
    'Alimentation',
    'Transport',
    'Charges',
    'Épargne',
    'Divers',
    'Revenu',
  ];

  static const Map<String, String> _catKeys = {
    'Tout': '',
    'Loyer': 'loyer',
    'Alimentation': 'food',
    'Transport': 'transport',
    'Charges': 'charges',
    'Épargne': 'epargne',
    'Divers': 'divers',
    'Revenu': 'income',
  };

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(currentMonthTransactionsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final currency = profileAsync.value?.currency ?? 'BIF';
    final salary = profileAsync.value?.monthlySalary ?? 700000.0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Budget'),
            Text(
              AppFormatters.formatMonthYear(DateTime.now()),
              style: AppTextStyles.bodySmall
                  .copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/budget/add?type=expense'),
            tooltip: 'Ajouter une transaction',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/budget/add?type=expense'),
        tooltip: 'Nouvelle dépense',
        child: const Icon(Icons.add_rounded),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (transactions) {
          // Filtrage par catégorie
          final filtered = _selectedCategory == 'Tout'
              ? transactions
              : transactions.where((t) {
                  final key = _catKeys[_selectedCategory] ?? '';
                  return t.category == key ||
                      (key == 'income' && t.type == 'income');
                }).toList();

          // Dépenses par catégorie pour le camembert
          final expenseMap = <String, double>{};
          for (final t in transactions.where((t) => t.type == 'expense')) {
            expenseMap[t.category] =
                (expenseMap[t.category] ?? 0) + t.amount;
          }

          return CustomScrollView(
            slivers: [
              // Filtre catégories
              SliverToBoxAdapter(
                child: _buildCategoryFilter(),
              ),

              // Graphique camembert
              if (expenseMap.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _buildPieChart(expenseMap, currency),
                  ),
                ),

              // Règle 50/30/20
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _build502030Widget(
                      transactions, salary, currency),
                ),
              ),

              // Liste transactions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: SectionHeader(
                    title: 'Transactions (${filtered.length})',
                  ),
                ),
              ),

              if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.receipt_long_rounded,
                    title: 'Aucune transaction',
                    subtitle: _selectedCategory == 'Tout'
                        ? 'Commence à enregistrer tes dépenses.'
                        : 'Aucune transaction dans cette catégorie.',
                    actionLabel: 'Ajouter',
                    onAction: () =>
                        context.push('/budget/add?type=expense'),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Grouper par date
                      final t = filtered[index];
                      final showDate = index == 0 ||
                          !_sameDay(filtered[index - 1].date, t.date);
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDate) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 8),
                                child: Text(
                                  AppFormatters.formatRelativeDate(t.date),
                                  style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                            _TransactionCard(
                                transaction: t, currency: currency),
                          ],
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Text(
                cat,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data, String currency) {
    final total = data.values.fold(0.0, (s, v) => s + v);
    final sections = data.entries.map((e) {
      final pct = total > 0 ? e.value / total : 0.0;
      return PieChartSectionData(
        value: e.value,
        color: AppColors.forCategory(e.key),
        title: '${(pct * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();

    return HezaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Répartition des dépenses',
              style: AppTextStyles.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Total : ${AppFormatters.formatAmount(total, currency: currency)}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.forCategory(e.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _catLabel(e.key),
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            AppFormatters.formatNumber(e.value),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build502030Widget(
      List<Transaction> transactions, double salary, String currency) {
    final needsSpent = transactions
        .where((t) =>
            t.type == 'expense' &&
            ['loyer', 'food', 'transport', 'charges'].contains(t.category))
        .fold(0.0, (s, t) => s + t.amount);
    final wantsSpent = transactions
        .where((t) => t.type == 'expense' && t.category == 'divers')
        .fold(0.0, (s, t) => s + t.amount);
    final savingsSpent = transactions
        .where((t) => t.category == 'epargne')
        .fold(0.0, (s, t) => s + t.amount);

    return HezaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Règle 50 / 30 / 20', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Basé sur ${AppFormatters.formatAmount(salary, currency: currency)}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          _BudgetRow(
              label: '50% Besoins',
              spent: needsSpent,
              target: salary * 0.5,
              color: AppColors.action,
              currency: currency),
          const SizedBox(height: 12),
          _BudgetRow(
              label: '30% Envies',
              spent: wantsSpent,
              target: salary * 0.3,
              color: AppColors.alert,
              currency: currency),
          const SizedBox(height: 12),
          _BudgetRow(
              label: '20% Épargne',
              spent: savingsSpent,
              target: salary * 0.2,
              color: AppColors.primary,
              currency: currency),
        ],
      ),
    );
  }

  String _catLabel(String key) {
    const m = {
      'transport': 'Transport',
      'food': 'Alimentation',
      'loyer': 'Loyer',
      'charges': 'Charges',
      'epargne': 'Épargne',
      'divers': 'Divers',
    };
    return m[key] ?? key;
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double spent;
  final double target;
  final Color color;
  final String currency;
  const _BudgetRow(
      {required this.label,
      required this.spent,
      required this.target,
      required this.color,
      required this.currency});
  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (spent / target).clamp(0.0, 1.0) : 0.0;
    final over = spent > target;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: AppTextStyles.titleSmall)),
        Text(
          '${AppFormatters.formatNumber(spent)} / ${AppFormatters.formatNumber(target)}',
          style: AppTextStyles.bodySmall,
        ),
      ]),
      const SizedBox(height: 6),
      HezaProgressBar(value: ratio, color: over ? AppColors.error : color),
    ]);
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String currency;
  const _TransactionCard({required this.transaction, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    return HezaCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        CategoryIcon(category: transaction.category, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_label(transaction.category),
                style: AppTextStyles.titleSmall),
            if (transaction.note?.isNotEmpty == true)
              Text(transaction.note!,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${isIncome ? '+' : '-'}${AppFormatters.formatNumber(transaction.amount)}',
            style: AppTextStyles.amountSmall.copyWith(
              color: isIncome ? AppColors.action : AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          Text(currency, style: AppTextStyles.bodySmall),
        ]),
      ]),
    );
  }

  String _label(String cat) {
    const m = {
      'transport': 'Transport',
      'food': 'Alimentation',
      'loyer': 'Loyer',
      'charges': 'Charges',
      'epargne': 'Épargne',
      'divers': 'Divers',
      'revenu': 'Revenu',
      'income': 'Revenu',
    };
    return m[cat.toLowerCase()] ?? cat;
  }
}
