import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/set_primary_currency.dart';

enum ExpenseValidationError {
  /// Neither the amount charged nor an original amount with a currency.
  amountRequired,
  amountNotPositive,
  originalAmountNotPositive,

  /// An original amount without a currency, or the reverse.
  originalIncomplete,
  originalSameCurrency,
  currencyInvalid,
  taxNotPositive,
  taxWithoutAmount,
  taxExceedsTotal,
  categoryNotFound,
  expenseNotFound,

  /// The expense points to a document that does not exist.
  documentNotFound,
}

class ExpenseValidationException implements Exception {
  const ExpenseValidationException(this.error);

  final ExpenseValidationError error;

  @override
  String toString() => 'ExpenseValidationException($error)';
}

/// The checked and normalized money fields of an expense.
class ValidatedExpenseMoney {
  const ValidatedExpenseMoney({
    required this.currencyCode,
    required this.amount,
    required this.original,
    required this.tax,
  });

  final String currencyCode;
  final Money? amount;
  final OriginalAmount? original;
  final Money? tax;
}

/// Shared checks of the expense use cases. The database has CHECK constraints
/// for the same rules; this gives the user a message instead of a crash.
ValidatedExpenseMoney validateExpenseMoney({
  required String currencyCode,
  required Money? amount,
  required Money? originalAmount,
  required String? originalCurrencyCode,
  required Money? tax,
}) {
  ExpenseValidationException fail(ExpenseValidationError e) =>
      ExpenseValidationException(e);

  final account = normalizeCurrencyCode(currencyCode);
  if (account == null) throw fail(ExpenseValidationError.currencyInvalid);

  final originalCurrencyText = originalCurrencyCode?.trim();
  final hasOriginalCurrency =
      originalCurrencyText != null && originalCurrencyText.isNotEmpty;
  if ((originalAmount != null) != hasOriginalCurrency) {
    throw fail(ExpenseValidationError.originalIncomplete);
  }
  OriginalAmount? original;
  if (originalAmount != null) {
    final originalCurrency = normalizeCurrencyCode(originalCurrencyText!);
    if (originalCurrency == null) {
      throw fail(ExpenseValidationError.currencyInvalid);
    }
    if (originalAmount.minorUnits <= 0) {
      throw fail(ExpenseValidationError.originalAmountNotPositive);
    }
    if (originalCurrency == account) {
      throw fail(ExpenseValidationError.originalSameCurrency);
    }
    original = OriginalAmount(originalAmount, originalCurrency);
  }

  if (amount == null && original == null) {
    throw fail(ExpenseValidationError.amountRequired);
  }
  if (amount != null && amount.minorUnits <= 0) {
    throw fail(ExpenseValidationError.amountNotPositive);
  }

  if (tax != null) {
    if (amount == null) throw fail(ExpenseValidationError.taxWithoutAmount);
    if (tax.minorUnits <= 0) throw fail(ExpenseValidationError.taxNotPositive);
    if (tax.minorUnits > amount.minorUnits) {
      throw fail(ExpenseValidationError.taxExceedsTotal);
    }
  }

  return ValidatedExpenseMoney(
    currencyCode: account,
    amount: amount,
    original: original,
    tax: tax,
  );
}

/// Trimmed text, or null when it is empty.
String? normalizeDescription(String? description) {
  final text = description?.trim();
  return text == null || text.isEmpty ? null : text;
}
