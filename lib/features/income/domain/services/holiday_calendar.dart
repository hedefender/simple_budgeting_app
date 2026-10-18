import 'package:simple_budgeting_app/core/time/calendar_date.dart';

/// Tells which days are public holidays. Pure domain contract; the Greek
/// implementation lives in the data layer.
abstract interface class HolidayCalendar {
  bool isHoliday(CalendarDate date);
}

/// A calendar without holidays (only weekends are non-working).
class NoHolidays implements HolidayCalendar {
  const NoHolidays();

  @override
  bool isHoliday(CalendarDate date) => false;
}
