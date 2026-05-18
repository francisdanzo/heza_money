import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';

/// Écran modal d'ajout de transaction
class AddTransactionScreen extends ConsumerStatefulWidget {
  final String initialType;
  const AddTransactionScreen({super.key, this.initialType = 'expense'});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  late String _type;
  String _category = 'divers';
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;

  static const _expenseCategories = [
    ('loyer', 'Loyer', Icons.home_rounded),
    ('food', 'Alimentation', Icons.restaurant_rounded),
    ('transport', 'Transport', Icons.directions_bus_rounded),
    ('charges', 'Charges', Icons.bolt_rounded),
    ('epargne', 'Épargne', Icons.savings_rounded),
    ('divers', 'Divers', Icons.category_rounded),
  ];

  static const _incomeCategories = [
    ('revenu', 'Salaire', Icons.work_rounded),
    ('revenu', 'Prime', Icons.star_rounded),
    ('revenu', 'Autre', Icons.trending_up_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _category = _type == 'income' ? 'revenu' : 'divers';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amountText = _amountController.text.replaceAll(' ', '');
    if (amountText.isEmpty) {
      _showError('Saisis un montant');
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Montant invalide');
      return;
    }

    setState(() => _loading = true);
    try {
      final now = _date;
      final monthKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';

      await ref.read(transactionsDaoProvider).addTransaction(
            TransactionsCompanion(
              amount: Value(amount),
              category: Value(_category),
              type: Value(_type),
              note: Value(
                  _noteController.text.isNotEmpty ? _noteController.text : null),
              date: Value(_date),
              monthKey: Value(monthKey),
            ),
          );

      // Vérifie badge "Premier pas"
      await _checkBadges();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Murakoze ! Transaction enregistrée 💚'),
            backgroundColor: AppColors.action,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkBadges() async {
    final badgesDao = ref.read(earnedBadgesDaoProvider);
    final transDao = ref.read(transactionsDaoProvider);
    if (!await badgesDao.hasBadge('first_step')) {
      if (await transDao.hasAnyTransaction()) {
        await badgesDao.awardBadge('first_step');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
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
    final categories =
        _type == 'income' ? _incomeCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_type == 'income' ? 'Ajouter un revenu' : 'Ajouter une dépense'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Dépense / Revenu
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    _typeTab('expense', 'Dépense'),
                    _typeTab('income', 'Revenu'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Montant
              const Text('Montant', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.headlineLarge,
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: ref.watch(userProfileProvider).value?.currency ?? 'BIF',
                  suffixStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),

              // Catégorie
              const Text('Catégorie', style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((c) {
                  final (key, label, icon) = c;
                  final selected = _category == key;
                  return GestureDetector(
                    onTap: () => setState(() => _category = key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.cardBackground,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 16,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Date
              const Text('Date', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusInput),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        AppFormatters.formatDateLong(_date),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Note optionnelle
              const Text('Note (optionnelle)', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Ex: Loyer du mois de mai...',
                ),
              ),
              const SizedBox(height: 32),

              // Bouton sauvegarder
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeTab(String type, String label) {
    final active = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = type;
          _category = type == 'income' ? 'revenu' : 'divers';
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
