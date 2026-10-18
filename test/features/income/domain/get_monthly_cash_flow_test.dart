import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';

import '../../../support/income_harness.dart';

/// "Today" in all tests is 2026-10-18 unless a test moves the clock.
void main() {
  late IncomeHarness h;
  final jan1 = CalendarDate(2026, 1, 1);

  setUp(() => h = IncomeHarness());

  Future<MonthlyCashFlow> flow(int y, int m, {String currency = 'EUR'}) =>
      h.cashFlow(YearMonth(y, m), currency);

  group('without anchors', () {
    test('all income since the start counts', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);

      final october = await flow(2026, 10);

      expect(october.openingBalance, const Money(900000)); // Jan-Sep
      expect(october.projectedClosingBalance, const Money(1000000));
      expect(october.receivedIncome, const Money(100000));
      expect(october.expectedIncome, Money.zero);
      expect(october.occurrences.single.state, OccurrenceState.received);
    });

    test('a future month shows expected income and keeps adding', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);

      final november = await flow(2026, 11);

      expect(november.openingBalance, const Money(1000000));
      expect(november.expectedIncome, const Money(100000));
      expect(november.receivedIncome, Money.zero);
      expect(november.projectedClosingBalance, const Money(1100000));
      expect(november.occurrences.single.state, OccurrenceState.expected);
    });

    test('an occurrence dated today counts as received', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 18, start: jan1);

      final october = await flow(2026, 10);

      expect(october.occurrences.single.state, OccurrenceState.received);
    });

    test('an occurrence dated tomorrow is expected', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 19, start: jan1);

      final october = await flow(2026, 10);

      expect(october.occurrences.single.state, OccurrenceState.expected);
    });

    test(
      'the month sums several sources and sorts by date then name',
      () async {
        await h.monthly(name: 'B job', minor: 20000, day: 5, start: jan1);
        await h.monthly(name: 'A job', minor: 30000, day: 5, start: jan1);
        await h.monthly(name: 'Rent', minor: 10000, day: 1, start: jan1);

        final october = await flow(2026, 10);

        expect(october.occurrences.map((o) => o.source.name), [
          'Rent',
          'A job',
          'B job',
        ]);
        expect(october.receivedIncome, const Money(60000));
      },
    );
  });

  group('balance anchors', () {
    test('an anchor inside the month changes that month\'s balance', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);
      await h.monthly(name: 'Side', minor: 5000, day: 20, start: jan1);
      // 500,00 at the end of 10 October.
      await h.setAnchor(
        date: CalendarDate(2026, 10, 10),
        balance: const Money(50000),
        currencyCode: 'EUR',
      );

      final october = await flow(2026, 10);

      // Opening: no anchor on or before 30 Sep, so all income Jan-Sep.
      expect(october.openingBalance, const Money(900000 + 45000));
      // Closing: the anchor, plus only income AFTER 10 Oct (Side on the 20th).
      // The salary of the 5th is already part of the anchor.
      expect(october.projectedClosingBalance, const Money(50000 + 5000));
    });

    test('income on the same day as the anchor is NOT added again', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);
      await h.setAnchor(
        date: CalendarDate(2026, 10, 5),
        balance: const Money(250000),
        currencyCode: 'EUR',
      );

      final october = await flow(2026, 10);

      expect(october.projectedClosingBalance, const Money(250000));
    });

    test('income the day after the anchor IS added', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);
      await h.setAnchor(
        date: CalendarDate(2026, 10, 4),
        balance: const Money(250000),
        currencyCode: 'EUR',
      );

      final october = await flow(2026, 10);

      expect(october.projectedClosingBalance, const Money(350000));
    });

    test('the latest anchor on or before the day wins', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);
      await h.setAnchor(
        date: CalendarDate(2026, 3, 31),
        balance: const Money(111111),
        currencyCode: 'EUR',
      );
      await h.setAnchor(
        date: CalendarDate(2026, 9, 30),
        balance: const Money(222222),
        currencyCode: 'EUR',
      );

      final october = await flow(2026, 10);

      expect(october.openingBalance, const Money(222222));
      expect(october.projectedClosingBalance, const Money(322222));
    });

    test(
      'an anchor after the month does not affect an earlier month',
      () async {
        await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);
        await h.setAnchor(
          date: CalendarDate(2026, 11, 15),
          balance: const Money(999),
          currencyCode: 'EUR',
        );

        final october = await flow(2026, 10);

        expect(october.projectedClosingBalance, const Money(1000000));
      },
    );

    test('a negative balance is allowed', () async {
      await h.setAnchor(
        date: CalendarDate(2026, 10, 1),
        balance: const Money(-12000),
        currencyCode: 'EUR',
      );

      final october = await flow(2026, 10);

      expect(october.projectedClosingBalance, const Money(-12000));
    });

    test('a second anchor for the same day replaces the first', () async {
      await h.setAnchor(
        date: CalendarDate(2026, 10, 1),
        balance: const Money(100),
        currencyCode: 'EUR',
      );
      await h.setAnchor(
        date: CalendarDate(2026, 10, 1),
        balance: const Money(200),
        currencyCode: 'EUR',
      );

      expect((await flow(2026, 10)).projectedClosingBalance, const Money(200));
    });
  });

  group('skipped payments', () {
    test('a skipped occurrence is not counted anywhere', () async {
      final source = await h.monthly(
        name: 'Salary',
        minor: 100000,
        day: 5,
        start: jan1,
      );
      await h.skip(
        sourceId: source.id,
        originalDate: CalendarDate(2026, 10, 5),
      );

      final october = await flow(2026, 10);

      expect(october.occurrences.single.state, OccurrenceState.skipped);
      expect(october.occurrences.single.amount, const Money(100000));
      expect(october.receivedIncome, Money.zero);
      expect(october.projectedClosingBalance, const Money(900000));
      // The next month's opening balance also leaves it out.
      expect((await flow(2026, 11)).openingBalance, const Money(900000));
    });

    test('resetting a skipped occurrence brings it back', () async {
      final source = await h.monthly(
        name: 'Salary',
        minor: 100000,
        day: 5,
        start: jan1,
      );
      final date = CalendarDate(2026, 10, 5);
      await h.skip(sourceId: source.id, originalDate: date);
      await h.reset(sourceId: source.id, originalDate: date);

      final october = await flow(2026, 10);

      expect(october.occurrences.single.state, OccurrenceState.received);
      expect(october.occurrences.single.isStored, isFalse);
    });
  });

  group('source start, end and archive', () {
    test('a source that starts inside the month skips earlier days', () async {
      await h.monthly(
        name: 'Salary',
        minor: 100000,
        day: 5,
        start: CalendarDate(2026, 10, 10),
      );

      final october = await flow(2026, 10);
      final november = await flow(2026, 11);

      expect(october.occurrences, isEmpty);
      expect(october.projectedClosingBalance, Money.zero);
      expect(november.occurrences.single.date, CalendarDate(2026, 11, 5));
    });

    test('a source that starts inside the month pays on later days', () async {
      await h.monthly(
        name: 'Salary',
        minor: 100000,
        day: 25,
        start: CalendarDate(2026, 10, 10),
      );

      final october = await flow(2026, 10);

      expect(october.occurrences.single.date, CalendarDate(2026, 10, 25));
      expect(october.occurrences.single.state, OccurrenceState.expected);
      expect(october.openingBalance, Money.zero);
      expect(october.projectedClosingBalance, const Money(100000));
    });

    test('nothing is generated after the end date', () async {
      await h.monthly(
        name: 'Contract',
        minor: 100000,
        day: 5,
        start: jan1,
        end: CalendarDate(2026, 10, 4),
      );

      final october = await flow(2026, 10);

      expect(october.occurrences, isEmpty);
      expect(october.projectedClosingBalance, const Money(900000));
      expect(
        (await flow(2027, 3)).projectedClosingBalance,
        const Money(900000),
      );
    });

    test('the end date itself is still generated', () async {
      await h.monthly(
        name: 'Contract',
        minor: 100000,
        day: 5,
        start: jan1,
        end: CalendarDate(2026, 10, 5),
      );

      expect((await flow(2026, 10)).occurrences, hasLength(1));
      expect((await flow(2026, 11)).occurrences, isEmpty);
    });

    test(
      'an archived source stops after the archive day, keeps history',
      () async {
        final source = await h.monthly(
          name: 'Salary',
          minor: 100000,
          day: 5,
          start: jan1,
        );
        await h.archive(source.id);

        expect((await flow(2026, 10)).occurrences, hasLength(1));
        expect((await flow(2026, 11)).occurrences, isEmpty);
        expect((await flow(2026, 11)).openingBalance, const Money(1000000));
      },
    );

    test('a one-off income appears once', () async {
      await h.create(
        name: 'Tax refund',
        type: IncomeType.other,
        amount: const Money(45000),
        currencyCode: 'EUR',
        schedule: OneOff(CalendarDate(2026, 11, 20)),
        startDate: CalendarDate(2026, 11, 20),
      );

      expect((await flow(2026, 10)).occurrences, isEmpty);
      final november = await flow(2026, 11);
      expect(november.occurrences.single.state, OccurrenceState.expected);
      expect(november.projectedClosingBalance, const Money(45000));
      expect((await flow(2026, 12)).openingBalance, const Money(45000));
      expect((await flow(2026, 12)).occurrences, isEmpty);
    });
  });

  group('changing an amount', () {
    test('does not change earlier months', () async {
      final source = await h.monthly(
        name: 'Salary',
        minor: 100000,
        day: 5,
        start: jan1,
      );
      final septemberBefore = await flow(2026, 9);
      final octoberBefore = await flow(2026, 10);

      await h.update(
        sourceId: source.id,
        name: 'Salary',
        type: IncomeType.salary,
        amount: const Money(120000),
        schedule: const Monthly.onDay(5),
        startDate: jan1,
      );

      final september = await flow(2026, 9);
      final october = await flow(2026, 10);
      final november = await flow(2026, 11);

      expect(september.occurrences.single.amount, const Money(100000));
      expect(september.openingBalance, septemberBefore.openingBalance);
      expect(
        september.projectedClosingBalance,
        septemberBefore.projectedClosingBalance,
      );
      expect(october.occurrences.single.amount, const Money(100000));
      expect(october.openingBalance, octoberBefore.openingBalance);
      expect(
        october.projectedClosingBalance,
        octoberBefore.projectedClosingBalance,
      );
      // Only the future uses the new amount.
      expect(november.occurrences.single.amount, const Money(120000));
      expect(november.projectedClosingBalance, const Money(1000000 + 120000));
    });

    test(
      'changing one payment keeps it received when it is in the past',
      () async {
        final source = await h.monthly(
          name: 'Salary',
          minor: 100000,
          day: 5,
          start: jan1,
        );
        await h.changeAmount(
          sourceId: source.id,
          originalDate: CalendarDate(2026, 10, 5),
          amount: const Money(95000),
        );

        final october = await flow(2026, 10);

        expect(october.occurrences.single.amount, const Money(95000));
        expect(october.occurrences.single.state, OccurrenceState.received);
        expect(october.occurrences.single.isStored, isTrue);
        expect(october.projectedClosingBalance, const Money(995000));
        // Other months are untouched.
        expect(
          (await flow(2026, 9)).occurrences.single.amount,
          const Money(100000),
        );
      },
    );

    test('changing a future payment keeps it expected', () async {
      final source = await h.monthly(
        name: 'Salary',
        minor: 100000,
        day: 5,
        start: jan1,
      );
      await h.changeAmount(
        sourceId: source.id,
        originalDate: CalendarDate(2026, 11, 5),
        amount: const Money(80000),
      );

      final november = await flow(2026, 11);

      expect(november.occurrences.single.state, OccurrenceState.expected);
      expect(november.expectedIncome, const Money(80000));
      expect(november.projectedClosingBalance, const Money(1080000));
    });
  });

  group('currencies', () {
    test('sources and anchors of another currency are ignored', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);
      await h.monthly(
        name: 'Dollar job',
        minor: 777700,
        day: 5,
        start: jan1,
        currency: 'USD',
      );
      await h.setAnchor(
        date: CalendarDate(2026, 10, 1),
        balance: const Money(5),
        currencyCode: 'USD',
      );

      final eur = await flow(2026, 10);
      final usd = await flow(2026, 10, currency: 'USD');

      expect(eur.occurrences.single.source.name, 'Salary');
      expect(eur.projectedClosingBalance, const Money(1000000));
      expect(usd.occurrences.single.source.name, 'Dollar job');
      expect(usd.projectedClosingBalance, const Money(5 + 777700));
    });
  });

  test('a schedule day beyond the month end pays on the last day', () async {
    await h.monthly(name: 'Salary', minor: 100000, day: 31, start: jan1);

    final february = await flow(2026, 2);

    expect(february.occurrences.single.date, CalendarDate(2026, 2, 28));
  });
}
