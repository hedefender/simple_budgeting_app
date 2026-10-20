import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/category_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/create_expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';

/// Replaces every editable field. Giving the amount that was charged to a
/// pending expense completes it.
class UpdateExpense {
  const UpdateExpense(this._repository, this._categories, this._clock);

  final ExpenseRepository _repository;
  final CategoryRepository _categories;
  final Clock _clock;

  Future<Expense> call({
    required String expenseId,
    required String categoryId,
    required CalendarDate date,
    required String currencyCode,
    Money? amount,
    Money? originalAmount,
    String? originalCurrencyCode,
    Money? tax,
    String? description,
  }) async {
    final existing = await _repository.get(expenseId);
    if (existing == null) {
      throw const ExpenseValidationException(
        ExpenseValidationError.expenseNotFound,
      );
    }
    final money = validateExpenseMoney(
      currencyCode: currencyCode,
      amount: amount,
      originalAmount: originalAmount,
      originalCurrencyCode: originalCurrencyCode,
      tax: tax,
    );
    await requireCategory(_categories, categoryId);
    final updated = Expense(
      id: existing.id,
      description: normalizeDescription(description),
      categoryId: categoryId,
      date: date,
      currencyCode: money.currencyCode,
      amount: money.amount,
      original: money.original,
      tax: money.tax,
      // The link to the document is kept when the expense is edited.
      documentId: existing.documentId,
      createdAt: existing.createdAt,
      updatedAt: _clock().toUtc(),
    );
    await _repository.update(updated);
    return updated;
  }
}
