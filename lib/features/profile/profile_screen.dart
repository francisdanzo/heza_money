import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/services/pdf_export_service.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';
import '../../shared/widgets/common_widgets.dart';

/// Écran Profil — paramètres utilisateur
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
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
    final name = _nameController.text.trim();
    final salaryText = _salaryController.text.replaceAll(' ', '');
    final salary = double.tryParse(salaryText);

    if (name.isEmpty || salary == null || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vérifie le nom et le salaire'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    await ref.read(userProfileDaoProvider).updateProfile(
          UserProfileCompanion(
            name: Value(name),
            monthlySalary: Value(salary),
          ),
        );
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profil mis à jour 💚'),
        backgroundColor: AppColors.action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
      ));
    }
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser les données',
            style: AppTextStyles.headlineSmall),
        content: const Text(
          'Cette action supprimera toutes tes transactions, objectifs et progressions. Cette action est irréversible.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Données réinitialisées'),
          backgroundColor: AppColors.textSecondary,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final scoreAsync = ref.watch(financialScoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close_rounded : Icons.edit_rounded),
            onPressed: () {
              setState(() => _editing = !_editing);
              if (!_editing) {
                // Annuler — restaure les valeurs
                final profile = profileAsync.value;
                if (profile != null) {
                  _nameController.text = profile.name;
                  _salaryController.text =
                      profile.monthlySalary.toStringAsFixed(0);
                }
              }
            },
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) return const SizedBox();
          // Initialise les contrôleurs si pas en édition
          if (!_editing) {
            _nameController.text = profile.name;
            _salaryController.text = profile.monthlySalary.toStringAsFixed(0);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // Avatar
              Center(
                child: Column(children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.action,
                    child: Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.name, style: AppTextStyles.headlineMedium),
                  Text(
                    AppFormatters.formatAmount(profile.monthlySalary,
                        currency: profile.currency),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Score financier
              GestureDetector(
                onTap: () => context.push('/badges'),
                child: HezaCard(
                  backgroundColor: AppColors.primary,
                  child: Row(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Score financier',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white70)),
                          Text(
                            '${scoreAsync.value ?? 0} / 100',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ]),
                    const Spacer(),
                    const Text('🏆', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.white54),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // Informations personnelles
              const SectionHeader(title: 'Informations'),
              const SizedBox(height: 12),
              HezaCard(
                child: Column(children: [
                  _SettingRow(
                    label: 'Nom',
                    child: _editing
                        ? TextField(
                            controller: _nameController,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          )
                        : Text(profile.name, style: AppTextStyles.bodyMedium),
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    label: 'Salaire mensuel',
                    child: _editing
                        ? TextField(
                            controller: _salaryController,
                            keyboardType: TextInputType.number,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              suffixText: profile.currency,
                            ),
                          )
                        : Text(
                            AppFormatters.formatAmount(profile.monthlySalary,
                                currency: profile.currency),
                            style: AppTextStyles.bodyMedium),
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    label: 'Devise',
                    child: _editing
                        ? DropdownButton<String>(
                            value: profile.currency,
                            items: _currencies
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (c) async {
                              if (c != null) {
                                await ref
                                    .read(userProfileDaoProvider)
                                    .updateProfile(UserProfileCompanion(
                                        currency: Value(c)));
                              }
                            },
                            underline: const SizedBox(),
                            style: AppTextStyles.bodyMedium,
                          )
                        : Text(profile.currency,
                            style: AppTextStyles.bodyMedium),
                  ),
                ]),
              ),

              if (_editing) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Enregistrer les modifications'),
                ),
              ],
              const SizedBox(height: 20),

              // Thème
              const SectionHeader(title: 'Apparence'),
              const SizedBox(height: 12),
              HezaCard(
                child: _SettingRow(
                  label: 'Mode sombre',
                  child: Switch(
                    value: profile.themeMode == 1,
                    activeThumbColor: AppColors.action,
                    onChanged: (val) async {
                      await ref.read(userProfileDaoProvider).updateProfile(
                          UserProfileCompanion(themeMode: Value(val ? 1 : 0)));
                      ref.read(themeModeProvider.notifier).state = val ? 1 : 0;
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
                    color: AppColors.alert,
                    onTap: () => context.push('/badges'),
                  ),
                  const Divider(height: 1),
                  _ActionRow(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Exporter le bilan PDF',
                    color: AppColors.action,
                    onTap: () => _showExportInfo(context),
                  ),
                  const Divider(height: 1),
                  _ActionRow(
                    icon: Icons.delete_outline_rounded,
                    label: 'Réinitialiser les données',
                    color: AppColors.error,
                    onTap: _resetData,
                  ),
                ]),
              ),
              const SizedBox(height: 32),

              // Version
              const Center(
                child: Text(
                  'Heza Money v1.0 — Feel good about your money 💚',
                  style: AppTextStyles.bodySmall,
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
        title: const Text('Export PDF', style: AppTextStyles.headlineSmall),
        content: const Text(
          'L\'export PDF génère un bilan mensuel complet avec tes transactions, ton score financier et la répartition de tes dépenses.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _exportPdfBilan();
            },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdfBilan() async {
    try {
      // Récupérer les données du mois courant
      final profile = await ref.read(userProfileProvider.future);
      final transactions =
          await ref.read(currentMonthTransactionsProvider.future);
      final goals = await ref.read(goalsProvider.future);
      final score = await ref.read(financialScoreProvider.future);

      if (profile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Profil utilisateur non trouvé'),
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }

      // Générer le PDF
      final filePath = await PdfExportService().exportMonthlyBilan(
        userName: profile.name,
        salary: profile.monthlySalary,
        currency: profile.currency,
        transactions: transactions,
        goals: goals,
        financialScore: score,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('PDF généré : ${filePath.split('/').last}'),
          backgroundColor: AppColors.action,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _SettingRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
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
  const _ActionRow(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textDisabled),
        ]),
      ),
    );
  }
}
