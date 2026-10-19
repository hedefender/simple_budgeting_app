import 'package:drift/drift.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_category.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<ExpenseCategory>> listCategories() async {
    final rows = await (_db.select(
      _db.categories,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    return <ExpenseCategory>[
      for (final row in rows)
        ExpenseCategory(
          id: row.id,
          key: row.categoryKey,
          sortOrder: row.sortOrder,
        ),
    ];
  }
}
