import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';

/// Couleurs disponibles pour les objectifs
const _goalColors = [
  '#1D9E75', // vert action
  '#0F6E56', // vert profond
  '#EF9F27', // or
  '#2196F3', // bleu
  '#9C27B0', // violet
  '#E53935', // rouge
  '#607D8B', // gris bleu
  '#FF7043', // orange
];

/// Écran de création d'un objectif d'épargne
class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 180));
  String _selectedColor = _goalColors[0];
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('Donne un nom à ton objectif');
      return;
    }
    final targetText = _targetController.text.replaceAll(' ', '');
    final target = double.tryParse(targetText);
    if (target == null || target <= 0) {
      _showError('Saisis un montant cible valide');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(goalsDaoProvider).addGoal(
            GoalsCompanion(
              title: Value(title),
              targetAmount: Value(target),
              currentAmount: const Value(0.0),
              deadline: Value(_deadline),
              color: Value(_selectedColor),
              createdAt: Value(DateTime.now()),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Objectif "$title" créé 💚'),
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
    ));
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      locale: const Locale('fr'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    final currency =
        ref.watch(userProfileProvider).value?.currency ?? 'BIF';
    final selectedColorVal =
        Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));
    final monthsLeft = AppFormatters.monthsUntil(_deadline);
    final targetText = _targetController.text.replaceAll(' ', '');
    final target = double.tryParse(targetText) ?? 0;
    final monthly = monthsLeft > 0 ? target / monthsLeft : target;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvel objectif'),
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
              // Aperçu de la couleur
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: selectedColorVal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.flag_rounded,
                      color: selectedColorVal, size: 40),
                ),
              ),
              const SizedBox(height: 24),

              // Nom de l'objectif
              Text('Nom de l\'objectif', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Ex: Nouveau téléphone, Voyage, Voiture...',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Montant cible
              Text('Montant cible', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: currency,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Échéance
              Text('Échéance', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusInput),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(AppFormatters.formatDateMedium(_deadline),
                        style: AppTextStyles.bodyMedium),
                    const Spacer(),
                    Text('$monthsLeft mois',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.action)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // Couleur
              Text('Couleur', style: AppTextStyles.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _goalColors.map((hex) {
                  final color =
                      Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  final selected = hex == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: AppColors.textPrimary, width: 3)
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 8)
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Calcul automatique
              if (target > 0 && monthsLeft > 0)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusCard),
                  ),
                  child: Row(children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tu dois épargner ${AppFormatters.formatAmount(monthly, currency: currency)}/mois pendant $monthsLeft mois',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ]),
                ),
              const SizedBox(height: 32),

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
                      : const Text('Créer l\'objectif'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
