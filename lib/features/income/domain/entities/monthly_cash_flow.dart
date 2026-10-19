import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';

/// received: dated today or earlier and not skipped. expected: later than
/// today. skipped: the user marked it as not received.
enum OccurrenceState { received, expected, skipped }

/// One payment of a source. [date] is the day it is paid (after shifting);
/// [nominalDate] is the day the schedule rule gave, and identifies the payment
/// for actions and stored entries. Computed, except when [isStored] is true:
/// then a stored entry changed it.
class IncomeOccurrence {
  const IncomeOccurrence({
    required this.source,
    required this.date,
    required this.nominalDate,
    required this.amount,
    required this.state,
    required this.isStored,
  });

  final IncomeSource source;
  final CalendarDate date;
  final CalendarDate nominalDate;
  final Money amount;
  final OccurrenceState state;
  final bool isStored;
}

class MonthlyCashFlow {
  const MonthlyCashFlow({
    required this.month,
    required this.currencyCode,
    required this.occurrences,
    required this.openingBalance,
    required this.receivedIncome,
    required this.expectedIncome,
    required this.projectedClosingBalance,
  });

  final YearMonth month;
  final String currencyCode;

  /// Sorted by date, then source name. Includes skipped ones.
  final List<IncomeOccurrence> occurrences;

  /// Balance at the end of the day before the month starts.
  final Money openingBalance;
  final Money receivedIncome;
  final Money expectedIncome;

  /// Balance at the end of the last day of the month: the last anchor on or
  /// before that day, plus all non-skipped income dated after the anchor.
  /// Expenses are not part of Phase 1a.
  final Money projectedClosingBalance;
}

/// The month in every currency that appears in the data. Nothing is hidden and
/// amounts of different currencies are never added.
class MonthlyCashFlowSummary {
  const MonthlyCashFlowSummary({
    required this.month,
    required this.currencies,
    required this.occurrences,
  });

  final YearMonth month;

  /// One cash flow per currency, the primary currency first, the others
  /// sorted by code.
  final List<MonthlyCashFlow> currencies;

  /// The payments of all currencies, sorted by date, then source name. Each
  /// payment carries its currency through `source.currencyCode`.
  final List<IncomeOccurrence> occurrences;
}
