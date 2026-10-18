import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';

/// The user's balance at the END of [date]. Income dated after [date] is
/// added on top of it.
class BalanceAnchor {
  const BalanceAnchor({
    required this.id,
    required this.date,
    required this.balance,
    required this.currencyCode,
    required this.createdAt,
  });

  final String id;
  final CalendarDate date;
  final Money balance;
  final String currencyCode;
  final DateTime createdAt;
}
