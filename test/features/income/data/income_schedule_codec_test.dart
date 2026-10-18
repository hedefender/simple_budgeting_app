import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/data/income_schedule_codec.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';

Matcher get _decodeError => throwsA(isA<ScheduleDecodeException>());

void main() {
  group('version 2 (written)', () {
    final schedules = <IncomeSchedule>[
      OneOff(CalendarDate(2026, 3, 5)),
      const Monthly.onDay(1),
      const Monthly.onDay(31, shift: ShiftRule.previousWorkingDay),
      const Monthly.onLastDay(shift: ShiftRule.nextWorkingDay),
      const Monthly(NthWorkingDay(3)),
      SeveralPerMonth(const [DayOfMonth(1), DayOfMonth(15)]),
      SeveralPerMonth(const [
        DayOfMonth(10),
        LastDay(),
        NthWorkingDay(2),
      ], shift: ShiftRule.previousWorkingDay),
      const Weekly(5, shift: ShiftRule.previousWorkingDay),
      const Weekly(7),
    ];

    test('round trips every schedule', () {
      for (final schedule in schedules) {
        expect(
          IncomeScheduleCodec.decode(IncomeScheduleCodec.encode(schedule)),
          schedule,
          reason: '$schedule',
        );
      }
    });

    test('writes the documented JSON', () {
      expect(
        IncomeScheduleCodec.encode(OneOff(CalendarDate(2026, 3, 5))),
        '{"v":2,"type":"one_off","date":"2026-03-05"}',
      );
      expect(
        IncomeScheduleCodec.encode(
          const Monthly.onDay(31, shift: ShiftRule.previousWorkingDay),
        ),
        '{"v":2,"type":"monthly","rule":{"kind":"day","day":31},'
        '"shift":"previous"}',
      );
      expect(
        IncomeScheduleCodec.encode(const Monthly.onLastDay()),
        '{"v":2,"type":"monthly","rule":{"kind":"last"},"shift":"none"}',
      );
      expect(
        IncomeScheduleCodec.encode(const Monthly(NthWorkingDay(3))),
        '{"v":2,"type":"monthly","rule":{"kind":"nth_working","n":3},'
        '"shift":"none"}',
      );
      expect(
        IncomeScheduleCodec.encode(
          SeveralPerMonth(const [
            DayOfMonth(1),
            DayOfMonth(15),
          ], shift: ShiftRule.nextWorkingDay),
        ),
        '{"v":2,"type":"several_per_month","rules":['
        '{"kind":"day","day":1},{"kind":"day","day":15}],"shift":"next"}',
      );
      expect(
        IncomeScheduleCodec.encode(const Weekly(5)),
        '{"v":2,"type":"weekly","weekday":5,"shift":"none"}',
      );
    });
  });

  group('version 1 (read only, backward compatible)', () {
    test('one_off is read as before', () {
      expect(
        IncomeScheduleCodec.decode(
          '{"v":1,"type":"one_off","date":"2026-03-05"}',
        ),
        OneOff(CalendarDate(2026, 3, 5)),
      );
    });

    test('monthly on a day is read with NO shifting', () {
      final schedule = IncomeScheduleCodec.decode(
        '{"v":1,"type":"monthly","day":31}',
      );
      expect(schedule, const Monthly.onDay(31));
      expect((schedule as Monthly).shift, ShiftRule.none);
      expect(schedule.dayOfMonth, 31);
    });

    test('monthly on the last day is read with NO shifting', () {
      final schedule = IncomeScheduleCodec.decode(
        '{"v":1,"type":"monthly","day":"last"}',
      );
      expect(schedule, const Monthly.onLastDay());
      expect((schedule as Monthly).shift, ShiftRule.none);
    });

    test('v1 does not know the new types', () {
      expect(
        () => IncomeScheduleCodec.decode('{"v":1,"type":"weekly","day":2}'),
        _decodeError,
      );
      expect(
        () => IncomeScheduleCodec.decode(
          '{"v":1,"type":"several_per_month","rules":[]}',
        ),
        _decodeError,
      );
    });

    test('malformed v1 fails safely', () {
      for (final text in <String>[
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
  });

  group('failing safely', () {
    test('an unknown type', () {
      expect(
        () => IncomeScheduleCodec.decode('{"v":2,"type":"yearly"}'),
        _decodeError,
      );
    });

    test('an unknown or missing version', () {
      for (final text in <String>[
        '{"v":3,"type":"monthly","rule":{"kind":"last"},"shift":"none"}',
        '{"v":0,"type":"one_off","date":"2026-03-05"}',
        '{"type":"weekly","weekday":5,"shift":"none"}',
        '{"v":"2","type":"weekly","weekday":5,"shift":"none"}',
      ]) {
        expect(
          () => IncomeScheduleCodec.decode(text),
          _decodeError,
          reason: text,
        );
      }
    });

    test('malformed content', () {
      for (final text in <String>[
        '',
        'not json',
        '[]',
        '"monthly"',
        '{}',
        '{"v":2}',
        // monthly
        '{"v":2,"type":"monthly","shift":"none"}',
        '{"v":2,"type":"monthly","rule":"last","shift":"none"}',
        '{"v":2,"type":"monthly","rule":{"kind":"last"}}',
        '{"v":2,"type":"monthly","rule":{"kind":"last"},"shift":"sideways"}',
        '{"v":2,"type":"monthly","rule":{"kind":"day","day":0},"shift":"none"}',
        '{"v":2,"type":"monthly","rule":{"kind":"day","day":32},"shift":"none"}',
        '{"v":2,"type":"monthly","rule":{"kind":"day"},"shift":"none"}',
        '{"v":2,"type":"monthly","rule":{"kind":"nth_working","n":0},"shift":"none"}',
        '{"v":2,"type":"monthly","rule":{"kind":"nth_working","n":24},"shift":"none"}',
        '{"v":2,"type":"monthly","rule":{"kind":"every_other"},"shift":"none"}',
        // several
        '{"v":2,"type":"several_per_month","shift":"none"}',
        '{"v":2,"type":"several_per_month","rules":[{"kind":"last"}],"shift":"none"}',
        '{"v":2,"type":"several_per_month","rules":"x","shift":"none"}',
        '{"v":2,"type":"several_per_month","rules":[{"kind":"last"},{"kind":"zzz"}],"shift":"none"}',
        // weekly
        '{"v":2,"type":"weekly","shift":"none"}',
        '{"v":2,"type":"weekly","weekday":0,"shift":"none"}',
        '{"v":2,"type":"weekly","weekday":8,"shift":"none"}',
        '{"v":2,"type":"weekly","weekday":"fri","shift":"none"}',
        // one_off
        '{"v":2,"type":"one_off"}',
        '{"v":2,"type":"one_off","date":"2026-02-30"}',
      ]) {
        expect(
          () => IncomeScheduleCodec.decode(text),
          _decodeError,
          reason: text,
        );
      }
    });
  });
}
