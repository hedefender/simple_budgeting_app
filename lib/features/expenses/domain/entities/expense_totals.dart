import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';

/// The sum of the counted (not pending) expenses of one currency, and how many
/// pending ones of that currency are not in the sum.
class ExpenseCurrencyTotal {
  const ExpenseCurrencyTotal({
    required this.currencyCode,
    required this.total,
    required this.pendingCount,
  });

  final String currencyCode;
  final Money total;
  final int pendingCount;
}

/// Totals per currency. Amounts of different currencies are never added. The
/// primary currency comes first, the others are sorted by code. A currency
/// that has only pending expenses still gets an entry (total zero).
List<ExpenseCurrencyTotal> expenseTotalsByCurrency(
  Iterable<Expense> expenses, {
  String? primaryCurrency,
}) {
  final totals = <String, Money>{};
  final pending = <String, int>{};
  for (final e in expenses) {
    totals.putIfAbsent(e.currencyCode, () => Money.zero);
    final amount = e.amount;
    if (amount == null) {
      pending[e.currencyCode] = (pending[e.currencyCode] ?? 0) + 1;
    } else {
      totals[e.currencyCode] = totals[e.currencyCode]! + amount;
    }
  }
  final codes = totals.keys.toList()
    ..sort((a, b) {
      if (a == primaryCurrency) return -1;
      if (b == primaryCurrency) return 1;
      return a.compareTo(b);
    });
  return <ExpenseCurrencyTotal>[
    for (final code in codes)
      ExpenseCurrencyTotal(
        currencyCode: code,
        total: totals[code]!,
        pendingCount: pending[code] ?? 0,
      ),
  ];
}

/// The expenses of a month (after the category filter) and their totals.
class ExpenseListResult {
  const ExpenseListResult({required this.expenses, required this.totals});

  /// Newest first, pending ones included.
  final List<Expense> expenses;
  final List<ExpenseCurrencyTotal> totals;
}
