import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/services/holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/domain/services/working_days.dart';

/// One scheduled payment: the date the rule gave ([nominal]) and the date it
/// is paid after shifting ([actual]). Stored decisions key on [nominal], so a
/// later correction of the holiday calendar cannot orphan them.
class ScheduledPayment {
  const ScheduledPayment({required this.nominal, required this.actual});

  final CalendarDate nominal;
  final CalendarDate actual;

  @override
  bool operator ==(Object other) =>
      other is ScheduledPayment &&
      other.nominal == nominal &&
      other.actual == actual;

  @override
  int get hashCode => Object.hash(nominal, actual);

  @override
  String toString() => 'ScheduledPayment($nominal -> $actual)';
}

/// Computes when a schedule pays. Pure Dart; knows nothing about sources,
/// start/end dates or stored entries.
class ScheduleEngine {
  const ScheduleEngine([this._holidays = const NoHolidays()]);

  final HolidayCalendar _holidays;

  WorkingDays get _workingDays => WorkingDays(_holidays);

  /// The payments whose ACTUAL date falls inside [month], ascending by actual
  /// date, then nominal date.
  ///
  /// A shift can move a payment across a month boundary, so the nominal dates
  /// of the months before and after are computed too, then filtered by actual
  /// date.
  List<ScheduledPayment> occurrencesInMonth(
    IncomeSchedule schedule,
    YearMonth month,
  ) {
    final result = <ScheduledPayment>[];
    for (final m in <YearMonth>[
      month.plusMonths(-1),
      month,
      month.plusMonths(1),
    ]) {
      for (final payment in _paymentsOfNominalMonth(schedule, m)) {
        if (month.contains(payment.actual)) result.add(payment);
      }
    }
    result.sort((a, b) {
      final byActual = a.actual.compareTo(b.actual);
      return byActual != 0 ? byActual : a.nominal.compareTo(b.nominal);
    });
    return result;
  }

  /// Payments whose NOMINAL date is inside [month] (not yet filtered).
  List<ScheduledPayment> _paymentsOfNominalMonth(
    IncomeSchedule schedule,
    YearMonth month,
  ) {
    switch (schedule) {
      case OneOff(:final date):
        return month.contains(date)
            ? <ScheduledPayment>[ScheduledPayment(nominal: date, actual: date)]
            : <ScheduledPayment>[];
      case Monthly(:final rule, :final shift):
        return _fromRules(<DayRule>[rule], shift, month);
      case SeveralPerMonth(:final rules, :final shift):
        return _fromRules(rules, shift, month);
      case Weekly(:final weekday, :final shift):
        return <ScheduledPayment>[
          for (var d = 1; d <= month.daysInMonth; d++)
            if (CalendarDate(month.year, month.month, d).weekday == weekday)
              _shifted(CalendarDate(month.year, month.month, d), shift),
        ];
    }
  }

  List<ScheduledPayment> _fromRules(
    List<DayRule> rules,
    ShiftRule shift,
    YearMonth month,
  ) {
    final seen = <CalendarDate>{};
    final payments = <ScheduledPayment>[];
    for (final rule in rules) {
      switch (rule) {
        case DayOfMonth(:final day):
          final nominal = month.dayClamped(day);
          if (seen.add(nominal)) payments.add(_shifted(nominal, shift));
        case LastDay():
          final nominal = month.lastDay;
          if (seen.add(nominal)) payments.add(_shifted(nominal, shift));
        case NthWorkingDay(:final n):
          // Already a working day: never shifted.
          final nominal = _workingDays.nth(month, n);
          if (nominal != null && seen.add(nominal)) {
            payments.add(ScheduledPayment(nominal: nominal, actual: nominal));
          }
      }
    }
    return payments;
  }

  ScheduledPayment _shifted(CalendarDate nominal, ShiftRule shift) =>
      ScheduledPayment(
        nominal: nominal,
        actual: _workingDays.applyShift(nominal, shift),
      );
}
