import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/data/greek_holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/services/holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/domain/services/working_days.dart';

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

class _OnlyHolidays implements HolidayCalendar {
  _OnlyHolidays(this.days);

  final Set<CalendarDate> days;

  @override
  bool isHoliday(CalendarDate date) => days.contains(date);
}

void main() {
  final greek = WorkingDays(GreekHolidayCalendar());
  const plain = WorkingDays(NoHolidays());

  group('isWorkingDay', () {
    test('Monday to Friday, not weekends', () {
      expect(plain.isWorkingDay(_d(2026, 10, 16)), isTrue); // Friday
      expect(plain.isWorkingDay(_d(2026, 10, 17)), isFalse); // Saturday
      expect(plain.isWorkingDay(_d(2026, 10, 18)), isFalse); // Sunday
      expect(plain.isWorkingDay(_d(2026, 10, 19)), isTrue); // Monday
    });

    test('a holiday on a weekday is not a working day', () {
      expect(greek.isWorkingDay(_d(2026, 3, 25)), isFalse); // Wednesday
      expect(plain.isWorkingDay(_d(2026, 3, 25)), isTrue);
    });
  });

  group('shifting around holidays', () {
    test('Easter 2026: Good Friday, weekend, Easter Monday', () {
      // Fri 10 Apr holiday, Sat 11, Sun 12, Mon 13 holiday.
      expect(greek.previousOrSame(_d(2026, 4, 13)), _d(2026, 4, 9));
      expect(greek.previousOrSame(_d(2026, 4, 12)), _d(2026, 4, 9));
      expect(greek.nextOrSame(_d(2026, 4, 10)), _d(2026, 4, 14));
      expect(greek.nextOrSame(_d(2026, 4, 11)), _d(2026, 4, 14));
    });

    test('a working day stays where it is', () {
      expect(greek.previousOrSame(_d(2026, 4, 9)), _d(2026, 4, 9));
      expect(greek.nextOrSame(_d(2026, 4, 9)), _d(2026, 4, 9));
    });

    test('25 March 2026 (Wednesday)', () {
      expect(greek.previousOrSame(_d(2026, 3, 25)), _d(2026, 3, 24));
      expect(greek.nextOrSame(_d(2026, 3, 25)), _d(2026, 3, 26));
    });

    test('Christmas 2026: Fri 25, Sat 26 (holiday), Sun 27', () {
      expect(greek.nextOrSame(_d(2026, 12, 25)), _d(2026, 12, 28));
      expect(greek.previousOrSame(_d(2026, 12, 26)), _d(2026, 12, 24));
    });

    test('crosses a month boundary', () {
      expect(greek.previousOrSame(_d(2026, 11, 1)), _d(2026, 10, 30));
      expect(greek.nextOrSame(_d(2026, 10, 31)), _d(2026, 11, 2));
    });

    test('crosses a year boundary', () {
      // 1 Jan 2026 (Thu) is a holiday; 2 Jan is a working day.
      expect(greek.nextOrSame(_d(2026, 1, 1)), _d(2026, 1, 2));
      expect(greek.previousOrSame(_d(2026, 1, 1)), _d(2025, 12, 31));
    });

    test('a calendar that never has a working day does not loop forever', () {
      final allDays = _OnlyHolidays({
        for (var i = 0; i < 60; i++) _d(2026, 10, 1).addDays(i),
      });
      final days = WorkingDays(allDays);
      // Gives up and returns the date unchanged.
      expect(days.nextOrSame(_d(2026, 10, 1)), _d(2026, 10, 1));
    });

    test('applyShift', () {
      final holiday = _d(2026, 4, 10);
      expect(greek.applyShift(holiday, ShiftRule.none), holiday);
      expect(
        greek.applyShift(holiday, ShiftRule.previousWorkingDay),
        _d(2026, 4, 9),
      );
      expect(
        greek.applyShift(holiday, ShiftRule.nextWorkingDay),
        _d(2026, 4, 14),
      );
    });
  });

  group('nth working day', () {
    test('January 2026 skips 1 Jan (Thu) and 6 Jan (Tue)', () {
      expect(greek.nth(YearMonth(2026, 1), 1), _d(2026, 1, 2));
      expect(greek.nth(YearMonth(2026, 1), 2), _d(2026, 1, 5));
      expect(greek.nth(YearMonth(2026, 1), 3), _d(2026, 1, 7));
    });

    test('October 2026 has 21 working days (22 weekdays minus 28 Oct)', () {
      final october = YearMonth(2026, 10);
      expect(greek.nth(october, 1), _d(2026, 10, 1));
      expect(greek.nth(october, 3), _d(2026, 10, 5));
      expect(greek.nth(october, 21), _d(2026, 10, 30));
      expect(greek.nth(october, 22), isNull);
      expect(plain.nth(october, 22), _d(2026, 10, 30));
    });

    test('the first working day of a month that starts on a weekend', () {
      // 1 Nov 2026 is a Sunday.
      expect(greek.nth(YearMonth(2026, 11), 1), _d(2026, 11, 2));
    });
  });
}
