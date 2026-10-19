import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/income_validation.dart';

/// Stores a different amount and/or a different paid date for one payment
/// (identified by its NOMINAL date). Whether it counts as received or expected
/// depends on the paid date. A new [actualDate] is pinned; without it, a date
/// pinned earlier is kept.
class ChangeOccurrenceAmount {
  const ChangeOccurrenceAmount(this._repository, this._clock, this._newId);

  final IncomeRepository _repository;
  final Clock _clock;
  final IdGenerator _newId;

  Future<void> call({
    required String sourceId,
    required CalendarDate originalDate,
    required Money amount,
    CalendarDate? actualDate,
  }) async {
    if (amount.minorUnits <= 0) {
      throw const IncomeValidationException(
        IncomeValidationError.amountNotPositive,
      );
    }
    await _requireSource(_repository, sourceId);
    final existing = await _existingEntry(_repository, sourceId, originalDate);
    await _repository.saveEntry(
      IncomeEntry(
        id: _newId(),
        sourceId: sourceId,
        originalDate: originalDate,
        status: IncomeEntryStatus.received,
        amount: amount,
        createdAt: _clock().toUtc(),
        actualDate: actualDate ?? existing?.actualDate,
      ),
    );
  }
}

/// Marks one payment as not received. The planned amount is kept so it can be
/// shown.
class SkipOccurrence {
  const SkipOccurrence(this._repository, this._clock, this._newId);

  final IncomeRepository _repository;
  final Clock _clock;
  final IdGenerator _newId;

  Future<void> call({
    required String sourceId,
    required CalendarDate originalDate,
  }) async {
    final source = await _requireSource(_repository, sourceId);
    final existing = await _existingEntry(_repository, sourceId, originalDate);
    await _repository.saveEntry(
      IncomeEntry(
        id: _newId(),
        sourceId: sourceId,
        originalDate: originalDate,
        status: IncomeEntryStatus.skipped,
        amount: existing?.amount ?? source.amount,
        createdAt: _clock().toUtc(),
        actualDate: existing?.actualDate,
      ),
    );
  }
}

/// Removes the stored decision, so the payment is computed again.
class ResetOccurrence {
  const ResetOccurrence(this._repository);

  final IncomeRepository _repository;

  Future<void> call({
    required String sourceId,
    required CalendarDate originalDate,
  }) => _repository.removeEntry(sourceId, originalDate);
}

Future<IncomeEntry?> _existingEntry(
  IncomeRepository repository,
  String sourceId,
  CalendarDate originalDate,
) async {
  final entries = await repository.listEntries();
  return entries
      .where((e) => e.sourceId == sourceId && e.originalDate == originalDate)
      .firstOrNull;
}

Future<IncomeSource> _requireSource(
  IncomeRepository repository,
  String sourceId,
) async {
  final source = await repository.getSource(sourceId);
  if (source == null) {
    throw const IncomeValidationException(IncomeValidationError.sourceNotFound);
  }
  return source;
}
