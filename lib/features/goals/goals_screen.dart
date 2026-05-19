import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync   = ref.watch(goalsProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final currency = profileAsync.value?.currency ?? 'BIF';
    final salary   = profileAsync.value?.monthlySalary ?? 700000.0;
    final t = HezaTheme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Objectifs d\'épargne',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () => context.push('/goals/add'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/add'),
        label: const Text('Nouvel objectif'),
        icon: const Icon(Icons.flag_rounded),
        backgroundColor: t.primary,
        foregroundColor: Colors.white,
      ),
      body: goalsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: t.primary)),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (goals) => RefreshIndicator(
          color: t.primary,
          onRefresh: () async {
            ref.invalidate(goalsProvider);
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _EmergencyFundCard(salary: salary, currency: currency),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: SectionHeader(title: 'Mes objectifs (${goals.length})'),
              ),
            ),
            if (goals.isEmpty)
              SliverToBoxAdapter(
                child: EmptyStateWidget(
                  icon: Icons.flag_rounded,
                  title: 'Aucun objectif',
                  subtitle: 'Définis un objectif d\'épargne pour rester motivé.',
                  actionLabel: 'Créer un objectif',
                  onAction: () => context.push('/goals/add'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final goal = goals[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(goal.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Supprimer l\'objectif', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: HezaTheme.of(ctx).text)),
                                content: Text('Supprimer "${goal.title}" ? Cette action est irréversible.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(ctx).textSub)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: HezaColors.error),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 18),
                            decoration: BoxDecoration(
                              color: HezaColors.error.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(HezaRadius.md),
                            ),
                            child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
                          ),
                          onDismissed: (_) {
                            HapticFeedback.mediumImpact();
                            ref.read(goalsDaoProvider).deleteGoal(goal.id);
                          },
                          child: _GoalCard(goal: goal, currency: currency),
                        ),
                      );
                    },
                    childCount: goals.length,
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

// ─── GOAL CARD ───────────────────────────────────────────────────────────────
class _GoalCard extends ConsumerWidget {
  final Goal goal;
  final String currency;
  const _GoalCard({required this.goal, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = HezaTheme.of(context);
    final ratio    = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final pct      = (ratio * 100).toStringAsFixed(0);
    final remaining = goal.targetAmount - goal.currentAmount;
    final monthsLeft = AppFormatters.monthsUntil(goal.deadline);
    final monthlyNeeded = monthsLeft > 0 ? remaining / monthsLeft : remaining;
    final color = _parseColor(goal.color);

    return HezaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(HezaRadius.md),
              ),
              child: Icon(Icons.flag_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(goal.title, style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: t.text)),
                Text(
                  'Échéance : ${AppFormatters.formatDateMedium(goal.deadline)}',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub),
                ),
              ]),
            ),
            if (goal.isCompleted)
              HezaBadge(label: 'Atteint', backgroundColor: HezaColors.success.withValues(alpha: 0.15), textColor: HezaColors.success)
            else
              Text('$pct%', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 18, color: t.textMuted),
              padding: EdgeInsets.zero,
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/goals/add', extra: goal);
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Supprimer l\'objectif', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: HezaTheme.of(ctx).text)),
                      content: Text('Supprimer "${goal.title}" ?', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(ctx).textSub)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: HezaColors.error), child: const Text('Supprimer')),
                      ],
                    ),
                  );
                  if (confirmed == true) await ref.read(goalsDaoProvider).deleteGoal(goal.id);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit',   child: Row(children: [Icon(Icons.edit_rounded,   size: 16, color: t.primary), const SizedBox(width: 8), Text('Modifier',  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: t.text))])),
                PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_rounded, size: 16, color: HezaColors.error), const SizedBox(width: 8), const Text('Supprimer', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: HezaColors.error))])),
              ],
            ),
          ]),
          const SizedBox(height: 14),

          HezaProgressBar(value: ratio, color: color, height: 10),
          const SizedBox(height: 8),

          Row(children: [
            Text(
              AppFormatters.formatNumber(goal.currentAmount),
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
            Text(
              ' / ${AppFormatters.formatAmount(goal.targetAmount, currency: currency)}',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub),
            ),
          ]),

          if (!goal.isCompleted && monthsLeft > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: t.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(HezaRadius.sm),
                border: Border.all(color: t.primary.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(children: [
                Icon(Icons.lightbulb_outline_rounded, size: 14, color: t.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Il te faut ${AppFormatters.formatAmount(monthlyNeeded, currency: currency)}/mois pendant $monthsLeft mois',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.primary),
                  ),
                ),
              ]),
            ),
          ],

          if (!goal.isCompleted) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddFundsDialog(context, ref, goal, currency),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    foregroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Ajouter'),
                ),
              ),
              if (goal.currentAmount > 0) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showWithdrawDialog(context, ref, goal, currency),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.textSub.withValues(alpha: 0.4)),
                      foregroundColor: t.textSub,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.remove_rounded, size: 16),
                    label: const Text('Retirer'),
                  ),
                ),
              ],
            ]),
          ],
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return HezaColors.primaryLight;
    }
  }

  Future<void> _showWithdrawDialog(BuildContext context, WidgetRef ref, Goal goal, String currency) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Retirer des fonds', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: HezaTheme.of(ctx).text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disponible : ${AppFormatters.formatAmount(goal.currentAmount, currency: currency)}',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: HezaTheme.of(ctx).textSub)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(hintText: '0', suffixText: currency, labelText: 'Montant'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: HezaColors.error),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.isNotEmpty) {
      final amount = double.tryParse(controller.text);
      if (amount != null && amount > 0) {
        final newAmount = (goal.currentAmount - amount).clamp(0.0, goal.targetAmount);
        await ref.read(goalsDaoProvider).updateCurrentAmount(goal.id, newAmount);
      }
    }
  }

  Future<void> _showAddFundsDialog(BuildContext context, WidgetRef ref, Goal goal, String currency) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ajouter des fonds', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: HezaTheme.of(ctx).text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Objectif : ${goal.title}', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: HezaTheme.of(ctx).textSub)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(hintText: '0', suffixText: currency, labelText: 'Montant'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmer')),
        ],
      ),
    );

    if (confirmed == true && controller.text.isNotEmpty) {
      final amount = double.tryParse(controller.text);
      if (amount != null && amount > 0) {
        final newAmount = goal.currentAmount + amount;
        await ref.read(goalsDaoProvider).updateCurrentAmount(goal.id, newAmount);
        final now = DateTime.now();
        final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
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
        if (newAmount >= goal.targetAmount) {
          await ref.read(earnedBadgesDaoProvider).awardBadge('independence');
        }
      }
    }
  }
}

// ─── EMERGENCY FUND CARD ─────────────────────────────────────────────────────
class _EmergencyFundCard extends StatelessWidget {
  final double salary;
  final String currency;
  const _EmergencyFundCard({required this.salary, required this.currency});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final recommended = salary * 0.30 * 3;

    return GlassCard(
      tintColor: HezaColors.warning,
      opacity: t.isDark ? 0.08 : 0.08,
      border: Border.all(color: HezaColors.warning.withValues(alpha: 0.3), width: 1),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: HezaColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(HezaRadius.md),
          ),
          child: const Icon(Icons.shield_rounded, color: HezaColors.warning, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Fonds d\'urgence recommandé', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: t.text)),
            const SizedBox(height: 4),
            Text(
              AppFormatters.formatAmount(recommended, currency: currency),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: HezaColors.warning),
            ),
            Text('= 3 mois de loyer estimé', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.textSub)),
          ]),
        ),
      ]),
    );
  }
}
