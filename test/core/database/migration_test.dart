import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';

import '../../generated_migrations/schema.dart';
import '../../generated_migrations/schema_v1.dart' as v1;
import '../../generated_migrations/schema_v2.dart' as v2;
import '../../generated_migrations/schema_v3.dart' as v3;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test(
    'v1 -> v4 creates the income and expense tables and keeps existing data',
    () async {
      final schema = await verifier.schemaAt(1);

      final oldDb = v1.DatabaseAtV1(schema.newConnection());
      await oldDb.customStatement(
        "INSERT INTO app_settings (setting_key, setting_value) "
        "VALUES ('launch_count', '7')",
      );
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 4);

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
        "'{\"v\":2,\"type\":\"monthly\",\"rule\":{\"kind\":\"last\"},"
        "\"shift\":\"none\"}', '2026-01-01', 0)",
      );
      final count = await db
          .customSelect('SELECT COUNT(*) AS c FROM income_sources')
          .getSingle();
      expect(count.read<int>('c'), 1);
    },
  );

  group('v2 -> v4 (actual_date, then expenses)', () {
    Future<void> seedV2(v2.DatabaseAtV2 db) async {
      Future<void> source(String id, {String? frozenThrough}) =>
          db.customStatement(
            "INSERT INTO income_sources (id, name, type, amount_minor, "
            "currency_code, schedule_json, start_date, frozen_through, "
            "created_at) VALUES ('$id', '$id', 'salary', 100000, 'EUR', "
            "'{\"v\":1,\"type\":\"monthly\",\"day\":5}', '2026-01-01', "
            "${frozenThrough == null ? 'NULL' : "'$frozenThrough'"}, 0)",
          );
      Future<void> entry(String id, String sourceId, String original) =>
          db.customStatement(
            "INSERT INTO income_entries (id, source_id, original_date, "
            "status, amount_minor, created_at) VALUES "
            "('$id', '$sourceId', '$original', 'received', 100000, 0)",
          );

      await source('frozen', frozenThrough: '2026-10-18');
      await source('plain');
      // Frozen source: two entries inside the frozen range, one after it.
      await entry('e1', 'frozen', '2026-09-05');
      await entry('e2', 'frozen', '2026-10-05');
      await entry(
        'e3',
        'frozen',
        '2026-11-05',
      ); // user changed a future payment
      // Source that was never edited: a skipped/changed payment, not frozen.
      await entry('e4', 'plain', '2026-09-05');
    }

    test(
      'backfills actual_date only for entries inside frozen_through',
      () async {
        final schema = await verifier.schemaAt(2);
        final oldDb = v2.DatabaseAtV2(schema.newConnection());
        await seedV2(oldDb);
        await oldDb.close();

        final db = AppDatabase(schema.newConnection());
        addTearDown(db.close);
        await verifier.migrateAndValidate(db, 4);

        final rows = await db
            .customSelect(
              'SELECT id, original_date, actual_date FROM income_entries '
              'ORDER BY id',
            )
            .get();
        final actual = {
          for (final r in rows)
            r.read<String>('id'): r.read<String?>('actual_date'),
        };
        expect(actual, {
          'e1': '2026-09-05', // pinned: inside the frozen range
          'e2': '2026-10-05', // pinned
          'e3': null, // after frozen_through: computed from the schedule
          'e4': null, // source never frozen
        });
      },
    );

    test('keeps every other column and row', () async {
      final schema = await verifier.schemaAt(2);
      final oldDb = v2.DatabaseAtV2(schema.newConnection());
      await seedV2(oldDb);
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 4);

      final count = await db
          .customSelect('SELECT COUNT(*) AS c FROM income_entries')
          .getSingle();
      expect(count.read<int>('c'), 4);
      final sources = await db
          .customSelect('SELECT COUNT(*) AS c FROM income_sources')
          .getSingle();
      expect(sources.read<int>('c'), 2);
    });

    test('new rows can use actual_date', () async {
      final schema = await verifier.schemaAt(2);
      final oldDb = v2.DatabaseAtV2(schema.newConnection());
      await seedV2(oldDb);
      await oldDb.close();
      final db = AppDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 4);

      await db.customStatement(
        "INSERT INTO income_entries (id, source_id, original_date, "
        "actual_date, status, amount_minor, created_at) VALUES "
        "('e5', 'plain', '2026-12-01', '2026-11-30', 'received', 1, 0)",
      );
      final row = await db
          .customSelect(
            "SELECT actual_date FROM income_entries WHERE id = 'e5'",
          )
          .getSingle();
      expect(row.read<String>('actual_date'), '2026-11-30');
    });
  });
  group('v3 -> v4 (categories and expenses)', () {
    Future<AppDatabase> migrated() async {
      final schema = await verifier.schemaAt(3);
      final oldDb = v3.DatabaseAtV3(schema.newConnection());
      await oldDb.customStatement(
        "INSERT INTO app_settings (setting_key, setting_value) "
        "VALUES ('primary_currency', 'EUR')",
      );
      await oldDb.customStatement(
        "INSERT INTO income_sources (id, name, type, amount_minor, "
        "currency_code, schedule_json, start_date, created_at) VALUES "
        "('s1', 'Salary', 'salary', 100000, 'EUR', "
        "'{\"v\":2,\"type\":\"monthly\",\"rule\":{\"kind\":\"last\"},"
        "\"shift\":\"none\"}', '2026-01-01', 0)",
      );
      await oldDb.customStatement(
        "INSERT INTO income_entries (id, source_id, original_date, "
        "actual_date, status, amount_minor, created_at) VALUES "
        "('e1', 's1', '2026-09-30', '2026-09-30', 'received', 100000, 0)",
      );
      await oldDb.close();

      final db = AppDatabase(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, 4);
      return db;
    }

    Future<int> count(AppDatabase db, String table) async =>
        (await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle())
            .read<int>('c');

    test('keeps the existing data', () async {
      final db = await migrated();
      expect(await count(db, 'income_sources'), 1);
      expect(await count(db, 'income_entries'), 1);
      final setting = await db
          .customSelect(
            "SELECT setting_value FROM app_settings "
            "WHERE setting_key = 'primary_currency'",
          )
          .getSingle();
      expect(setting.read<String>('setting_value'), 'EUR');
    });

    test('creates the expenses table, empty', () async {
      final db = await migrated();
      expect(await count(db, 'expenses'), 0);
    });

    test('has the eight built-in categories, ids equal to keys', () async {
      final db = await migrated();
      final rows = await db
          .customSelect(
            'SELECT id, category_key FROM categories ORDER BY sort_order',
          )
          .get();
      expect(rows.map((r) => r.read<String>('id')).toList(), [
        'energy',
        'water',
        'telecom',
        'food',
        'fuel_transport',
        'health',
        'insurance',
        'other',
      ]);
      expect(
        rows.map((r) => r.read<String>('category_key')),
        rows.map((r) => r.read<String>('id')),
      );
    });

    test('an expense can be stored for a seeded category', () async {
      final db = await migrated();
      await db.customStatement(
        "INSERT INTO expenses (id, category_id, expense_date, currency_code, "
        "amount_minor, created_at, updated_at) VALUES "
        "('x1', 'food', '2026-10-19', 'EUR', 4500, 0, 0)",
      );
      expect(await count(db, 'expenses'), 1);
    });
  });
}
