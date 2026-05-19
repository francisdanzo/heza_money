import '../../data/database/daos.dart';

/// Vérifie et attribue les badges selon l'état actuel de la base de données.
/// Retourne la liste des IDs des badges nouvellement débloqués.
class BadgeService {
  static Future<List<String>> checkAll({
    required EarnedBadgesDao badgesDao,
    required TransactionsDao transDao,
    required GoalsDao goalsDao,
    required LessonProgressDao lessonDao,
  }) async {
    final newBadges = <String>[];

    Future<void> award(String id) async {
      if (!await badgesDao.hasBadge(id)) {
        await badgesDao.awardBadge(id);
        newBadges.add(id);
      }
    }

    // first_step — 1ère transaction
    if (await transDao.hasAnyTransaction()) await award('first_step');

    // ten_transactions — 10 transactions
    if (await transDao.hasTenTransactions()) await award('ten_transactions');

    // first_income — 1er revenu
    if (await transDao.hasIncomeTransaction()) await award('first_income');

    // saver — 3 mois d'épargne consécutifs
    if (await transDao.hasSaved3ConsecutiveMonths()) await award('saver');

    // learner — 3 leçons complétées
    if (await lessonDao.getCompletedCount() >= 3) await award('learner');

    // all_lessons — toutes les leçons complétées (6)
    if (await lessonDao.getCompletedCount() >= 6) await award('all_lessons');

    // first_goal — 1er objectif atteint
    if (await goalsDao.getCompletedCount() >= 1) await award('independence');

    // three_goals — 3 objectifs atteints
    if (await goalsDao.getCompletedCount() >= 3) await award('three_goals');

    // goal_halfway — un objectif atteint à 50%+
    final allGoals = await goalsDao.watchAll().first;
    final hasHalfway = allGoals.any(
      (g) => g.targetAmount > 0 && g.currentAmount / g.targetAmount >= 0.5,
    );
    if (hasHalfway) await award('goal_halfway');

    return newBadges;
  }
}
