import 'package:simple_budgeting_app/core/time/calendar_date.dart';

/// What to do when a payment's nominal date is not a working day.
enum ShiftRule { previousWorkingDay, nextWorkingDay, none }

/// How one payment of a month is placed. Knows nothing about JSON.
sealed class DayRule {
  const DayRule();
}

/// A day of the month (1-31). In a shorter month it is the last day.
final class DayOfMonth extends DayRule {
  const DayOfMonth(this.day) : assert(day >= 1 && day <= 31);

  final int day;

  @override
  bool operator ==(Object other) => other is DayOfMonth && other.day == day;

  @override
  int get hashCode => Object.hash('day', day);

  @override
  String toString() => 'DayOfMonth($day)';
}

/// The last calendar day of the month.
final class LastDay extends DayRule {
  const LastDay();

  @override
  bool operator ==(Object other) => other is LastDay;

  @override
  int get hashCode => 'last-day'.hashCode;

  @override
  String toString() => 'LastDay';
}

/// The Nth working day of the month (1 = first). Never shifted. A month with
/// fewer working days has no such payment.
final class NthWorkingDay extends DayRule {
  const NthWorkingDay(this.n) : assert(n >= 1 && n <= maxN);

  /// A month has at most 23 weekdays.
  static const int maxN = 23;

  final int n;

  @override
  bool operator ==(Object other) => other is NthWorkingDay && other.n == n;

  @override
  int get hashCode => Object.hash('nth-working', n);

  @override
  String toString() => 'NthWorkingDay($n)';
}

/// When an income source pays. The data layer owns the JSON codec.
sealed class IncomeSchedule {
  const IncomeSchedule();
}

/// One payment on [date]. Never shifted.
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

/// One payment every month placed by [rule]. [shift] applies to
/// [DayOfMonth] and [LastDay] only.
final class Monthly extends IncomeSchedule {
  const Monthly(DayRule this._rule, {this.shift = ShiftRule.none})
    : _day = null;

  const Monthly.onDay(int this._day, {this.shift = ShiftRule.none})
    : _rule = null,
      assert(_day >= 1 && _day <= 31);

  const Monthly.onLastDay({this.shift = ShiftRule.none})
    : _rule = const LastDay(),
      _day = null;

  // Either a rule, or a plain day (kept as an int so `const Monthly.onDay(5)`
  // stays a constant).
  final DayRule? _rule;
  final int? _day;
  final ShiftRule shift;

  DayRule get rule => _rule ?? DayOfMonth(_day!);

  /// The day of the month when [rule] is a [DayOfMonth], else null.
  int? get dayOfMonth => switch (rule) {
    DayOfMonth(:final day) => day,
    _ => null,
  };

  bool get isLastDay => rule is LastDay;

  @override
  bool operator ==(Object other) =>
      other is Monthly && other.rule == rule && other.shift == shift;

  @override
  int get hashCode => Object.hash('monthly', rule, shift);

  @override
  String toString() => 'Monthly($rule, $shift)';
}

/// Several payments every month, one per rule (at least two). Rules that
/// give the same nominal date in a month make one payment.
final class SeveralPerMonth extends IncomeSchedule {
  SeveralPerMonth(List<DayRule> rules, {this.shift = ShiftRule.none})
    : rules = List<DayRule>.unmodifiable(rules),
      assert(rules.length >= 2);

  final List<DayRule> rules;
  final ShiftRule shift;

  @override
  bool operator ==(Object other) =>
      other is SeveralPerMonth &&
      other.shift == shift &&
      _sameRules(other.rules, rules);

  @override
  int get hashCode => Object.hash('several', shift, Object.hashAll(rules));

  @override
  String toString() => 'SeveralPerMonth($rules, $shift)';
}

/// One payment every week on [weekday] (1 = Monday ... 7 = Sunday).
final class Weekly extends IncomeSchedule {
  const Weekly(this.weekday, {this.shift = ShiftRule.none})
    : assert(weekday >= 1 && weekday <= 7);

  final int weekday;
  final ShiftRule shift;

  @override
  bool operator ==(Object other) =>
      other is Weekly && other.weekday == weekday && other.shift == shift;

  @override
  int get hashCode => Object.hash('weekly', weekday, shift);

  @override
  String toString() => 'Weekly($weekday, $shift)';
}

/// Where a [Yearly] payment sits in the year. Knows nothing about JSON.
sealed class YearlyAnchor {
  const YearlyAnchor();
}

/// A fixed [month] (1-12) and [day] (1-31). A day past the end of the month
/// (29 February in a common year) is the last day of that month.
final class FixedDate extends YearlyAnchor {
  const FixedDate(this.month, this.day)
    : assert(month >= 1 && month <= 12),
      assert(day >= 1 && day <= 31);

  final int month;
  final int day;

  @override
  bool operator ==(Object other) =>
      other is FixedDate && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash('fixed', month, day);

  @override
  String toString() => 'FixedDate($month-$day)';
}

/// [offsetDays] after Orthodox Easter Sunday (negative: before). Holy
/// Wednesday is [holyWednesdayOffset].
final class EasterRelative extends YearlyAnchor {
  const EasterRelative(this.offsetDays)
    : assert(offsetDays >= -maxOffsetDays && offsetDays <= maxOffsetDays);

  static const int holyWednesdayOffset = -4;

  /// Easter-based dates stay within about 50 days of Easter.
  static const int maxOffsetDays = 60;

  final int offsetDays;

  bool get isHolyWednesday => offsetDays == holyWednesdayOffset;

  @override
  bool operator ==(Object other) =>
      other is EasterRelative && other.offsetDays == offsetDays;

  @override
  int get hashCode => Object.hash('easter', offsetDays);

  @override
  String toString() => 'EasterRelative($offsetDays)';
}

/// One payment a year at [anchor]. [shift] moves it off a weekend or holiday.
final class Yearly extends IncomeSchedule {
  const Yearly(this.anchor, {this.shift = ShiftRule.none});

  final YearlyAnchor anchor;
  final ShiftRule shift;

  @override
  bool operator ==(Object other) =>
      other is Yearly && other.anchor == anchor && other.shift == shift;

  @override
  int get hashCode => Object.hash('yearly', anchor, shift);

  @override
  String toString() => 'Yearly($anchor, $shift)';
}

bool _sameRules(List<DayRule> a, List<DayRule> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
