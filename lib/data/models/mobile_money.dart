// Modèle de frais pour les opérations mobile money / bancaires au Burundi
// Les tarifs sont indicatifs — vérifier avec votre opérateur.

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
  final List<FeeTier> transferFees;
  final List<FeeTier> withdrawalFees;
  final String? depositNote; // note sur les dépôts

  const MobileMoneyProvider({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    required this.color,
    required this.transferFees,
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
  double withdrawalFee(double amount) => calculateFee(withdrawalFees, amount);
}

class MobileMoneyData {
  static const List<MobileMoneyProvider> providers = [
    MobileMoneyProvider(
      id: 'lumicash',
      name: 'Lumicash',
      shortName: 'Lumicash',
      type: 'mobile_money',
      color: '#E8A020',
      depositNote: 'Dépôt gratuit chez les agents Lumitel',
      transferFees: [
        FeeTier(minAmount: 500,    maxAmount: 5000,    fee: 50),
        FeeTier(minAmount: 5001,   maxAmount: 10000,   fee: 100),
        FeeTier(minAmount: 10001,  maxAmount: 25000,   fee: 200),
        FeeTier(minAmount: 25001,  maxAmount: 50000,   fee: 400),
        FeeTier(minAmount: 50001,  maxAmount: 100000,  fee: 700),
        FeeTier(minAmount: 100001, maxAmount: 250000,  fee: 1500),
        FeeTier(minAmount: 250001, maxAmount: 500000,  fee: 2500),
        FeeTier(minAmount: 500001, maxAmount: 1000000, fee: 5000),
      ],
      withdrawalFees: [
        FeeTier(minAmount: 500,    maxAmount: 5000,    fee: 100),
        FeeTier(minAmount: 5001,   maxAmount: 10000,   fee: 200),
        FeeTier(minAmount: 10001,  maxAmount: 25000,   fee: 350),
        FeeTier(minAmount: 25001,  maxAmount: 50000,   fee: 600),
        FeeTier(minAmount: 50001,  maxAmount: 100000,  fee: 1000),
        FeeTier(minAmount: 100001, maxAmount: 250000,  fee: 2000),
        FeeTier(minAmount: 250001, maxAmount: 500000,  fee: 4000),
        FeeTier(minAmount: 500001, maxAmount: 1000000, fee: 7500),
      ],
    ),

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

  // Banques disponibles au Burundi (pas de frais intégrés — info seulement)
  static const List<Map<String, String>> banks = [
    {'id': 'bcb',     'name': 'BCB (Banque Commerciale du Burundi)',  'color': '#1565C0'},
    {'id': 'bancobu', 'name': 'BANCOBU',                              'color': '#6A1B9A'},
    {'id': 'ibb',     'name': 'IBB (Interbank Burundi)',              'color': '#AD1457'},
    {'id': 'brd',     'name': 'BRD (Banque Régionale du Développement)', 'color': '#00695C'},
    {'id': 'cospecbu','name': 'COSPECBU',                             'color': '#E65100'},
    {'id': 'other_bank','name': 'Autre banque',                       'color': '#546E7A'},
  ];
}
