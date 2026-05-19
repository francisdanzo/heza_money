import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos.dart';

part 'app_database.g.dart';

/// Base de données principale Heza Money (Drift + SQLite)
/// 100% offline — stockée dans le répertoire documents de l'appareil
@DriftDatabase(
  tables: [
    Transactions,
    Goals,
    UserProfile,
    LessonProgress,
    EarnedBadges,
    CategoryBudgets,
  ],
  daos: [
    TransactionsDao,
    GoalsDao,
    UserProfileDao,
    LessonProgressDao,
    EarnedBadgesDao,
    CategoryBudgetsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(goals, goals.icon);
          await m.addColumn(userProfile, userProfile.notificationsEnabled);
          await m.createTable(categoryBudgets);
        }
      },
    );
  }
}

/// Ouvre la connexion SQLite sur le fichier local de l'appareil
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'heza_money.db'));
    return NativeDatabase.createInBackground(file);
  });
}
