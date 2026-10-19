import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:simple_budgeting_app/app/di/service_locator.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/create_expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/list_expenses.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/update_expense.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/get_monthly_cash_flow.dart';

/// On-device test using a SEPARATE temporary database file (deleted at the
/// end), so the app's real data on the device is never touched:
///   `flutter test integration_test/expense_persistence_test.dart -d <device-id>`
///
/// Expenses in two currencies, one of them pending, are written, the
/// dependency graph is closed (like a process exit) and rebuilt on the same
/// file; everything must still be there, and the pending one must still count
/// nowhere until it is completed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('expenses, a pending one and the categories survive a restart', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('expense_persistence_');
    final file = File('${dir.path}/test.sqlite');
    final locator = GetIt.instance;
    addTearDown(() async {
      await locator.reset();
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    configureDependencies(locator, databaseExecutor: NativeDatabase(file));
    final food = await locator.get<CreateExpense>()(
      categoryId: 'food',
      date: CalendarDate(2026, 10, 5),
      currencyCode: 'EUR',
      amount: const Money(4500),
      tax: const Money(520),
      description: 'Supermarket',
    );
    final pending = await locator.get<CreateExpense>()(
      categoryId: 'other',
      date: CalendarDate(2026, 10, 6),
      currencyCode: 'CHF',
      originalAmount: const Money(2450),
      originalCurrencyCode: 'GBP',
    );
    await locator.reset(); // closes the database like a process exit

    configureDependencies(locator, databaseExecutor: NativeDatabase(file));
    final month = YearMonth(2026, 10);
    final result = await locator.get<ListExpenses>()(
      month,
      primaryCurrency: 'EUR',
    );
    expect(result.expenses, hasLength(2));
    final storedFood = result.expenses.firstWhere((e) => e.id == food.id);
    expect(storedFood.amount, const Money(4500));
    expect(storedFood.tax, const Money(520));
    expect(storedFood.description, 'Supermarket');
    expect(storedFood.categoryId, 'food');
    final storedPending = result.expenses.firstWhere((e) => e.id == pending.id);
    expect(storedPending.isPending, isTrue);
    expect(storedPending.original, const OriginalAmount(Money(2450), 'GBP'));
    expect(result.totals.map((t) => t.currencyCode), ['EUR', 'CHF']);
    expect(result.totals[0].total, const Money(4500));
    expect(result.totals[1].total, Money.zero);
    expect(result.totals[1].pendingCount, 1);

    // The cash flow: the pending expense counts in no balance.
    final summary = await locator.get<GetMonthlyCashFlow>().forAllCurrencies(
      month,
      'EUR',
    );
    final eur = summary.currencies.firstWhere((c) => c.currencyCode == 'EUR');
    final chf = summary.currencies.firstWhere((c) => c.currencyCode == 'CHF');
    expect(eur.expenses, const Money(4500));
    expect(eur.projectedClosingBalance, const Money(-4500));
    expect(chf.pendingExpenseCount, 1);
    expect(chf.projectedClosingBalance, Money.zero);

    // Completing the pending expense makes it count.
    await locator.get<UpdateExpense>()(
      expenseId: pending.id,
      categoryId: 'other',
      date: CalendarDate(2026, 10, 6),
      currencyCode: 'CHF',
      amount: const Money(2890),
      originalAmount: const Money(2450),
      originalCurrencyCode: 'GBP',
    );
    final after = await locator.get<GetMonthlyCashFlow>()(month, 'CHF');
    expect(after.pendingExpenseCount, 0);
    expect(after.projectedClosingBalance, const Money(-2890));
  });
}
