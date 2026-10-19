import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_start.dart';
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
    required this.expenses,
    required this.pendingExpenseCount,
    required this.projectedClosingBalance,
    required this.balanceStart,
  });

  final YearMonth month;
  final String currencyCode;

  /// Sorted by date, then source name. Includes skipped ones.
  final List<IncomeOccurrence> occurrences;

  /// Balance at the end of the day before the month starts.
  final Money openingBalance;
  final Money receivedIncome;
  final Money expectedIncome;

  /// All registered expenses of the month in this currency, except pending
  /// ones. Like [receivedIncome] it ignores the anchor, so with an anchor
  /// inside the month it is not the difference of the two balances.
  final Money expenses;

  /// Expenses of the month in this currency that await the amount that was
  /// charged. They are in no sum and no balance.
  final int pendingExpenseCount;

  /// Balance at the end of the last day of the month: the last anchor on or
  /// before that day, plus all non-skipped income and minus all expenses dated
  /// after the anchor.
  final Money projectedClosingBalance;

  /// Where the balance of this currency starts, or null when it has no anchor
  /// and no source.
  final BalanceStart? balanceStart;

  /// The whole month is before the balance starts: the opening and closing
  /// balances are unknown and must not be shown as numbers. Income and expense
  /// lines stay valid.
  bool get balanceUnknown {
    final start = balanceStart;
    return start != null && month.lastDay.isBefore(start.date);
  }
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
