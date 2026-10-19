import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/data/greek_holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/data/income_schedule_codec.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/services/orthodox_easter.dart';
import 'package:simple_budgeting_app/features/income/domain/services/schedule_engine.dart';

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

void main() {
  final engine = ScheduleEngine(GreekHolidayCalendar());

  List<ScheduledPayment> inMonth(IncomeSchedule schedule, int y, int m) =>
      engine.occurrencesInMonth(schedule, YearMonth(y, m));

  List<CalendarDate> actual(List<ScheduledPayment> payments) =>
      payments.map((p) => p.actual).toList();

  group('Yearly with a fixed date (Christmas bonus, 21 December)', () {
    const christmas = Yearly(
      FixedDate(12, 21),
      shift: ShiftRule.previousWorkingDay,
    );

    test('pays once a year, only in its month', () {
      for (var month = 1; month <= 12; month++) {
        expect(
          inMonth(christmas, 2026, month),
          hasLength(month == 12 ? 1 : 0),
          reason: 'month $month',
        );
      }
    });

    test('a working day is not moved (21 Dec 2026 is a Monday)', () {
      expect(actual(inMonth(christmas, 2026, 12)), [_d(2026, 12, 21)]);
    });

    test('Sunday 21 Dec 2025 moves to Friday 19 Dec', () {
      final payment = inMonth(christmas, 2025, 12).single;
      expect(payment.nominal, _d(2025, 12, 21));
      expect(payment.actual, _d(2025, 12, 19));
    });

    test('Saturday 21 Dec 2024 moves to Friday 20 Dec', () {
      expect(actual(inMonth(christmas, 2024, 12)), [_d(2024, 12, 20)]);
    });

    test('shift none keeps the weekend date', () {
      expect(actual(inMonth(const Yearly(FixedDate(12, 21)), 2025, 12)), [
        _d(2025, 12, 21),
      ]);
    });

    test('29 February becomes the last day in a common year', () {
      const leapDay = Yearly(FixedDate(2, 29));
      expect(actual(inMonth(leapDay, 2028, 2)), [_d(2028, 2, 29)]);
      expect(actual(inMonth(leapDay, 2027, 2)), [_d(2027, 2, 28)]);
    });

    test('a shift across a month boundary lands in the other month', () {
      // 1 March 2026 is a Sunday: previous working day is Friday 27 Feb.
      const march1 = Yearly(
        FixedDate(3, 1),
        shift: ShiftRule.previousWorkingDay,
      );
      expect(inMonth(march1, 2026, 3), isEmpty);
      final payment = inMonth(march1, 2026, 2).single;
      expect(payment.nominal, _d(2026, 3, 1));
      expect(payment.actual, _d(2026, 2, 27));
    });
  });

  group('Yearly relative to Orthodox Easter (Holy Wednesday)', () {
    const easterBonus = Yearly(
      EasterRelative(EasterRelative.holyWednesdayOffset),
      shift: ShiftRule.previousWorkingDay,
    );

    test('Holy Wednesday is Easter - 4 days and a Wednesday', () {
      for (var year = 2020; year <= 2040; year++) {
        final date = orthodoxEaster(year).addDays(-4);
        expect(date.weekday, DateTime.wednesday, reason: '$year');
      }
    });

    test('2026: Easter 12 April, so 8 April', () {
      expect(orthodoxEaster(2026), _d(2026, 4, 12));
      expect(actual(inMonth(easterBonus, 2026, 4)), [_d(2026, 4, 8)]);
    });

    test('2027: Easter 2 May, so 28 April', () {
      expect(orthodoxEaster(2027), _d(2027, 5, 2));
      expect(actual(inMonth(easterBonus, 2027, 4)), [_d(2027, 4, 28)]);
      expect(inMonth(easterBonus, 2027, 5), isEmpty);
    });

    test('2025: Easter 20 April, so 16 April; nothing in other months', () {
      expect(actual(inMonth(easterBonus, 2025, 4)), [_d(2025, 4, 16)]);
      expect(inMonth(easterBonus, 2025, 3), isEmpty);
    });

    test('an offset that crosses into the next month is found there', () {
      // Easter 2 May 2027 minus 2 days = Friday 30 April.
      const goodFriday = Yearly(EasterRelative(-2));
      expect(actual(inMonth(goodFriday, 2027, 4)), [_d(2027, 4, 30)]);
    });
  });

  group('IncomeScheduleCodec for Yearly', () {
    test('round trips fixed and Easter-relative schedules', () {
      const schedules = <IncomeSchedule>[
        Yearly(FixedDate(12, 21), shift: ShiftRule.previousWorkingDay),
        Yearly(FixedDate(2, 29)),
        Yearly(EasterRelative(-4), shift: ShiftRule.previousWorkingDay),
        Yearly(EasterRelative(50), shift: ShiftRule.nextWorkingDay),
      ];
      for (final schedule in schedules) {
        expect(
          IncomeScheduleCodec.decode(IncomeScheduleCodec.encode(schedule)),
          schedule,
        );
      }
    });

    test('writes the documented JSON', () {
      expect(
        IncomeScheduleCodec.encode(
          const Yearly(FixedDate(12, 21), shift: ShiftRule.previousWorkingDay),
        ),
        '{"v":2,"type":"yearly","anchor":{"kind":"fixed","month":12,'
        '"day":21},"shift":"previous"}',
      );
      expect(
        IncomeScheduleCodec.encode(const Yearly(EasterRelative(-4))),
        '{"v":2,"type":"yearly","anchor":{"kind":"easter","offset":-4},'
        '"shift":"none"}',
      );
    });

    test('rejects malformed yearly JSON instead of guessing', () {
      const bad = <String>[
        '{"v":2,"type":"yearly","shift":"none"}',
        '{"v":2,"type":"yearly","anchor":"x","shift":"none"}',
        '{"v":2,"type":"yearly","anchor":{"kind":"fixed","month":13,"day":1},"shift":"none"}',
        '{"v":2,"type":"yearly","anchor":{"kind":"fixed","month":1,"day":32},"shift":"none"}',
        '{"v":2,"type":"yearly","anchor":{"kind":"easter","offset":61},"shift":"none"}',
        '{"v":2,"type":"yearly","anchor":{"kind":"easter","offset":"a"},"shift":"none"}',
        '{"v":2,"type":"yearly","anchor":{"kind":"moon"},"shift":"none"}',
        '{"v":2,"type":"yearly","anchor":{"kind":"easter","offset":-4},"shift":"x"}',
      ];
      for (final text in bad) {
        expect(
          () => IncomeScheduleCodec.decode(text),
          throwsA(isA<ScheduleDecodeException>()),
          reason: text,
        );
      }
    });
  });
}
