import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_category.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_totals.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/category_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';

/// The expenses of a month with the totals per currency. The totals follow the
/// same category filter as the list and leave pending expenses out.
class ListExpenses {
  const ListExpenses(this._repository);

  final ExpenseRepository _repository;

  Future<ExpenseListResult> call(
    YearMonth month, {
    String? categoryId,
    String? primaryCurrency,
  }) async {
    final expenses = await _repository.list(
      from: month.firstDay,
      to: month.lastDay,
      categoryId: categoryId,
    );
    return ExpenseListResult(
      expenses: expenses,
      totals: expenseTotalsByCurrency(
        expenses,
        primaryCurrency: primaryCurrency,
      ),
    );
  }
}

class ListExpenseCategories {
  const ListExpenseCategories(this._repository);

  final CategoryRepository _repository;

  Future<List<ExpenseCategory>> call() => _repository.listCategories();
}
