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
  ],
  daos: [
    TransactionsDao,
    GoalsDao,
    UserProfileDao,
    LessonProgressDao,
    EarnedBadgesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Version du schéma de la base de données
  @override
  int get schemaVersion => 1;

  /// Migrations futures — vide pour la v1
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        // Création initiale de toutes les tables
        await m.createAll();

        // Insertion du profil utilisateur par défaut
        await into(userProfile).insert(
          const UserProfileCompanion(
            name: Value('Utilisateur'),
            monthlySalary: Value(700000.0),
            currency: Value('BIF'),
            themeMode: Value(0),
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migrations futures ici
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
