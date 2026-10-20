import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';

abstract interface class ExpenseRepository {
  Future<void> add(Expense expense);

  /// Replaces the stored expense with the same id.
  Future<void> update(Expense expense);

  Future<void> delete(String id);

  Future<Expense?> get(String id);

  /// Newest date first, then newest created first. [from] and [to] are
  /// inclusive; all filters are optional.
  Future<List<Expense>> list({
    CalendarDate? from,
    CalendarDate? to,
    String? categoryId,
  });

  /// The expenses linked to a document, newest first.
  Future<List<Expense>> listByDocument(String documentId);

  /// The ids of the documents that have at least one expense.
  Future<Set<String>> documentIdsWithExpenses();

  /// The currencies of all expenses, pending ones included.
  Future<Set<String>> listCurrencyCodes();
}
