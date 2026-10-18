import 'dart:convert';

import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';

/// Thrown when stored schedule JSON cannot be understood (unknown version or
/// type, wrong shape). Never returns a guessed schedule.
class ScheduleDecodeException implements Exception {
  const ScheduleDecodeException(this.reason);

  final String reason;

  @override
  String toString() => 'ScheduleDecodeException($reason)';
}

/// Versioned JSON codec for [IncomeSchedule], kept in the data layer.
///
/// ```json
/// {"v":1,"type":"one_off","date":"2026-03-05"}
/// {"v":1,"type":"monthly","day":31}
/// {"v":1,"type":"monthly","day":"last"}
/// ```
abstract final class IncomeScheduleCodec {
  static const int currentVersion = 1;

  static String encode(IncomeSchedule schedule) {
    final Map<String, Object?> json = switch (schedule) {
      OneOff(:final date) => <String, Object?>{
        'v': currentVersion,
        'type': 'one_off',
        'date': date.toString(),
      },
      Monthly(:final dayOfMonth) => <String, Object?>{
        'v': currentVersion,
        'type': 'monthly',
        'day': dayOfMonth ?? 'last',
      },
    };
    return jsonEncode(json);
  }

  static IncomeSchedule decode(String text) {
    final Object? parsed;
    try {
      parsed = jsonDecode(text);
    } on FormatException {
      throw const ScheduleDecodeException('not valid JSON');
    }
    if (parsed is! Map<String, Object?>) {
      throw const ScheduleDecodeException('not a JSON object');
    }
    final version = parsed['v'];
    if (version != currentVersion) {
      throw ScheduleDecodeException('unsupported version: $version');
    }
    final type = parsed['type'];
    switch (type) {
      case 'one_off':
        final date = parsed['date'];
        if (date is! String) {
          throw const ScheduleDecodeException('one_off needs a date');
        }
        try {
          return OneOff(CalendarDate.parse(date));
        } on FormatException {
          throw const ScheduleDecodeException('one_off date is invalid');
        }
      case 'monthly':
        final day = parsed['day'];
        if (day == 'last') return const Monthly.onLastDay();
        if (day is int && day >= 1 && day <= 31) return Monthly.onDay(day);
        throw const ScheduleDecodeException('monthly day is invalid');
      default:
        throw ScheduleDecodeException('unknown schedule type: $type');
    }
  }
}
