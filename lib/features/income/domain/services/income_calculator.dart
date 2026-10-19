import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/services/schedule_engine.dart';

/// Turns a source plus its stored entries into the payments of a month.
/// Payments are computed, not stored; entries only override them.
///
/// Everything time related (which month a payment belongs to, received or
/// expected, start/end/archive/frozen limits) uses the ACTUAL date. Entries
/// are matched on the NOMINAL date.
class IncomeCalculator {
  const IncomeCalculator(this._engine);

  final ScheduleEngine _engine;

  /// Payments of [source] whose actual date is in [month], ascending by date.
  ///
  /// [entries] may contain entries of other sources and other months; only
  /// those of [source] are used.
  List<IncomeOccurrence> occurrencesInMonth({
    required IncomeSource source,
    required Iterable<IncomeEntry> entries,
    required YearMonth month,
    required CalendarDate today,
  }) {
    final byNominal = <CalendarDate, IncomeEntry>{
      for (final entry in entries)
        if (entry.sourceId == source.id) entry.originalDate: entry,
    };

    final result = <IncomeOccurrence>[];
    final shown = <CalendarDate>{}; // nominal dates already in the result

    for (final payment in _engine.occurrencesInMonth(source.schedule, month)) {
      final entry = byNominal[payment.nominal];
      final pinned = entry?.actualDate;
      final actual = pinned ?? payment.actual;
      if (!month.contains(actual)) continue; // the user moved it elsewhere
      // A pinned entry is a decision of the user (or frozen history): it is
      // shown whatever the source limits are. Computed payments obey them.
      if (pinned == null && !source.generatesOn(actual)) continue;
      shown.add(payment.nominal);
      result.add(_build(source, payment.nominal, actual, entry, today));
    }

    // Pinned entries that the schedule does not produce in this month: frozen
    // history of an old schedule, or a payment moved into this month.
    for (final entry in byNominal.values) {
      final pinned = entry.actualDate;
      if (pinned == null || !month.contains(pinned)) continue;
      if (!shown.add(entry.originalDate)) continue;
      result.add(_build(source, entry.originalDate, pinned, entry, today));
    }

    result.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.nominalDate.compareTo(b.nominalDate);
    });
    return result;
  }

  /// Payments of [source] whose actual date is on or before [through],
  /// ascending.
  List<IncomeOccurrence> occurrencesThrough({
    required IncomeSource source,
    required Iterable<IncomeEntry> entries,
    required CalendarDate through,
    required CalendarDate today,
  }) {
    var first = YearMonth.of(source.startDate);
    for (final entry in entries) {
      if (entry.sourceId != source.id) continue;
      final month = YearMonth.of(entry.actualDate ?? entry.originalDate);
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
    CalendarDate nominal,
    CalendarDate actual,
    IncomeEntry? entry,
    CalendarDate today,
  ) {
    final OccurrenceState state;
    if (entry?.status == IncomeEntryStatus.skipped) {
      state = OccurrenceState.skipped;
    } else if (actual.isAfter(today)) {
      state = OccurrenceState.expected;
    } else {
      state = OccurrenceState.received;
    }
    return IncomeOccurrence(
      source: source,
      date: actual,
      nominalDate: nominal,
      amount: entry?.amount ?? source.amount,
      state: state,
      isStored: entry != null,
    );
  }
}
