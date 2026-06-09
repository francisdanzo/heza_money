import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/design_tokens.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController   = TextEditingController();
  final _salaryController = TextEditingController();
  String _currency        = 'BIF';
  bool   _loading         = false;

  static const _currencies = ['BIF', 'USD', 'EUR'];

  @override
  void dispose() {
    _nameController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Entre ton prénom pour continuer');
      return;
    }
    final salaryText = _salaryController.text.replaceAll(' ', '');
    final salary     = double.tryParse(salaryText);
    if (salary == null || salary <= 0) {
      _showError('Entre un salaire mensuel valide');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(userProfileDaoProvider).createProfile(
        UserProfileCompanion(
          name:          Value(name),
          monthlySalary: Value(salary),
          currency:      Value(_currency),
          themeMode:     const Value(0),
        ),
      );
      if (mounted) context.go('/');
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
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [HezaColors.darkBg, Color(0xFF1A3D2B), HezaColors.primary],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo ────────────────────────────────────────────────────
                Center(
                  child: Column(children: [
                    Image.asset(
                      'assets/logo/logo.png',
                      width: 90,
                      height: 90,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Heza Money',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Feel good about your money',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withValues(alpha: 0.65)),
                    ),
                  ]),
                ),
                const SizedBox(height: 48),

                // ── Section title ─────────────────────────────────────────
                const Text(
                  'Dis-nous qui tu es',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ces informations restent sur ton téléphone — 100% privé.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.6), height: 1.5),
                ),
                const SizedBox(height: 32),

                // ── Prénom ────────────────────────────────────────────────
                _FieldLabel('Ton prénom'),
                const SizedBox(height: 8),
                _GlassField(
                  controller: _nameController,
                  hintText: 'Ex: Francis, Amina, Jean...',
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 20),

                // ── Salaire ───────────────────────────────────────────────
                _FieldLabel('Salaire mensuel net'),
                const SizedBox(height: 8),
                _SalaryRow(
                  controller: _salaryController,
                  currency: _currency,
                  currencies: _currencies,
                  onCurrencyChanged: (c) => setState(() => _currency = c),
                ),
                const SizedBox(height: 12),
                _CurrencyHint(currency: _currency),
                const SizedBox(height: 40),

                // ── Bouton ────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: HezaColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HezaRadius.md)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: HezaColors.primary, strokeWidth: 2))
                        : const Text('Commencer', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'Tu pourras modifier ces informations\ndans ton profil à tout moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withValues(alpha: 0.45), height: 1.5),
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

// ── Helpers ───────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.75)));
  }
}

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final Widget? suffix;

  const _GlassField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(HezaRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(HezaRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white.withValues(alpha: 0.35)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (suffix != null) suffix!,
          ]),
        ),
      ),
    );
  }
}

class _SalaryRow extends StatelessWidget {
  final TextEditingController controller;
  final String currency;
  final List<String> currencies;
  final ValueChanged<String> onCurrencyChanged;

  const _SalaryRow({
    required this.controller,
    required this.currency,
    required this.currencies,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(HezaRadius.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(HezaRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '700000',
                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white.withValues(alpha: 0.35)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            DropdownButton<String>(
              value: currency,
              dropdownColor: HezaColors.darkSurface,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              underline: const SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withValues(alpha: 0.6), size: 18),
              items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (c) { if (c != null) onCurrencyChanged(c); },
            ),
          ]),
        ),
      ),
    );
  }
}

class _CurrencyHint extends StatelessWidget {
  final String currency;
  const _CurrencyHint({required this.currency});

  @override
  Widget build(BuildContext context) {
    final hints = {
      'BIF': 'En BIF (Franc burundais) — salaire moyen ~700 000 BIF',
      'USD': 'En USD (Dollar américain)',
      'EUR': 'En EUR (Euro)',
    };
    return Row(children: [
      Icon(Icons.info_outline_rounded, size: 13, color: Colors.white.withValues(alpha: 0.4)),
      const SizedBox(width: 6),
      Text(hints[currency] ?? '', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
    ]);
  }
}
