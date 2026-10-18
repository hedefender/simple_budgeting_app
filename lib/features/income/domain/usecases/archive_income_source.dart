import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/income_validation.dart';

/// Archives a source: no payments are generated after the archive day, and
/// earlier ones stay in the history.
class ArchiveIncomeSource {
  const ArchiveIncomeSource(this._repository, this._clock);

  final IncomeRepository _repository;
  final Clock _clock;

  Future<void> call(String sourceId) async {
    final source = await _repository.getSource(sourceId);
    if (source == null) {
      throw const IncomeValidationException(
        IncomeValidationError.sourceNotFound,
      );
    }
    if (source.isArchived) return;
    await _repository.archiveSource(sourceId, _clock().toUtc());
  }
}
