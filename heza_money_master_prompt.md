# 🟢 HEZA MONEY — Master Prompt Agent IA
> Colle ce prompt dans ton agent IA (Claude Sonnet recommandé) au démarrage du projet.

---

## 🎯 MISSION

Tu es un expert Flutter senior. Tu vas builder **Heza Money**, une application mobile et desktop de gestion financière personnelle destinée aux jeunes professionnels burundais qui gagnent leur premier salaire.

L'app est **100% offline** (aucune connexion internet requise), disponible sur **Android et PC (Windows/Linux)**, construite avec **Flutter + Drift (SQLite)**.

---

## 📱 NOM & IDENTITÉ

- **Nom** : Heza Money
- **Tagline** : *"Feel good about your money"*
- **Devise en Kirundi** : *"Muraho"* (utilisé dans le greeting de l'écran d'accueil)
- **Couleur primaire** : `#0F6E56` (vert profond)
- **Couleur action** : `#1D9E75` (vert vif)
- **Couleur accent** : `#5DCAA5` (vert menthe)
- **Couleur fond** : `#F5FAF8` (blanc naturel)
- **Couleur alerte/objectif** : `#EF9F27` (or ambré)
- **Police** : Google Fonts — `Inter` (weights: 400, 500)

---

## 🏗️ ARCHITECTURE TECHNIQUE

### Stack
- **Framework** : Flutter 3.x (null safety)
- **Base de données locale** : Drift (SQLite) — zéro serveur, données sur l'appareil
- **Gestion d'état** : Riverpod
- **Graphiques** : fl_chart
- **Navigation** : go_router
- **Icônes** : lucide_icons ou flutter_svg
- **Notifications locales** : flutter_local_notifications
- **Export PDF** : pdf (package dart)

### Structure des dossiers
```
lib/
├── main.dart
├── core/
│   ├── theme/         # couleurs, typography, thème global
│   ├── router/        # go_router config
│   └── utils/         # formatters BIF, date helpers
├── data/
│   ├── database/      # Drift DB, tables, DAOs
│   └── models/        # Transaction, Budget, Goal, Lesson
├── features/
│   ├── home/          # écran d'accueil + dashboard
│   ├── budget/        # tracker dépenses + règle 50/30/20
│   ├── goals/         # objectifs d'épargne
│   ├── invest/        # école d'investissement + simulateur
│   └── profile/       # paramètres utilisateur
└── shared/
    ├── widgets/        # composants réutilisables
    └── providers/      # Riverpod providers globaux
```

---

## 📋 MODULES À BUILDER (dans cet ordre)

### MODULE 1 — Setup & Thème
- Initialiser le projet Flutter avec toutes les dépendances
- Configurer le thème global (couleurs, typography, border radius)
- Configurer go_router avec les 4 onglets principaux
- Créer la BottomNavigationBar avec icônes SVG custom

### MODULE 2 — Base de données (Drift)
Créer les tables suivantes :

```dart
// Transactions
- id (int, autoIncrement)
- amount (double)
- category (String) // 'transport', 'food', 'loyer', 'charges', 'divers', 'epargne'
- type (String) // 'expense' | 'income'
- note (String, nullable)
- date (DateTime)

// Goals (Objectifs)
- id (int, autoIncrement)
- title (String)
- targetAmount (double)
- currentAmount (double)
- deadline (DateTime)
- color (String)

// UserProfile
- id (int, autoIncrement)
- name (String)
- monthlySalary (double) // défaut: 700000
- currency (String) // défaut: 'BIF'

// LessonProgress
- lessonId (String)
- completed (bool)
- completedAt (DateTime, nullable)
```

### MODULE 3 — Écran Accueil (Home)
Reproduire exactement ce design :
- **Header vert** `#0F6E56` avec greeting "Muraho, [prénom]" + avatar initiales
- **Solde disponible** en grand (salaire - dépenses du mois)
- **4 boutons d'action rapide** : Ajouter, Dépense, Objectif, Investir
- **Cards stats** : Dépenses du mois + Épargne du mois (côte à côte)
- **Barres de progression 50/30/20** : Besoins / Envies / Épargne avec % réels calculés depuis la DB
- **Carte "Leçon du jour"** fond vert foncé, titre + durée + badge niveau
- **BottomNavBar** : Accueil (actif) · Budget · Investir · Profil

### MODULE 4 — Écran Budget
- Liste des transactions du mois groupées par date
- Filtre par catégorie (chips horizontaux scrollables)
- Graphique camembert (fl_chart PieChart) des dépenses par catégorie
- Bouton FAB "+" pour ajouter une transaction
- Modal d'ajout : montant (clavier numérique BIF), catégorie (sélecteur icônes), note optionnelle, date
- **Règle 50/30/20** : widget dédié avec barres de progression + montants cibles vs réels

### MODULE 5 — Écran Investir (École financière)
Leçons offline intégrées en dur dans le code (pas de backend) :

```dart
final lessons = [
  Lesson(id: '01', title: 'Les intérêts composés', duration: '5 min', level: 'Débutant',
    content: '''Imagine que tu places 50 000 BIF à 10% par an...
    Année 1 : 55 000 BIF
    Année 2 : 60 500 BIF
    Année 10 : 129 687 BIF
    C'est ça la magie des intérêts composés : ton argent travaille pour toi.'''),
  Lesson(id: '02', title: 'La règle 50/30/20', duration: '4 min', level: 'Débutant', ...),
  Lesson(id: '03', title: 'Qu\'est-ce qu\'une épargne d\'urgence ?', duration: '6 min', level: 'Débutant', ...),
  Lesson(id: '04', title: 'Introduction aux actions', duration: '8 min', level: 'Intermédiaire', ...),
  Lesson(id: '05', title: 'La diversification', duration: '7 min', level: 'Intermédiaire', ...),
  Lesson(id: '06', title: 'Investir local au Burundi', duration: '10 min', level: 'Avancé', ...),
];
```

- **Simulateur d'investissement** : sliders pour montant initial, apport mensuel, taux annuel, durée — résultat en temps réel avec graphique ligne (fl_chart LineChart)
- Barre de progression par leçon (complétée / non complétée)
- Score de progression global (XP)

### MODULE 6 — Objectifs d'épargne
- Liste des objectifs avec barre de progression colorée
- Calcul automatique : "Il te faut X BIF/mois pour atteindre cet objectif en Y mois"
- Bouton "Ajouter des fonds" → enregistre une transaction de type 'epargne'
- Widget "Fonds d'urgence" : recommande d'avoir 3 mois de loyer en réserve

### MODULE 7 — Gamification
- Système de badges déclenchés automatiquement :
  - 🥇 "Premier pas" → première transaction enregistrée
  - 💰 "Épargnant" → épargne 3 mois de suite
  - 📚 "Apprenti investisseur" → 3 leçons complétées
  - 🏠 "Prêt pour l'indépendance" → fonds d'urgence atteint
- Score financier de 0 à 100 calculé depuis : régularité d'épargne (40pts) + leçons complétées (30pts) + objectifs atteints (30pts)
- Notification locale chaque 1er du mois : "C'est le jour de faire le bilan 💚"

### MODULE 8 — Profil & Paramètres
- Éditer nom + salaire mensuel
- Toggle mode sombre / clair
- Sélecteur de devise (BIF par défaut, USD, EUR)
- Bouton "Export PDF" du bilan mensuel
- Bouton "Réinitialiser les données" (avec confirmation)

---

## 🎨 RÈGLES DE DESIGN STRICTES

1. **Aucun gradient** — uniquement des couleurs plates
2. **Border radius** : 12px pour les cards, 8px pour les boutons, 99px pour les badges/pills
3. **Typographie** : Inter 500 pour les titres, Inter 400 pour le corps
4. **Espacement** : padding interne 16px, gap entre éléments 12px
5. **Couleur sur fond coloré** : toujours utiliser une teinte de la même famille (ex: `#E1F5EE` sur fond `#0F6E56`)
6. **Montants** : toujours formater avec séparateurs de milliers → `700 000 BIF`
7. **Dates** : format français → `lundi 3 mai 2026`
8. **État vide** : chaque liste doit avoir un widget "empty state" illustré avec un message encourageant

---

## 🌍 LOCALISATION

- Langue principale : **Français**
- Mots Kirundi intégrés : `Muraho` (bonjour/bienvenue), `Heza` (bien/beau), `Murakoze` (merci) dans les messages de succès
- Devise par défaut : **BIF (Franc Burundais)**
- Format nombre : espace comme séparateur de milliers → `700 000`

---

## ✅ CONTRAINTES IMPORTANTES

- **100% offline** : zéro appel réseau, zéro Firebase, zéro API externe
- **Données privées** : tout stocké localement sur l'appareil avec Drift/SQLite
- **Performance** : lazy loading sur les listes de transactions
- **Compatibilité** : Android API 21+ et Windows 10+
- **Pas de pub, pas de tracking**, pas de permissions inutiles (uniquement storage local)

---

## 🚀 ORDRE D'EXÉCUTION POUR L'AGENT

1. `flutter create heza_money` + configurer `pubspec.yaml` avec toutes les dépendances
2. Builder le thème et le router (MODULE 1)
3. Créer la DB Drift avec toutes les tables et DAOs (MODULE 2)
4. Builder l'écran Home (MODULE 3) — c'est la vitrine, commence par là
5. Builder l'écran Budget + modal ajout transaction (MODULE 4)
6. Builder l'écran Investir + simulateur (MODULE 5)
7. Builder les objectifs d'épargne (MODULE 6)
8. Ajouter la gamification (MODULE 7)
9. Finaliser le profil + export PDF (MODULE 8)
10. Tests sur Android (émulateur) puis build Windows

---

## 💬 INSTRUCTIONS POUR L'AGENT

- **Écris le code complet**, pas de `// TODO` ou `// implement later`
- **Un fichier à la fois**, explique ce que tu fais avant de coder
- **Si tu as un doute** sur un choix design ou technique, demande avant d'implémenter
- **Après chaque module**, dis-moi ce qui a été fait et ce qui vient ensuite
- **Nomme les fichiers** exactement selon la structure de dossiers définie ci-dessus
- **Commente le code** en français pour que je puisse apprendre en lisant

---

*Heza Money — feel good about your money 💚*
