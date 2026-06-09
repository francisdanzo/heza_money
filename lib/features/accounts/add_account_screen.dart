import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_providers.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  final Account? account; // null = création, non-null = édition
  const AddAccountScreen({super.key, this.account});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _type = 'mobile_money';
  String? _provider;
  String _color = '#1D9E75';
  bool _loading = false;

  bool get _isEditing => widget.account != null;

  static const _accountColors = [
    '#1D9E75', '#E8A020', '#1E88E5', '#43A047',
    '#E53935', '#8E24AA', '#00ACC1', '#F4511E',
  ];

  static const _mobileMoney = [
    ('lumicash', 'Lumicash',  '#E8A020', Icons.phone_android_rounded),
    ('ecocash',  'Ecocash',   '#1E88E5', Icons.phone_iphone_rounded),
    ('mobibank', 'Mobibank',  '#43A047', Icons.mobile_friendly_rounded),
  ];

  static const _banks = [
    ('bcb',      'BCB',    '#1565C0'),
    ('bancobu',  'BANCOBU','#6A1B9A'),
    ('ibb',      'IBB',    '#AD1457'),
    ('brd',      'BRD',    '#00695C'),
    ('cospecbu', 'COSPECBU','#E65100'),
    ('other_bank','Autre banque', '#546E7A'),
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    if (a != null) {
      _nameController.text = a.name;
      _balanceController.text = a.balance.toStringAsFixed(0);
      _type = a.type;
      _provider = a.provider;
      _color = a.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) { _showError('Entre un nom pour le compte'); return; }

    final balanceText = _balanceController.text.replaceAll(' ', '');
    final balance = double.tryParse(balanceText.isEmpty ? '0' : balanceText) ?? 0;

    setState(() => _loading = true);
    try {
      final dao = ref.read(accountsDaoProvider);
      if (_isEditing) {
        await dao.updateAccount(widget.account!.copyWith(
          name: name,
          type: _type,
          provider: Value(_provider),
          balance: balance,
          color: _color,
        ));
      } else {
        await dao.addAccount(AccountsCompanion(
          name: Value(name),
          type: Value(_type),
          provider: Value(_provider),
          balance: Value(balance),
          color: Value(_color),
          createdAt: Value(DateTime.now()),
        ));
      }
      if (mounted) Navigator.of(context).pop();
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
    final t = HezaTheme.of(context);

    return Scaffold(
      appBar: GlassAppBar(
        title: _isEditing ? 'Modifier le compte' : 'Nouveau compte',
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Type de compte ───────────────────────────────────────────
            Text('Type de compte', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
            const SizedBox(height: 10),
            Row(children: [
              _typeChip('mobile_money', Icons.phone_android_rounded, 'Mobile Money', t),
              const SizedBox(width: 8),
              _typeChip('bank',         Icons.account_balance_rounded, 'Banque',       t),
              const SizedBox(width: 8),
              _typeChip('cash',         Icons.wallet_rounded,           'Cash',         t),
            ]),
            const SizedBox(height: 24),

            // ── Opérateur / Banque ───────────────────────────────────────
            if (_type == 'mobile_money') ...[
              Text('Opérateur', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: _mobileMoney.map((mm) {
                final (id, label, hex, icon) = mm;
                final selected = _provider == id;
                final color = Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
                return GestureDetector(
                  onTap: () => setState(() {
                    _provider = id;
                    _color = hex;
                    if (_nameController.text.isEmpty) _nameController.text = label;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? color : t.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(HezaRadius.md),
                      border: Border.all(color: selected ? color : t.glassBorder),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon, size: 15, color: selected ? Colors.white : t.textSub),
                      const SizedBox(width: 6),
                      Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : t.text)),
                    ]),
                  ),
                );
              }).toList()),
              const SizedBox(height: 24),
            ],

            if (_type == 'bank') ...[
              Text('Banque', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: _banks.map((b) {
                final (id, label, hex) = b;
                final selected = _provider == id;
                final color = Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
                return GestureDetector(
                  onTap: () => setState(() {
                    _provider = id;
                    _color = hex;
                    if (_nameController.text.isEmpty) _nameController.text = label;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? color : t.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(HezaRadius.md),
                      border: Border.all(color: selected ? color : t.glassBorder),
                    ),
                    child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : t.text)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 24),
            ],

            // ── Nom du compte ────────────────────────────────────────────
            Text('Nom du compte', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
            const SizedBox(height: 8),
            _GlassTextField(controller: _nameController, hint: 'Ex: Mon Lumicash perso', t: t),
            const SizedBox(height: 24),

            // ── Solde initial ────────────────────────────────────────────
            Text('Solde actuel', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
            const SizedBox(height: 8),
            _BalanceField(controller: _balanceController, t: t),
            const SizedBox(height: 24),

            // ── Couleur ──────────────────────────────────────────────────
            Text('Couleur', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: t.textSub)),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: _accountColors.map((hex) {
              final color = Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
              final selected = _color == hex;
              return GestureDetector(
                onTap: () => setState(() => _color = hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: selected ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)] : null,
                  ),
                  child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                ),
              );
            }).toList()),
            const SizedBox(height: 36),

            // ── Bouton enregistrer ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: _isEditing ? 'Modifier' : 'Créer le compte',
                onPressed: _loading ? null : _save,
                isLoading: _loading,
                fullWidth: true,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _typeChip(String type, IconData icon, String label, HezaTheme t) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type = type;
          _provider = null;
          if (type == 'cash') _color = '#546E7A';
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? t.primary : t.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(HezaRadius.md),
            border: Border.all(color: selected ? t.primary : t.glassBorder),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: selected ? Colors.white : t.textSub),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : t.textSub)),
          ]),
        ),
      ),
    );
  }
}

// ── Glass text field ──────────────────────────────────────────────────────────
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final HezaTheme t;
  const _GlassTextField({required this.controller, required this.hint, required this.t});

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
            border: Border.all(color: t.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: t.text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 15, color: t.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Balance field ─────────────────────────────────────────────────────────────
class _BalanceField extends StatelessWidget {
  final TextEditingController controller;
  final HezaTheme t;
  const _BalanceField({required this.controller, required this.t});

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
            border: Border.all(color: t.glassBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, color: t.text),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w300, color: t.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Text('BIF', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textSub)),
          ]),
        ),
      ),
    );
  }
}
