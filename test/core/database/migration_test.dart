import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';

import '../../generated_migrations/schema.dart';
import '../../generated_migrations/schema_v1.dart' as v1;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 -> v2 creates the income tables and keeps existing data', () async {
    final schema = await verifier.schemaAt(1);

    final oldDb = v1.DatabaseAtV1(schema.newConnection());
    await oldDb.customStatement(
      "INSERT INTO app_settings (setting_key, setting_value) "
      "VALUES ('launch_count', '7')",
    );
    await oldDb.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);

    final kept = await db
        .customSelect(
          "SELECT setting_value FROM app_settings "
          "WHERE setting_key = 'launch_count'",
        )
        .getSingle();
    expect(kept.read<String>('setting_value'), '7');

    await db.customStatement(
      "INSERT INTO income_sources (id, name, type, amount_minor, "
      "currency_code, schedule_json, start_date, created_at) VALUES "
      "('s1', 'Salary', 'salary', 100000, 'EUR', "
      "'{\"v\":1,\"type\":\"monthly\",\"day\":5}', '2026-01-01', 0)",
    );
    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM income_sources')
        .getSingle();
    expect(count.read<int>('c'), 1);
  });
}
