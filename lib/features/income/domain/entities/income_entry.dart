import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';

enum IncomeEntryStatus { received, skipped }

/// A stored decision about one computed payment: the user skipped it or
/// changed its amount (or history was frozen). It replaces the computed
/// payment whose date is [originalDate].
class IncomeEntry {
  const IncomeEntry({
    required this.id,
    required this.sourceId,
    required this.originalDate,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String sourceId;

  /// The date the schedule produced for this payment.
  final CalendarDate originalDate;
  final IncomeEntryStatus status;

  /// For a skipped entry this is the amount that was planned.
  final Money amount;
  final DateTime createdAt;
}
