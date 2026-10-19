import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_category.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// The display name of a category. A key without a translation (a category
/// added to the catalogue before its ARB entry) shows the key itself.
String categoryLabel(AppLocalizations l10n, ExpenseCategory category) {
  return switch (category.key) {
    'energy' => l10n.categoryEnergy,
    'water' => l10n.categoryWater,
    'telecom' => l10n.categoryTelecom,
    'food' => l10n.categoryFood,
    'fuel_transport' => l10n.categoryFuelTransport,
    'health' => l10n.categoryHealth,
    'insurance' => l10n.categoryInsurance,
    'other' => l10n.categoryOther,
    final String other => other,
  };
}

/// The category with [id] in [categories], or null.
ExpenseCategory? categoryById(List<ExpenseCategory> categories, String id) {
  for (final category in categories) {
    if (category.id == id) return category;
  }
  return null;
}

String expenseValidationMessage(
  AppLocalizations l10n,
  ExpenseValidationError error,
) {
  return switch (error) {
    ExpenseValidationError.amountRequired => l10n.errorExpenseAmountRequired,
    ExpenseValidationError.amountNotPositive => l10n.errorAmountPositive,
    ExpenseValidationError.originalAmountNotPositive =>
      l10n.errorAmountPositive,
    ExpenseValidationError.originalIncomplete =>
      l10n.errorExpenseOriginalIncomplete,
    ExpenseValidationError.originalSameCurrency =>
      l10n.errorExpenseOriginalSameCurrency,
    ExpenseValidationError.currencyInvalid => l10n.currencyInvalid,
    ExpenseValidationError.taxNotPositive => l10n.errorAmountPositive,
    ExpenseValidationError.taxWithoutAmount => l10n.errorExpenseTaxNoAmount,
    ExpenseValidationError.taxExceedsTotal => l10n.errorExpenseTaxTooLarge,
    ExpenseValidationError.categoryNotFound => l10n.errorExpenseCategory,
    ExpenseValidationError.expenseNotFound => l10n.errorExpenseNotFound,
  };
}
