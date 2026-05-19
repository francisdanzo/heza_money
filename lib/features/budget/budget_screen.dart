import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  String _selectedCategory = 'Tout';
  bool _showSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
    'Tout', 'Loyer', 'Alimentation', 'Transport', 'Charges', 'Épargne', 'Divers', 'Revenu',
  ];

  static const Map<String, String> _catKeys = {
    'Tout': '', 'Loyer': 'loyer', 'Alimentation': 'food', 'Transport': 'transport',
    'Charges': 'charges', 'Épargne': 'epargne', 'Divers': 'divers', 'Revenu': 'income',
  };

  static const Map<String, String> _catLabels = {
    'transport': 'Transport', 'food': 'Alimentation', 'loyer': 'Loyer',
    'charges': 'Charges', 'epargne': 'Épargne', 'divers': 'Divers',
    'revenu': 'Revenu', 'income': 'Revenu',
  };

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isCurrentMonth {
    final now   = DateTime.now();
    final month = ref.read(selectedBudgetMonthProvider);
    return month.year == now.year && month.month == now.month;
  }

  void _prevMonth() {
    final current = ref.read(selectedBudgetMonthProvider);
    ref.read(selectedBudgetMonthProvider.notifier).state =
        DateTime(current.year, current.month - 1);
  }

  void _nextMonth() {
    if (_isCurrentMonth) return;
    final current = ref.read(selectedBudgetMonthProvider);
    ref.read(selectedBudgetMonthProvider.notifier).state =
        DateTime(current.year, current.month + 1);
  }

  void _showTransactionOptions(BuildContext context, Transaction tx) {
    final t = HezaTheme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.edit_rounded, color: t.primary),
            title: Text('Modifier', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text)),
            onTap: () { Navigator.pop(ctx); context.push('/budget/add', extra: tx); },
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: HezaColors.error),
            title: const Text('Supprimer', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaColors.error)),
            onTap: () async {
              Navigator.pop(ctx);
              await ref.read(transactionsDaoProvider).deleteTransaction(tx.id);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t            = HezaTheme.of(context);
    final selectedMonth = ref.watch(selectedBudgetMonthProvider);
    final transAsync   = ref.watch(selectedMonthTransactionsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final currency     = profileAsync.value?.currency ?? 'BIF';
    final salary       = profileAsync.value?.monthlySalary ?? 700000.0;
    final isCurrentMo  = DateTime.now().year == selectedMonth.year &&
                         DateTime.now().month == selectedMonth.month;

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Budget',
        subtitle: AppFormatters.formatMonthYear(selectedMonth),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.search_off_rounded : Icons.search_rounded, color: Colors.white),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchController.clear();
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => context.push('/budget/add?type=expense'),
          ),
        ],
      ),
      floatingActionButton: isCurrentMo
          ? FloatingActionButton(
              onPressed: () => context.push('/budget/add?type=expense'),
              tooltip: 'Nouvelle dépense',
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: transAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: t.primary)),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (transactions) {
          var filtered = _selectedCategory == 'Tout'
              ? transactions
              : transactions.where((tx) {
                  final key = _catKeys[_selectedCategory] ?? '';
                  return tx.category == key || (key == 'income' && tx.type == 'income');
                }).toList();

          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            filtered = filtered.where((tx) {
              return (tx.note?.toLowerCase().contains(q) ?? false) ||
                  (_catLabels[tx.category]?.toLowerCase().contains(q) ?? false) ||
                  tx.category.toLowerCase().contains(q);
            }).toList();
          }

          final expenseMap = <String, double>{};
          for (final tx in transactions.where((tx) => tx.type == 'expense')) {
            expenseMap[tx.category] = (expenseMap[tx.category] ?? 0) + tx.amount;
          }

          return RefreshIndicator(
            color: t.primary,
            onRefresh: () async {
              ref.invalidate(selectedMonthTransactionsProvider);
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Navigateur de mois ──────────────────────────────────────
              SliverToBoxAdapter(child: _MonthNavigator(
                selectedMonth: selectedMonth,
                isCurrentMonth: isCurrentMo,
                onPrev: _prevMonth,
                onNext: _nextMonth,
                t: t,
              )),

              // Barre de recherche
              if (_showSearch)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _SearchBar(controller: _searchController, t: t, onChanged: (q) => setState(() => _searchQuery = q)),
                  ),
                ),

              // Filtre catégories
              SliverToBoxAdapter(child: _CategoryFilter(
                categories: _categories,
                selected: _selectedCategory,
                onSelect: (cat) => setState(() => _selectedCategory = cat),
              )),

              // Carte limite budget par catégorie
              if (_selectedCategory != 'Tout')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _CategoryLimitCard(
                      category: _catKeys[_selectedCategory] ?? '',
                      categoryLabel: _selectedCategory,
                      spent: expenseMap[_catKeys[_selectedCategory] ?? ''] ?? 0,
                      currency: currency,
                    ),
                  ),
                ),

              // Graphique camembert
              if (expenseMap.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _PieChartCard(expenseMap: expenseMap, currency: currency, catLabels: _catLabels),
                  ),
                ),

              // Règle 50/30/20
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _BudgetRuleCard(transactions: transactions, salary: salary, currency: currency),
                ),
              ),

              // En-tête liste
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: SectionHeader(title: 'Transactions (${filtered.length})'),
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
                    actionLabel: isCurrentMo ? 'Ajouter' : null,
                    onAction: isCurrentMo ? () => context.push('/budget/add?type=expense') : null,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final tx       = filtered[i];
                      final showDate = i == 0 || !_sameDay(filtered[i - 1].date, tx.date);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDate)
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 8),
                                child: Text(
                                  AppFormatters.formatRelativeDate(tx.date),
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: t.textSub),
                                ),
                              ),
                            Dismissible(
                              key: ValueKey(tx.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 18),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: HezaColors.error.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(HezaRadius.md),
                                ),
                                child: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                              ),
                              onDismissed: (_) async {
                                HapticFeedback.mediumImpact();
                                await ref.read(transactionsDaoProvider).deleteTransaction(tx.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: const Text('Transaction supprimée'),
                                    backgroundColor: HezaColors.error,
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                }
                              },
                              child: GestureDetector(
                                onLongPress: () => _showTransactionOptions(context, tx),
                                child: _TransactionCard(transaction: tx, currency: currency, catLabels: _catLabels),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          );
        },
      ),
    );
  }
}

// ─── SEARCH BAR ──────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final HezaTheme t;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.t, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: t.isDark ? 0.4 : 0.85),
        borderRadius: BorderRadius.circular(HezaRadius.md),
        border: Border.all(color: t.glassBorder, width: 1),
      ),
      child: Row(children: [
        Icon(Icons.search_rounded, size: 18, color: t.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: true,
            onChanged: onChanged,
            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text),
            decoration: InputDecoration(
              hintText: 'Rechercher une transaction...',
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
          ),
        ),
        if (controller.text.isNotEmpty)
          GestureDetector(
            onTap: () { controller.clear(); onChanged(''); },
            child: Icon(Icons.close_rounded, size: 16, color: t.textMuted),
          ),
      ]),
    );
  }
}

// ─── MONTH NAVIGATOR ─────────────────────────────────────────────────────────
class _MonthNavigator extends StatelessWidget {
  final DateTime selectedMonth;
  final bool     isCurrentMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final HezaTheme t;

  const _MonthNavigator({
    required this.selectedMonth,
    required this.isCurrentMonth,
    required this.onPrev,
    required this.onNext,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: [
        _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev, t: t),
        const SizedBox(width: 8),
        Expanded(
          child: Center(
            child: Text(
              AppFormatters.formatMonthYear(selectedMonth),
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: t.text),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _NavBtn(icon: Icons.chevron_right_rounded, onTap: isCurrentMonth ? null : onNext, t: t),
      ]),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final HezaTheme t;
  const _NavBtn({required this.icon, required this.onTap, required this.t});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: active ? t.primary.withValues(alpha: 0.12) : t.border.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(HezaRadius.sm),
          border: Border.all(color: active ? t.primary.withValues(alpha: 0.3) : t.border, width: 1),
        ),
        child: Icon(icon, size: 20, color: active ? t.primary : t.textMuted),
      ),
    );
  }
}

// ─── CATEGORY FILTER ─────────────────────────────────────────────────────────
class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryFilter({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final bg = t.isDark ? HezaColors.darkBg : HezaColors.lightBg;
    return SizedBox(
      height: 48,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [bg, Colors.transparent, Colors.transparent, bg],
          stops: const [0.0, 0.05, 0.95, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstOut,
        child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? t.primary : t.surface.withValues(alpha: t.isDark ? 0.4 : 0.9),
                borderRadius: BorderRadius.circular(HezaRadius.full),
                border: Border.all(
                  color: isSelected ? t.primary : t.glassBorder,
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : t.textSub,
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}

// ─── PIE CHART CARD ──────────────────────────────────────────────────────────
class _PieChartCard extends StatelessWidget {
  final Map<String, double> expenseMap;
  final String currency;
  final Map<String, String> catLabels;

  const _PieChartCard({required this.expenseMap, required this.currency, required this.catLabels});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final total = expenseMap.values.fold(0.0, (s, v) => s + v);
    final sections = expenseMap.entries.map((e) {
      final pct = total > 0 ? e.value / total : 0.0;
      return PieChartSectionData(
        value: e.value,
        color: HezaColors.forCategory(e.key),
        title: pct > 0.05 ? '${(pct * 100).toStringAsFixed(0)}%' : '',
        radius: 60,
        titleStyle: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      );
    }).toList();

    return HezaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Répartition des dépenses', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: t.text)),
          const SizedBox(height: 4),
          Text('Total : ${AppFormatters.formatAmount(total, currency: currency)}', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(PieChartData(
                  sections: sections,
                  centerSpaceRadius: 32,
                  sectionsSpace: 2,
                )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: expenseMap.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(color: HezaColors.forCategory(e.key), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(catLabels[e.key] ?? e.key, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub), overflow: TextOverflow.ellipsis),
                        ),
                        Text(AppFormatters.formatNumber(e.value), style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: t.text)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── BUDGET RULE CARD ────────────────────────────────────────────────────────
class _BudgetRuleCard extends StatelessWidget {
  final List<Transaction> transactions;
  final double salary;
  final String currency;

  const _BudgetRuleCard({required this.transactions, required this.salary, required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final needsSpent = transactions
        .where((tx) => tx.type == 'expense' && ['loyer','food','transport','charges'].contains(tx.category))
        .fold(0.0, (s, tx) => s + tx.amount);
    final wantsSpent = transactions
        .where((tx) => tx.type == 'expense' && tx.category == 'divers')
        .fold(0.0, (s, tx) => s + tx.amount);
    final savings = transactions
        .where((tx) => tx.category == 'epargne')
        .fold(0.0, (s, tx) => s + tx.amount);

    return HezaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Règle 50 / 30 / 20', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: t.text)),
          const SizedBox(height: 4),
          Text('Basé sur ${AppFormatters.formatAmount(salary, currency: currency)}', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub)),
          const SizedBox(height: 16),
          _BudgetRow(label: '50% Besoins', spent: needsSpent, target: salary * 0.5, color: HezaColors.primary, currency: currency),
          const SizedBox(height: 12),
          _BudgetRow(label: '30% Envies',  spent: wantsSpent, target: salary * 0.3, color: HezaColors.warning, currency: currency),
          const SizedBox(height: 12),
          _BudgetRow(label: '20% Épargne', spent: savings,    target: salary * 0.2, color: HezaColors.primaryLight, currency: currency),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String label;
  final double spent, target;
  final Color color;
  final String currency;

  const _BudgetRow({required this.label, required this.spent, required this.target, required this.color, required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final ratio = target > 0 ? (spent / target).clamp(0.0, 1.0) : 0.0;
    final over  = spent > target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.text))),
            Text(
              '${AppFormatters.formatNumber(spent)} / ${AppFormatters.formatNumber(target)}',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: t.textSub),
            ),
          ],
        ),
        const SizedBox(height: 6),
        HezaProgressBar(value: ratio, color: over ? HezaColors.error : color),
      ],
    );
  }
}

// ─── TRANSACTION CARD ────────────────────────────────────────────────────────
class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String currency;
  final Map<String, String> catLabels;

  const _TransactionCard({required this.transaction, required this.currency, required this.catLabels});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final isIncome = transaction.type == 'income';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HezaCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CategoryIcon(category: transaction.category, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(catLabels[transaction.category.toLowerCase()] ?? transaction.category,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: t.text)),
                  if (transaction.note?.isNotEmpty == true)
                    Text(transaction.note!, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${AppFormatters.formatNumber(transaction.amount)}',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700,
                    color: isIncome ? HezaColors.success : t.text,
                  ),
                ),
                Text(currency, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: t.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LIMITE DE BUDGET PAR CATÉGORIE ──────────────────────────────────────────
class _CategoryLimitCard extends ConsumerWidget {
  final String category;
  final String categoryLabel;
  final double spent;
  final String currency;

  const _CategoryLimitCard({
    required this.category,
    required this.categoryLabel,
    required this.spent,
    required this.currency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t           = HezaTheme.of(context);
    final budgetsAsync = ref.watch(categoryBudgetsProvider);
    final limit        = budgetsAsync.value?.where((b) => b.category == category).firstOrNull;
    final hasLimit     = limit != null;
    final ratio        = hasLimit && limit.limitAmount > 0 ? (spent / limit.limitAmount).clamp(0.0, 1.0) : 0.0;
    final isOver       = hasLimit && spent > limit.limitAmount;

    return HezaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                'Limite $categoryLabel',
                style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: t.text),
              ),
            ),
            GestureDetector(
              onTap: () => _showSetLimit(context, ref, limit?.limitAmount),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: t.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(HezaRadius.sm),
                  border: Border.all(color: t.primary.withValues(alpha: 0.25), width: 1),
                ),
                child: Text(
                  hasLimit ? 'Modifier' : 'Définir',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: t.primary),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          if (hasLimit) ...[
            Row(children: [
              Expanded(
                child: Text(
                  '${AppFormatters.formatNumber(spent)} / ${AppFormatters.formatNumber(limit.limitAmount)} $currency',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: t.textSub),
                ),
              ),
              Text(
                isOver ? 'Dépassé !' : '${((ratio) * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
                  color: isOver ? HezaColors.error : (ratio > 0.8 ? HezaColors.warning : t.primary),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            HezaProgressBar(
              value: ratio,
              color: isOver ? HezaColors.error : (ratio > 0.8 ? HezaColors.warning : t.primary),
            ),
            if (isOver)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Tu as dépassé ta limite de ${AppFormatters.formatNumber(spent - limit.limitAmount)} $currency',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: HezaColors.error),
                ),
              ),
          ] else
            Text(
              'Aucune limite définie pour cette catégorie.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textMuted),
            ),
        ],
      ),
    );
  }

  void _showSetLimit(BuildContext context, WidgetRef ref, double? current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SetLimitBottomSheet(
        category: category,
        categoryLabel: categoryLabel,
        currentLimit: current,
        onSave: (amount) async {
          if (amount == null) {
            await ref.read(categoryBudgetsDaoProvider).removeLimit(category);
          } else {
            await ref.read(categoryBudgetsDaoProvider).setLimit(category, amount);
          }
        },
      ),
    );
  }
}

class _SetLimitBottomSheet extends StatefulWidget {
  final String category;
  final String categoryLabel;
  final double? currentLimit;
  final Future<void> Function(double? amount) onSave;

  const _SetLimitBottomSheet({
    required this.category,
    required this.categoryLabel,
    required this.currentLimit,
    required this.onSave,
  });

  @override
  State<_SetLimitBottomSheet> createState() => _SetLimitBottomSheetState();
}

class _SetLimitBottomSheetState extends State<_SetLimitBottomSheet> {
  late TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.currentLimit != null ? widget.currentLimit!.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Limite ${widget.categoryLabel}', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: t.text)),
          const SizedBox(height: 4),
          Text('Définis ton budget maximum pour cette catégorie.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: t.textSub)),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: t.text),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: t.textMuted),
              suffixText: 'BIF',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(HezaRadius.md)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            if (widget.currentLimit != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () async {
                    setState(() => _saving = true);
                    await widget.onSave(null);
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: HezaColors.error, side: const BorderSide(color: HezaColors.error)),
                  child: const Text('Supprimer'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _saving ? null : () async {
                  final val = double.tryParse(_ctrl.text.replaceAll(' ', ''));
                  if (val == null || val <= 0) return;
                  setState(() => _saving = true);
                  await widget.onSave(val);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Enregistrer'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
