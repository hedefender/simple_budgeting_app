import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/income_validation.dart';

import '../../../support/income_harness.dart';

Matcher _validation(IncomeValidationError error) => throwsA(
  isA<IncomeValidationException>().having((e) => e.error, 'error', error),
);

void main() {
  late IncomeHarness h;
  final jan1 = CalendarDate(2026, 1, 1);

  setUp(() => h = IncomeHarness());

  group('CreateIncomeSource', () {
    test('stores the source with trimmed name and UTC creation time', () async {
      final source = await h.create(
        name: '  Salary  ',
        type: IncomeType.salary,
        amount: const Money(100000),
        currencyCode: 'EUR',
        schedule: const Monthly.onDay(5),
        startDate: jan1,
      );

      expect(source.name, 'Salary');
      expect(source.createdAt, h.now);
      expect(source.createdAt.isUtc, isTrue);
      expect(await h.income.getSource(source.id), isNotNull);
    });

    test('rejects an empty name', () {
      expect(
        h.create(
          name: '   ',
          type: IncomeType.other,
          amount: const Money(100),
          currencyCode: 'EUR',
          schedule: const Monthly.onDay(5),
          startDate: jan1,
        ),
        _validation(IncomeValidationError.nameEmpty),
      );
    });

    test('rejects zero and negative amounts', () {
      for (final minor in <int>[0, -1]) {
        expect(
          h.create(
            name: 'X',
            type: IncomeType.other,
            amount: Money(minor),
            currencyCode: 'EUR',
            schedule: const Monthly.onDay(5),
            startDate: jan1,
          ),
          _validation(IncomeValidationError.amountNotPositive),
        );
      }
    });

    test('rejects an end date before the start date', () {
      expect(
        h.create(
          name: 'X',
          type: IncomeType.other,
          amount: const Money(100),
          currencyCode: 'EUR',
          schedule: const Monthly.onDay(5),
          startDate: CalendarDate(2026, 5, 1),
          endDate: CalendarDate(2026, 4, 30),
        ),
        _validation(IncomeValidationError.endBeforeStart),
      );
    });

    test(
      'a one-off source starts on its payment date and has no end',
      () async {
        final source = await h.create(
          name: 'Refund',
          type: IncomeType.other,
          amount: const Money(100),
          currencyCode: 'EUR',
          schedule: OneOff(CalendarDate(2026, 11, 20)),
          startDate: CalendarDate(2026, 1, 1),
          endDate: CalendarDate(2026, 2, 1),
        );

        expect(source.startDate, CalendarDate(2026, 11, 20));
        expect(source.endDate, isNull);
      },
    );
  });

  group('UpdateIncomeSource', () {
    Future<IncomeSource> salary() =>
        h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);

    test('a name change does not freeze history', () async {
      final source = await salary();

      final updated = await h.update(
        sourceId: source.id,
        name: 'Main job',
        type: IncomeType.salary,
        amount: source.amount,
        schedule: source.schedule,
        startDate: source.startDate,
      );

      expect(updated.name, 'Main job');
      expect(updated.frozenThrough, isNull);
      expect(h.income.entries, isEmpty);
    });

    test(
      'an amount change stores the past as received with the old amount',
      () async {
        final source = await salary();

        final updated = await h.update(
          sourceId: source.id,
          name: source.name,
          type: source.type,
          amount: const Money(120000),
          schedule: source.schedule,
          startDate: source.startDate,
        );

        // Jan 5 ... Oct 5 = 10 payments up to 2026-10-18.
        expect(h.income.entries, hasLength(10));
        expect(
          h.income.entries.every(
            (e) =>
                e.status == IncomeEntryStatus.received &&
                e.amount == const Money(100000),
          ),
          isTrue,
        );
        expect(updated.frozenThrough, CalendarDate(2026, 10, 18));
        expect(updated.amount, const Money(120000));
      },
    );

    test('a schedule change also freezes history', () async {
      final source = await salary();

      await h.update(
        sourceId: source.id,
        name: source.name,
        type: source.type,
        amount: source.amount,
        schedule: const Monthly.onDay(10),
        startDate: source.startDate,
      );

      expect(h.income.entries, hasLength(10));
      expect(h.income.entries.map((e) => e.originalDate.day).toSet(), {5});
    });

    test(
      'payments already stored (skipped or changed) are kept as they are',
      () async {
        final source = await salary();
        await h.skip(
          sourceId: source.id,
          originalDate: CalendarDate(2026, 9, 5),
        );
        await h.changeAmount(
          sourceId: source.id,
          originalDate: CalendarDate(2026, 8, 5),
          amount: const Money(90000),
        );

        await h.update(
          sourceId: source.id,
          name: source.name,
          type: source.type,
          amount: const Money(120000),
          schedule: source.schedule,
          startDate: source.startDate,
        );

        expect(h.income.entries, hasLength(10));
        final september = h.income.entries.singleWhere(
          (e) => e.originalDate == CalendarDate(2026, 9, 5),
        );
        final august = h.income.entries.singleWhere(
          (e) => e.originalDate == CalendarDate(2026, 8, 5),
        );
        expect(september.status, IncomeEntryStatus.skipped);
        expect(august.amount, const Money(90000));
      },
    );

    test('a second edit later freezes only the new part of the past', () async {
      final source = await salary();
      await h.update(
        sourceId: source.id,
        name: source.name,
        type: source.type,
        amount: const Money(120000),
        schedule: source.schedule,
        startDate: source.startDate,
      );
      h.now = DateTime.utc(2026, 12, 20, 9);

      final first = (await h.income.getSource(source.id))!;
      await h.update(
        sourceId: source.id,
        name: first.name,
        type: first.type,
        amount: const Money(150000),
        schedule: first.schedule,
        startDate: first.startDate,
      );

      // Nov 5 and Dec 5 were generated with 1200,00 and are now frozen.
      final nov = h.income.entries.singleWhere(
        (e) => e.originalDate == CalendarDate(2026, 11, 5),
      );
      final dec = h.income.entries.singleWhere(
        (e) => e.originalDate == CalendarDate(2026, 12, 5),
      );
      expect(nov.amount, const Money(120000));
      expect(dec.amount, const Money(120000));
      expect(h.income.entries, hasLength(12));
    });

    test('cannot edit an archived or missing source', () async {
      final source = await salary();
      await h.archive(source.id);

      expect(
        h.update(
          sourceId: source.id,
          name: 'X',
          type: source.type,
          amount: source.amount,
          schedule: source.schedule,
          startDate: source.startDate,
        ),
        _validation(IncomeValidationError.sourceArchived),
      );
      expect(
        h.update(
          sourceId: 'nope',
          name: 'X',
          type: source.type,
          amount: source.amount,
          schedule: source.schedule,
          startDate: source.startDate,
        ),
        _validation(IncomeValidationError.sourceNotFound),
      );
    });
  });

  group('ArchiveIncomeSource and ListIncomeSources', () {
    test('archived sources leave the default list', () async {
      final a = await h.monthly(name: 'A', minor: 100, day: 1, start: jan1);
      await h.monthly(name: 'B', minor: 100, day: 1, start: jan1);

      await h.archive(a.id);

      expect((await h.list()).map((s) => s.name), ['B']);
      expect(await h.list(includeArchived: true), hasLength(2));
      expect((await h.income.getSource(a.id))!.archivedAt, h.now);
    });

    test('archiving twice keeps the first archive time', () async {
      final a = await h.monthly(name: 'A', minor: 100, day: 1, start: jan1);
      await h.archive(a.id);
      final first = (await h.income.getSource(a.id))!.archivedAt;
      h.now = DateTime.utc(2026, 11, 1, 9);

      await h.archive(a.id);

      expect((await h.income.getSource(a.id))!.archivedAt, first);
    });

    test('archiving an unknown source fails', () {
      expect(
        h.archive('nope'),
        _validation(IncomeValidationError.sourceNotFound),
      );
    });
  });

  group('occurrence actions', () {
    test('changing an amount to zero or negative is rejected', () async {
      final a = await h.monthly(name: 'A', minor: 100, day: 1, start: jan1);

      expect(
        h.changeAmount(
          sourceId: a.id,
          originalDate: CalendarDate(2026, 10, 1),
          amount: Money.zero,
        ),
        _validation(IncomeValidationError.amountNotPositive),
      );
    });

    test('skip keeps the planned amount, including a changed one', () async {
      final a = await h.monthly(name: 'A', minor: 100, day: 1, start: jan1);
      final date = CalendarDate(2026, 10, 1);
      await h.changeAmount(
        sourceId: a.id,
        originalDate: date,
        amount: const Money(250),
      );

      await h.skip(sourceId: a.id, originalDate: date);

      final entry = h.income.entries.single;
      expect(entry.status, IncomeEntryStatus.skipped);
      expect(entry.amount, const Money(250));
    });

    test('actions on an unknown source fail', () {
      expect(
        h.skip(sourceId: 'nope', originalDate: CalendarDate(2026, 10, 1)),
        _validation(IncomeValidationError.sourceNotFound),
      );
    });
  });
}
