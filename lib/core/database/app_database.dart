import 'package:drift/drift.dart';
import 'package:simple_budgeting_app/core/database/tables/app_settings.dart';
import 'package:simple_budgeting_app/core/database/tables/income_tables.dart';

part 'app_database.g.dart';

/// The single local SQLite database of the app.
///
/// The [QueryExecutor] is injected so production uses a file database
/// (`drift_flutter`) and tests use an in-memory or temp-file database.
@DriftDatabase(
  tables: [AppSettings, IncomeSources, IncomeEntries, BalanceAnchors],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Bump when the schema changes, add a step to [migration], and dump the
  /// new schema: `dart run drift_dev schema dump
  /// lib/core/database/app_database.dart drift_schemas/`.
  /// 1: app_settings. 2: income_sources, income_entries, balance_anchors.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(incomeSources);
        await m.createTable(incomeEntries);
        await m.createTable(balanceAnchors);
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
