import 'package:simple_budgeting_app/core/time/calendar_date.dart';

/// Orthodox Easter Sunday of [year] as a Gregorian date.
///
/// Meeus' Julian algorithm gives the date in the Julian calendar; it is then
/// moved to the Gregorian calendar by the difference of the two calendars in
/// that year (13 days for 1900-2099, 14 days for 2100-2199).
CalendarDate orthodoxEaster(int year) {
  final a = year % 4;
  final b = year % 7;
  final c = year % 19;
  final d = (19 * c + 15) % 30;
  final e = (2 * a + 4 * b - d + 34) % 7;
  final month = (d + e + 114) ~/ 31; // 3 = March, 4 = April
  final day = (d + e + 114) % 31 + 1;
  final julian = DateTime.utc(year, month, day);
  final gregorian = julian.add(Duration(days: julianGregorianOffsetDays(year)));
  return CalendarDate(gregorian.year, gregorian.month, gregorian.day);
}

/// Days the Gregorian calendar is ahead of the Julian one for dates from
/// 1 March of [year] until the end of that year: `century - century/4 - 2`.
int julianGregorianOffsetDays(int year) => year ~/ 100 - year ~/ 400 - 2;
