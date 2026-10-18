import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/services/income_calculator.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/income_validation.dart';

/// Edits a source. When the amount or the schedule changes, the payments up
/// to today that are not stored yet are first stored as received with the OLD
/// values ("freeze history"), so earlier months never change.
class UpdateIncomeSource {
  const UpdateIncomeSource(
    this._repository,
    this._calculator,
    this._clock,
    this._newId,
  );

  final IncomeRepository _repository;
  final IncomeCalculator _calculator;
  final Clock _clock;
  final IdGenerator _newId;

  Future<IncomeSource> call({
    required String sourceId,
    required String name,
    required IncomeType type,
    required Money amount,
    required IncomeSchedule schedule,
    required CalendarDate startDate,
    CalendarDate? endDate,
  }) async {
    final old = await _repository.getSource(sourceId);
    if (old == null) {
      throw const IncomeValidationException(
        IncomeValidationError.sourceNotFound,
      );
    }
    if (old.isArchived) {
      throw const IncomeValidationException(
        IncomeValidationError.sourceArchived,
      );
    }
    final oneOff = schedule is OneOff ? schedule : null;
    final effectiveStart = oneOff?.date ?? startDate;
    final effectiveEnd = oneOff == null ? endDate : null;
    validateSourceFields(
      name: name,
      amount: amount,
      schedule: schedule,
      startDate: effectiveStart,
      endDate: effectiveEnd,
    );

    final now = _clock().toUtc();
    final today = CalendarDate.fromInstant(now);
    final mustFreeze = amount != old.amount || schedule != old.schedule;

    var freezeEntries = <IncomeEntry>[];
    CalendarDate? frozenThrough = old.frozenThrough;
    if (mustFreeze) {
      final entries = await _repository.listEntries();
      freezeEntries = <IncomeEntry>[
        for (final occurrence in _calculator.occurrencesThrough(
          source: old,
          entries: entries,
          through: today,
          today: today,
        ))
          if (!occurrence.isStored)
            IncomeEntry(
              id: _newId(),
              sourceId: old.id,
              originalDate: occurrence.date,
              status: IncomeEntryStatus.received,
              amount: occurrence.amount,
              createdAt: now,
            ),
      ];
      final previous = old.frozenThrough;
      frozenThrough = previous != null && previous.isAfter(today)
          ? previous
          : today;
    }

    final updated = IncomeSource(
      id: old.id,
      name: name.trim(),
      type: type,
      amount: amount,
      currencyCode: old.currencyCode,
      schedule: schedule,
      startDate: effectiveStart,
      endDate: effectiveEnd,
      frozenThrough: frozenThrough,
      createdAt: old.createdAt,
      archivedAt: old.archivedAt,
    );
    await _repository.updateSource(updated, freezeEntries: freezeEntries);
    return updated;
  }
}
