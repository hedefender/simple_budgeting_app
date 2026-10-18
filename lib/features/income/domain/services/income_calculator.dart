import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/services/schedule_engine.dart';

/// Turns a source plus its stored entries into the payments of a month.
/// Payments are computed, not stored; entries only override them.
class IncomeCalculator {
  const IncomeCalculator(this._engine);

  final ScheduleEngine _engine;

  /// Payments of [source] in [month], ascending by date.
  ///
  /// [entries] may contain entries of other sources and other months; only
  /// those of [source] are used.
  List<IncomeOccurrence> occurrencesInMonth({
    required IncomeSource source,
    required Iterable<IncomeEntry> entries,
    required YearMonth month,
    required CalendarDate today,
  }) {
    final byDate = <CalendarDate, IncomeEntry>{
      for (final entry in entries)
        if (entry.sourceId == source.id) entry.originalDate: entry,
    };

    final generated = _engine
        // Phase 1b stage 1: nominal date only (no shifting exists yet).
        .occurrencesInMonth(source.schedule, month)
        .map((p) => p.nominal)
        .where(source.generatesOn)
        .toList();
    final result = <IncomeOccurrence>[
      for (final date in generated) _build(source, date, byDate[date], today),
    ];

    // History that was frozen when the source was edited: no longer
    // generated, only stored.
    final frozen = source.frozenThrough;
    if (frozen != null) {
      for (final entry in byDate.values) {
        if (month.contains(entry.originalDate) &&
            !entry.originalDate.isAfter(frozen)) {
          result.add(_build(source, entry.originalDate, entry, today));
        }
      }
    }

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  /// Payments of [source] dated on or before [through], ascending.
  List<IncomeOccurrence> occurrencesThrough({
    required IncomeSource source,
    required Iterable<IncomeEntry> entries,
    required CalendarDate through,
    required CalendarDate today,
  }) {
    var first = YearMonth.of(source.startDate);
    for (final entry in entries) {
      if (entry.sourceId != source.id) continue;
      final month = YearMonth.of(entry.originalDate);
      if (month.compareTo(first) < 0) first = month;
    }
    final last = YearMonth.of(through);
    final result = <IncomeOccurrence>[];
    var month = first;
    // Guard against absurd start dates: at most 100 years of months.
    for (var i = 0; i < 1200 && month.compareTo(last) <= 0; i++) {
      result.addAll(
        occurrencesInMonth(
          source: source,
          entries: entries,
          month: month,
          today: today,
        ).where((o) => !o.date.isAfter(through)),
      );
      month = month.plusMonths(1);
    }
    return result;
  }

  IncomeOccurrence _build(
    IncomeSource source,
    CalendarDate date,
    IncomeEntry? entry,
    CalendarDate today,
  ) {
    final OccurrenceState state;
    if (entry?.status == IncomeEntryStatus.skipped) {
      state = OccurrenceState.skipped;
    } else if (date.isAfter(today)) {
      state = OccurrenceState.expected;
    } else {
      state = OccurrenceState.received;
    }
    return IncomeOccurrence(
      source: source,
      date: date,
      amount: entry?.amount ?? source.amount,
      state: state,
      isStored: entry != null,
    );
  }
}
