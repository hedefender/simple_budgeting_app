import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/services/holiday_calendar.dart';

/// Greek public and bank holidays, computed offline in pure Dart.
///
/// Rules and sources: `docs/holidays.md`. In short:
/// - fixed: 1 Jan, 6 Jan, 25 Mar, 1 May, 15 Aug, 28 Oct, 25 Dec, 26 Dec;
/// - relative to Orthodox Easter Sunday: Clean Monday (-48), Good Friday (-2),
///   Easter Monday (+1), Whit Monday / Holy Spirit Monday (+50).
///
/// Not modelled (not confirmed, see the docs): moving 1 May when it falls in
/// Holy Week, local holidays, holidays that only apply to some sectors.
class GreekHolidayCalendar implements HolidayCalendar {
  GreekHolidayCalendar();

  final Map<int, Set<CalendarDate>> _cache = <int, Set<CalendarDate>>{};

  @override
  bool isHoliday(CalendarDate date) => holidaysOf(date.year).contains(date);

  /// All holidays of [year].
  Set<CalendarDate> holidaysOf(int year) {
    return _cache.putIfAbsent(year, () {
      final easter = orthodoxEaster(year);
      return <CalendarDate>{
        CalendarDate(year, 1, 1),
        CalendarDate(year, 1, 6),
        CalendarDate(year, 3, 25),
        CalendarDate(year, 5, 1),
        CalendarDate(year, 8, 15),
        CalendarDate(year, 10, 28),
        CalendarDate(year, 12, 25),
        CalendarDate(year, 12, 26),
        easter.addDays(-48), // Clean Monday
        easter.addDays(-2), // Good Friday
        easter.addDays(1), // Easter Monday
        easter.addDays(50), // Whit Monday (Holy Spirit)
      };
    });
  }

  /// Orthodox Easter Sunday of [year] as a Gregorian date.
  ///
  /// Meeus' Julian algorithm gives the date in the Julian calendar; it is then
  /// moved to the Gregorian calendar by the difference of the two calendars
  /// in that year (13 days for 1900-2099, 14 days for 2100-2199).
  static CalendarDate orthodoxEaster(int year) {
    final a = year % 4;
    final b = year % 7;
    final c = year % 19;
    final d = (19 * c + 15) % 30;
    final e = (2 * a + 4 * b - d + 34) % 7;
    final month = (d + e + 114) ~/ 31; // 3 = March, 4 = April
    final day = (d + e + 114) % 31 + 1;
    final julian = DateTime.utc(year, month, day);
    final gregorian = julian.add(
      Duration(days: julianGregorianOffsetDays(year)),
    );
    return CalendarDate(gregorian.year, gregorian.month, gregorian.day);
  }

  /// Days the Gregorian calendar is ahead of the Julian one for dates from
  /// 1 March of [year] until the end of that year: `century - century/4 - 2`.
  static int julianGregorianOffsetDays(int year) =>
      year ~/ 100 - year ~/ 400 - 2;
}
