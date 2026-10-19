import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/data/greek_holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/services/holiday_calendar.dart';

import '../../../support/income_harness.dart';

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

/// A calendar the test can change, to model a later correction of holidays.
class _EditableHolidays implements HolidayCalendar {
  _EditableHolidays(this._base);

  final HolidayCalendar _base;
  final Set<CalendarDate> extra = <CalendarDate>{};

  @override
  bool isHoliday(CalendarDate date) =>
      extra.contains(date) || _base.isHoliday(date);
}

/// "Today" is Sunday 2026-10-18 unless a test moves the clock.
void main() {
  late _EditableHolidays holidays;
  late IncomeHarness h;
  final jan1 = _d(2026, 1, 1);

  setUp(() {
    holidays = _EditableHolidays(GreekHolidayCalendar());
    h = IncomeHarness(holidays: holidays);
  });

  Future<MonthlyCashFlow> flow(int y, int m) =>
      h.cashFlow(YearMonth(y, m), 'EUR');

  Future<IncomeSource> create(
    String name,
    IncomeSchedule schedule, {
    int minor = 100000,
  }) => h.create(
    name: name,
    type: IncomeType.salary,
    amount: Money(minor),
    currencyCode: 'EUR',
    schedule: schedule,
    startDate: jan1,
  );

  Future<IncomeSource> edit(
    IncomeSource s, {
    int? minor,
    IncomeSchedule? schedule,
  }) => h.update(
    sourceId: s.id,
    name: s.name,
    type: s.type,
    amount: minor == null ? s.amount : Money(minor),
    schedule: schedule ?? s.schedule,
    startDate: s.startDate,
  );

  group('a shifted payment belongs to the month of its actual date', () {
    // 1 Nov 2026 is a Sunday, so the payment is made on Friday 30 Oct.
    const firstPrevious = Monthly.onDay(1, shift: ShiftRule.previousWorkingDay);

    test('shown in October with the nominal date kept', () async {
      await create('Salary', firstPrevious);

      final october = await flow(2026, 10);

      expect(october.occurrences.map((o) => o.date), [
        _d(2026, 10, 1),
        _d(2026, 10, 30),
      ]);
      expect(october.occurrences.last.nominalDate, _d(2026, 11, 1));
      expect((await flow(2026, 11)).occurrences, isEmpty);
    });

    test('received or expected follows the actual date', () async {
      await create('Salary', firstPrevious);

      final october = await flow(2026, 10);

      expect(october.occurrences.first.state, OccurrenceState.received);
      // 30 Oct is after today (18 Oct) even though 1 Nov is further away.
      expect(october.occurrences.last.state, OccurrenceState.expected);
      expect(october.receivedIncome, const Money(100000));
      expect(october.expectedIncome, const Money(100000));
    });

    test('balances count it in October, not November', () async {
      await create('Salary', firstPrevious);

      expect(
        (await flow(2026, 10)).projectedClosingBalance,
        const Money(1000000),
      );
      // 1 Jan 2026 is a holiday: its payment moves to 31 Dec 2025, before the
      // source starts, so it is never generated. Feb..Nov (nominal) = 10.
      expect((await flow(2026, 11)).openingBalance, const Money(1000000));
      expect(
        (await flow(2026, 9)).projectedClosingBalance,
        const Money(800000), // Feb..Sep
      );
    });

    test('an anchor on the actual date already includes the payment', () async {
      await create('Salary', firstPrevious);
      await h.setAnchor(
        date: _d(2026, 10, 30),
        balance: const Money(500000),
        currencyCode: 'EUR',
      );

      expect(
        (await flow(2026, 10)).projectedClosingBalance,
        const Money(500000),
      );
    });

    test('an anchor the day before the actual date adds the payment', () async {
      await create('Salary', firstPrevious);
      await h.setAnchor(
        date: _d(2026, 10, 29),
        balance: const Money(500000),
        currencyCode: 'EUR',
      );

      expect(
        (await flow(2026, 10)).projectedClosingBalance,
        const Money(600000),
      );
    });

    test(
      'an anchor on the NOMINAL date does not hide it (it is earlier)',
      () async {
        await create('Salary', firstPrevious);
        await h.setAnchor(
          date: _d(2026, 11, 1),
          balance: const Money(500000),
          currencyCode: 'EUR',
        );

        // The payment was made on 30 Oct, before the anchor day.
        expect(
          (await flow(2026, 11)).projectedClosingBalance,
          const Money(500000),
        );
        expect(
          (await flow(2026, 10)).projectedClosingBalance,
          const Money(1000000),
        );
      },
    );

    test('the January payment of next year lands in December', () async {
      await create('Salary', firstPrevious);

      final december = await flow(2026, 12);

      // 1 Jan 2027 is a holiday (Friday).
      expect(december.occurrences.map((o) => o.date), [
        _d(2026, 12, 1),
        _d(2026, 12, 31),
      ]);
      expect(december.occurrences.last.nominalDate, _d(2027, 1, 1));
    });
  });

  group('actions use the nominal date', () {
    test('skipping the shifted payment removes it from October', () async {
      final s = await create(
        'Salary',
        const Monthly.onDay(1, shift: ShiftRule.previousWorkingDay),
      );

      await h.skip(sourceId: s.id, originalDate: _d(2026, 11, 1));

      final october = await flow(2026, 10);
      expect(october.occurrences.last.state, OccurrenceState.skipped);
      expect(october.projectedClosingBalance, const Money(900000));
    });

    test(
      'a stored skip survives a correction of the holiday calendar',
      () async {
        final s = await create(
          'Salary',
          const Monthly.onDay(20, shift: ShiftRule.previousWorkingDay),
        );
        await h.skip(sourceId: s.id, originalDate: _d(2026, 11, 20));
        expect(
          (await flow(2026, 11)).occurrences.single.date,
          _d(2026, 11, 20),
        );

        holidays.extra.add(_d(2026, 11, 20)); // the calendar is corrected

        final november = await flow(2026, 11);
        expect(november.occurrences.single.date, _d(2026, 11, 19));
        expect(november.occurrences.single.state, OccurrenceState.skipped);
        expect(november.occurrences.single.nominalDate, _d(2026, 11, 20));
      },
    );

    test(
      'a changed amount survives a correction of the holiday calendar',
      () async {
        final s = await create(
          'Salary',
          const Monthly.onDay(20, shift: ShiftRule.previousWorkingDay),
        );
        await h.changeAmount(
          sourceId: s.id,
          originalDate: _d(2026, 11, 20),
          amount: const Money(77700),
        );

        holidays.extra.add(_d(2026, 11, 20));

        final payment = (await flow(2026, 11)).occurrences.single;
        expect(payment.amount, const Money(77700));
        expect(payment.date, _d(2026, 11, 19));
      },
    );
  });

  group('changing the date of one payment (pinned actual date)', () {
    late IncomeSource salary;

    setUp(() async {
      salary = await create('Salary', const Monthly.onDay(5));
    });

    test('moves the payment into another month', () async {
      await h.changeAmount(
        sourceId: salary.id,
        originalDate: _d(2026, 11, 5),
        amount: const Money(100000),
        actualDate: _d(2026, 12, 2),
      );

      expect((await flow(2026, 11)).occurrences, isEmpty);
      final december = await flow(2026, 12);
      expect(december.occurrences.map((o) => o.date), [
        _d(2026, 12, 2),
        _d(2026, 12, 5),
      ]);
      expect(december.occurrences.first.nominalDate, _d(2026, 11, 5));
      expect(december.occurrences.first.isStored, isTrue);
    });

    test('moving a future payment to the past makes it received', () async {
      await h.changeAmount(
        sourceId: salary.id,
        originalDate: _d(2026, 11, 5),
        amount: const Money(100000),
        actualDate: _d(2026, 10, 10),
      );

      final october = await flow(2026, 10);
      final moved = october.occurrences.singleWhere(
        (o) => o.nominalDate == _d(2026, 11, 5),
      );
      expect(moved.state, OccurrenceState.received);
    });

    test(
      'later amount, skip and reset keep or drop the pin correctly',
      () async {
        final nominal = _d(2026, 11, 5);
        await h.changeAmount(
          sourceId: salary.id,
          originalDate: nominal,
          amount: const Money(100000),
          actualDate: _d(2026, 12, 2),
        );

        await h.changeAmount(
          sourceId: salary.id,
          originalDate: nominal,
          amount: const Money(90000),
        );
        expect(h.income.entries.single.actualDate, _d(2026, 12, 2));

        await h.skip(sourceId: salary.id, originalDate: nominal);
        expect(h.income.entries.single.actualDate, _d(2026, 12, 2));
        expect(h.income.entries.single.status, IncomeEntryStatus.skipped);

        await h.reset(sourceId: salary.id, originalDate: nominal);
        expect(h.income.entries, isEmpty);
        expect((await flow(2026, 11)).occurrences.single.date, nominal);
      },
    );

    test(
      'a pinned payment is not duplicated when the schedule also makes it',
      () async {
        await h.changeAmount(
          sourceId: salary.id,
          originalDate: _d(2026, 11, 5),
          amount: const Money(100000),
          actualDate: _d(2026, 11, 20),
        );

        final november = await flow(2026, 11);
        expect(november.occurrences, hasLength(1));
        expect(november.occurrences.single.date, _d(2026, 11, 20));
      },
    );
  });

  group('freeze history on edit keeps actual dates', () {
    test('pins the shifted dates of the past', () async {
      final s = await create(
        'Salary',
        const Monthly.onDay(31, shift: ShiftRule.previousWorkingDay),
      );

      await edit(s, minor: 120000);

      // 28 Feb 2026 is a Saturday: paid on Friday 27th.
      final february = h.income.entries.singleWhere(
        (e) => e.originalDate == _d(2026, 2, 28),
      );
      expect(february.actualDate, _d(2026, 2, 27));
      expect(h.income.entries.every((e) => e.actualDate != null), isTrue);
      expect((await flow(2026, 2)).occurrences.single.date, _d(2026, 2, 27));
    });

    test('a later calendar correction does not move frozen payments', () async {
      final s = await create(
        'Salary',
        const Monthly.onDay(31, shift: ShiftRule.previousWorkingDay),
      );
      await edit(s, minor: 120000);

      holidays.extra.add(_d(2026, 2, 27)); // would push February to the 26th

      expect((await flow(2026, 2)).occurrences.single.date, _d(2026, 2, 27));
      // A payment that was NOT frozen follows the corrected calendar.
      holidays.extra.add(_d(2026, 11, 30));
      final november = await flow(2026, 11);
      expect(november.occurrences.single.date, _d(2026, 11, 27));
    });

    test(
      'earlier months do not change; later months use the new amount',
      () async {
        final s = await create(
          'Salary',
          const Monthly.onDay(1, shift: ShiftRule.previousWorkingDay),
        );
        final octoberBefore = await flow(2026, 10);

        await edit(s, minor: 150000);

        final october = await flow(2026, 10);
        expect(october.occurrences.map((o) => o.amount), [
          const Money(100000), // 1 Oct, frozen
          const Money(
            150000,
          ), // 30 Oct (nominal 1 Nov) is after today: new amount
        ]);
        expect(
          october.occurrences.first.amount,
          octoberBefore.occurrences.first.amount,
        );
        expect(
          (await flow(2026, 9)).projectedClosingBalance,
          const Money(800000), // Feb..Sep; 1 Jan would be paid before the start
        );
      },
    );

    test('a skipped payment stays skipped and keeps its pinned date', () async {
      final s = await create(
        'Salary',
        const Monthly.onDay(31, shift: ShiftRule.previousWorkingDay),
      );
      await h.skip(sourceId: s.id, originalDate: _d(2026, 8, 31));

      await edit(s, minor: 120000);

      final august = (await flow(2026, 8)).occurrences.single;
      expect(august.state, OccurrenceState.skipped);
      expect(august.date, _d(2026, 8, 31));
      expect(
        h.income.entries
            .singleWhere((e) => e.originalDate == _d(2026, 8, 31))
            .actualDate,
        _d(2026, 8, 31),
      );
    });

    test(
      'changing the schedule keeps the old payments where they were paid',
      () async {
        final s = await create('Salary', const Monthly.onDay(10));

        await edit(s, schedule: const Monthly.onDay(20));

        final september = (await flow(2026, 9)).occurrences;
        expect(september.single.date, _d(2026, 9, 10));
        // Today is 18 Oct: the 10th was paid, the new 20th is still expected.
        final october = (await flow(2026, 10)).occurrences;
        expect(october.map((o) => o.date), [
          _d(2026, 10, 10),
          _d(2026, 10, 20),
        ]);
        expect(october.last.state, OccurrenceState.expected);
      },
    );

    test('changing only the shift rule also freezes history', () async {
      final s = await create(
        'Salary',
        const Monthly.onDay(31, shift: ShiftRule.previousWorkingDay),
      );

      await edit(s, schedule: const Monthly.onDay(31));

      // With no shifting the future would be on the 28th, the past stays on 27th.
      expect((await flow(2026, 2)).occurrences.single.date, _d(2026, 2, 27));
    });
  });

  group('new schedule kinds in the cash flow', () {
    test(
      'weekly: three Fridays received, two expected (October 2026)',
      () async {
        await create(
          'Pocket money',
          const Weekly(DateTime.friday),
          minor: 5000,
        );

        final october = await flow(2026, 10);

        expect(october.occurrences, hasLength(5));
        expect(october.receivedIncome, const Money(15000));
        expect(october.expectedIncome, const Money(10000));
      },
    );

    test('several per month adds every payment', () async {
      await create(
        'Salary',
        SeveralPerMonth(const [DayOfMonth(1), DayOfMonth(15)]),
        minor: 50000,
      );

      final october = await flow(2026, 10);

      expect(october.occurrences.map((o) => o.date), [
        _d(2026, 10, 1),
        _d(2026, 10, 15),
      ]);
      expect(october.receivedIncome, const Money(100000));
    });

    test('the third working day of the month', () async {
      await create('Rent', const Monthly(NthWorkingDay(3)));

      final january = await flow(2026, 1);

      // 1 Jan and 6 Jan are holidays, so: 2 Jan, 5 Jan, 7 Jan.
      expect(january.occurrences.single.date, _d(2026, 1, 7));
    });
  });
}
