import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';

enum IncomeType { salary, freelance, sideHustle, other }

/// A recurring or one-off source of income. Amounts are net (as received).
class IncomeSource {
  const IncomeSource({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.currencyCode,
    required this.schedule,
    required this.startDate,
    required this.createdAt,
    this.endDate,
    this.frozenThrough,
    this.archivedAt,
  });

  final String id;
  final String name;
  final IncomeType type;

  /// Amount of one payment, in minor units of [currencyCode]. The currency is
  /// fixed when the source is created.
  final Money amount;
  final String currencyCode;
  final IncomeSchedule schedule;

  /// First day payments may be generated (inclusive).
  final CalendarDate startDate;

  /// Last day payments may be generated (inclusive), or null.
  final CalendarDate? endDate;

  /// History up to and including this day is stored as entries; the schedule
  /// only generates payments after it. Set when the amount or schedule is
  /// edited ("freeze history on edit").
  final CalendarDate? frozenThrough;

  /// UTC instants.
  final DateTime createdAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  /// Last day this source may generate payments: the earlier of [endDate] and
  /// the day it was archived. Null means no limit.
  CalendarDate? get lastActiveDay {
    final archivedDay = archivedAt == null
        ? null
        : CalendarDate.fromInstant(archivedAt!);
    final end = endDate;
    if (archivedDay == null) return end;
    if (end == null) return archivedDay;
    return end.isBefore(archivedDay) ? end : archivedDay;
  }

  /// Whether the schedule may generate a payment on [date].
  bool generatesOn(CalendarDate date) {
    if (date.isBefore(startDate)) return false;
    final last = lastActiveDay;
    if (last != null && date.isAfter(last)) return false;
    final frozen = frozenThrough;
    if (frozen != null && !date.isAfter(frozen)) return false;
    return true;
  }

  IncomeSource copyWith({
    String? name,
    IncomeType? type,
    Money? amount,
    IncomeSchedule? schedule,
    CalendarDate? startDate,
    CalendarDate? endDate,
    bool clearEndDate = false,
    CalendarDate? frozenThrough,
    DateTime? archivedAt,
  }) {
    return IncomeSource(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currencyCode: currencyCode,
      schedule: schedule ?? this.schedule,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      frozenThrough: frozenThrough ?? this.frozenThrough,
      createdAt: createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}
