import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_category.dart';

abstract interface class CategoryRepository {
  /// In display order.
  Future<List<ExpenseCategory>> listCategories();
}
