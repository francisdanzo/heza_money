import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/pdf_export_service.dart';
import '../../core/services/csv_export_service.dart';
import '../../core/services/notifications_service.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController   = TextEditingController();
  final _salaryController = TextEditingController();
  bool _editing = false;

  static const _currencies = ['BIF', 'USD', 'EUR'];

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name       = _nameController.text.trim();
    final salaryText = _salaryController.text.replaceAll(' ', '');
    final salary     = double.tryParse(salaryText);

    if (name.isEmpty || salary == null || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vérifie le nom et le salaire'),
      ));
      return;
    }

    await ref.read(userProfileDaoProvider).updateProfile(
      UserProfileCompanion(name: Value(name), monthlySalary: Value(salary)),
    );
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profil mis à jour — Murakoze !'),
      ));
    }
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Réinitialiser les données', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: HezaTheme.of(ctx).text)),
        content: Text(
          'Cette action supprimera toutes tes transactions, objectifs et progressions. Cette action est irréversible.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(ctx).textSub),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: HezaColors.error),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(transactionsDaoProvider).deleteAll();
      await ref.read(goalsDaoProvider).deleteAll();
      await ref.read(lessonProgressDaoProvider).deleteAll();
      await ref.read(earnedBadgesDaoProvider).deleteAll();
      await ref.read(categoryBudgetsDaoProvider).deleteAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Données réinitialisées')),
        );
      }
    }
  }

  Future<void> _exportCsv() async {
    try {
      final profile      = await ref.read(userProfileProvider.future);
      final transactions = await ref.read(transactionsDaoProvider).watchAll().first;
      if (profile == null) return;

      final filePath = await CsvExportService().exportTransactions(
        transactions: transactions,
        currency: profile.currency,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV généré : ${filePath.split('/').last}')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final scoreAsync   = ref.watch(financialScoreProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: 'Mon Profil',
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close_rounded : Icons.edit_rounded, color: Colors.white),
            onPressed: () {
              setState(() => _editing = !_editing);
              if (!_editing) {
                final profile = profileAsync.value;
                if (profile != null) {
                  _nameController.text   = profile.name;
                  _salaryController.text = profile.monthlySalary.toStringAsFixed(0);
                }
              }
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: t.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) return const SizedBox();
          if (!_editing) {
            _nameController.text   = profile.name;
            _salaryController.text = profile.monthlySalary.toStringAsFixed(0);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            children: [
              // Avatar glassmorphique
              Center(
                child: Column(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(44),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 88, height: 88,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [HezaColors.primary, HezaColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                          borderRadius: BorderRadius.circular(44),
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.name, style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: t.text)),
                  Text(
                    AppFormatters.formatAmount(profile.monthlySalary, currency: profile.currency),
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textSub),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Score financier
              GlassCard(
                onTap: () => context.push('/badges'),
                tintColor: HezaColors.primary,
                opacity: t.isDark ? 0.15 : 0.12,
                border: Border.all(color: HezaColors.primary.withValues(alpha: 0.3), width: 1),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Score financier', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: t.primary.withValues(alpha: 0.8))),
                    Text(
                      '${scoreAsync.value ?? 0} / 100',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, color: t.primary),
                    ),
                  ]),
                  const Spacer(),
                  Icon(Icons.emoji_events_rounded, size: 36, color: HezaColors.warning),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: t.textMuted),
                ]),
              ),
              const SizedBox(height: 20),

              // Informations
              const SectionHeader(title: 'Informations'),
              const SizedBox(height: 12),
              HezaCard(
                child: Column(children: [
                  _SettingRow(
                    label: 'Nom',
                    child: _editing
                        ? SizedBox(
                            width: 150,
                            child: TextField(
                              controller: _nameController,
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(context).text),
                              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                            ),
                          )
                        : Text(profile.name, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(context).text)),
                  ),
                  Divider(height: 1, color: HezaTheme.of(context).border),
                  _SettingRow(
                    label: 'Salaire mensuel',
                    child: _editing
                        ? SizedBox(
                            width: 150,
                            child: TextField(
                              controller: _salaryController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(context).text),
                              decoration: InputDecoration(isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), suffixText: profile.currency),
                            ),
                          )
                        : Text(AppFormatters.formatAmount(profile.monthlySalary, currency: profile.currency), style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(context).text)),
                  ),
                  Divider(height: 1, color: HezaTheme.of(context).border),
                  _SettingRow(
                    label: 'Devise',
                    child: _editing
                        ? DropdownButton<String>(
                            value: profile.currency,
                            items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (c) async {
                              if (c != null) {
                                await ref.read(userProfileDaoProvider).updateProfile(UserProfileCompanion(currency: Value(c)));
                              }
                            },
                            underline: const SizedBox(),
                          )
                        : Text(profile.currency, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(context).text)),
                  ),
                ]),
              ),

              if (_editing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Enregistrer les modifications'),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Apparence
              const SectionHeader(title: 'Apparence'),
              const SizedBox(height: 12),
              HezaCard(
                child: _SettingRow(
                  label: 'Thème',
                  child: _ThemeModeSelector(
                    value: profile.themeMode,
                    onChanged: (val) async {
                      await ref.read(userProfileDaoProvider).updateProfile(
                        UserProfileCompanion(themeMode: Value(val)),
                      );
                      ref.read(themeModeProvider.notifier).state = val;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notifications
              const SectionHeader(title: 'Notifications'),
              const SizedBox(height: 12),
              HezaCard(
                child: _SettingRow(
                  label: 'Rappel mensuel',
                  child: Switch(
                    value: profile.notificationsEnabled,
                    activeThumbColor: HezaTheme.of(context).primary,
                    onChanged: (val) async {
                      await ref.read(userProfileDaoProvider).updateProfile(
                        UserProfileCompanion(notificationsEnabled: Value(val)),
                      );
                      if (val) {
                        await NotificationsService().scheduleMonthlyReminder();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              const SectionHeader(title: 'Actions'),
              const SizedBox(height: 12),
              HezaCard(
                child: Column(children: [
                  _ActionRow(
                    icon: Icons.emoji_events_rounded,
                    label: 'Mes badges',
                    color: HezaColors.warning,
                    onTap: () => context.push('/badges'),
                  ),
                  Divider(height: 1, color: HezaTheme.of(context).border),
                  _ActionRow(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Exporter le bilan PDF',
                    color: HezaColors.primaryLight,
                    onTap: () => _showExportInfo(context),
                  ),
                  Divider(height: 1, color: HezaTheme.of(context).border),
                  _ActionRow(
                    icon: Icons.table_chart_rounded,
                    label: 'Exporter en CSV',
                    color: HezaColors.success,
                    onTap: _exportCsv,
                  ),
                  Divider(height: 1, color: HezaTheme.of(context).border),
                  _ActionRow(
                    icon: Icons.delete_outline_rounded,
                    label: 'Réinitialiser les données',
                    color: HezaColors.error,
                    onTap: _resetData,
                  ),
                ]),
              ),
              const SizedBox(height: 32),

              Center(
                child: Text(
                  'Heza Money v1.0 — Feel good about your money',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: HezaTheme.of(context).textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExportInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Export PDF', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: HezaTheme.of(ctx).text)),
        content: Text(
          'L\'export PDF génère un bilan mensuel complet avec tes transactions, ton score financier et la répartition de tes dépenses.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: HezaTheme.of(ctx).textSub),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); _exportPdfBilan(); },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdfBilan() async {
    try {
      final profile      = await ref.read(userProfileProvider.future);
      final transactions = await ref.read(currentMonthTransactionsProvider.future);
      final goals        = await ref.read(goalsProvider.future);
      final score        = await ref.read(financialScoreProvider.future);

      if (profile == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil utilisateur non trouvé')));
        return;
      }

      final filePath = await PdfExportService().exportMonthlyBilan(
        userName: profile.name,
        salary: profile.monthlySalary,
        currency: profile.currency,
        transactions: transactions,
        goals: goals,
        financialScore: score,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF généré : ${filePath.split('/').last}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _ThemeModeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThemeOption(icon: Icons.wb_sunny_rounded,    label: 'Clair',  active: value == 0, t: t, onTap: () => onChanged(0)),
        const SizedBox(width: 6),
        _ThemeOption(icon: Icons.nightlight_round,    label: 'Sombre', active: value == 1, t: t, onTap: () => onChanged(1)),
        const SizedBox(width: 6),
        _ThemeOption(icon: Icons.phone_android_rounded, label: 'Auto', active: value == 2, t: t, onTap: () => onChanged(2)),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final HezaTheme t;
  final VoidCallback onTap;
  const _ThemeOption({required this.icon, required this.label, required this.active, required this.t, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? t.primary : t.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(HezaRadius.sm),
          border: Border.all(color: active ? t.primary : t.glassBorder, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: active ? Colors.white : t.textSub),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: active ? Colors.white : t.textSub)),
        ]),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _SettingRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(children: [
        Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textSub)),
        const Spacer(),
        child,
      ]),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionRow({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(HezaRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(HezaRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: t.text)),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: t.textMuted),
        ]),
      ),
    );
  }
}
