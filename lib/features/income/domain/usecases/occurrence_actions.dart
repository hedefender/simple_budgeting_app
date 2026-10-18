import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/income_validation.dart';

/// Stores a different amount for one payment (identified by its original
/// date). Whether it counts as received or expected still depends on its date.
class ChangeOccurrenceAmount {
  const ChangeOccurrenceAmount(this._repository, this._clock, this._newId);

  final IncomeRepository _repository;
  final Clock _clock;
  final IdGenerator _newId;

  Future<void> call({
    required String sourceId,
    required CalendarDate originalDate,
    required Money amount,
  }) async {
    if (amount.minorUnits <= 0) {
      throw const IncomeValidationException(
        IncomeValidationError.amountNotPositive,
      );
    }
    await _requireSource(_repository, sourceId);
    await _repository.saveEntry(
      IncomeEntry(
        id: _newId(),
        sourceId: sourceId,
        originalDate: originalDate,
        status: IncomeEntryStatus.received,
        amount: amount,
        createdAt: _clock().toUtc(),
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
    final entries = await _repository.listEntries();
    final existing = entries
        .where((e) => e.sourceId == sourceId && e.originalDate == originalDate)
        .firstOrNull;
    await _repository.saveEntry(
      IncomeEntry(
        id: _newId(),
        sourceId: sourceId,
        originalDate: originalDate,
        status: IncomeEntryStatus.skipped,
        amount: existing?.amount ?? source.amount,
        createdAt: _clock().toUtc(),
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
