import 'package:drift/drift.dart';

/// Table des transactions (dépenses et revenus)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  // 'expense' | 'income'
  TextColumn get type => text().withDefault(const Constant('expense'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  // Mois au format 'YYYY-MM' pour filtrage rapide
  TextColumn get monthKey => text().withLength(min: 7, max: 7)();
}

/// Table des objectifs d'épargne
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get deadline => dateTime()();
  // Couleur hex → ex: '#1D9E75'
  TextColumn get color => text().withDefault(const Constant('#1D9E75'))();
  DateTimeColumn get createdAt => dateTime()();
  // true si l'objectif est atteint
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

/// Profil utilisateur (un seul enregistrement avec id=1)
class UserProfile extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get monthlySalary => real().withDefault(const Constant(700000.0))();
  // 'BIF', 'USD', 'EUR'
  TextColumn get currency => text().withDefault(const Constant('BIF'))();
  // Mode sombre : 0=clair, 1=sombre, 2=système
  IntColumn get themeMode => integer().withDefault(const Constant(0))();
}

/// Progression des leçons financières
class LessonProgress extends Table {
  // ID de la leçon → '01', '02', etc.
  TextColumn get lessonId => text().withLength(min: 2, max: 10)();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // La clé primaire est l'ID de la leçon (une seule entrée par leçon)
  @override
  Set<Column> get primaryKey => {lessonId};
}

/// Table des badges gagnés (gamification)
class EarnedBadges extends Table {
  // ID du badge → 'first_step', 'saver', 'learner', 'independence'
  TextColumn get badgeId => text().withLength(min: 1, max: 50)();
  DateTimeColumn get earnedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {badgeId};
}
