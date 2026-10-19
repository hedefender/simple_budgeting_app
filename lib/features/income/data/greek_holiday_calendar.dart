import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/services/holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/domain/services/orthodox_easter.dart'
    as oe;

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

  /// Orthodox Easter Sunday of [year]; the computation lives in the domain
  /// (`orthodox_easter.dart`) because the schedule engine needs it too.
  static CalendarDate orthodoxEaster(int year) => oe.orthodoxEaster(year);

  static int julianGregorianOffsetDays(int year) =>
      oe.julianGregorianOffsetDays(year);
}
