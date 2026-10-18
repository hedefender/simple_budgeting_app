import 'package:flutter/foundation.dart';

/// A calendar day (no time, no time zone), for example the day an income is
/// due. Instants (created_at, archived_at) are UTC `DateTime`s; days are
/// `CalendarDate`s.
///
/// Stored as text `yyyy-MM-dd`. All arithmetic goes through `DateTime.utc`,
/// never local time, so DST and the device time zone cannot shift a day.
@immutable
class CalendarDate implements Comparable<CalendarDate> {
  /// Throws [ArgumentError] when the combination is not a real day.
  factory CalendarDate(int year, int month, int day) {
    final check = DateTime.utc(year, month, day);
    if (check.year != year || check.month != month || check.day != day) {
      throw ArgumentError('Not a calendar day: $year-$month-$day');
    }
    return CalendarDate._(year, month, day);
  }

  const CalendarDate._(this.year, this.month, this.day);

  /// Parses `yyyy-MM-dd`. Throws [FormatException] otherwise.
  factory CalendarDate.parse(String text) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
    if (match == null) throw FormatException('Not yyyy-MM-dd', text);
    try {
      return CalendarDate(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      );
    } on ArgumentError {
      throw FormatException('Not a real calendar day', text);
    }
  }

  /// The calendar day that [instant] falls on, in the time zone given by
  /// [offset]. Without [offset] the device's current offset for that instant
  /// is used (the user's own calendar day).
  factory CalendarDate.fromInstant(DateTime instant, {Duration? offset}) {
    final utc = instant.toUtc();
    final shifted = utc.add(offset ?? instant.toLocal().timeZoneOffset);
    return CalendarDate(shifted.year, shifted.month, shifted.day);
  }

  final int year;
  final int month;
  final int day;

  /// Midnight UTC of this day. Only for arithmetic, not for storage.
  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  CalendarDate addDays(int days) {
    final moved = toUtcDateTime().add(Duration(days: days));
    return CalendarDate(moved.year, moved.month, moved.day);
  }

  /// 1 = Monday ... 7 = Sunday.
  int get weekday => toUtcDateTime().weekday;

  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  @override
  int compareTo(CalendarDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `yyyy-MM-dd`, the storage format.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
