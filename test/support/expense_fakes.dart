import 'package:simple_budgeting_app/core/database/seed/built_in_categories.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_category.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/category_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';

/// In-memory expense repository for tests that must not touch SQLite.
class FakeExpenseRepository implements ExpenseRepository {
  final Map<String, Expense> expenses = <String, Expense>{};

  /// When set, a link to any other document id fails like the real
  /// repository does. Null: links are not checked.
  Set<String>? knownDocumentIds;

  void _requireDocument(String? documentId) {
    final known = knownDocumentIds;
    if (documentId == null || known == null || known.contains(documentId)) {
      return;
    }
    throw const ExpenseValidationException(
      ExpenseValidationError.documentNotFound,
    );
  }

  /// What the database does when a document is deleted: the link is cleared.
  void clearDocumentLink(String documentId) {
    for (final e in expenses.values.toList()) {
      if (e.documentId == documentId) {
        expenses[e.id] = Expense(
          id: e.id,
          description: e.description,
          categoryId: e.categoryId,
          date: e.date,
          currencyCode: e.currencyCode,
          amount: e.amount,
          original: e.original,
          tax: e.tax,
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
        );
      }
    }
  }

  @override
  Future<void> add(Expense expense) async {
    _requireDocument(expense.documentId);
    expenses[expense.id] = expense;
  }

  @override
  Future<void> update(Expense expense) async {
    _requireDocument(expense.documentId);
    expenses[expense.id] = expense;
  }

  @override
  Future<void> delete(String id) async {
    expenses.remove(id);
  }

  @override
  Future<Expense?> get(String id) async => expenses[id];

  @override
  Future<List<Expense>> list({
    CalendarDate? from,
    CalendarDate? to,
    String? categoryId,
  }) async {
    final result = expenses.values.where((e) {
      if (from != null && e.date.isBefore(from)) return false;
      if (to != null && e.date.isAfter(to)) return false;
      if (categoryId != null && e.categoryId != categoryId) return false;
      return true;
    }).toList();
    result.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
    });
    return result;
  }

  @override
  Future<List<Expense>> listByDocument(String documentId) async =>
      (await list()).where((e) => e.documentId == documentId).toList();

  @override
  Future<Set<String>> documentIdsWithExpenses() async => {
    for (final e in expenses.values)
      if (e.documentId != null) e.documentId!,
  };

  @override
  Future<Set<String>> listCurrencyCodes() async =>
      expenses.values.map((e) => e.currencyCode).toSet();
}

/// The eight built-in categories, ids equal to keys.
class FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<ExpenseCategory>> listCategories() async => <ExpenseCategory>[
    for (var i = 0; i < builtInCategoryKeys.length; i++)
      ExpenseCategory(
        id: builtInCategoryKeys[i],
        key: builtInCategoryKeys[i],
        sortOrder: i,
      ),
  ];
}
