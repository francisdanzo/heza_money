import 'package:drift/drift.dart';
import 'app_database.dart';
import 'tables.dart';
// ignore_for_file: unused_import

part 'daos.g.dart';

/// DAO (Data Access Object) pour les transactions
/// Toutes les opérations CRUD sur la table Transactions
@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  // --- Requêtes de lecture ---

  /// Toutes les transactions triées par date décroissante
  Stream<List<Transaction>> watchAll() {
    return (select(db.transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Transactions du mois courant (filtrage par monthKey)
  Stream<List<Transaction>> watchCurrentMonth() {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return (select(db.transactions)
          ..where((t) => t.monthKey.equals(key))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Transactions d'un mois spécifique
  Stream<List<Transaction>> watchMonth(int year, int month) {
    final key = '$year-${month.toString().padLeft(2, '0')}';
    return (select(db.transactions)
          ..where((t) => t.monthKey.equals(key))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Transactions filtrées par catégorie pour le mois courant
  Stream<List<Transaction>> watchByCategory(String category) {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return (select(db.transactions)
          ..where((t) => t.monthKey.equals(key) & t.category.equals(category))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// Total des dépenses du mois courant
  Future<double> getTotalExpensesCurrentMonth() async {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final result = await (select(db.transactions)
          ..where(
              (t) => t.monthKey.equals(key) & t.type.equals('expense')))
        .get();
    return result.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Total des revenus du mois courant
  Future<double> getTotalIncomeCurrentMonth() async {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final result = await (select(db.transactions)
          ..where(
              (t) => t.monthKey.equals(key) & t.type.equals('income')))
        .get();
    return result.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Total épargne du mois courant (catégorie 'epargne')
  Future<double> getTotalSavingsCurrentMonth() async {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final result = await (select(db.transactions)
          ..where((t) =>
              t.monthKey.equals(key) &
              t.category.equals('epargne') &
              t.type.equals('expense')))
        .get();
    return result.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Dépenses groupées par catégorie pour le mois courant
  Future<Map<String, double>> getExpensesByCategory() async {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final rows = await (select(db.transactions)
          ..where(
              (t) => t.monthKey.equals(key) & t.type.equals('expense')))
        .get();

    final map = <String, double>{};
    for (final t in rows) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  /// Vérifie si au moins une transaction existe (pour badge premier pas)
  Future<bool> hasAnyTransaction() async {
    final count = await (select(db.transactions)).get();
    return count.isNotEmpty;
  }

  /// Vérifie si 10 transactions ou plus existent
  Future<bool> hasTenTransactions() async {
    final rows = await (select(db.transactions)).get();
    return rows.length >= 10;
  }

  /// Vérifie si au moins un revenu existe
  Future<bool> hasIncomeTransaction() async {
    final rows = await (select(db.transactions)
          ..where((t) => t.type.equals('income')))
        .get();
    return rows.isNotEmpty;
  }

  /// Retourne le total des dépenses d'un mois spécifique
  Future<double> getTotalExpensesForMonth(String monthKey) async {
    final rows = await (select(db.transactions)
          ..where((t) => t.monthKey.equals(monthKey) & t.type.equals('expense')))
        .get();
    return rows.fold<double>(0.0, (s, t) => s + t.amount);
  }

  /// Retourne les dépenses des 6 derniers mois (clé → montant)
  Future<Map<String, double>> getLastSixMonthsExpenses() async {
    final now = DateTime.now();
    final result = <String, double>{};
    for (int i = 5; i >= 0; i--) {
      var month = now.month - i;
      var year  = now.year;
      if (month <= 0) { month += 12; year -= 1; }
      final key = '$year-${month.toString().padLeft(2, '0')}';
      result[key] = await getTotalExpensesForMonth(key);
    }
    return result;
  }

  /// Vérifie si l'utilisateur a épargné 3 mois de suite
  Future<bool> hasSaved3ConsecutiveMonths() async {
    final now = DateTime.now();
    for (int i = 1; i <= 3; i++) {
      final month = now.month - i;
      final year = month <= 0 ? now.year - 1 : now.year;
      final m = month <= 0 ? month + 12 : month;
      final key = '$year-${m.toString().padLeft(2, '0')}';
      final savings = await (select(db.transactions)
            ..where((t) =>
                t.monthKey.equals(key) &
                t.category.equals('epargne')))
          .get();
      if (savings.isEmpty) return false;
    }
    return true;
  }

  // --- Opérations d'écriture ---

  /// Ajoute une nouvelle transaction
  Future<int> addTransaction(TransactionsCompanion entry) {
    return into(db.transactions).insert(entry);
  }

  /// Met à jour une transaction existante
  Future<bool> updateTransaction(Transaction transaction) {
    return update(db.transactions).replace(transaction);
  }

  /// Supprime une transaction par ID
  Future<int> deleteTransaction(int id) {
    return (delete(db.transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Supprime toutes les transactions (réinitialisation)
  Future<int> deleteAll() {
    return delete(db.transactions).go();
  }
}

/// DAO pour les objectifs d'épargne
@DriftAccessor(tables: [Goals])
class GoalsDao extends DatabaseAccessor<AppDatabase> with _$GoalsDaoMixin {
  GoalsDao(super.db);

  /// Flux de tous les objectifs
  Stream<List<Goal>> watchAll() {
    return (select(db.goals)
          ..orderBy([(g) => OrderingTerm.asc(g.deadline)]))
        .watch();
  }

  /// Un objectif par ID
  Future<Goal?> getById(int id) async {
    return (select(db.goals)..where((g) => g.id.equals(id))).getSingleOrNull();
  }

  /// Crée un objectif
  Future<int> addGoal(GoalsCompanion entry) {
    return into(db.goals).insert(entry);
  }

  /// Met à jour le montant courant d'un objectif
  Future<void> updateCurrentAmount(int id, double amount) async {
    await (update(db.goals)..where((g) => g.id.equals(id)))
        .write(GoalsCompanion(
      currentAmount: Value(amount),
      isCompleted: Value(amount >= (await getById(id))!.targetAmount),
    ));
  }

  /// Met à jour un objectif complet
  Future<bool> updateGoal(Goal goal) {
    return update(db.goals).replace(goal);
  }

  /// Supprime un objectif
  Future<int> deleteGoal(int id) {
    return (delete(db.goals)..where((g) => g.id.equals(id))).go();
  }

  /// Nombre d'objectifs atteints
  Future<int> getCompletedCount() async {
    final all = await (select(db.goals)
          ..where((g) => g.isCompleted.equals(true)))
        .get();
    return all.length;
  }

  /// Supprime tous les objectifs (réinitialisation)
  Future<int> deleteAll() {
    return delete(db.goals).go();
  }
}

/// DAO pour le profil utilisateur
@DriftAccessor(tables: [UserProfile])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  /// Retourne le profil (crée un profil par défaut s'il n'existe pas)
  Future<UserProfileData?> getProfile() async {
    return (select(db.userProfile)).getSingleOrNull();
  }

  /// Stream du profil
  Stream<UserProfileData?> watchProfile() {
    return (select(db.userProfile)).watchSingleOrNull();
  }

  /// Crée le profil initial
  Future<int> createProfile(UserProfileCompanion entry) {
    return into(db.userProfile).insert(entry);
  }

  /// Met à jour le profil
  Future<void> updateProfile(UserProfileCompanion entry) async {
    final existing = await getProfile();
    if (existing != null) {
      await (update(db.userProfile)..where((p) => p.id.equals(existing.id)))
          .write(entry);
    }
  }

  /// Supprime le profil (réinitialisation)
  Future<int> deleteAll() {
    return delete(db.userProfile).go();
  }
}

/// DAO pour la progression des leçons
@DriftAccessor(tables: [LessonProgress])
class LessonProgressDao extends DatabaseAccessor<AppDatabase>
    with _$LessonProgressDaoMixin {
  LessonProgressDao(super.db);

  /// Toutes les progressions
  Stream<List<LessonProgressData>> watchAll() {
    return select(db.lessonProgress).watch();
  }

  /// Progression d'une leçon
  Future<LessonProgressData?> getByLessonId(String lessonId) async {
    return (select(db.lessonProgress)
          ..where((l) => l.lessonId.equals(lessonId)))
        .getSingleOrNull();
  }

  /// Marque une leçon comme complétée
  Future<void> markCompleted(String lessonId) async {
    await into(db.lessonProgress).insertOnConflictUpdate(
      LessonProgressCompanion(
        lessonId: Value(lessonId),
        completed: const Value(true),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Nombre de leçons complétées
  Future<int> getCompletedCount() async {
    final all = await (select(db.lessonProgress)
          ..where((l) => l.completed.equals(true)))
        .get();
    return all.length;
  }

  /// Supprime toutes les progressions (réinitialisation)
  Future<int> deleteAll() {
    return delete(db.lessonProgress).go();
  }
}

/// DAO pour les badges
@DriftAccessor(tables: [EarnedBadges])
class EarnedBadgesDao extends DatabaseAccessor<AppDatabase>
    with _$EarnedBadgesDaoMixin {
  EarnedBadgesDao(super.db);

  Stream<List<EarnedBadge>> watchAll() {
    return select(db.earnedBadges).watch();
  }

  Future<bool> hasBadge(String badgeId) async {
    final b = await (select(db.earnedBadges)
          ..where((b) => b.badgeId.equals(badgeId)))
        .getSingleOrNull();
    return b != null;
  }

  Future<void> awardBadge(String badgeId) async {
    await into(db.earnedBadges).insertOnConflictUpdate(
      EarnedBadgesCompanion(
        badgeId: Value(badgeId),
        earnedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteAll() {
    return delete(db.earnedBadges).go();
  }
}

/// DAO pour les limites budgétaires par catégorie
@DriftAccessor(tables: [CategoryBudgets])
class CategoryBudgetsDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryBudgetsDaoMixin {
  CategoryBudgetsDao(super.db);

  Stream<List<CategoryBudget>> watchAll() =>
      select(db.categoryBudgets).watch();

  Future<CategoryBudget?> getByCategory(String category) async {
    return (select(db.categoryBudgets)
          ..where((c) => c.category.equals(category)))
        .getSingleOrNull();
  }

  Future<void> setLimit(String category, double amount) async {
    await into(db.categoryBudgets).insertOnConflictUpdate(
      CategoryBudgetsCompanion(
        category: Value(category),
        limitAmount: Value(amount),
      ),
    );
  }

  Future<void> removeLimit(String category) async {
    await (delete(db.categoryBudgets)
          ..where((c) => c.category.equals(category)))
        .go();
  }

  Future<int> deleteAll() => delete(db.categoryBudgets).go();
}

/// DAO pour les comptes (banque, mobile money, cash)
@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Stream<List<Account>> watchAll() {
    return (select(db.accounts)
          ..where((a) => a.isActive.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
        .watch();
  }

  Future<List<Account>> getAll() {
    return (select(db.accounts)
          ..where((a) => a.isActive.equals(true)))
        .get();
  }

  Future<Account?> getById(int id) async {
    return (select(db.accounts)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> addAccount(AccountsCompanion entry) {
    return into(db.accounts).insert(entry);
  }

  Future<bool> updateAccount(Account account) {
    return update(db.accounts).replace(account);
  }

  Future<void> updateBalance(int id, double newBalance) async {
    await (update(db.accounts)..where((a) => a.id.equals(id)))
        .write(AccountsCompanion(balance: Value(newBalance)));
  }

  Future<int> deleteAccount(int id) {
    return (delete(db.accounts)..where((a) => a.id.equals(id))).go();
  }

  Future<double> getTotalBalance() async {
    final all = await getAll();
    return all.fold<double>(0.0, (s, a) => s + a.balance);
  }

  Future<int> deleteAll() => delete(db.accounts).go();
}
