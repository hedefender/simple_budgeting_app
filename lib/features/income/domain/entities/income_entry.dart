import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';

enum IncomeEntryStatus { received, skipped }

/// A stored decision about one scheduled payment: the user skipped it,
/// changed its amount or date, or history was frozen. It replaces the
/// scheduled payment whose NOMINAL date is [originalDate].
class IncomeEntry {
  const IncomeEntry({
    required this.id,
    required this.sourceId,
    required this.originalDate,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.actualDate,
  });

  final String id;
  final String sourceId;

  /// The nominal date the schedule rule gave for this payment. It is the key
  /// of the entry, so a later correction of the holiday calendar cannot
  /// orphan it.
  final CalendarDate originalDate;
  final IncomeEntryStatus status;

  /// For a skipped entry this is the amount that was planned.
  final Money amount;
  final DateTime createdAt;

  /// The date the payment is paid, when pinned (frozen history, or a date the
  /// user changed). Null: computed from the schedule and the holiday calendar.
  final CalendarDate? actualDate;

  IncomeEntry copyWith({
    String? id,
    IncomeEntryStatus? status,
    Money? amount,
    DateTime? createdAt,
    CalendarDate? actualDate,
  }) {
    return IncomeEntry(
      id: id ?? this.id,
      sourceId: sourceId,
      originalDate: originalDate,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      actualDate: actualDate ?? this.actualDate,
    );
  }
}
