import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';

void main() {
  group('CalendarDate', () {
    test('formats and parses yyyy-MM-dd', () {
      final date = CalendarDate(2026, 3, 5);
      expect(date.toString(), '2026-03-05');
      expect(CalendarDate.parse('2026-03-05'), date);
    });

    test('rejects days that do not exist', () {
      expect(() => CalendarDate(2026, 2, 29), throwsArgumentError);
      expect(() => CalendarDate(2026, 13, 1), throwsArgumentError);
      expect(() => CalendarDate.parse('2026-02-30'), throwsFormatException);
      expect(() => CalendarDate.parse('2026-2-3'), throwsFormatException);
      expect(() => CalendarDate.parse('garbage'), throwsFormatException);
    });

    test('a leap day exists only in leap years', () {
      expect(CalendarDate(2028, 2, 29).toString(), '2028-02-29');
      expect(() => CalendarDate(2100, 2, 29), throwsArgumentError);
    });

    test('addDays crosses months and years', () {
      expect(CalendarDate(2026, 12, 31).addDays(1), CalendarDate(2027, 1, 1));
      expect(CalendarDate(2026, 3, 1).addDays(-1), CalendarDate(2026, 2, 28));
      expect(CalendarDate(2028, 3, 1).addDays(-1), CalendarDate(2028, 2, 29));
    });

    test('addDays is not affected by a daylight saving change', () {
      // Greece switched to summer time on 2026-03-29.
      expect(CalendarDate(2026, 3, 28).addDays(1), CalendarDate(2026, 3, 29));
      expect(CalendarDate(2026, 3, 28).addDays(2), CalendarDate(2026, 3, 30));
      expect(CalendarDate(2026, 10, 24).addDays(2), CalendarDate(2026, 10, 26));
    });

    test('compares chronologically', () {
      expect(
        CalendarDate(2026, 3, 5).isBefore(CalendarDate(2026, 3, 6)),
        isTrue,
      );
      expect(
        CalendarDate(2027, 1, 1).isAfter(CalendarDate(2026, 12, 31)),
        isTrue,
      );
      expect(CalendarDate(2026, 3, 5).compareTo(CalendarDate(2026, 3, 5)), 0);
    });

    test('weekday: 2026-10-18 is a Sunday', () {
      expect(CalendarDate(2026, 10, 18).weekday, DateTime.sunday);
    });

    test('toUtcDateTime is midnight UTC', () {
      final dt = CalendarDate(2026, 3, 1).toUtcDateTime();
      expect(dt, DateTime.utc(2026, 3, 1));
      expect(dt.isUtc, isTrue);
    });

    test('the stored text does not shift in a UTC+3 zone', () {
      // 21:00 UTC on 28 Feb is already 1 March in UTC+3 (Greek summer time
      // offset), but 20:59 UTC is still 28 February.
      const utcPlus3 = Duration(hours: 3);
      expect(
        CalendarDate.fromInstant(
          DateTime.utc(2026, 2, 28, 21),
          offset: utcPlus3,
        ),
        CalendarDate(2026, 3, 1),
      );
      expect(
        CalendarDate.fromInstant(
          DateTime.utc(2026, 2, 28, 20, 59),
          offset: utcPlus3,
        ),
        CalendarDate(2026, 2, 28),
      );
      expect(
        CalendarDate.fromInstant(
          DateTime.utc(2026, 2, 28, 22),
          offset: Duration.zero,
        ),
        CalendarDate(2026, 2, 28),
      );

      // A day stored as text comes back as the same day, whatever the zone.
      final stored = CalendarDate(2026, 3, 1).toString();
      expect(CalendarDate.parse(stored), CalendarDate(2026, 3, 1));
      expect(stored, '2026-03-01');
    });
  });

  group('YearMonth', () {
    test('daysInMonth handles February and leap years', () {
      expect(YearMonth(2026, 2).daysInMonth, 28);
      expect(YearMonth(2028, 2).daysInMonth, 29);
      expect(YearMonth(2100, 2).daysInMonth, 28);
      expect(YearMonth(2026, 4).daysInMonth, 30);
      expect(YearMonth(2026, 12).daysInMonth, 31);
    });

    test('first and last day', () {
      expect(YearMonth(2026, 2).firstDay, CalendarDate(2026, 2, 1));
      expect(YearMonth(2026, 2).lastDay, CalendarDate(2026, 2, 28));
    });

    test('plusMonths crosses years in both directions', () {
      expect(YearMonth(2026, 12).plusMonths(1), YearMonth(2027, 1));
      expect(YearMonth(2026, 1).plusMonths(-1), YearMonth(2025, 12));
      expect(YearMonth(2026, 10).plusMonths(-22), YearMonth(2024, 12));
    });

    test('dayClamped uses the last day of a short month', () {
      expect(YearMonth(2026, 2).dayClamped(31), CalendarDate(2026, 2, 28));
      expect(YearMonth(2028, 2).dayClamped(30), CalendarDate(2028, 2, 29));
      expect(YearMonth(2026, 4).dayClamped(31), CalendarDate(2026, 4, 30));
      expect(YearMonth(2026, 4).dayClamped(15), CalendarDate(2026, 4, 15));
    });

    test('rejects an invalid month', () {
      expect(() => YearMonth(2026, 0), throwsArgumentError);
      expect(() => YearMonth(2026, 13), throwsArgumentError);
    });
  });
}
