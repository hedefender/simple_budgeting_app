import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/category_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';

class CreateExpense {
  const CreateExpense(
    this._repository,
    this._categories,
    this._clock,
    this._newId,
  );

  final ExpenseRepository _repository;
  final CategoryRepository _categories;
  final Clock _clock;
  final IdGenerator _newId;

  /// [amount] is what was charged, in [currencyCode] (the account currency).
  /// With only [originalAmount] and [originalCurrencyCode] the expense is
  /// saved as pending (awaiting amount).
  Future<Expense> call({
    required String categoryId,
    required CalendarDate date,
    required String currencyCode,
    Money? amount,
    Money? originalAmount,
    String? originalCurrencyCode,
    Money? tax,
    String? description,
  }) async {
    final money = validateExpenseMoney(
      currencyCode: currencyCode,
      amount: amount,
      originalAmount: originalAmount,
      originalCurrencyCode: originalCurrencyCode,
      tax: tax,
    );
    await requireCategory(_categories, categoryId);
    final now = _clock().toUtc();
    final expense = Expense(
      id: _newId(),
      description: normalizeDescription(description),
      categoryId: categoryId,
      date: date,
      currencyCode: money.currencyCode,
      amount: money.amount,
      original: money.original,
      tax: money.tax,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.add(expense);
    return expense;
  }
}

/// Throws [ExpenseValidationError.categoryNotFound] for an unknown category.
Future<void> requireCategory(CategoryRepository categories, String id) async {
  final all = await categories.listCategories();
  if (!all.any((c) => c.id == id)) {
    throw const ExpenseValidationException(
      ExpenseValidationError.categoryNotFound,
    );
  }
}
