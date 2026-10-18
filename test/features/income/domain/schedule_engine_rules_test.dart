import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/data/greek_holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/services/schedule_engine.dart';

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

ScheduledPayment _p(CalendarDate nominal, CalendarDate actual) =>
    ScheduledPayment(nominal: nominal, actual: actual);

void main() {
  final engine = ScheduleEngine(GreekHolidayCalendar());
  const noHolidayEngine = ScheduleEngine();

  List<ScheduledPayment> inMonth(
    IncomeSchedule schedule,
    int year,
    int month, {
    ScheduleEngine? using,
  }) => (using ?? engine).occurrencesInMonth(schedule, YearMonth(year, month));

  List<CalendarDate> actual(List<ScheduledPayment> payments) =>
      payments.map((p) => p.actual).toList();

  group('weekly', () {
    test('a month with five Fridays (October 2026) has five payments', () {
      for (final shift in ShiftRule.values) {
        expect(
          actual(inMonth(Weekly(DateTime.friday, shift: shift), 2026, 10)),
          [
            _d(2026, 10, 2),
            _d(2026, 10, 9),
            _d(2026, 10, 16),
            _d(2026, 10, 23),
            _d(2026, 10, 30),
          ],
          reason: '$shift',
        );
      }
    });

    test('a month with four Fridays (November 2026)', () {
      expect(actual(inMonth(const Weekly(DateTime.friday), 2026, 11)), [
        _d(2026, 11, 6),
        _d(2026, 11, 13),
        _d(2026, 11, 20),
        _d(2026, 11, 27),
      ]);
    });

    test('February 2026 has exactly four of every weekday', () {
      for (var weekday = 1; weekday <= 7; weekday++) {
        expect(inMonth(Weekly(weekday), 2026, 2), hasLength(4));
      }
    });

    test('leap February 2028 has five Tuesdays (1, 8, 15, 22, 29)', () {
      expect(actual(inMonth(const Weekly(DateTime.tuesday), 2028, 2)), [
        _d(2028, 2, 1),
        _d(2028, 2, 8),
        _d(2028, 2, 15),
        _d(2028, 2, 22),
        _d(2028, 2, 29),
      ]);
    });

    test('1 May 2026 (Friday, holiday): previous moves it into April', () {
      const schedule = Weekly(
        DateTime.friday,
        shift: ShiftRule.previousWorkingDay,
      );

      expect(actual(inMonth(schedule, 2026, 5)), [
        _d(2026, 5, 8),
        _d(2026, 5, 15),
        _d(2026, 5, 22),
        _d(2026, 5, 29),
      ]);
      expect(
        inMonth(schedule, 2026, 4).last,
        _p(_d(2026, 5, 1), _d(2026, 4, 30)),
      );
      expect(inMonth(schedule, 2026, 4), hasLength(5)); // 3, 10*, 17, 24, 1 May
    });

    test('1 May 2026: next moves it to Monday 4 May', () {
      const schedule = Weekly(DateTime.friday, shift: ShiftRule.nextWorkingDay);

      expect(
        inMonth(schedule, 2026, 5).first,
        _p(_d(2026, 5, 1), _d(2026, 5, 4)),
      );
      expect(inMonth(schedule, 2026, 4).last.actual, _d(2026, 4, 24));
    });

    test('Good Friday 2026 (10 April) moves to Thursday or Tuesday', () {
      final previous = inMonth(
        const Weekly(DateTime.friday, shift: ShiftRule.previousWorkingDay),
        2026,
        4,
      );
      final next = inMonth(
        const Weekly(DateTime.friday, shift: ShiftRule.nextWorkingDay),
        2026,
        4,
      );

      expect(previous.map((p) => p.nominal), contains(_d(2026, 4, 10)));
      expect(
        previous.singleWhere((p) => p.nominal == _d(2026, 4, 10)).actual,
        _d(2026, 4, 9),
      );
      expect(
        next.singleWhere((p) => p.nominal == _d(2026, 4, 10)).actual,
        _d(2026, 4, 14),
      );
    });

    test(
      'Saturday and Sunday payments: none keeps, previous goes to Friday',
      () {
        expect(actual(inMonth(const Weekly(DateTime.saturday), 2026, 10)), [
          _d(2026, 10, 3),
          _d(2026, 10, 10),
          _d(2026, 10, 17),
          _d(2026, 10, 24),
          _d(2026, 10, 31),
        ]);
        expect(
          actual(
            inMonth(
              const Weekly(
                DateTime.sunday,
                shift: ShiftRule.previousWorkingDay,
              ),
              2026,
              10,
            ),
          ),
          // Sundays 4, 11, 18, 25 Oct and 1 Nov go back to Fridays.
          [
            _d(2026, 10, 2),
            _d(2026, 10, 9),
            _d(2026, 10, 16),
            _d(2026, 10, 23),
            _d(2026, 10, 30),
          ],
        );
      },
    );
  });

  group('monthly on a day of the month', () {
    test(
      'day 31 in February 2026 is Saturday 28th; previous gives Friday 27th',
      () {
        expect(
          inMonth(
            const Monthly.onDay(31, shift: ShiftRule.previousWorkingDay),
            2026,
            2,
          ),
          [_p(_d(2026, 2, 28), _d(2026, 2, 27))],
        );
      },
    );

    test('February 2028 (leap): day 31 is Tuesday 29th, no shift needed', () {
      expect(
        inMonth(
          const Monthly.onDay(31, shift: ShiftRule.previousWorkingDay),
          2028,
          2,
        ),
        [_p(_d(2028, 2, 29), _d(2028, 2, 29))],
      );
    });

    test('none keeps a weekend date', () {
      expect(inMonth(const Monthly.onDay(17), 2026, 10), [
        _p(_d(2026, 10, 17), _d(2026, 10, 17)),
      ]);
    });

    test('a shifted payment appears only in the month of its actual date', () {
      const schedule = Monthly.onDay(1, shift: ShiftRule.previousWorkingDay);

      // 1 Nov 2026 is a Sunday. October holds 1 Oct and the shifted 1 Nov.
      expect(inMonth(schedule, 2026, 10), [
        _p(_d(2026, 10, 1), _d(2026, 10, 1)),
        _p(_d(2026, 11, 1), _d(2026, 10, 30)),
      ]);
      // November holds nothing: its own 1st moved to October, 1 Dec is in December.
      expect(inMonth(schedule, 2026, 11), isEmpty);
      // 1 Jan 2027 is a holiday (Friday) and moves back to 31 Dec.
      expect(inMonth(schedule, 2026, 12), [
        _p(_d(2026, 12, 1), _d(2026, 12, 1)),
        _p(_d(2027, 1, 1), _d(2026, 12, 31)),
      ]);
    });

    test('next working day from the last day goes to the next month', () {
      const schedule = Monthly.onLastDay(shift: ShiftRule.nextWorkingDay);

      // 31 Oct 2026 is a Saturday.
      expect(inMonth(schedule, 2026, 10), isEmpty);
      expect(inMonth(schedule, 2026, 11), [
        _p(_d(2026, 10, 31), _d(2026, 11, 2)),
        _p(_d(2026, 11, 30), _d(2026, 11, 30)),
      ]);
    });

    test('Greek holidays: 25 March 2026 (Wednesday)', () {
      expect(
        inMonth(
          const Monthly.onDay(25, shift: ShiftRule.previousWorkingDay),
          2026,
          3,
        ),
        [_p(_d(2026, 3, 25), _d(2026, 3, 24))],
      );
      expect(
        inMonth(
          const Monthly.onDay(25, shift: ShiftRule.nextWorkingDay),
          2026,
          3,
        ),
        [_p(_d(2026, 3, 25), _d(2026, 3, 26))],
      );
    });

    test('without holidays only weekends move', () {
      expect(
        inMonth(
          const Monthly.onDay(25, shift: ShiftRule.previousWorkingDay),
          2026,
          3,
          using: noHolidayEngine,
        ),
        [_p(_d(2026, 3, 25), _d(2026, 3, 25))],
      );
    });

    test('exactly one payment in every month of a year', () {
      for (var m = 1; m <= 12; m++) {
        final payments = <ScheduledPayment>[
          for (final p in inMonth(
            const Monthly.onDay(15, shift: ShiftRule.previousWorkingDay),
            2026,
            m,
          ))
            p,
        ];
        expect(payments, hasLength(1), reason: 'month $m');
      }
    });
  });

  group('monthly on the last day', () {
    test('February, leap February and 30-day months', () {
      const schedule = Monthly.onLastDay();
      expect(inMonth(schedule, 2026, 2).single.actual, _d(2026, 2, 28));
      expect(inMonth(schedule, 2028, 2).single.actual, _d(2028, 2, 29));
      expect(inMonth(schedule, 2026, 4).single.actual, _d(2026, 4, 30));
    });

    test('31 December 2026 is a Thursday: no shift', () {
      expect(
        inMonth(
          const Monthly.onLastDay(shift: ShiftRule.previousWorkingDay),
          2026,
          12,
        ),
        [_p(_d(2026, 12, 31), _d(2026, 12, 31))],
      );
    });
  });

  group('nth working day', () {
    test('is never shifted, whatever the shift rule says', () {
      for (final shift in ShiftRule.values) {
        expect(
          inMonth(Monthly(const NthWorkingDay(1), shift: shift), 2026, 1),
          [_p(_d(2026, 1, 2), _d(2026, 1, 2))],
        );
      }
    });

    test('third working day of January 2026 is 7 Jan (6 Jan is a holiday)', () {
      expect(
        inMonth(const Monthly(NthWorkingDay(3)), 2026, 1).single.actual,
        _d(2026, 1, 7),
      );
    });

    test('the last working day of October 2026 is the 21st', () {
      expect(
        inMonth(const Monthly(NthWorkingDay(21)), 2026, 10).single.actual,
        _d(2026, 10, 30),
      );
    });

    test('a month with fewer working days has no payment', () {
      expect(inMonth(const Monthly(NthWorkingDay(22)), 2026, 10), isEmpty);
      expect(inMonth(const Monthly(NthWorkingDay(23)), 2026, 2), isEmpty);
    });

    test('depends on the holiday calendar', () {
      final noHolidays = inMonth(
        const Monthly(NthWorkingDay(3)),
        2026,
        1,
        using: noHolidayEngine,
      );
      expect(noHolidays.single.actual, _d(2026, 1, 5));
    });
  });

  group('several payments per month', () {
    test('1st and 15th', () {
      expect(
        actual(
          inMonth(
            SeveralPerMonth(const [DayOfMonth(1), DayOfMonth(15)]),
            2026,
            10,
          ),
        ),
        [_d(2026, 10, 1), _d(2026, 10, 15)],
      );
    });

    test('rules giving the same nominal date make one payment', () {
      final schedule = SeveralPerMonth(const [DayOfMonth(30), LastDay()]);
      expect(inMonth(schedule, 2026, 4), hasLength(1)); // 30 days
      expect(inMonth(schedule, 2026, 2), hasLength(1)); // day 30 -> 28 = last
      expect(inMonth(schedule, 2026, 1), hasLength(2)); // 30 and 31
    });

    test('different nominal dates may share an actual date', () {
      // Good Friday 10 Apr, Sun 12 Apr: both go back to Thursday 9 Apr.
      final schedule = SeveralPerMonth(const [
        DayOfMonth(10),
        DayOfMonth(12),
      ], shift: ShiftRule.previousWorkingDay);

      expect(inMonth(schedule, 2026, 4), [
        _p(_d(2026, 4, 10), _d(2026, 4, 9)),
        _p(_d(2026, 4, 12), _d(2026, 4, 9)),
      ]);
    });

    test('mixing rules; the shift applies to day rules only', () {
      final schedule = SeveralPerMonth(const [
        NthWorkingDay(1),
        LastDay(),
      ], shift: ShiftRule.previousWorkingDay);

      // November 2026: 1st working day Mon 2 Nov; last day Mon 30 Nov.
      expect(inMonth(schedule, 2026, 11), [
        _p(_d(2026, 11, 2), _d(2026, 11, 2)),
        _p(_d(2026, 11, 30), _d(2026, 11, 30)),
      ]);
      // October 2026: last day Sat 31 Oct -> Fri 30 Oct.
      expect(
        inMonth(schedule, 2026, 10).last,
        _p(_d(2026, 10, 31), _d(2026, 10, 30)),
      );
    });

    test('results are sorted by actual date', () {
      final schedule = SeveralPerMonth(const [
        LastDay(),
        DayOfMonth(1),
      ], shift: ShiftRule.previousWorkingDay);

      final dates = actual(inMonth(schedule, 2026, 10));
      expect(dates, orderedEquals([...dates]..sort()));
    });
  });

  group('one-off', () {
    test('is never shifted', () {
      final schedule = OneOff(_d(2026, 10, 17)); // Saturday
      expect(inMonth(schedule, 2026, 10), [
        _p(_d(2026, 10, 17), _d(2026, 10, 17)),
      ]);
      expect(inMonth(schedule, 2026, 9), isEmpty);
      expect(inMonth(schedule, 2026, 11), isEmpty);
    });
  });
}
