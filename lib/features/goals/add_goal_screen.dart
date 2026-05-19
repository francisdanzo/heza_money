import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart' show AppFormatters, ThousandsSeparatorFormatter;
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';

const _goalColors = [
  '#1D9E75',
  '#0F6E56',
  '#EF9F27',
  '#2196F3',
  '#9C27B0',
  '#E53935',
  '#607D8B',
  '#FF7043',
];

class AddGoalScreen extends ConsumerStatefulWidget {
  final Goal? goal; // null = création, non-null = édition
  const AddGoalScreen({super.key, this.goal});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _titleController  = TextEditingController();
  final _targetController = TextEditingController();
  DateTime _deadline      = DateTime.now().add(const Duration(days: 180));
  String _selectedColor   = _goalColors[0];
  bool _loading           = false;

  bool get _isEditing => widget.goal != null;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    if (g != null) {
      _titleController.text  = g.title;
      _targetController.text = g.targetAmount.toStringAsFixed(0);
      _deadline              = g.deadline;
      _selectedColor         = g.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) { _showError('Donne un nom à ton objectif'); return; }
    final targetText = _targetController.text.replaceAll(' ', '');
    final target = double.tryParse(targetText);
    if (target == null || target <= 0) { _showError('Saisis un montant cible valide'); return; }

    setState(() => _loading = true);
    try {
      if (_isEditing) {
        await ref.read(goalsDaoProvider).updateGoal(
          widget.goal!.copyWith(
            title:        title,
            targetAmount: target,
            deadline:     _deadline,
            color:        _selectedColor,
          ),
        );
      } else {
        await ref.read(goalsDaoProvider).addGoal(
          GoalsCompanion(
            title:         Value(title),
            targetAmount:  Value(target),
            currentAmount: const Value(0.0),
            deadline:      Value(_deadline),
            color:         Value(_selectedColor),
            createdAt:     Value(DateTime.now()),
          ),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Objectif modifié' : 'Objectif "$title" créé'),
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: HezaColors.error,
    ));
  }

  Future<void> _pickDeadline() async {
    final t = HezaTheme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      locale: const Locale('fr'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: t.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() { _deadline = picked; _isDirty = true; });
  }

  @override
  Widget build(BuildContext context) {
    final t              = HezaTheme.of(context);
    final currency       = ref.watch(userProfileProvider).value?.currency ?? 'BIF';
    final selectedColor  = Color(int.parse(_selectedColor.replaceFirst('#', '0xFF')));
    final monthsLeft     = AppFormatters.monthsUntil(_deadline);
    final targetText     = _targetController.text.replaceAll(' ', '');
    final target         = double.tryParse(targetText) ?? 0;
    final monthly        = monthsLeft > 0 ? target / monthsLeft : target;

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
        title: _isEditing ? 'Modifier l\'objectif' : 'Nouvel objectif',
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
              // ── Preview icon ─────────────────────────────────────────────
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(HezaRadius.lg),
                    border: Border.all(color: selectedColor.withValues(alpha: 0.4), width: 2),
                    boxShadow: [BoxShadow(color: selectedColor.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: Icon(Icons.flag_rounded, color: selectedColor, size: 44),
                ),
              ),
              const SizedBox(height: 28),

              // ── Nom ──────────────────────────────────────────────────────
              Text('Nom de l\'objectif', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 8),
              _GlassTextField(
                controller: _titleController,
                hintText: 'Ex: Nouveau téléphone, Voyage, Voiture...',
                t: t,
                onChanged: (_) => setState(() => _isDirty = true),
              ),
              const SizedBox(height: 20),

              // ── Montant cible ─────────────────────────────────────────────
              Text('Montant cible', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 8),
              _GlassTextField(
                controller: _targetController,
                hintText: '0',
                suffixText: currency,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorFormatter()],
                t: t,
                onChanged: (_) => setState(() => _isDirty = true),
              ),
              const SizedBox(height: 20),

              // ── Échéance ─────────────────────────────────────────────────
              Text('Échéance', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDeadline,
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
                        Text(AppFormatters.formatDateMedium(_deadline), style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: t.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(HezaRadius.full),
                          ),
                          child: Text('$monthsLeft mois', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: t.primary)),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Couleur ──────────────────────────────────────────────────
              Text('Couleur', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _goalColors.map((hex) {
                  final color    = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  final selected = hex == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() { _selectedColor = hex; _isDirty = true; }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: selected
                            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Calcul automatique ────────────────────────────────────────
              if (target > 0 && monthsLeft > 0) ...[
                GlassCard(
                  tintColor: t.primary,
                  opacity: t.isDark ? 0.10 : 0.08,
                  border: Border.all(color: t.primary.withValues(alpha: 0.25), width: 1),
                  child: Row(children: [
                    Icon(Icons.lightbulb_outline_rounded, size: 18, color: t.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tu dois épargner ${AppFormatters.formatAmount(monthly, currency: currency)}/mois pendant $monthsLeft mois',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: t.primary),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
              ],

              // ── Bouton créer ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  label: _isEditing ? 'Enregistrer' : 'Créer l\'objectif',
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
}

// ── Reusable glass text field ─────────────────────────────────────────────────
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? suffixText;
  final TextInputType keyboardType;
  final HezaTheme t;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const _GlassTextField({
    required this.controller,
    required this.hintText,
    required this.t,
    this.suffixText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.inputFormatters,
  });

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
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.text),
            decoration: InputDecoration(
              hintText: hintText,
              suffixText: suffixText,
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textMuted),
              suffixStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textSub),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}
