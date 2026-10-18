import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/income_validation.dart';

class CreateIncomeSource {
  const CreateIncomeSource(this._repository, this._clock, this._newId);

  final IncomeRepository _repository;
  final Clock _clock;
  final IdGenerator _newId;

  /// For a [OneOff] schedule the start date is the payment date and there is
  /// no end date.
  Future<IncomeSource> call({
    required String name,
    required IncomeType type,
    required Money amount,
    required String currencyCode,
    required IncomeSchedule schedule,
    required CalendarDate startDate,
    CalendarDate? endDate,
  }) async {
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
    final source = IncomeSource(
      id: _newId(),
      name: name.trim(),
      type: type,
      amount: amount,
      currencyCode: currencyCode,
      schedule: schedule,
      startDate: effectiveStart,
      endDate: effectiveEnd,
      createdAt: _clock().toUtc(),
    );
    await _repository.addSource(source);
    return source;
  }
}
