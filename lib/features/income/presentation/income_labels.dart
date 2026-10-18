import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/income_validation.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

String incomeTypeLabel(AppLocalizations l10n, IncomeType type) {
  return switch (type) {
    IncomeType.salary => l10n.typeSalary,
    IncomeType.freelance => l10n.typeFreelance,
    IncomeType.sideHustle => l10n.typeSideHustle,
    IncomeType.other => l10n.typeOther,
  };
}

String scheduleSummary(AppLocalizations l10n, IncomeSchedule schedule) {
  return switch (schedule) {
    OneOff(:final date) => l10n.scheduleSummaryOneOff(date.toUtcDateTime()),
    Monthly(:final dayOfMonth) =>
      dayOfMonth == null
          ? l10n.scheduleSummaryMonthlyLast
          : l10n.scheduleSummaryMonthlyDay(dayOfMonth),
  };
}

String incomeValidationMessage(
  AppLocalizations l10n,
  IncomeValidationError error,
) {
  return switch (error) {
    IncomeValidationError.nameEmpty => l10n.errorNameRequired,
    IncomeValidationError.amountNotPositive => l10n.errorAmountPositive,
    IncomeValidationError.endBeforeStart => l10n.errorEndBeforeStart,
    IncomeValidationError.sourceNotFound => l10n.errorSourceNotFound,
    IncomeValidationError.sourceArchived => l10n.errorSourceArchived,
  };
}

String occurrenceStateLabel(AppLocalizations l10n, OccurrenceState state) {
  return switch (state) {
    OccurrenceState.received => l10n.occurrenceReceived,
    OccurrenceState.expected => l10n.occurrenceExpected,
    OccurrenceState.skipped => l10n.occurrenceSkipped,
  };
}
