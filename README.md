# Heza Money

> **"Feel good about your money."**  
> Application de gestion financière personnelle pour jeunes professionnels burundais.

Heza Money est une application mobile Flutter, **100 % hors ligne**, conçue pour aider les utilisateurs à maîtriser leur budget, suivre leurs dépenses, gérer leurs comptes mobile money et apprendre à investir — le tout dans une interface glassmorphique premium.

---

## Aperçu

| Accueil | Budget | Comptes | Investir |
|---------|--------|---------|----------|
| Solde disponible en temps réel, règle 50/30/20, tendance 6 mois | Historique des transactions, ajout rapide revenu/dépense | Mobile money (Lumicash, Ecocash, Mobibank) + banques | Leçons financières progressives, badges de progression |

---

## Fonctionnalités

### Budget & Finances
- **Solde disponible** calculé en temps réel (salaire + revenus − dépenses)
- **Règle 50/30/20** — répartition automatique Besoins / Envies / Épargne avec barres de progression
- **Tendance 6 mois** — graphique de l'évolution des dépenses
- **Transactions** — ajout, catégorisation, notes, historique complet
- **Objectifs d'épargne** — création d'objectifs avec montant cible et suivi de progression
- **Export CSV** — téléchargement de l'historique des transactions

### Comptes & Mobile Money
- **Comptes multiples** — mobile money, banques, portefeuilles
- **Calculateur de frais** — tarifs officiels Lumitel/Lumipay pour Lumicash (transfert, réseau externe, retrait), Ecocash, Mobibank
- **Solde total consolidé** des comptes

### Apprentissage
- **Leçons financières** — 6 modules progressifs :
  - Les intérêts composés
  - La règle 50/30/20
  - L'épargne d'urgence
  - Introduction aux actions
  - La diversification
  - Investir local au Burundi
- **Badges de gamification** — récompenses débloquées à la progression
- **Leçon du jour** — prochaine leçon non complétée mise en avant sur l'accueil

### UX & Accessibilité
- **Thème système** — suit automatiquement le mode dark/light du téléphone, surridable manuellement
- **100 % hors ligne** — aucune connexion réseau, aucun compte requis
- **Langue française** — interface entièrement en français, formatage local BIF/FBu
- **Notifications** — rappel mensuel de saisie du budget

---

## Stack technique

| Couche | Technologie |
|--------|-------------|
| Framework | Flutter 3.x (Dart 3.5) |
| État | Riverpod 2.x + code generation |
| Base de données | Drift (SQLite) — schéma v3 |
| Navigation | go_router 14 |
| Graphiques | fl_chart 0.69 |
| Typographie | Inter (Google Fonts) |
| Notifications | flutter_local_notifications |
| Export | PDF + CSV |

### Architecture

```
lib/
├── core/
│   ├── router/          # go_router — routes et shell
│   ├── theme/           # Design tokens (HezaColors, HezaTheme, HezaBlur…)
│   ├── utils/           # Formatters, helpers
│   └── widgets/         # Composants glass (GlassCard, GlassBottomNavBar…)
├── data/
│   ├── database/        # Tables Drift, DAOs, migrations
│   └── models/          # Mobile money, leçons, catégories
├── features/
│   ├── home/            # Écran d'accueil — solde, stats, chart
│   ├── budget/          # Transactions, ajout, historique
│   ├── accounts/        # Comptes, calculateur de frais
│   ├── goals/           # Objectifs d'épargne
│   ├── invest/          # Leçons, détail leçon
│   ├── gamification/    # Badges
│   ├── profile/         # Paramètres, thème, notifications
│   └── onboarding/      # Premier lancement
└── shared/
    ├── providers/        # Riverpod providers globaux
    └── widgets/          # Widgets partagés (HezaCard, CategoryIcon…)
```

### Design system

L'application utilise un design system propriétaire **Premium Financial Dark** :

- **Glassmorphisme** — `BackdropFilter` + `ImageFilter.blur`, bordure hairline, top-edge highlight
- **Aurora Background** — blobs radials animés (7 s, `Curves.easeInOut`) pour les headers
- **Island NavBar** — barre flottante 36 px de rayon, ne touche pas les bords, glow vert ambiant
- **Palette** — deep navy `#020617`, surfaces `#0E1223`, vert financier `#22C55E`
- **Typographie** — Inter, poids 400/500/600/700/800, tabular figures sur les montants

---

## Démarrage

### Prérequis

- Flutter SDK >= 3.5.0
- Dart SDK >= 3.5.0
- Android SDK (API 24+)

### Installation

```bash
git clone https://github.com/francisdanzo/heza_money.git
cd heza_money
flutter pub get
```

### Génération de code (Drift + Riverpod)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Lancer en développement

```bash
flutter run
```

### Build release Android

```bash
flutter build apk --release
# APK → build/app/outputs/flutter-apk/app-release.apk
```

---

## Données & Vie privée

Toutes les données sont stockées **localement** dans une base SQLite sur l'appareil. Aucune donnée n'est envoyée sur un serveur. Aucun compte utilisateur. Aucune connexion réseau requise.

---

## Licence

Projet privé — tous droits réservés © 2026 Francis Danzo.
