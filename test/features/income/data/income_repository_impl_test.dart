import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/expenses/data/expense_repository_impl.dart';
import 'package:simple_budgeting_app/features/income/data/balance_anchor_repository_impl.dart';
import 'package:simple_budgeting_app/features/income/data/income_repository_impl.dart';
import 'package:simple_budgeting_app/features/income/data/income_schedule_codec.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/services/income_calculator.dart';
import 'package:simple_budgeting_app/features/income/domain/services/schedule_engine.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/get_monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/update_income_source.dart';

IncomeSource _source(String id, {IncomeSchedule? schedule}) => IncomeSource(
  id: id,
  name: 'Salary',
  type: IncomeType.salary,
  amount: const Money(100000),
  currencyCode: 'EUR',
  schedule: schedule ?? const Monthly.onDay(5),
  startDate: CalendarDate(2026, 1, 1),
  createdAt: DateTime.utc(2026, 1, 1, 8),
);

IncomeEntry _entry(
  String id,
  String sourceId,
  CalendarDate date, {
  IncomeEntryStatus status = IncomeEntryStatus.received,
  int minor = 100,
}) => IncomeEntry(
  id: id,
  sourceId: sourceId,
  originalDate: date,
  status: status,
  amount: Money(minor),
  createdAt: DateTime.utc(2026, 10, 1),
);

void main() {
  late AppDatabase db;
  late IncomeRepositoryImpl repository;
  late BalanceAnchorRepositoryImpl anchors;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = IncomeRepositoryImpl(db);
    anchors = BalanceAnchorRepositoryImpl(db);
  });

  tearDown(() => db.close());

  group('income sources', () {
    test('a source round trips with all its fields', () async {
      final source = IncomeSource(
        id: 's1',
        name: 'Contract',
        type: IncomeType.freelance,
        amount: const Money(123456),
        currencyCode: 'EUR',
        schedule: const Monthly.onLastDay(),
        startDate: CalendarDate(2026, 2, 1),
        endDate: CalendarDate(2026, 12, 31),
        frozenThrough: CalendarDate(2026, 6, 30),
        createdAt: DateTime.utc(2026, 1, 1, 8),
      );
      await repository.addSource(source);

      final loaded = (await repository.getSource('s1'))!;

      expect(loaded.name, 'Contract');
      expect(loaded.type, IncomeType.freelance);
      expect(loaded.amount, const Money(123456));
      expect(loaded.schedule, const Monthly.onLastDay());
      expect(loaded.startDate, CalendarDate(2026, 2, 1));
      expect(loaded.endDate, CalendarDate(2026, 12, 31));
      expect(loaded.frozenThrough, CalendarDate(2026, 6, 30));
      expect(loaded.createdAt, DateTime.utc(2026, 1, 1, 8));
      expect(loaded.createdAt.isUtc, isTrue);
      expect(loaded.archivedAt, isNull);
    });

    test('the schedule is stored as versioned JSON text', () async {
      await repository.addSource(_source('s1'));

      final row = await db.select(db.incomeSources).getSingle();

      expect(
        row.scheduleJson,
        '{"v":2,"type":"monthly","rule":{"kind":"day","day":5},"shift":"none"}',
      );
      expect(row.startDate, '2026-01-01');
    });

    test('update replaces the fields', () async {
      await repository.addSource(_source('s1'));

      await repository.updateSource(
        _source('s1').copyWith(name: 'Main job', amount: const Money(5)),
      );

      final loaded = (await repository.getSource('s1'))!;
      expect(loaded.name, 'Main job');
      expect(loaded.amount, const Money(5));
    });

    test('archived sources are listed only on request', () async {
      await repository.addSource(_source('s1'));
      await repository.addSource(_source('s2'));
      await repository.archiveSource('s1', DateTime.utc(2026, 10, 1, 9));

      expect((await repository.listSources()).map((s) => s.id), ['s2']);
      expect(await repository.listSources(includeArchived: true), hasLength(2));
      expect(
        (await repository.getSource('s1'))!.archivedAt,
        DateTime.utc(2026, 10, 1, 9),
      );
    });

    test('an unknown stored schedule fails safely when read', () async {
      await repository.addSource(_source('s1'));
      await db.customStatement(
        "UPDATE income_sources SET schedule_json = "
        "'{\"v\":1,\"type\":\"weekly\"}'",
      );

      await expectLater(
        repository.listSources(),
        throwsA(isA<ScheduleDecodeException>()),
      );
    });
  });

  group('income entries', () {
    test('saving twice for the same source and date keeps one row', () async {
      await repository.addSource(_source('s1'));
      final date = CalendarDate(2026, 10, 5);

      await repository.saveEntry(_entry('e1', 's1', date, minor: 100));
      await repository.saveEntry(
        _entry('e2', 's1', date, status: IncomeEntryStatus.skipped, minor: 200),
      );

      final entries = await repository.listEntries();
      expect(entries, hasLength(1));
      expect(entries.single.status, IncomeEntryStatus.skipped);
      expect(entries.single.amount, const Money(200));
    });

    test('the unique key (source_id, original_date) is enforced by SQL', () async {
      await repository.addSource(_source('s1'));
      await db.customStatement(
        "INSERT INTO income_entries (id, source_id, original_date, status, "
        "amount_minor, created_at) VALUES ('a', 's1', '2026-10-05', 'received', 1, 0)",
      );

      await expectLater(
        db.customStatement(
          "INSERT INTO income_entries (id, source_id, original_date, status, "
          "amount_minor, created_at) VALUES ('b', 's1', '2026-10-05', 'received', 2, 0)",
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('the same date for two different sources is allowed', () async {
      await repository.addSource(_source('s1'));
      await repository.addSource(_source('s2'));
      final date = CalendarDate(2026, 10, 5);

      await repository.saveEntry(_entry('e1', 's1', date));
      await repository.saveEntry(_entry('e2', 's2', date));

      expect(await repository.listEntries(), hasLength(2));
    });

    test('a pinned actual date round trips and can be cleared', () async {
      await repository.addSource(_source('s1'));
      final nominal = CalendarDate(2026, 11, 1);

      await repository.saveEntry(
        _entry(
          'e1',
          's1',
          nominal,
        ).copyWith(actualDate: CalendarDate(2026, 10, 30)),
      );
      expect(
        (await repository.listEntries()).single.actualDate,
        CalendarDate(2026, 10, 30),
      );
      final row = await db.select(db.incomeEntries).getSingle();
      expect(row.originalDate, '2026-11-01');
      expect(row.actualDate, '2026-10-30');

      // Saving the same payment again without a date clears the pin.
      await repository.saveEntry(_entry('e2', 's1', nominal));
      expect((await repository.listEntries()).single.actualDate, isNull);
    });

    test('removeEntry deletes only that payment', () async {
      await repository.addSource(_source('s1'));
      await repository.saveEntry(_entry('e1', 's1', CalendarDate(2026, 10, 5)));
      await repository.saveEntry(_entry('e2', 's1', CalendarDate(2026, 11, 5)));

      await repository.removeEntry('s1', CalendarDate(2026, 10, 5));

      expect((await repository.listEntries()).map((e) => e.originalDate), [
        CalendarDate(2026, 11, 5),
      ]);
    });

    test(
      'an entry for a missing source is rejected (foreign keys on)',
      () async {
        await expectLater(
          repository.saveEntry(
            _entry('e1', 'missing', CalendarDate(2026, 10, 5)),
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('updateSource with freeze entries is atomic', () async {
      await repository.addSource(_source('s1'));

      await expectLater(
        repository.updateSource(
          _source('s1').copyWith(name: 'Changed'),
          freezeEntries: [
            _entry('e1', 's1', CalendarDate(2026, 9, 5)),
            _entry('e2', 'missing', CalendarDate(2026, 9, 5)), // fails
          ],
        ),
        throwsA(isA<Exception>()),
      );

      expect((await repository.getSource('s1'))!.name, 'Salary');
      expect(await repository.listEntries(), isEmpty);
    });
  });

  group('freeze history on edit (real database)', () {
    test('earlier months keep the old amount after the edit', () async {
      final now = DateTime.utc(2026, 10, 18, 9);
      const calculator = IncomeCalculator(ScheduleEngine());
      var n = 0;
      final update = UpdateIncomeSource(
        repository,
        calculator,
        () => now,
        () => 'gen-${++n}',
      );
      final cashFlow = GetMonthlyCashFlow(
        repository,
        anchors,
        ExpenseRepositoryImpl(db),
        calculator,
        () => now,
      );
      await repository.addSource(_source('s1'));
      final before = await cashFlow(YearMonth(2026, 9), 'EUR');

      await update(
        sourceId: 's1',
        name: 'Salary',
        type: IncomeType.salary,
        amount: const Money(120000),
        schedule: const Monthly.onDay(5),
        startDate: CalendarDate(2026, 1, 1),
      );

      final september = await cashFlow(YearMonth(2026, 9), 'EUR');
      final november = await cashFlow(YearMonth(2026, 11), 'EUR');
      expect(september.occurrences.single.amount, const Money(100000));
      expect(september.projectedClosingBalance, before.projectedClosingBalance);
      expect(november.occurrences.single.amount, const Money(120000));
      expect(
        (await repository.getSource('s1'))!.frozenThrough,
        CalendarDate(2026, 10, 18),
      );
      expect(await repository.listEntries(), hasLength(10));
    });
  });

  group('balance anchors', () {
    BalanceAnchor anchor(
      String id,
      CalendarDate date,
      int minor, {
      String currency = 'EUR',
    }) => BalanceAnchor(
      id: id,
      date: date,
      balance: Money(minor),
      currencyCode: currency,
      createdAt: DateTime.utc(2026, 10, 1),
    );

    test('anchors round trip, sorted by date, filtered by currency', () async {
      await anchors.saveAnchor(anchor('a2', CalendarDate(2026, 10, 1), -500));
      await anchors.saveAnchor(anchor('a1', CalendarDate(2026, 3, 1), 1000));
      await anchors.saveAnchor(
        anchor('a3', CalendarDate(2026, 5, 1), 7, currency: 'USD'),
      );

      final eur = await anchors.listAnchors('EUR');

      expect(eur.map((a) => a.date), [
        CalendarDate(2026, 3, 1),
        CalendarDate(2026, 10, 1),
      ]);
      expect(eur.last.balance, const Money(-500));
      expect(await anchors.listAnchors('USD'), hasLength(1));
    });

    test(
      'listCurrencyCodes returns each currency with an anchor once',
      () async {
        expect(await anchors.listCurrencyCodes(), isEmpty);

        await anchors.saveAnchor(anchor('a1', CalendarDate(2026, 3, 1), 1000));
        await anchors.saveAnchor(anchor('a2', CalendarDate(2026, 4, 1), 2000));
        await anchors.saveAnchor(
          anchor('a3', CalendarDate(2026, 5, 1), 7, currency: 'USD'),
        );

        expect(await anchors.listCurrencyCodes(), {'EUR', 'USD'});
      },
    );

    test('same date and currency replaces the balance', () async {
      await anchors.saveAnchor(anchor('a1', CalendarDate(2026, 3, 1), 1000));
      await anchors.saveAnchor(anchor('a2', CalendarDate(2026, 3, 1), 2000));

      final list = await anchors.listAnchors('EUR');

      expect(list, hasLength(1));
      expect(list.single.balance, const Money(2000));
    });
  });

  test('PRAGMA foreign_keys is ON', () async {
    final pragma = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(pragma.read<int>('foreign_keys'), 1);
  });
}
