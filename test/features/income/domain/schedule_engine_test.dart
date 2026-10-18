import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/services/schedule_engine.dart';

void main() {
  const engine = ScheduleEngine();

  List<CalendarDate> inMonth(IncomeSchedule s, int y, int m) =>
      engine.occurrencesInMonth(s, YearMonth(y, m));

  group('Monthly on a day', () {
    test('a normal day lands on that day', () {
      expect(inMonth(const Monthly.onDay(5), 2026, 10), [
        CalendarDate(2026, 10, 5),
      ]);
    });

    test('day 31 in February 2026 is the 28th', () {
      expect(inMonth(const Monthly.onDay(31), 2026, 2), [
        CalendarDate(2026, 2, 28),
      ]);
    });

    test('day 29 and 30 in February 2026 are the 28th', () {
      expect(inMonth(const Monthly.onDay(29), 2026, 2), [
        CalendarDate(2026, 2, 28),
      ]);
      expect(inMonth(const Monthly.onDay(30), 2026, 2), [
        CalendarDate(2026, 2, 28),
      ]);
    });

    test('leap year: day 29 is the 29th, day 30 and 31 are the 29th', () {
      expect(inMonth(const Monthly.onDay(29), 2028, 2), [
        CalendarDate(2028, 2, 29),
      ]);
      expect(inMonth(const Monthly.onDay(30), 2028, 2), [
        CalendarDate(2028, 2, 29),
      ]);
      expect(inMonth(const Monthly.onDay(31), 2028, 2), [
        CalendarDate(2028, 2, 29),
      ]);
    });

    test('2100 is not a leap year', () {
      expect(inMonth(const Monthly.onDay(29), 2100, 2), [
        CalendarDate(2100, 2, 28),
      ]);
    });

    test(
      'day 31 in a 30-day month is the 30th, in a 31-day month the 31st',
      () {
        expect(inMonth(const Monthly.onDay(31), 2026, 4), [
          CalendarDate(2026, 4, 30),
        ]);
        expect(inMonth(const Monthly.onDay(31), 2026, 5), [
          CalendarDate(2026, 5, 31),
        ]);
      },
    );

    test('exactly one payment in every month of a year', () {
      for (var m = 1; m <= 12; m++) {
        expect(inMonth(const Monthly.onDay(31), 2026, m), hasLength(1));
      }
    });
  });

  group('Monthly on the last day', () {
    test('is the real last day of every month', () {
      const lastDay = Monthly.onLastDay();
      expect(inMonth(lastDay, 2026, 2), [CalendarDate(2026, 2, 28)]);
      expect(inMonth(lastDay, 2028, 2), [CalendarDate(2028, 2, 29)]);
      expect(inMonth(lastDay, 2026, 4), [CalendarDate(2026, 4, 30)]);
      expect(inMonth(lastDay, 2026, 12), [CalendarDate(2026, 12, 31)]);
    });
  });

  group('OneOff', () {
    final schedule = OneOff(CalendarDate(2026, 3, 15));

    test('appears only in its own month', () {
      expect(inMonth(schedule, 2026, 3), [CalendarDate(2026, 3, 15)]);
      expect(inMonth(schedule, 2026, 2), isEmpty);
      expect(inMonth(schedule, 2026, 4), isEmpty);
      expect(inMonth(schedule, 2027, 3), isEmpty);
    });
  });

  group('IncomeSchedule equality', () {
    test('value equality', () {
      expect(const Monthly.onDay(5), const Monthly.onDay(5));
      expect(const Monthly.onDay(5), isNot(const Monthly.onDay(6)));
      expect(const Monthly.onLastDay(), const Monthly.onLastDay());
      expect(const Monthly.onLastDay(), isNot(const Monthly.onDay(31)));
      expect(
        OneOff(CalendarDate(2026, 1, 1)),
        OneOff(CalendarDate(2026, 1, 1)),
      );
    });
  });
}
