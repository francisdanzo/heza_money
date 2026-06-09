import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../data/models/mobile_money.dart';
import '../../shared/providers/database_providers.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = HezaTheme.of(context);
    final accountsAsync = ref.watch(accountsProvider);
    final currency = ref.watch(userProfileProvider).value?.currency ?? 'BIF';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _AccountsHeader(currency: currency),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text('Mes comptes',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: t.text)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/accounts/add'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: t.primary,
                        borderRadius: BorderRadius.circular(HezaRadius.sm),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        const Text('Ajouter', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          accountsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(padding: const EdgeInsets.all(16),
                  child: Text('Erreur: $e', style: TextStyle(color: HezaColors.error))),
            ),
            data: (accounts) {
              if (accounts.isEmpty) {
                return SliverToBoxAdapter(child: _EmptyAccountsState(t: t));
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AccountCard(
                        account: accounts[i],
                        currency: currency,
                        onTap: () => context.push('/accounts/${accounts[i].id}'),
                      ),
                    ),
                    childCount: accounts.length,
                  ),
                ),
              );
            },
          ),
          // ── Calculatrice de frais ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calculatrice de frais',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: t.text)),
                  const SizedBox(height: 4),
                  Text('Estimez les frais avant de transférer ou retirer',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: t.textSub)),
                  const SizedBox(height: 12),
                  const _FeeCalculator(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Header avec total des comptes ─────────────────────────────────────────────
class _AccountsHeader extends ConsumerWidget {
  final String currency;
  const _AccountsHeader({required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(totalAccountsBalanceProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: HezaColors.primary,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [HezaColors.darkBg2, const Color(0xFF1A3526)]
                  : [HezaColors.primary, HezaColors.primaryLight],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mes Comptes',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Balance totale',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.75))),
                  const SizedBox(height: 6),
                  totalAsync.when(
                    loading: () => const Text('...', style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Inter')),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (total) => Text(
                      AppFormatters.formatAmount(total, currency: currency),
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  accountsAsync.maybeWhen(
                    data: (accounts) => Text(
                      '${accounts.length} compte${accounts.length > 1 ? 's' : ''} actif${accounts.length > 1 ? 's' : ''}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Carte de compte ───────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  final Account account;
  final String currency;
  final VoidCallback? onTap;

  const _AccountCard({required this.account, required this.currency, this.onTap});

  Color _providerColor() {
    if (account.provider != null) {
      final mmProvider = MobileMoneyData.getById(account.provider!);
      if (mmProvider != null) {
        return Color(int.parse(mmProvider.color.replaceFirst('#', 'FF'), radix: 16));
      }
      final bank = MobileMoneyData.banks.firstWhere(
        (b) => b['id'] == account.provider,
        orElse: () => {'color': '#546E7A'},
      );
      return Color(int.parse(bank['color']!.replaceFirst('#', 'FF'), radix: 16));
    }
    return Color(int.parse(account.color.replaceFirst('#', 'FF'), radix: 16));
  }

  IconData _typeIcon() {
    switch (account.type) {
      case 'mobile_money': return Icons.phone_android_rounded;
      case 'bank': return Icons.account_balance_rounded;
      default: return Icons.wallet_rounded;
    }
  }

  String _typeLabel() {
    switch (account.type) {
      case 'mobile_money': return 'Mobile Money';
      case 'bank': return 'Banque';
      default: return 'Espèces';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final color = _providerColor();

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(HezaRadius.md),
            ),
            child: Icon(_typeIcon(), color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(account.name,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: t.text)),
              const SizedBox(height: 2),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(_typeLabel(),
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: color)),
                ),
                if (account.provider != null) ...[
                  const SizedBox(width: 6),
                  Text(account.provider!.toUpperCase(),
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: t.textMuted)),
                ],
              ]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(AppFormatters.formatAmount(account.balance, currency: ''),
                style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: t.text)),
            Text('BIF', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: t.textMuted)),
          ]),
        ]),
      ),
    );
  }
}

// ── État vide ─────────────────────────────────────────────────────────────────
class _EmptyAccountsState extends StatelessWidget {
  final HezaTheme t;
  const _EmptyAccountsState({required this.t});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: HezaColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.account_balance_wallet_outlined, size: 36, color: HezaColors.primary),
        ),
        const SizedBox(height: 16),
        Text('Aucun compte', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: t.text)),
        const SizedBox(height: 6),
        Text('Ajoute ton premier compte\npour suivre tes soldes',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textSub)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => context.push('/accounts/add'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: HezaColors.primary, borderRadius: BorderRadius.circular(HezaRadius.md)),
            child: const Text('Ajouter un compte',
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ── Calculatrice de frais ─────────────────────────────────────────────────────
class _FeeCalculator extends StatefulWidget {
  const _FeeCalculator();
  @override
  State<_FeeCalculator> createState() => _FeeCalculatorState();
}

class _FeeCalculatorState extends State<_FeeCalculator> {
  String _selectedProvider = 'lumicash';
  String _operationType = 'transfer'; // 'transfer' | 'external_transfer' | 'withdrawal'
  final _amountController = TextEditingController();
  double? _calculatedFee;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculate() {
    final text = _amountController.text.replaceAll(' ', '');
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() => _calculatedFee = null);
      return;
    }
    final provider = MobileMoneyData.getById(_selectedProvider);
    if (provider == null) return;
    setState(() {
      switch (_operationType) {
        case 'external_transfer':
          _calculatedFee = provider.externalTransferFee(amount);
        case 'withdrawal':
          _calculatedFee = provider.withdrawalFee(amount);
        default:
          _calculatedFee = provider.transferFee(amount);
      }
    });
  }

  void _selectProvider(String id) {
    final provider = MobileMoneyData.getById(id);
    // Si l'opération courante n'est pas disponible pour ce provider, reset
    final hasExternal = provider?.hasExternalTransferFees ?? false;
    setState(() {
      _selectedProvider = id;
      _calculatedFee = null;
      if (_operationType == 'external_transfer' && !hasExternal) {
        _operationType = 'transfer';
      }
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final providers = MobileMoneyData.providers;
    final currentProvider = MobileMoneyData.getById(_selectedProvider);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Provider selector
        Row(children: providers.map((p) {
          final selected = _selectedProvider == p.id;
          final color = Color(int.parse(p.color.replaceFirst('#', 'FF'), radix: 16));
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectProvider(p.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? color : t.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(HezaRadius.sm),
                  border: Border.all(color: selected ? color : t.glassBorder),
                ),
                child: Text(p.shortName,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : t.textSub)),
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: 14),

        // Operation type
        Wrap(spacing: 8, runSpacing: 8, children: [
          _opChip('transfer', Icons.send_rounded, 'Transfert Lumi', t),
          if (currentProvider?.hasExternalTransferFees == true)
            _opChip('external_transfer', Icons.swap_horiz_rounded, 'Vers autre réseau', t),
          _opChip('withdrawal', Icons.money_off_rounded, 'Retrait', t),
        ]),
        const SizedBox(height: 14),

        // Amount input
        ClipRRect(
          borderRadius: BorderRadius.circular(HezaRadius.md),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              decoration: BoxDecoration(
                color: t.glassBg.withValues(alpha: t.isDark ? 0.2 : 0.6),
                borderRadius: BorderRadius.circular(HezaRadius.md),
                border: Border.all(color: t.glassBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculate(),
                    style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: t.text),
                    decoration: InputDecoration(
                      hintText: 'Montant',
                      hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 16, color: t.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Text('BIF', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: t.textSub)),
              ]),
            ),
          ),
        ),

        // Result
        if (_calculatedFee != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HezaColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(HezaRadius.md),
              border: Border.all(color: HezaColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: HezaColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Frais estimés : ${AppFormatters.formatAmount(_calculatedFee!, currency: 'BIF')}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: HezaColors.primary)),
                  Text('Montant total débité : ${AppFormatters.formatAmount(
                    double.parse(_amountController.text.replaceAll(' ', '')) + _calculatedFee!,
                    currency: 'BIF',
                  )}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: HezaColors.primary.withValues(alpha: 0.75))),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedProvider == 'lumicash'
                ? '* Source : tableau officiel Lumitel / Lumipay'
                : '* Tarifs indicatifs — vérifier avec votre opérateur',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: t.textMuted, fontStyle: FontStyle.italic),
          ),
        ],
      ]),
    );
  }

  Widget _opChip(String type, IconData icon, String label, HezaTheme t) {
    final selected = _operationType == type;
    return GestureDetector(
      onTap: () { setState(() { _operationType = type; _calculatedFee = null; }); _calculate(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? t.primary : t.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(HezaRadius.sm),
          border: Border.all(color: selected ? t.primary : t.glassBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: selected ? Colors.white : t.textSub),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
              color: selected ? Colors.white : t.textSub)),
        ]),
      ),
    );
  }
}
