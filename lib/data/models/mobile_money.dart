// Frais officiels Lumicash — source : tableau officiel Lumitel/Lumipay
// Vérifier les mises à jour sur le site de Lumitel.

class FeeTier {
  final double minAmount;
  final double maxAmount;
  final double fee; // frais fixes en BIF

  const FeeTier({
    required this.minAmount,
    required this.maxAmount,
    required this.fee,
  });
}

class MobileMoneyProvider {
  final String id;
  final String name;
  final String shortName;
  final String type; // 'mobile_money' | 'bank'
  final String color;
  final List<FeeTier> transferFees;          // Lumi → Lumi
  final List<FeeTier> externalTransferFees;  // Lumi → autre réseau (vide si non applicable)
  final List<FeeTier> withdrawalFees;        // retrait agent / Lumipay
  final String? depositNote;

  const MobileMoneyProvider({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.color,
    required this.transferFees,
    this.externalTransferFees = const [],
    required this.withdrawalFees,
    this.depositNote,
  });

  double calculateFee(List<FeeTier> tiers, double amount) {
    for (final tier in tiers) {
      if (amount >= tier.minAmount && amount <= tier.maxAmount) {
        return tier.fee;
      }
    }
    if (tiers.isNotEmpty && amount > tiers.last.maxAmount) {
      return tiers.last.fee;
    }
    return 0;
  }

  double transferFee(double amount) => calculateFee(transferFees, amount);
  double externalTransferFee(double amount) =>
      externalTransferFees.isNotEmpty
          ? calculateFee(externalTransferFees, amount)
          : calculateFee(transferFees, amount);
  double withdrawalFee(double amount) => calculateFee(withdrawalFees, amount);

  bool get hasExternalTransferFees => externalTransferFees.isNotEmpty;
}

class MobileMoneyData {
  static const List<MobileMoneyProvider> providers = [
    // ── LUMICASH ──────────────────────────────────────────────────────────────
    // Tableau officiel Lumitel (IBICIRO)
    MobileMoneyProvider(
      id: 'lumicash',
      name: 'Lumicash',
      shortName: 'Lumicash',
      type: 'mobile_money',
      color: '#E8A020',
      depositNote: 'Dépôt gratuit chez les agents Lumitel',

      // Colonne "Frais de transfert" (Lumicash → Lumicash)
      transferFees: [
        FeeTier(minAmount: 1000,   maxAmount: 4999,    fee: 148),
        FeeTier(minAmount: 5000,   maxAmount: 9999,    fee: 384),
        FeeTier(minAmount: 10000,  maxAmount: 19999,   fee: 620),
        FeeTier(minAmount: 20000,  maxAmount: 29999,   fee: 840),
        FeeTier(minAmount: 30000,  maxAmount: 49999,   fee: 1020),
        FeeTier(minAmount: 50000,  maxAmount: 59999,   fee: 1200),
        FeeTier(minAmount: 60000,  maxAmount: 79999,   fee: 1440),
        FeeTier(minAmount: 80000,  maxAmount: 99999,   fee: 1860),
        FeeTier(minAmount: 100000, maxAmount: 199999,  fee: 2400),
        FeeTier(minAmount: 200000, maxAmount: 299999,  fee: 3600),
        FeeTier(minAmount: 300000, maxAmount: 499999,  fee: 4600),
        FeeTier(minAmount: 500000, maxAmount: 1000000, fee: 5160),
      ],

      // Colonne intermédiaire — transfert vers autre réseau / paiement Lumipay
      externalTransferFees: [
        FeeTier(minAmount: 1000,   maxAmount: 4999,    fee: 720),
        FeeTier(minAmount: 5000,   maxAmount: 9999,    fee: 1760),
        FeeTier(minAmount: 10000,  maxAmount: 19999,   fee: 2880),
        FeeTier(minAmount: 20000,  maxAmount: 29999,   fee: 3280),
        FeeTier(minAmount: 30000,  maxAmount: 49999,   fee: 3640),
        FeeTier(minAmount: 50000,  maxAmount: 59999,   fee: 3240),
        FeeTier(minAmount: 60000,  maxAmount: 79999,   fee: 3920),
        FeeTier(minAmount: 80000,  maxAmount: 99999,   fee: 4620),
        FeeTier(minAmount: 100000, maxAmount: 199999,  fee: 6000),
        FeeTier(minAmount: 200000, maxAmount: 299999,  fee: 8160),
        FeeTier(minAmount: 300000, maxAmount: 499999,  fee: 10320),
        FeeTier(minAmount: 500000, maxAmount: 1000000, fee: 17040),
      ],

      // Colonne "Frais de retrait en Lumipay"
      withdrawalFees: [
        FeeTier(minAmount: 1000,   maxAmount: 4999,    fee: 276),
        FeeTier(minAmount: 5000,   maxAmount: 9999,    fee: 995),
        FeeTier(minAmount: 10000,  maxAmount: 19999,   fee: 1480),
        FeeTier(minAmount: 20000,  maxAmount: 29999,   fee: 1020),
        FeeTier(minAmount: 30000,  maxAmount: 49999,   fee: 1280),
        FeeTier(minAmount: 50000,  maxAmount: 59999,   fee: 1620),
        FeeTier(minAmount: 60000,  maxAmount: 79999,   fee: 1960),
        FeeTier(minAmount: 80000,  maxAmount: 99999,   fee: 2280),
        FeeTier(minAmount: 100000, maxAmount: 199999,  fee: 3000),
        FeeTier(minAmount: 200000, maxAmount: 299999,  fee: 4680),
        FeeTier(minAmount: 300000, maxAmount: 499999,  fee: 5740),
        FeeTier(minAmount: 500000, maxAmount: 1000000, fee: 10440),
      ],
    ),

    // ── ECOCASH ───────────────────────────────────────────────────────────────
    MobileMoneyProvider(
      id: 'ecocash',
      name: 'Ecocash',
      shortName: 'Ecocash',
      type: 'mobile_money',
      color: '#1E88E5',
      depositNote: 'Dépôt gratuit chez les agents Econet',
      transferFees: [
        FeeTier(minAmount: 500,    maxAmount: 5000,    fee: 50),
        FeeTier(minAmount: 5001,   maxAmount: 10000,   fee: 100),
        FeeTier(minAmount: 10001,  maxAmount: 25000,   fee: 200),
        FeeTier(minAmount: 25001,  maxAmount: 50000,   fee: 350),
        FeeTier(minAmount: 50001,  maxAmount: 100000,  fee: 650),
        FeeTier(minAmount: 100001, maxAmount: 250000,  fee: 1200),
        FeeTier(minAmount: 250001, maxAmount: 500000,  fee: 2200),
        FeeTier(minAmount: 500001, maxAmount: 1000000, fee: 4500),
      ],
      withdrawalFees: [
        FeeTier(minAmount: 500,    maxAmount: 5000,    fee: 100),
        FeeTier(minAmount: 5001,   maxAmount: 10000,   fee: 200),
        FeeTier(minAmount: 10001,  maxAmount: 25000,   fee: 300),
        FeeTier(minAmount: 25001,  maxAmount: 50000,   fee: 550),
        FeeTier(minAmount: 50001,  maxAmount: 100000,  fee: 900),
        FeeTier(minAmount: 100001, maxAmount: 250000,  fee: 1800),
        FeeTier(minAmount: 250001, maxAmount: 500000,  fee: 3500),
        FeeTier(minAmount: 500001, maxAmount: 1000000, fee: 6500),
      ],
    ),

    // ── MOBIBANK ──────────────────────────────────────────────────────────────
    MobileMoneyProvider(
      id: 'mobibank',
      name: 'Mobibank',
      shortName: 'Mobibank',
      type: 'mobile_money',
      color: '#43A047',
      depositNote: 'Vérifier les frais auprès de votre banque',
      transferFees: [
        FeeTier(minAmount: 500,    maxAmount: 10000,   fee: 100),
        FeeTier(minAmount: 10001,  maxAmount: 50000,   fee: 250),
        FeeTier(minAmount: 50001,  maxAmount: 100000,  fee: 500),
        FeeTier(minAmount: 100001, maxAmount: 500000,  fee: 1500),
        FeeTier(minAmount: 500001, maxAmount: 1000000, fee: 3000),
      ],
      withdrawalFees: [
        FeeTier(minAmount: 500,    maxAmount: 10000,   fee: 150),
        FeeTier(minAmount: 10001,  maxAmount: 50000,   fee: 350),
        FeeTier(minAmount: 50001,  maxAmount: 100000,  fee: 700),
        FeeTier(minAmount: 100001, maxAmount: 500000,  fee: 2000),
        FeeTier(minAmount: 500001, maxAmount: 1000000, fee: 4000),
      ],
    ),
  ];

  static MobileMoneyProvider? getById(String id) {
    try {
      return providers.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static const List<Map<String, String>> banks = [
    {'id': 'bcb',       'name': 'BCB (Banque Commerciale du Burundi)',      'color': '#1565C0'},
    {'id': 'bancobu',   'name': 'BANCOBU',                                  'color': '#6A1B9A'},
    {'id': 'ibb',       'name': 'IBB (Interbank Burundi)',                  'color': '#AD1457'},
    {'id': 'brd',       'name': 'BRD (Banque Régionale du Développement)', 'color': '#00695C'},
    {'id': 'cospecbu',  'name': 'COSPECBU',                                 'color': '#E65100'},
    {'id': 'other_bank','name': 'Autre banque',                             'color': '#546E7A'},
  ];
}
