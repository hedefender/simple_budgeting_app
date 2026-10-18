import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/services/holiday_calendar.dart';

/// A working day is Monday to Friday and not a holiday.
class WorkingDays {
  const WorkingDays(this._holidays);

  final HolidayCalendar _holidays;

  /// Searching further than this many days means the calendar is broken (no
  /// real calendar has weeks of consecutive holidays).
  static const int _searchLimit = 14;

  bool isWorkingDay(CalendarDate date) =>
      date.weekday <= DateTime.friday && !_holidays.isHoliday(date);

  /// [date] itself if it is a working day, else the closest earlier one.
  CalendarDate previousOrSame(CalendarDate date) => _search(date, -1) ?? date;

  /// [date] itself if it is a working day, else the closest later one.
  CalendarDate nextOrSame(CalendarDate date) => _search(date, 1) ?? date;

  CalendarDate applyShift(CalendarDate date, ShiftRule shift) {
    return switch (shift) {
      ShiftRule.none => date,
      ShiftRule.previousWorkingDay => previousOrSame(date),
      ShiftRule.nextWorkingDay => nextOrSame(date),
    };
  }

  /// The [n]th working day (1 = first) of [month], or null when the month has
  /// fewer.
  CalendarDate? nth(YearMonth month, int n) {
    var count = 0;
    for (var d = 1; d <= month.daysInMonth; d++) {
      final date = CalendarDate(month.year, month.month, d);
      if (isWorkingDay(date) && ++count == n) return date;
    }
    return null;
  }

  CalendarDate? _search(CalendarDate from, int step) {
    var date = from;
    for (var i = 0; i <= _searchLimit; i++) {
      if (isWorkingDay(date)) return date;
      date = date.addDays(step);
    }
    return null;
  }
}
