import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';

import '../../../support/income_harness.dart';

/// "Today" is 2026-10-18 (IncomeHarness default).
void main() {
  late IncomeHarness h;
  final jan1 = CalendarDate(2026, 1, 1);
  final at = DateTime.utc(2026, 10, 1);
  var n = 0;

  setUp(() {
    h = IncomeHarness();
    n = 0;
  });

  Future<void> spend(int minor, CalendarDate date, {String currency = 'EUR'}) =>
      h.expenses.add(
        Expense(
          id: 'x${++n}',
          categoryId: 'food',
          date: date,
          currencyCode: currency,
          amount: Money(minor),
          createdAt: at,
          updatedAt: at,
        ),
      );

  Future<void> pending(CalendarDate date, {String currency = 'EUR'}) =>
      h.expenses.add(
        Expense(
          id: 'p${++n}',
          categoryId: 'food',
          date: date,
          currencyCode: currency,
          original: const OriginalAmount(Money(2450), 'GBP'),
          createdAt: at,
          updatedAt: at,
        ),
      );

  Future<void> anchor(CalendarDate date, int minor, {String code = 'EUR'}) =>
      h.setAnchor(date: date, balance: Money(minor), currencyCode: code);

  Future<MonthlyCashFlow> flow(int y, int m, {String currency = 'EUR'}) =>
      h.cashFlow(YearMonth(y, m), currency);

  group('without an anchor', () {
    test('every expense up to the day is subtracted', () async {
      await h.monthly(name: 'Salary', minor: 100000, day: 5, start: jan1);
      await spend(4500, CalendarDate(2026, 9, 10));
      await spend(1500, CalendarDate(2026, 10, 12));

      final october = await flow(2026, 10);

      expect(october.openingBalance, const Money(900000 - 4500));
      expect(october.projectedClosingBalance, const Money(1000000 - 6000));
      expect(october.expenses, const Money(1500));
    });

    test('a month with no income can have negative balance', () async {
      await spend(2000, CalendarDate(2026, 10, 3));
      final october = await flow(2026, 10);
      expect(october.expenses, const Money(2000));
      expect(october.projectedClosingBalance, const Money(-2000));
    });

    test('a future expense is subtracted from the projected balance', () async {
      await spend(3000, CalendarDate(2026, 10, 28));
      final october = await flow(2026, 10);
      expect(october.projectedClosingBalance, const Money(-3000));
    });
  });

  group('with an anchor', () {
    test('an expense before the anchor is already inside it', () async {
      await anchor(CalendarDate(2026, 10, 10), 50000);
      await spend(7000, CalendarDate(2026, 10, 9));

      final october = await flow(2026, 10);

      expect(october.projectedClosingBalance, const Money(50000));
      // The line still lists the month's expense (like received income does).
      expect(october.expenses, const Money(7000));
    });

    test('an expense ON the anchor day is inside the anchor', () async {
      await anchor(CalendarDate(2026, 10, 10), 50000);
      await spend(7000, CalendarDate(2026, 10, 10));

      expect(
        (await flow(2026, 10)).projectedClosingBalance,
        const Money(50000),
      );
    });

    test('an expense the day after the anchor is subtracted', () async {
      await anchor(CalendarDate(2026, 10, 10), 50000);
      await spend(7000, CalendarDate(2026, 10, 11));

      expect(
        (await flow(2026, 10)).projectedClosingBalance,
        const Money(43000),
      );
    });

    test('the opening balance of the next month uses the same rule', () async {
      await anchor(CalendarDate(2026, 10, 10), 50000);
      await spend(7000, CalendarDate(2026, 10, 10));
      await spend(1000, CalendarDate(2026, 10, 20));

      final november = await flow(2026, 11);

      expect(november.openingBalance, const Money(49000));
    });

    test('with the anchor inside the month the line is not the balance '
        'difference', () async {
      await anchor(CalendarDate(2026, 10, 10), 50000);
      await spend(7000, CalendarDate(2026, 10, 5)); // before the anchor
      await spend(1000, CalendarDate(2026, 10, 20)); // after it

      final october = await flow(2026, 10);

      expect(october.expenses, const Money(8000));
      expect(
        october.openingBalance - october.projectedClosingBalance,
        isNot(october.expenses),
      );
    });
  });

  group('pending expenses', () {
    test(
      'count in no sum and no balance, but are counted for the card',
      () async {
        await spend(1000, CalendarDate(2026, 10, 5));
        await pending(CalendarDate(2026, 10, 6));
        await pending(CalendarDate(2026, 10, 7));

        final october = await flow(2026, 10);

        expect(october.expenses, const Money(1000));
        expect(october.pendingExpenseCount, 2);
        expect(october.projectedClosingBalance, const Money(-1000));
      },
    );

    test('only the pending expenses of that month are counted there', () async {
      await pending(CalendarDate(2026, 9, 30));
      expect((await flow(2026, 10)).pendingExpenseCount, 0);
      expect((await flow(2026, 9)).pendingExpenseCount, 1);
    });

    test('become part of the balance once the amount is given', () async {
      await pending(CalendarDate(2026, 10, 6));
      expect((await flow(2026, 10)).projectedClosingBalance, Money.zero);

      await h.expenses.update(
        Expense(
          id: 'p1',
          categoryId: 'food',
          date: CalendarDate(2026, 10, 6),
          currencyCode: 'EUR',
          amount: const Money(2890),
          original: const OriginalAmount(Money(2450), 'GBP'),
          createdAt: at,
          updatedAt: at,
        ),
      );

      final october = await flow(2026, 10);
      expect(october.projectedClosingBalance, const Money(-2890));
      expect(october.pendingExpenseCount, 0);
    });
  });

  group('currencies', () {
    test('expenses never mix currencies', () async {
      await spend(1000, CalendarDate(2026, 10, 5), currency: 'EUR');
      await spend(400, CalendarDate(2026, 10, 6), currency: 'USD');

      expect((await flow(2026, 10)).expenses, const Money(1000));
      expect(
        (await flow(2026, 10, currency: 'USD')).projectedClosingBalance,
        const Money(-400),
      );
    });

    test('an anchor applies only to its own currency', () async {
      await anchor(CalendarDate(2026, 10, 10), 50000, code: 'EUR');
      await spend(900, CalendarDate(2026, 10, 5), currency: 'USD');

      expect(
        (await flow(2026, 10, currency: 'USD')).projectedClosingBalance,
        const Money(-900),
      );
    });

    test('a currency that has only expenses gets its own block', () async {
      await spend(900, CalendarDate(2026, 10, 5), currency: 'CHF');

      final summary = await h.cashFlow.forAllCurrencies(
        YearMonth(2026, 10),
        'EUR',
      );

      expect(summary.currencies.map((c) => c.currencyCode), ['EUR', 'CHF']);
      expect(summary.currencies.last.expenses, const Money(900));
    });

    test('a currency with only a pending expense still gets a block', () async {
      await pending(CalendarDate(2026, 10, 5), currency: 'CHF');

      final summary = await h.cashFlow.forAllCurrencies(
        YearMonth(2026, 10),
        'EUR',
      );

      final chf = summary.currencies.firstWhere((c) => c.currencyCode == 'CHF');
      expect(chf.pendingExpenseCount, 1);
      expect(chf.expenses, Money.zero);
    });
  });
}
