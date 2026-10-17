import 'package:drift/drift.dart';
import 'package:simple_budgeting_app/core/database/tables/app_settings.dart';

part 'app_database.g.dart';

/// The single local SQLite database of the app.
///
/// The [QueryExecutor] is injected so production uses a file database
/// (`drift_flutter`) and tests use an in-memory or temp-file database.
@DriftDatabase(tables: [AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump when the schema changes and add a step to [migration].
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        // Future phases: add `onUpgrade: stepByStep(...)` here.
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
