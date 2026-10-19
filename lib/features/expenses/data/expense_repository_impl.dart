import 'package:drift/drift.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> add(Expense expense) async {
    await _db.into(_db.expenses).insert(_companion(expense));
  }

  @override
  Future<void> update(Expense expense) async {
    await (_db.update(
      _db.expenses,
    )..where((t) => t.id.equals(expense.id))).write(_companion(expense));
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<Expense?> get(String id) async {
    final row = await (_db.select(
      _db.expenses,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toExpense(row);
  }

  @override
  Future<List<Expense>> list({
    CalendarDate? from,
    CalendarDate? to,
    String? categoryId,
  }) async {
    final query = _db.select(_db.expenses)
      ..orderBy([
        (t) => OrderingTerm.desc(t.expenseDate),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    // Dates are `yyyy-MM-dd` text, so text order is date order.
    if (from != null) {
      query.where((t) => t.expenseDate.isBiggerOrEqualValue(from.toString()));
    }
    if (to != null) {
      query.where((t) => t.expenseDate.isSmallerOrEqualValue(to.toString()));
    }
    if (categoryId != null) {
      query.where((t) => t.categoryId.equals(categoryId));
    }
    return (await query.get()).map(_toExpense).toList();
  }

  @override
  Future<Set<String>> listCurrencyCodes() async {
    final query = _db.selectOnly(_db.expenses, distinct: true)
      ..addColumns([_db.expenses.currencyCode]);
    final rows = await query.get();
    return rows.map((r) => r.read(_db.expenses.currencyCode)!).toSet();
  }

  ExpensesCompanion _companion(Expense e) {
    return ExpensesCompanion(
      id: Value(e.id),
      description: Value(e.description),
      categoryId: Value(e.categoryId),
      expenseDate: Value(e.date.toString()),
      currencyCode: Value(e.currencyCode),
      amountMinor: Value(e.amount?.minorUnits),
      originalAmountMinor: Value(e.original?.amount.minorUnits),
      originalCurrencyCode: Value(e.original?.currencyCode),
      taxAmountMinor: Value(e.tax?.minorUnits),
      createdAt: Value(e.createdAt),
      updatedAt: Value(e.updatedAt),
    );
  }

  Expense _toExpense(ExpenseRow row) {
    final originalMinor = row.originalAmountMinor;
    final originalCurrency = row.originalCurrencyCode;
    return Expense(
      id: row.id,
      description: row.description,
      categoryId: row.categoryId,
      date: CalendarDate.parse(row.expenseDate),
      currencyCode: row.currencyCode,
      amount: row.amountMinor == null ? null : Money(row.amountMinor!),
      original: originalMinor == null || originalCurrency == null
          ? null
          : OriginalAmount(Money(originalMinor), originalCurrency),
      tax: row.taxAmountMinor == null ? null : Money(row.taxAmountMinor!),
      createdAt: row.createdAt.toUtc(),
      updatedAt: row.updatedAt.toUtc(),
    );
  }
}
