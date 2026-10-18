import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/data/greek_holiday_calendar.dart';

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

void main() {
  final calendar = GreekHolidayCalendar();

  group('Orthodox Easter (Gregorian date)', () {
    // Source: Wikipedia, "List of dates for Easter" (see docs/holidays.md).
    final known = <int, CalendarDate>{
      2016: _d(2016, 5, 1),
      2017: _d(2017, 4, 16),
      2018: _d(2018, 4, 8),
      2019: _d(2019, 4, 28),
      2020: _d(2020, 4, 19),
      2021: _d(2021, 5, 2),
      2022: _d(2022, 4, 24),
      2023: _d(2023, 4, 16),
      2024: _d(2024, 5, 5),
      2025: _d(2025, 4, 20),
      2026: _d(2026, 4, 12),
      2027: _d(2027, 5, 2),
      2028: _d(2028, 4, 16),
      2029: _d(2029, 4, 8),
      2030: _d(2030, 4, 28),
      2031: _d(2031, 4, 13),
      2032: _d(2032, 5, 2),
      2033: _d(2033, 4, 24),
      2034: _d(2034, 4, 9),
      2035: _d(2035, 4, 29),
    };

    for (final entry in known.entries) {
      test('${entry.key} is ${entry.value}', () {
        expect(GreekHolidayCalendar.orthodoxEaster(entry.key), entry.value);
      });
    }

    test('the earliest and latest dates between 1875 and 2099', () {
      // Wikipedia: earliest 4 April (1915, 2010), latest 8 May (1983, 2078).
      expect(GreekHolidayCalendar.orthodoxEaster(1915), _d(1915, 4, 4));
      expect(GreekHolidayCalendar.orthodoxEaster(2010), _d(2010, 4, 4));
      expect(GreekHolidayCalendar.orthodoxEaster(1983), _d(1983, 5, 8));
      expect(GreekHolidayCalendar.orthodoxEaster(2078), _d(2078, 5, 8));
    });

    test('is always a Sunday, also across the 2099/2100 boundary', () {
      for (var year = 1900; year <= 2199; year++) {
        expect(
          GreekHolidayCalendar.orthodoxEaster(year).weekday,
          DateTime.sunday,
          reason: 'year $year',
        );
      }
    });

    test('falls between 4 April and 8 May (Gregorian) for 2000-2099', () {
      for (var year = 2000; year <= 2099; year++) {
        final easter = GreekHolidayCalendar.orthodoxEaster(year);
        expect(easter.isBefore(_d(year, 4, 4)), isFalse, reason: '$year');
        expect(easter.isAfter(_d(year, 5, 8)), isFalse, reason: '$year');
      }
    });
  });

  group('Julian - Gregorian difference', () {
    test('is 13 days from 1900 to 2099 and 14 days from 2100', () {
      expect(GreekHolidayCalendar.julianGregorianOffsetDays(1900), 13);
      expect(GreekHolidayCalendar.julianGregorianOffsetDays(2000), 13);
      expect(GreekHolidayCalendar.julianGregorianOffsetDays(2099), 13);
      expect(GreekHolidayCalendar.julianGregorianOffsetDays(2100), 14);
      expect(GreekHolidayCalendar.julianGregorianOffsetDays(2199), 14);
      expect(GreekHolidayCalendar.julianGregorianOffsetDays(2200), 15);
      expect(GreekHolidayCalendar.julianGregorianOffsetDays(1899), 12);
    });
  });

  group('holidays', () {
    test('fixed holidays of 2026', () {
      for (final date in <CalendarDate>[
        _d(2026, 1, 1),
        _d(2026, 1, 6),
        _d(2026, 3, 25),
        _d(2026, 5, 1),
        _d(2026, 8, 15),
        _d(2026, 10, 28),
        _d(2026, 12, 25),
        _d(2026, 12, 26),
      ]) {
        expect(calendar.isHoliday(date), isTrue, reason: '$date');
      }
    });

    test('Easter-based holidays of 2026 (Easter 12 April)', () {
      expect(calendar.isHoliday(_d(2026, 2, 23)), isTrue); // Clean Monday
      expect(calendar.isHoliday(_d(2026, 4, 10)), isTrue); // Good Friday
      expect(calendar.isHoliday(_d(2026, 4, 13)), isTrue); // Easter Monday
      expect(calendar.isHoliday(_d(2026, 6, 1)), isTrue); // Whit Monday
      // Neighbours are not holidays.
      expect(calendar.isHoliday(_d(2026, 2, 24)), isFalse);
      expect(calendar.isHoliday(_d(2026, 4, 9)), isFalse);
      expect(calendar.isHoliday(_d(2026, 4, 14)), isFalse);
      expect(calendar.isHoliday(_d(2026, 6, 2)), isFalse);
    });

    test('Clean Monday and Whit Monday of 2024 and 2025', () {
      // Easter 5 May 2024 and 20 April 2025.
      expect(calendar.isHoliday(_d(2024, 3, 18)), isTrue);
      expect(calendar.isHoliday(_d(2024, 6, 24)), isTrue);
      expect(calendar.isHoliday(_d(2025, 3, 3)), isTrue);
      expect(calendar.isHoliday(_d(2025, 6, 9)), isTrue);
    });

    test('every year has 11 or 12 holidays, all in that year', () {
      for (var year = 2000; year <= 2100; year++) {
        final days = calendar.holidaysOf(year);
        expect(days.length, inInclusiveRange(11, 12), reason: '$year');
        expect(days.every((d) => d.year == year), isTrue, reason: '$year');
      }
    });

    test('two holidays can coincide (2000: Easter Monday is 1 May)', () {
      expect(GreekHolidayCalendar.orthodoxEaster(2000), _d(2000, 4, 30));
      expect(calendar.holidaysOf(2000), hasLength(11));
    });

    test('an ordinary day is not a holiday', () {
      expect(calendar.isHoliday(_d(2026, 10, 14)), isFalse);
      expect(calendar.isHoliday(_d(2026, 11, 2)), isFalse);
    });
  });
}
