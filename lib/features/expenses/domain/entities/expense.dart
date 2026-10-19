import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';

/// The amount and currency on the receipt (for example 24.50 GBP).
/// Informational: nothing is converted or added to it.
class OriginalAmount {
  const OriginalAmount(this.amount, this.currencyCode);

  final Money amount;
  final String currencyCode;

  @override
  bool operator ==(Object other) =>
      other is OriginalAmount &&
      other.amount == amount &&
      other.currencyCode == currencyCode;

  @override
  int get hashCode => Object.hash(amount, currencyCode);

  @override
  String toString() => 'OriginalAmount($amount $currencyCode)';
}

/// One expense: one total and one category. Per-product lines may come later
/// in their own table; nothing here assumes there are none.
class Expense {
  const Expense({
    required this.id,
    required this.categoryId,
    required this.date,
    required this.currencyCode,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.amount,
    this.original,
    this.tax,
  });

  final String id;
  final String? description;
  final String categoryId;
  final CalendarDate date;

  /// Currency of the account that was charged. Always set, also when pending.
  final String currencyCode;

  /// What left the user's pocket, in [currencyCode]. Null: the expense is
  /// pending ("awaiting amount").
  final Money? amount;

  /// Informational receipt amount and currency.
  final OriginalAmount? original;

  /// Informational: the part of [amount] that is VAT/taxes. Added to no sum.
  final Money? tax;

  /// UTC instants.
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Awaiting the amount that was charged. A pending expense is always shown
  /// but counts in no total and no balance.
  bool get isPending => amount == null;
}
