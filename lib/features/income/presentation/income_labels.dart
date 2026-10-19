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

/// One line describing [schedule]. When payments can move off a weekend or
/// holiday, the shift rule is appended.
String scheduleSummary(AppLocalizations l10n, IncomeSchedule schedule) {
  final base = _scheduleBase(l10n, schedule);
  final shift = switch (schedule) {
    OneOff() => ShiftRule.none,
    Monthly(:final rule, :final shift) =>
      rule is NthWorkingDay ? ShiftRule.none : shift,
    SeveralPerMonth(:final rules, :final shift) =>
      rules.every((r) => r is NthWorkingDay) ? ShiftRule.none : shift,
    Weekly(:final shift) => shift,
  };
  return switch (shift) {
    ShiftRule.none => base,
    ShiftRule.previousWorkingDay => l10n.scheduleSummaryWithShift(
      base,
      l10n.shiftShortPrevious,
    ),
    ShiftRule.nextWorkingDay => l10n.scheduleSummaryWithShift(
      base,
      l10n.shiftShortNext,
    ),
  };
}

String _scheduleBase(AppLocalizations l10n, IncomeSchedule schedule) {
  return switch (schedule) {
    OneOff(:final date) => l10n.scheduleSummaryOneOff(date.toUtcDateTime()),
    Monthly(:final rule) => switch (rule) {
      DayOfMonth(:final day) => l10n.scheduleSummaryMonthlyDay(day),
      LastDay() => l10n.scheduleSummaryMonthlyLast,
      NthWorkingDay(:final n) => l10n.scheduleSummaryMonthlyNth(n),
    },
    SeveralPerMonth(:final rules) => l10n.scheduleSummarySeveral(
      rules.map((r) => dayRuleShort(l10n, r)).join(', '),
    ),
    Weekly(:final weekday) => l10n.scheduleSummaryWeekly(weekdayDate(weekday)),
  };
}

/// Short text of one rule, for lists such as "day 1, working day 3".
String dayRuleShort(AppLocalizations l10n, DayRule rule) {
  return switch (rule) {
    DayOfMonth(:final day) => l10n.ruleShortDay(day),
    LastDay() => l10n.ruleShortLast,
    NthWorkingDay(:final n) => l10n.ruleShortNth(n),
  };
}

/// Any date that falls on [weekday] (1 = Monday), for weekday names.
/// 5 October 2026 is a Monday.
DateTime weekdayDate(int weekday) => DateTime.utc(2026, 10, 4 + weekday);

String shiftRuleLabel(AppLocalizations l10n, ShiftRule shift) {
  return switch (shift) {
    ShiftRule.previousWorkingDay => l10n.shiftPrevious,
    ShiftRule.nextWorkingDay => l10n.shiftNext,
    ShiftRule.none => l10n.shiftNone,
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
