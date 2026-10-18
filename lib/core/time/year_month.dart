import 'package:flutter/foundation.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';

/// A calendar month, for example October 2026.
@immutable
class YearMonth implements Comparable<YearMonth> {
  YearMonth(this.year, this.month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be 1..12');
    }
  }

  factory YearMonth.of(CalendarDate date) => YearMonth(date.year, date.month);

  final int year;
  final int month;

  int get daysInMonth => DateTime.utc(year, month + 1, 0).day;

  CalendarDate get firstDay => CalendarDate(year, month, 1);

  CalendarDate get lastDay => CalendarDate(year, month, daysInMonth);

  /// [day] clamped to the length of this month (31 in February -> 28 or 29).
  CalendarDate dayClamped(int day) =>
      CalendarDate(year, month, day.clamp(1, daysInMonth));

  bool contains(CalendarDate date) => date.year == year && date.month == month;

  YearMonth plusMonths(int months) {
    final index = year * 12 + (month - 1) + months;
    return YearMonth(index ~/ 12, index % 12 + 1);
  }

  @override
  int compareTo(YearMonth other) => year != other.year
      ? year.compareTo(other.year)
      : month.compareTo(other.month);

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}
