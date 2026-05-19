import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos.dart';

/// Provider singleton de la base de données Drift
/// Toute l'app utilise cette instance unique
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  // Fermer la DB proprement quand le provider est détruit
  ref.onDispose(db.close);
  return db;
});

/// Provider du DAO transactions
final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  return ref.watch(databaseProvider).transactionsDao;
});

/// Provider du DAO goals
final goalsDaoProvider = Provider<GoalsDao>((ref) {
  return ref.watch(databaseProvider).goalsDao;
});

/// Provider du DAO profil utilisateur
final userProfileDaoProvider = Provider<UserProfileDao>((ref) {
  return ref.watch(databaseProvider).userProfileDao;
});

/// Provider du DAO progression leçons
final lessonProgressDaoProvider = Provider<LessonProgressDao>((ref) {
  return ref.watch(databaseProvider).lessonProgressDao;
});

/// Provider du DAO badges
final earnedBadgesDaoProvider = Provider<EarnedBadgesDao>((ref) {
  return ref.watch(databaseProvider).earnedBadgesDao;
});

/// Provider du DAO limites budgétaires
final categoryBudgetsDaoProvider = Provider<CategoryBudgetsDao>((ref) {
  return ref.watch(databaseProvider).categoryBudgetsDao;
});

// --- Streams de données réactives ---

/// Stream du profil utilisateur courant
final userProfileProvider = StreamProvider<UserProfileData?>((ref) {
  return ref.watch(userProfileDaoProvider).watchProfile();
});

/// Stream des transactions du mois courant
final currentMonthTransactionsProvider =
    StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionsDaoProvider).watchCurrentMonth();
});

/// Stream de tous les objectifs
final goalsProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(goalsDaoProvider).watchAll();
});

/// Stream de la progression des leçons
final lessonProgressProvider =
    StreamProvider<List<LessonProgressData>>((ref) {
  return ref.watch(lessonProgressDaoProvider).watchAll();
});

/// Stream des badges gagnés
final earnedBadgesProvider = StreamProvider<List<EarnedBadge>>((ref) {
  return ref.watch(earnedBadgesDaoProvider).watchAll();
});

/// Stream des limites budgétaires par catégorie
final categoryBudgetsProvider = StreamProvider<List<CategoryBudget>>((ref) {
  return ref.watch(categoryBudgetsDaoProvider).watchAll();
});

// --- Providers calculés ---

/// Total dépenses du mois courant
final monthlyExpensesProvider = FutureProvider<double>((ref) {
  return ref.watch(transactionsDaoProvider).getTotalExpensesCurrentMonth();
});

/// Total épargne du mois courant
final monthlySavingsProvider = FutureProvider<double>((ref) {
  return ref.watch(transactionsDaoProvider).getTotalSavingsCurrentMonth();
});

/// Dépenses par catégorie du mois courant
final expensesByCategoryProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(transactionsDaoProvider).getExpensesByCategory();
});

/// Score financier global (0–100)
final financialScoreProvider = FutureProvider<int>((ref) async {
  final lessonDao = ref.watch(lessonProgressDaoProvider);
  final goalsDao = ref.watch(goalsDaoProvider);
  final transDao = ref.watch(transactionsDaoProvider);

  // 40 pts — régularité épargne (3 mois consécutifs)
  final hasSaved = await transDao.hasSaved3ConsecutiveMonths();
  final savingsScore = hasSaved ? 40 : 0;

  // 30 pts — leçons complétées (5 pts par leçon, max 30)
  final lessonsCompleted = await lessonDao.getCompletedCount();
  final lessonsScore = (lessonsCompleted * 5).clamp(0, 30);

  // 30 pts — objectifs atteints (10 pts par objectif, max 30)
  final goalsCompleted = await goalsDao.getCompletedCount();
  final goalsScore = (goalsCompleted * 10).clamp(0, 30);

  return (savingsScore + lessonsScore + goalsScore).clamp(0, 100).toInt();
});

/// Dépenses des 6 derniers mois (pour le graphique de tendance)
final sixMonthExpensesProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(transactionsDaoProvider).getLastSixMonthsExpenses();
});

/// Mois sélectionné dans l'écran Budget (navigation historique)
final selectedBudgetMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Transactions du mois sélectionné (réactif au changement de mois)
final selectedMonthTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final month = ref.watch(selectedBudgetMonthProvider);
  return ref.watch(transactionsDaoProvider).watchMonth(month.year, month.month);
});

/// Provider pour le mode thème (0=light, 1=dark, 2=system)
final themeModeProvider = StateProvider<int>((ref) => 0);
