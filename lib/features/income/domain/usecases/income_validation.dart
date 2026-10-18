import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';

enum IncomeValidationError {
  nameEmpty,
  amountNotPositive,
  endBeforeStart,
  sourceNotFound,
  sourceArchived,
}

class IncomeValidationException implements Exception {
  const IncomeValidationException(this.error);

  final IncomeValidationError error;

  @override
  String toString() => 'IncomeValidationException($error)';
}

/// Shared checks of the income use cases.
void validateSourceFields({
  required String name,
  required Money amount,
  required IncomeSchedule schedule,
  required CalendarDate startDate,
  required CalendarDate? endDate,
}) {
  if (name.trim().isEmpty) {
    throw const IncomeValidationException(IncomeValidationError.nameEmpty);
  }
  if (amount.minorUnits <= 0) {
    throw const IncomeValidationException(
      IncomeValidationError.amountNotPositive,
    );
  }
  if (schedule is! OneOff && endDate != null && endDate.isBefore(startDate)) {
    throw const IncomeValidationException(IncomeValidationError.endBeforeStart);
  }
}
