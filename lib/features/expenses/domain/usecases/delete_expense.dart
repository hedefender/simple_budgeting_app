import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';

/// Removes an expense for good (the UI asks for confirmation first).
class DeleteExpense {
  const DeleteExpense(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(String expenseId) async {
    if (await _repository.get(expenseId) == null) {
      throw const ExpenseValidationException(
        ExpenseValidationError.expenseNotFound,
      );
    }
    await _repository.delete(expenseId);
  }
}
