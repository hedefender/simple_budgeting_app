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
  /// 3: income_entries.actual_date.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(incomeSources);
        await m.createTable(incomeEntries);
        await m.createTable(balanceAnchors);
      }
      // A v1 database got the tables above in their current (v3) shape, so
      // only a v2 database needs the new column.
      if (from == 2) {
        await m.addColumn(incomeEntries, incomeEntries.actualDate);
        // Phase 1a froze history without shifting, so for entries up to the
        // source's frozen_through day the paid date was the original date.
        await customStatement(
          'UPDATE income_entries SET actual_date = original_date '
          'WHERE EXISTS (SELECT 1 FROM income_sources s '
          'WHERE s.id = income_entries.source_id '
          'AND s.frozen_through IS NOT NULL '
          'AND income_entries.original_date <= s.frozen_through)',
        );
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
