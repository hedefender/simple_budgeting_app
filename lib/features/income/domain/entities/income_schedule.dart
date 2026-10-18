import 'package:simple_budgeting_app/core/time/calendar_date.dart';

/// When an income source pays. Phase 1a supports a single payment and a
/// monthly payment; weekly and multi-payment schedules arrive in Phase 1b.
///
/// This type knows nothing about JSON. The data layer owns the codec.
sealed class IncomeSchedule {
  const IncomeSchedule();
}

/// One payment on [date].
final class OneOff extends IncomeSchedule {
  const OneOff(this.date);

  final CalendarDate date;

  @override
  bool operator ==(Object other) => other is OneOff && other.date == date;

  @override
  int get hashCode => Object.hash('one-off', date);

  @override
  String toString() => 'OneOff($date)';
}

/// One payment every month, on [dayOfMonth] (1-31) or on the last day of the
/// month when [dayOfMonth] is null. A day that a short month does not have
/// (29-31) falls on the last day of that month.
final class Monthly extends IncomeSchedule {
  const Monthly.onDay(int this.dayOfMonth)
    : assert(dayOfMonth >= 1 && dayOfMonth <= 31);

  const Monthly.onLastDay() : dayOfMonth = null;

  final int? dayOfMonth;

  bool get isLastDay => dayOfMonth == null;

  @override
  bool operator ==(Object other) =>
      other is Monthly && other.dayOfMonth == dayOfMonth;

  @override
  int get hashCode => Object.hash('monthly', dayOfMonth);

  @override
  String toString() => isLastDay ? 'Monthly(lastDay)' : 'Monthly($dayOfMonth)';
}
