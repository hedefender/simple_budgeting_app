import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_totals.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/create_expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/delete_expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/list_expenses.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/update_expense.dart';

import '../../../support/expense_fakes.dart';
import '../../../support/income_fakes.dart';

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

Matcher _fails(ExpenseValidationError error) => throwsA(
  isA<ExpenseValidationException>().having((e) => e.error, 'error', error),
);

void main() {
  late FakeExpenseRepository repository;
  late FakeCategoryRepository categories;
  late DateTime now;
  late CreateExpense create;
  late UpdateExpense update;
  late DeleteExpense delete;
  late ListExpenses list;

  setUp(() {
    repository = FakeExpenseRepository();
    categories = FakeCategoryRepository();
    now = DateTime.utc(2026, 10, 19, 9);
    final newId = sequentialIds();
    create = CreateExpense(repository, categories, () => now, newId);
    update = UpdateExpense(repository, categories, () => now);
    delete = DeleteExpense(repository);
    list = ListExpenses(repository);
  });

  Future<Expense> add({
    String category = 'food',
    CalendarDate? date,
    String currency = 'EUR',
    int? minor = 4500,
    int? originalMinor,
    String? originalCurrency,
    int? taxMinor,
    String? description,
  }) => create(
    categoryId: category,
    date: date ?? _d(2026, 10, 19),
    currencyCode: currency,
    amount: minor == null ? null : Money(minor),
    originalAmount: originalMinor == null ? null : Money(originalMinor),
    originalCurrencyCode: originalCurrency,
    tax: taxMinor == null ? null : Money(taxMinor),
    description: description,
  );

  group('CreateExpense', () {
    test('stores one total and one category', () async {
      final e = await add(description: '  Supermarket  ');
      expect(e.amount, const Money(4500));
      expect(e.currencyCode, 'EUR');
      expect(e.categoryId, 'food');
      expect(e.description, 'Supermarket');
      expect(e.isPending, isFalse);
      expect(e.createdAt, now);
      expect(e.updatedAt, now);
      expect(await repository.get(e.id), isNotNull);
    });

    test('an empty description is stored as null', () async {
      expect((await add(description: '   ')).description, isNull);
    });

    test('normalizes the currency codes', () async {
      final e = await add(
        currency: ' eur ',
        originalMinor: 2450,
        originalCurrency: 'gbp',
      );
      expect(e.currencyCode, 'EUR');
      expect(e.original, const OriginalAmount(Money(2450), 'GBP'));
    });

    test('keeps the amount and the original amount side by side', () async {
      final e = await add(
        minor: 2890,
        originalMinor: 2450,
        originalCurrency: 'GBP',
      );
      expect(e.amount, const Money(2890));
      expect(e.original!.amount, const Money(2450));
      expect(e.isPending, isFalse);
    });

    test('only an original amount makes a pending expense', () async {
      final e = await add(
        minor: null,
        originalMinor: 2450,
        originalCurrency: 'GBP',
      );
      expect(e.isPending, isTrue);
      expect(e.amount, isNull);
      expect(e.currencyCode, 'EUR');
    });

    test('a date in the future is allowed', () async {
      final e = await add(date: _d(2027, 1, 5));
      expect(e.date, _d(2027, 1, 5));
    });

    test('tax is informational and may equal the total', () async {
      expect((await add(taxMinor: 870)).tax, const Money(870));
      expect((await add(taxMinor: 4500)).tax, const Money(4500));
    });
  });

  group('validation', () {
    test('neither an amount nor an original amount', () {
      expect(add(minor: null), _fails(ExpenseValidationError.amountRequired));
    });

    test('zero and negative amounts', () {
      expect(add(minor: 0), _fails(ExpenseValidationError.amountNotPositive));
      expect(add(minor: -5), _fails(ExpenseValidationError.amountNotPositive));
    });

    test('an original amount needs a currency and the reverse', () {
      expect(
        add(originalMinor: 100),
        _fails(ExpenseValidationError.originalIncomplete),
      );
      expect(
        add(originalCurrency: 'GBP'),
        _fails(ExpenseValidationError.originalIncomplete),
      );
    });

    test('a zero original amount', () {
      expect(
        add(originalMinor: 0, originalCurrency: 'GBP'),
        _fails(ExpenseValidationError.originalAmountNotPositive),
      );
    });

    test('the original currency must differ from the account currency', () {
      expect(
        add(originalMinor: 100, originalCurrency: 'eur'),
        _fails(ExpenseValidationError.originalSameCurrency),
      );
    });

    test('invalid currency codes', () {
      expect(
        add(currency: 'EU'),
        _fails(ExpenseValidationError.currencyInvalid),
      );
      expect(
        add(originalMinor: 100, originalCurrency: 'G1P'),
        _fails(ExpenseValidationError.currencyInvalid),
      );
    });

    test('tax: zero, larger than the total, or without an amount', () {
      expect(add(taxMinor: 0), _fails(ExpenseValidationError.taxNotPositive));
      expect(
        add(taxMinor: 4501),
        _fails(ExpenseValidationError.taxExceedsTotal),
      );
      expect(
        add(
          minor: null,
          originalMinor: 100,
          originalCurrency: 'GBP',
          taxMinor: 10,
        ),
        _fails(ExpenseValidationError.taxWithoutAmount),
      );
    });

    test('an unknown category', () {
      expect(
        add(category: 'nope'),
        _fails(ExpenseValidationError.categoryNotFound),
      );
    });

    test('nothing is stored when validation fails', () async {
      await expectLater(
        add(minor: 0),
        throwsA(isA<ExpenseValidationException>()),
      );
      expect(repository.expenses, isEmpty);
    });
  });

  group('UpdateExpense', () {
    test(
      'completes a pending expense with the amount that was charged',
      () async {
        final pending = await add(
          minor: null,
          originalMinor: 2450,
          originalCurrency: 'GBP',
        );
        now = DateTime.utc(2026, 10, 20, 9);
        final done = await update(
          expenseId: pending.id,
          categoryId: pending.categoryId,
          date: pending.date,
          currencyCode: 'EUR',
          amount: const Money(2890),
          originalAmount: pending.original!.amount,
          originalCurrencyCode: pending.original!.currencyCode,
        );
        expect(done.isPending, isFalse);
        expect(done.amount, const Money(2890));
        expect(done.original, pending.original);
        expect(done.id, pending.id);
        expect(done.createdAt, pending.createdAt);
        expect(done.updatedAt, now);
        expect((await repository.get(pending.id))!.amount, const Money(2890));
      },
    );

    test('can change the category, date and currency', () async {
      final e = await add();
      final changed = await update(
        expenseId: e.id,
        categoryId: 'health',
        date: _d(2026, 11, 2),
        currencyCode: 'USD',
        amount: const Money(100),
      );
      expect(changed.categoryId, 'health');
      expect(changed.date, _d(2026, 11, 2));
      expect(changed.currencyCode, 'USD');
    });

    test('an unknown expense', () {
      expect(
        update(
          expenseId: 'missing',
          categoryId: 'food',
          date: _d(2026, 10, 19),
          currencyCode: 'EUR',
          amount: const Money(1),
        ),
        _fails(ExpenseValidationError.expenseNotFound),
      );
    });

    test(
      'is validated like create, and keeps the stored data on failure',
      () async {
        final e = await add();
        await expectLater(
          update(
            expenseId: e.id,
            categoryId: 'food',
            date: e.date,
            currencyCode: 'EUR',
            amount: const Money(0),
          ),
          _fails(ExpenseValidationError.amountNotPositive),
        );
        expect((await repository.get(e.id))!.amount, const Money(4500));
      },
    );
  });

  group('DeleteExpense', () {
    test('removes the expense', () async {
      final e = await add();
      await delete(e.id);
      expect(await repository.get(e.id), isNull);
    });

    test('an unknown expense', () {
      expect(delete('missing'), _fails(ExpenseValidationError.expenseNotFound));
    });
  });

  group('ListExpenses', () {
    test('only the month, newest first', () async {
      await add(date: _d(2026, 9, 30));
      final early = await add(date: _d(2026, 10, 1));
      final late = await add(date: _d(2026, 10, 31));
      await add(date: _d(2026, 11, 1));

      final result = await list(YearMonth(2026, 10));
      expect(result.expenses.map((e) => e.id), [late.id, early.id]);
    });

    test('filters by category, and the totals follow the filter', () async {
      await add(category: 'food', minor: 1000);
      await add(category: 'health', minor: 2500);
      final food = await list(YearMonth(2026, 10), categoryId: 'food');
      expect(food.expenses, hasLength(1));
      expect(food.totals.single.total, const Money(1000));
    });

    test('totals per currency, never added together', () async {
      await add(currency: 'EUR', minor: 1000);
      await add(currency: 'EUR', minor: 500);
      await add(currency: 'USD', minor: 700);
      await add(currency: 'CHF', minor: 300);

      final result = await list(YearMonth(2026, 10), primaryCurrency: 'USD');
      expect(result.totals.map((t) => t.currencyCode), ['USD', 'CHF', 'EUR']);
      expect(result.totals.map((t) => t.total.minorUnits), [700, 300, 1500]);
    });

    test('a pending expense is listed but counts in no total', () async {
      await add(minor: 1000);
      final pending = await add(
        minor: null,
        originalMinor: 2450,
        originalCurrency: 'GBP',
      );
      final result = await list(YearMonth(2026, 10));
      expect(result.expenses.map((e) => e.id), contains(pending.id));
      expect(result.totals.single.total, const Money(1000));
      expect(result.totals.single.pendingCount, 1);
    });

    test('a currency with only pending expenses still appears', () async {
      await add(
        currency: 'USD',
        minor: null,
        originalMinor: 100,
        originalCurrency: 'GBP',
      );
      final totals = (await list(YearMonth(2026, 10))).totals;
      expect(totals.single.currencyCode, 'USD');
      expect(totals.single.total, Money.zero);
      expect(totals.single.pendingCount, 1);
    });

    test('an empty month has no totals', () async {
      final result = await list(YearMonth(2026, 10));
      expect(result.expenses, isEmpty);
      expect(result.totals, isEmpty);
    });
  });

  test('expenseTotalsByCurrency puts the primary currency first', () {
    final e = Expense(
      id: 'a',
      categoryId: 'food',
      date: _d(2026, 10, 1),
      currencyCode: 'GBP',
      amount: const Money(1),
      createdAt: now,
      updatedAt: now,
    );
    expect(
      expenseTotalsByCurrency([e], primaryCurrency: 'EUR').single.currencyCode,
      'GBP',
    );
  });
}
