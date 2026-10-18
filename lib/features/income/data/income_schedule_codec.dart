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
/// Version 2 (written):
/// ```json
/// {"v":2,"type":"one_off","date":"2026-03-05"}
/// {"v":2,"type":"monthly","rule":{"kind":"day","day":31},"shift":"previous"}
/// {"v":2,"type":"monthly","rule":{"kind":"last"},"shift":"none"}
/// {"v":2,"type":"monthly","rule":{"kind":"nth_working","n":3},"shift":"none"}
/// {"v":2,"type":"several_per_month","rules":[{"kind":"day","day":1},{"kind":"day","day":15}],"shift":"next"}
/// {"v":2,"type":"weekly","weekday":5,"shift":"previous"}
/// ```
/// Version 1 (read only, written by Phase 1a): `one_off` as above, and
/// `{"v":1,"type":"monthly","day":31}` / `"day":"last"`. Version 1 had no
/// shifting, so it is read with `ShiftRule.none` and nothing moves.
abstract final class IncomeScheduleCodec {
  static const int currentVersion = 2;

  static String encode(IncomeSchedule schedule) {
    final Map<String, Object?> json = switch (schedule) {
      OneOff(:final date) => <String, Object?>{
        'v': currentVersion,
        'type': 'one_off',
        'date': date.toString(),
      },
      Monthly(:final rule, :final shift) => <String, Object?>{
        'v': currentVersion,
        'type': 'monthly',
        'rule': _encodeRule(rule),
        'shift': _encodeShift(shift),
      },
      SeveralPerMonth(:final rules, :final shift) => <String, Object?>{
        'v': currentVersion,
        'type': 'several_per_month',
        'rules': rules.map(_encodeRule).toList(),
        'shift': _encodeShift(shift),
      },
      Weekly(:final weekday, :final shift) => <String, Object?>{
        'v': currentVersion,
        'type': 'weekly',
        'weekday': weekday,
        'shift': _encodeShift(shift),
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
    return switch (parsed['v']) {
      1 => _decodeV1(parsed),
      2 => _decodeV2(parsed),
      final Object? other => throw ScheduleDecodeException(
        'unsupported version: $other',
      ),
    };
  }

  static IncomeSchedule _decodeV1(Map<String, Object?> json) {
    switch (json['type']) {
      case 'one_off':
        return _decodeOneOff(json);
      case 'monthly':
        final day = json['day'];
        if (day == 'last') return const Monthly.onLastDay();
        if (day is int && day >= 1 && day <= 31) return Monthly.onDay(day);
        throw const ScheduleDecodeException('monthly day is invalid');
      default:
        throw ScheduleDecodeException('unknown schedule type: ${json['type']}');
    }
  }

  static IncomeSchedule _decodeV2(Map<String, Object?> json) {
    switch (json['type']) {
      case 'one_off':
        return _decodeOneOff(json);
      case 'monthly':
        return Monthly(
          _decodeRule(json['rule']),
          shift: _decodeShift(json['shift']),
        );
      case 'several_per_month':
        final rules = json['rules'];
        if (rules is! List<Object?> || rules.length < 2) {
          throw const ScheduleDecodeException(
            'several_per_month needs at least two rules',
          );
        }
        return SeveralPerMonth(
          rules.map(_decodeRule).toList(),
          shift: _decodeShift(json['shift']),
        );
      case 'weekly':
        final weekday = json['weekday'];
        if (weekday is! int || weekday < 1 || weekday > 7) {
          throw const ScheduleDecodeException('weekly weekday is invalid');
        }
        return Weekly(weekday, shift: _decodeShift(json['shift']));
      default:
        throw ScheduleDecodeException('unknown schedule type: ${json['type']}');
    }
  }

  static IncomeSchedule _decodeOneOff(Map<String, Object?> json) {
    final date = json['date'];
    if (date is! String) {
      throw const ScheduleDecodeException('one_off needs a date');
    }
    try {
      return OneOff(CalendarDate.parse(date));
    } on FormatException {
      throw const ScheduleDecodeException('one_off date is invalid');
    }
  }

  static Map<String, Object?> _encodeRule(DayRule rule) {
    return switch (rule) {
      DayOfMonth(:final day) => <String, Object?>{'kind': 'day', 'day': day},
      LastDay() => <String, Object?>{'kind': 'last'},
      NthWorkingDay(:final n) => <String, Object?>{
        'kind': 'nth_working',
        'n': n,
      },
    };
  }

  static DayRule _decodeRule(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const ScheduleDecodeException('rule is not an object');
    }
    switch (json['kind']) {
      case 'day':
        final day = json['day'];
        if (day is int && day >= 1 && day <= 31) return DayOfMonth(day);
        throw const ScheduleDecodeException('rule day is invalid');
      case 'last':
        return const LastDay();
      case 'nth_working':
        final n = json['n'];
        if (n is int && n >= 1 && n <= NthWorkingDay.maxN) {
          return NthWorkingDay(n);
        }
        throw const ScheduleDecodeException('rule n is invalid');
      default:
        throw ScheduleDecodeException('unknown rule kind: ${json['kind']}');
    }
  }

  static String _encodeShift(ShiftRule shift) => switch (shift) {
    ShiftRule.previousWorkingDay => 'previous',
    ShiftRule.nextWorkingDay => 'next',
    ShiftRule.none => 'none',
  };

  static ShiftRule _decodeShift(Object? json) => switch (json) {
    'previous' => ShiftRule.previousWorkingDay,
    'next' => ShiftRule.nextWorkingDay,
    'none' => ShiftRule.none,
    _ => throw ScheduleDecodeException('unknown shift rule: $json'),
  };
}
