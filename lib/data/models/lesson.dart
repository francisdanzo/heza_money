/// Modèle d'une leçon financière (données statiques offline)
class Lesson {
  final String id;
  final String title;
  final String duration;
  final String level; // 'Débutant', 'Intermédiaire', 'Avancé'
  final String content;
  final String summary; // résumé court pour la card
  final String emoji;

  const Lesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.level,
    required this.content,
    required this.summary,
    required this.emoji,
  });
}

/// Toutes les leçons financières intégrées en dur — 100% offline
class LessonsData {
  LessonsData._();

  static const List<Lesson> all = [
    Lesson(
      id: '01',
      title: 'Les intérêts composés',
      duration: '5 min',
      level: 'Débutant',
      emoji: '📈',
      summary: 'Découvre comment ton argent peut travailler pour toi.',
      content: '''
Les intérêts composés sont la 8ème merveille du monde.

Imagine que tu places 50 000 BIF à 10% par an :

• Année 1 : 55 000 BIF
• Année 2 : 60 500 BIF
• Année 5 : 80 526 BIF
• Année 10 : 129 687 BIF
• Année 20 : 336 375 BIF

C'est ça la magie des intérêts composés : ton argent génère des intérêts, et ces intérêts génèrent eux-mêmes des intérêts. Plus tu commences tôt, plus l'effet est puissant.

La formule : A = P × (1 + r)ⁿ
• P = montant initial
• r = taux annuel (ex: 0.10 pour 10%)
• n = nombre d'années

💡 Conseil Heza : Commence petit mais commence maintenant. Même 10 000 BIF par mois peut devenir plus de 2 000 000 BIF en 10 ans à 8% d'intérêt.

Murakoze d'avoir lu cette leçon !
''',
    ),
    Lesson(
      id: '02',
      title: 'La règle 50/30/20',
      duration: '4 min',
      level: 'Débutant',
      emoji: '📊',
      summary: 'Une méthode simple pour répartir ton salaire chaque mois.',
      content: '''
La règle 50/30/20 est la méthode de budgétisation la plus simple et efficace.

Si ton salaire est de 700 000 BIF :

50% — LES BESOINS (350 000 BIF)
Ce sont tes dépenses indispensables :
• Loyer : ~200 000 BIF
• Nourriture : ~80 000 BIF
• Transport : ~40 000 BIF
• Charges (eau, électricité) : ~30 000 BIF

30% — LES ENVIES (210 000 BIF)
Ce que tu veux mais dont tu n'as pas besoin :
• Sorties, restaurants
• Vêtements non essentiels
• Divertissement
• Abonnements

20% — L'ÉPARGNE (140 000 BIF)
Priorité absolue — paie-toi en premier !
• Fonds d'urgence
• Objectifs d'épargne
• Investissements futurs

💡 Conseil Heza : Vire les 20% dès que ton salaire arrive. Traite l'épargne comme une facture obligatoire.

La régularité bat la quantité. Mieux vaut épargner 50 000 BIF chaque mois que 600 000 BIF une fois par an.
''',
    ),
    Lesson(
      id: '03',
      title: "L'épargne d'urgence",
      duration: '6 min',
      level: 'Débutant',
      emoji: '🛡️',
      summary: 'Ton filet de sécurité face aux imprévus de la vie.',
      content: '''
L'épargne d'urgence est ton bouclier financier.

Pourquoi en avoir une ?
La vie est imprévisible : maladie, perte d'emploi, réparation urgente... Sans filet de sécurité, tu te retrouves à emprunter (souvent à des taux élevés) ou à vendre tes biens.

Combien faut-il épargner ?
La règle standard : 3 à 6 mois de tes dépenses essentielles.

Exemple pour 700 000 BIF de salaire :
• Dépenses essentielles (~50%) = 350 000 BIF/mois
• Fonds d'urgence minimum = 1 050 000 BIF (3 mois)
• Fonds d'urgence idéal = 2 100 000 BIF (6 mois)

Où garder cet argent ?
• Sur un compte épargne séparé
• Accessible rapidement (pas dans des investissements bloqués)
• Ne pas y toucher sauf vraie urgence

Comment y arriver ?
1. Commence avec 10 000 BIF/mois
2. Augmente progressivement
3. Utilise chaque bonus ou rentrée extra

💡 Conseil Heza : Crée un objectif "Fonds d'urgence" dans l'app et vise d'abord 1 mois de dépenses. Un petit pas à la fois !
''',
    ),
    Lesson(
      id: '04',
      title: 'Introduction aux actions',
      duration: '8 min',
      level: 'Intermédiaire',
      emoji: '📉',
      summary: 'Comprendre les marchés boursiers sans jargon compliqué.',
      content: '''
Qu'est-ce qu'une action ?

Quand une entreprise a besoin d'argent pour grandir, elle peut vendre des "parts" d'elle-même au public. Ces parts s'appellent des actions.

Si tu achètes une action d'une entreprise :
• Tu deviens copropriétaire (même à 0,001%)
• Si l'entreprise fait des bénéfices → la valeur monte
• Si l'entreprise va mal → la valeur baisse
• Certaines entreprises partagent leurs bénéfices : ce sont les dividendes

Exemple concret :
Tu achètes 1 action d'une entreprise à 10 000 BIF.
• L'entreprise double ses ventes
• Ton action vaut maintenant 15 000 BIF
• Gain : +5 000 BIF (50%) sans rien faire de plus

Les risques :
• La valeur peut aussi baisser
• Aucune garantie de gains
• Volatilité à court terme

Les principes de base :
1. N'investis que ce que tu peux te permettre de perdre
2. Vision long terme (5+ ans)
3. Ne mets pas tous tes œufs dans le même panier
4. Évite de réagir à la panique des marchés

Où investir au Burundi ?
La Bourse Régionale des Valeurs Mobilières (BRVM) couvre l'Afrique de l'Ouest. Pour l'Afrique de l'Est, des options comme des fonds communs de placement locaux existent.

💡 Conseil Heza : Commence par comprendre une entreprise que tu connais avant d'investir. N'investis pas dans ce que tu ne comprends pas.
''',
    ),
    Lesson(
      id: '05',
      title: 'La diversification',
      duration: '7 min',
      level: 'Intermédiaire',
      emoji: '🎯',
      summary: 'Ne jamais mettre tous ses œufs dans le même panier.',
      content: '''
"Ne mets pas tous tes œufs dans le même panier."

C'est le principe de base de la diversification.

Pourquoi diversifier ?
Si tu mets tout ton argent dans une seule chose et que ça va mal, tu perds tout. En répartissant, si un placement baisse, les autres peuvent compenser.

Les différentes classes d'actifs :
1. Épargne liquide (compte épargne) — Sécurisé, faible rendement
2. Immobilier — Stable, rentabilité locative
3. Actions — Potentiel élevé, risque élevé
4. Obligations — Intermédiaire, plus stable
5. Or/Métaux précieux — Valeur refuge

Un portefeuille diversifié pour débutant :
• 50% — Épargne sécurisée (fonds d'urgence)
• 30% — Immobilier ou fonds immobilier
• 20% — Actions (fonds indiciels)

Diversification dans les actions :
• Différents secteurs (technologie, santé, alimentation...)
• Différents pays (ne pas se limiter au marché local)
• Différentes tailles d'entreprises

💡 Conseil Heza : Commence par construire ton fonds d'urgence (sécurité) avant de diversifier dans des placements plus risqués. La base avant le sommet !
''',
    ),
    Lesson(
      id: '06',
      title: 'Investir local au Burundi',
      duration: '10 min',
      level: 'Avancé',
      emoji: '🇧🇮',
      summary: 'Opportunités et stratégies d\'investissement au Burundi.',
      content: '''
Les opportunités d'investissement local au Burundi

Le Burundi offre des opportunités uniques pour les investisseurs locaux.

1. L'IMMOBILIER LOCATIF
Le secteur le plus accessible :
• Achat de terrain + construction progressive
• Rendement locatif : 8 à 15% par an à Bujumbura
• Plus-value sur le long terme
• Conseil : commence par un terrain en périphérie

2. L'AGRICULTURE
Secteur clé de l'économie burundaise :
• Café, thé, cacao (cultures d'exportation)
• Maraîchage pour le marché local
• Coopératives agricoles
• Possibilité de petit investissement via groupements

3. LE COMMERCE
• Boutique / kiosque dans un quartier animé
• Import-export (partenariat EAC)
• Commerce en ligne (croissance rapide)
• Franchise locale

4. LES MICROFINANCES & COOPÉRATIVES
• WISE (Women Initiatives for Self Empowerment)
• Coopératives d'épargne et de crédit (COOPEC)
• Taux d'intérêt sur épargne souvent meilleurs que les banques classiques

5. LES TONTINES (IBIMINA)
Tradition burundaise de finance communautaire :
• Groupe de personnes qui cotisent régulièrement
• Chacun reçoit la cagnotte à tour de rôle
• Discipline financière collective
• Zéro frais bancaires

6. LES OBLIGATIONS D'ÉTAT
• Émises par la Banque de la République du Burundi (BRB)
• Taux fixe garanti par l'État
• Placement sécurisé avec rendement prévisible

💡 Conseil Heza : Commence par ce que tu connais. Si tu connais l'agriculture, investis là-dedans. La meilleure opportunité est celle que tu comprends.

Points de vigilance :
• Méfie-toi des "opportunités" avec des rendements irréalistes
• Formalise toujours les contrats par écrit
• Consulte un conseiller financier agréé avant de gros investissements
''',
    ),
  ];

  /// Retourne une leçon par son ID
  static Lesson? findById(String id) {
    try {
      return all.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
