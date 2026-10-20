import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/document_usecases.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_category.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_totals.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/create_expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/delete_expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/list_expenses.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/update_expense.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_providers.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/list_known_currencies.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_providers.dart';

/// The month the Expenses page shows. Independent of the Income page.
class ExpenseMonthNotifier extends Notifier<YearMonth> {
  @override
  YearMonth build() => YearMonth.of(ref.read(todayProvider));

  void previous() => state = state.plusMonths(-1);

  void next() => state = state.plusMonths(1);
}

final NotifierProvider<ExpenseMonthNotifier, YearMonth> expenseMonthProvider =
    NotifierProvider<ExpenseMonthNotifier, YearMonth>(ExpenseMonthNotifier.new);

/// The category id the list is filtered by, or null for all categories.
class ExpenseCategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? categoryId) => state = categoryId;
}

final NotifierProvider<ExpenseCategoryFilterNotifier, String?>
expenseCategoryFilterProvider =
    NotifierProvider<ExpenseCategoryFilterNotifier, String?>(
      ExpenseCategoryFilterNotifier.new,
    );

final FutureProvider<List<ExpenseCategory>> expenseCategoriesProvider =
    FutureProvider.autoDispose<List<ExpenseCategory>>(
      (Ref ref) =>
          ref.watch(serviceLocatorProvider).get<ListExpenseCategories>()(),
    );

/// The expenses of the selected month and category, with totals per currency.
final FutureProvider<ExpenseListResult> expenseListProvider =
    FutureProvider.autoDispose<ExpenseListResult>((Ref ref) async {
      final month = ref.watch(expenseMonthProvider);
      final categoryId = ref.watch(expenseCategoryFilterProvider);
      final primary = await ref.watch(primaryCurrencyProvider.future);
      return ref.watch(serviceLocatorProvider).get<ListExpenses>()(
        month,
        categoryId: categoryId,
        primaryCurrency: primary,
      );
    });

/// The currencies an expense can be charged in: those that exist in the app,
/// the primary one first.
final FutureProvider<List<String>> knownCurrenciesProvider =
    FutureProvider.autoDispose<List<String>>((Ref ref) async {
      final primary = await ref.watch(primaryCurrencyProvider.future);
      return ref.watch(serviceLocatorProvider).get<ListKnownCurrencies>()(
        primary,
      );
    });

// The expenses of a document live here, not with the documents, because
// creating or editing an expense refreshes them and the documents screens
// depend on the expenses ones, never the other way round.

/// The ids of the documents that have at least one expense.
final FutureProvider<Set<String>> documentIdsWithExpensesProvider =
    FutureProvider.autoDispose<Set<String>>(
      (Ref ref) => ref
          .watch(serviceLocatorProvider)
          .get<ListDocumentIdsWithExpenses>()(),
    );

/// The expenses made from one document.
final documentExpensesProvider = FutureProvider.autoDispose
    .family<List<Expense>, String>(
      (Ref ref, String id) =>
          ref.watch(serviceLocatorProvider).get<ListDocumentExpenses>()(id),
    );

final Provider<ExpenseActions> expenseActionsProvider =
    Provider<ExpenseActions>((Ref ref) => ExpenseActions(ref));

/// Runs the expense use cases and refreshes what the screens show, including
/// the cash flow of the Income page.
class ExpenseActions {
  ExpenseActions(this._ref);

  final Ref _ref;

  T _use<T extends Object>() => _ref.read(serviceLocatorProvider).get<T>();

  void _refresh() {
    _ref
      ..invalidate(expenseListProvider)
      ..invalidate(knownCurrenciesProvider)
      ..invalidate(documentIdsWithExpensesProvider)
      ..invalidate(documentExpensesProvider)
      ..invalidate(monthlyCashFlowProvider);
  }

  Future<Expense> create({
    required String categoryId,
    required CalendarDate date,
    required String currencyCode,
    Money? amount,
    Money? originalAmount,
    String? originalCurrencyCode,
    Money? tax,
    String? description,
    String? documentId,
  }) async {
    final expense = await _use<CreateExpense>()(
      categoryId: categoryId,
      date: date,
      currencyCode: currencyCode,
      amount: amount,
      originalAmount: originalAmount,
      originalCurrencyCode: originalCurrencyCode,
      tax: tax,
      description: description,
      documentId: documentId,
    );
    _refresh();
    return expense;
  }

  Future<Expense> update({
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
    final expense = await _use<UpdateExpense>()(
      expenseId: expenseId,
      categoryId: categoryId,
      date: date,
      currencyCode: currencyCode,
      amount: amount,
      originalAmount: originalAmount,
      originalCurrencyCode: originalCurrencyCode,
      tax: tax,
      description: description,
    );
    _refresh();
    return expense;
  }

  Future<void> delete(String expenseId) async {
    await _use<DeleteExpense>()(expenseId);
    _refresh();
  }
}
