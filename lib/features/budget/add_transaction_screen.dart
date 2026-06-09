import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart' show AppFormatters, ThousandsSeparatorFormatter;
import '../../core/services/badge_service.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../features/gamification/badges_screen.dart' show showBadgeUnlocked;
import '../../shared/providers/database_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String       initialType;
  final Transaction? transaction; // null = création, non-null = édition
  const AddTransactionScreen({super.key, this.initialType = 'expense', this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late String _type;
  String _category = 'divers';
  final _amountController = TextEditingController();
  final _noteController   = TextEditingController();
  DateTime _date  = DateTime.now();
  bool _loading   = false;
  bool _isDirty   = false;

  bool get _isEditing => widget.transaction != null;

  static const _expenseCategories = [
    ('loyer',    'Loyer',        Icons.home_rounded),
    ('food',     'Alimentation', Icons.restaurant_rounded),
    ('transport','Transport',    Icons.directions_bus_rounded),
    ('charges',  'Charges',      Icons.bolt_rounded),
    ('epargne',  'Épargne',      Icons.savings_rounded),
    ('divers',   'Divers',       Icons.category_rounded),
  ];

  static const _incomeCategories = [
    ('salaire',      'Salaire',        Icons.work_rounded),
    ('freelance',    'Freelance',      Icons.laptop_mac_rounded),
    ('location',     'Location',       Icons.house_rounded),
    ('prime',        'Prime/Bonus',    Icons.star_rounded),
    ('pension',      'Pension',        Icons.elderly_rounded),
    ('transfert_recu','Transfert reçu',Icons.call_received_rounded),
    ('cadeau',       'Cadeau/Don',     Icons.card_giftcard_rounded),
    ('autre_revenu', 'Autre revenu',   Icons.trending_up_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _type     = tx.type;
      _category = tx.category;
      _date     = tx.date;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _noteController.text   = tx.note ?? '';
    } else {
      _type     = widget.initialType;
      _category = _type == 'income' ? 'salaire' : 'divers';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amountText = _amountController.text.replaceAll(' ', '');
    if (amountText.isEmpty) { _showError('Saisis un montant'); return; }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) { _showError('Montant invalide'); return; }

    setState(() => _loading = true);
    try {
      final now      = _date;
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final note     = _noteController.text.isNotEmpty ? _noteController.text : null;

      if (_isEditing) {
        await ref.read(transactionsDaoProvider).updateTransaction(
          widget.transaction!.copyWith(
            amount:   amount,
            category: _category,
            type:     _type,
            note:     Value(note),
            date:     _date,
            monthKey: monthKey,
          ),
        );
      } else {
        await ref.read(transactionsDaoProvider).addTransaction(
          TransactionsCompanion(
            amount:   Value(amount),
            category: Value(_category),
            type:     Value(_type),
            note:     Value(note),
            date:     Value(_date),
            monthKey: Value(monthKey),
          ),
        );
        await _checkBadges();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Transaction modifiée' : 'Murakoze ! Transaction enregistrée'),
          backgroundColor: HezaColors.primaryLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HezaRadius.md)),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkBadges() async {
    final newBadges = await BadgeService.checkAll(
      badgesDao:  ref.read(earnedBadgesDaoProvider),
      transDao:   ref.read(transactionsDaoProvider),
      goalsDao:   ref.read(goalsDaoProvider),
      lessonDao:  ref.read(lessonProgressDaoProvider),
    );
    if (mounted && newBadges.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final id in newBadges) {
          if (context.mounted) showBadgeUnlocked(context, id);
        }
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: HezaColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _pickDate() async {
    final t = HezaTheme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: t.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t          = HezaTheme.of(context);
    final categories = _type == 'income' ? _incomeCategories : _expenseCategories;
    final currency   = ref.watch(userProfileProvider).value?.currency ?? 'BIF';
    final isExpense  = _type == 'expense';

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Abandonner ?', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: HezaTheme.of(ctx).text)),
            content: Text('Les modifications non enregistrées seront perdues.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(ctx).textSub)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Continuer')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: HezaColors.error), child: const Text('Abandonner')),
            ],
          ),
        );
        if (confirmed == true && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
      appBar: GlassAppBar(
        title: _isEditing
            ? 'Modifier la transaction'
            : (isExpense ? 'Ajouter une dépense' : 'Ajouter un revenu'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Type toggle ──────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(HezaRadius.md),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: t.glassBg.withValues(alpha: t.isDark ? 0.15 : 0.6),
                      borderRadius: BorderRadius.circular(HezaRadius.md),
                      border: Border.all(color: t.glassBorder, width: 1),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      _typeTab('expense', 'Dépense', t),
                      _typeTab('income',  'Revenu',  t),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Montant ──────────────────────────────────────────────────
              Text('Montant', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 8),
              _AmountField(controller: _amountController, currency: currency, t: t, onChanged: (_) => setState(() => _isDirty = true)),
              const SizedBox(height: 24),

              // ── Catégorie ────────────────────────────────────────────────
              Text('Catégorie', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((c) {
                  final (key, label, icon) = c;
                  final actualSelected = _category == key;
                  return _CategoryChip(
                    label: label,
                    icon: icon,
                    selected: actualSelected,
                    t: t,
                    onTap: () => setState(() => _category = key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Date ─────────────────────────────────────────────────────
              Text('Date', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 8),
              _DateRow(date: _date, onTap: _pickDate, t: t),
              const SizedBox(height: 24),

              // ── Note ─────────────────────────────────────────────────────
              Text('Note (optionnelle)', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 8),
              _NoteField(controller: _noteController, t: t),
              const SizedBox(height: 32),

              // ── Bouton enregistrer ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  label: _isEditing ? 'Modifier' : 'Enregistrer',
                  onPressed: _loading ? null : _save,
                  isLoading: _loading,
                  fullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _typeTab(String type, String label, HezaTheme t) {
    final active = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type     = type;
          _category = type == 'income' ? 'salaire' : 'divers';
          _isDirty  = true;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? t.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(HezaRadius.sm),
            boxShadow: active ? [BoxShadow(color: t.primary.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : t.textSub,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Amount field ──────────────────────────────────────────────────────────────
class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currency;
  final HezaTheme t;
  final ValueChanged<String>? onChanged;
  const _AmountField({required this.controller, required this.currency, required this.t, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(HezaRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: t.glassBg.withValues(alpha: t.isDark ? 0.15 : 0.6),
            borderRadius: BorderRadius.circular(HezaRadius.md),
            border: Border.all(color: t.glassBorder, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorFormatter()],
                autofocus: true,
                onChanged: onChanged,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w300, color: t.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Text(currency, style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: t.textSub)),
          ]),
        ),
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final HezaTheme t;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.icon, required this.selected, required this.t, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? t.primary : t.surface.withValues(alpha: t.isDark ? 0.4 : 0.8),
          borderRadius: BorderRadius.circular(HezaRadius.md),
          border: Border.all(
            color: selected ? t.primary : t.glassBorder,
            width: 1,
          ),
          boxShadow: selected ? [BoxShadow(color: t.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: selected ? Colors.white : t.textSub),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : t.text)),
        ]),
      ),
    );
  }
}

// ── Date row ──────────────────────────────────────────────────────────────────
class _DateRow extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  final HezaTheme t;
  const _DateRow({required this.date, required this.onTap, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(HezaRadius.md),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: t.glassBg.withValues(alpha: t.isDark ? 0.15 : 0.6),
              borderRadius: BorderRadius.circular(HezaRadius.md),
              border: Border.all(color: t.glassBorder, width: 1),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: t.primary),
              const SizedBox(width: 10),
              Text(AppFormatters.formatDateLong(date), style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: t.textMuted),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Note field ────────────────────────────────────────────────────────────────
class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final HezaTheme t;
  const _NoteField({required this.controller, required this.t});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(HezaRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: t.glassBg.withValues(alpha: t.isDark ? 0.15 : 0.6),
            borderRadius: BorderRadius.circular(HezaRadius.md),
            border: Border.all(color: t.glassBorder, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            maxLines: 3,
            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text),
            decoration: InputDecoration(
              hintText: 'Ex: Loyer du mois de mai...',
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}
