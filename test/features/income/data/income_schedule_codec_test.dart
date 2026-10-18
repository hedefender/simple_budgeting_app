import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/data/income_schedule_codec.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';

Matcher get _decodeError => throwsA(isA<ScheduleDecodeException>());

void main() {
  test('round trips every supported schedule', () {
    final schedules = <IncomeSchedule>[
      OneOff(CalendarDate(2026, 3, 5)),
      const Monthly.onDay(1),
      const Monthly.onDay(31),
      const Monthly.onLastDay(),
    ];
    for (final schedule in schedules) {
      expect(
        IncomeScheduleCodec.decode(IncomeScheduleCodec.encode(schedule)),
        schedule,
      );
    }
  });

  test('writes the documented versioned JSON', () {
    expect(
      IncomeScheduleCodec.encode(OneOff(CalendarDate(2026, 3, 5))),
      '{"v":1,"type":"one_off","date":"2026-03-05"}',
    );
    expect(
      IncomeScheduleCodec.encode(const Monthly.onDay(31)),
      '{"v":1,"type":"monthly","day":31}',
    );
    expect(
      IncomeScheduleCodec.encode(const Monthly.onLastDay()),
      '{"v":1,"type":"monthly","day":"last"}',
    );
  });

  test('an unknown type fails safely', () {
    expect(
      () => IncomeScheduleCodec.decode('{"v":1,"type":"weekly","day":2}'),
      _decodeError,
    );
  });

  test('an unknown or missing version fails safely', () {
    expect(
      () => IncomeScheduleCodec.decode('{"v":2,"type":"monthly","day":5}'),
      _decodeError,
    );
    expect(
      () => IncomeScheduleCodec.decode('{"type":"monthly","day":5}'),
      _decodeError,
    );
  });

  test('malformed content fails safely', () {
    for (final text in <String>[
      '',
      'not json',
      '[]',
      '"monthly"',
      '{}',
      '{"v":1}',
      '{"v":1,"type":"monthly"}',
      '{"v":1,"type":"monthly","day":0}',
      '{"v":1,"type":"monthly","day":32}',
      '{"v":1,"type":"monthly","day":"first"}',
      '{"v":1,"type":"monthly","day":5.5}',
      '{"v":1,"type":"one_off"}',
      '{"v":1,"type":"one_off","date":"2026-02-30"}',
      '{"v":1,"type":"one_off","date":20260305}',
    ]) {
      expect(
        () => IncomeScheduleCodec.decode(text),
        _decodeError,
        reason: text,
      );
    }
  });
}
