import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';

/// The day from which the app knows the balance of one currency. Before it the
/// balance is unknown (not zero), so nothing before it is shown as a balance.
class BalanceStart {
  const BalanceStart({required this.date, required this.fromAnchor});

  /// The date of the oldest balance anchor of the currency; without an anchor,
  /// the start date of the oldest income source of the currency.
  final CalendarDate date;

  /// True when [date] is the day of an anchor. The anchor is the balance at the
  /// END of its day, so everything dated on that day is already inside it.
  final bool fromAnchor;

  /// The first day whose transactions change the balance: the day after an
  /// anchor, or the start day of a source.
  CalendarDate get firstAffectingDay => fromAnchor ? date.addDays(1) : date;

  /// Whether something dated [day] is too early to affect the balance.
  bool isBeforeBalance(CalendarDate day) => day.isBefore(firstAffectingDay);

  @override
  bool operator ==(Object other) =>
      other is BalanceStart &&
      other.date == date &&
      other.fromAnchor == fromAnchor;

  @override
  int get hashCode => Object.hash(date, fromAnchor);

  @override
  String toString() => 'BalanceStart($date, fromAnchor: $fromAnchor)';
}

/// The balance start of one currency, or null when there is neither an anchor
/// nor an income source ([anchors] and [sources] must be of that currency).
BalanceStart? computeBalanceStart(
  Iterable<BalanceAnchor> anchors,
  Iterable<IncomeSource> sources,
) {
  CalendarDate? oldest;
  for (final anchor in anchors) {
    if (oldest == null || anchor.date.isBefore(oldest)) oldest = anchor.date;
  }
  if (oldest != null) return BalanceStart(date: oldest, fromAnchor: true);

  for (final source in sources) {
    if (oldest == null || source.startDate.isBefore(oldest)) {
      oldest = source.startDate;
    }
  }
  return oldest == null ? null : BalanceStart(date: oldest, fromAnchor: false);
}
