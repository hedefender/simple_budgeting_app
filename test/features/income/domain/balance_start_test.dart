import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_start.dart';

import '../../../support/income_harness.dart';

CalendarDate _d(int y, int m, int d) => CalendarDate(y, m, d);

/// "Today" is 2026-10-18 (IncomeHarness default).
void main() {
  late IncomeHarness h;
  final at = DateTime.utc(2026, 10, 1);
  var n = 0;

  setUp(() {
    h = IncomeHarness();
    n = 0;
  });

  Future<void> anchor(CalendarDate date, int minor, {String code = 'EUR'}) =>
      h.setAnchor(date: date, balance: Money(minor), currencyCode: code);

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

  group('GetBalanceStart', () {
    test('the oldest anchor of the currency', () async {
      await anchor(_d(2026, 10, 12), 78000);
      await anchor(_d(2026, 10, 1), 50000);
      await h.monthly(name: 'Salary', minor: 1, day: 5, start: _d(2026, 1, 1));

      final start = (await h.balanceStart('EUR'))!;
      expect(start.date, _d(2026, 10, 1));
      expect(start.fromAnchor, isTrue);
    });

    test('an anchor wins over an older source', () async {
      await h.monthly(name: 'Salary', minor: 1, day: 5, start: _d(2026, 1, 1));
      await anchor(_d(2026, 10, 12), 78000);
      expect((await h.balanceStart('EUR'))!.date, _d(2026, 10, 12));
    });

    test('without an anchor, the oldest source (archived too)', () async {
      await h.monthly(name: 'New', minor: 1, day: 5, start: _d(2026, 6, 1));
      final old = await h.monthly(
        name: 'Old',
        minor: 1,
        day: 5,
        start: _d(2026, 2, 3),
      );
      await h.archive(old.id);

      final start = (await h.balanceStart('EUR'))!;
      expect(start.date, _d(2026, 2, 3));
      expect(start.fromAnchor, isFalse);
    });

    test('neither an anchor nor a source: no start', () async {
      expect(await h.balanceStart('EUR'), isNull);
    });

    test('every currency has its own start', () async {
      await anchor(_d(2026, 10, 12), 1, code: 'USD');
      await h.monthly(
        name: 'Euro job',
        minor: 1,
        day: 5,
        start: _d(2026, 3, 1),
      );
      expect((await h.balanceStart('USD'))!.date, _d(2026, 10, 12));
      expect((await h.balanceStart('EUR'))!.date, _d(2026, 3, 1));
      expect(await h.balanceStart('CHF'), isNull);
    });
  });

  group('BalanceStart', () {
    test('from an anchor, the anchor day is already inside the balance', () {
      final s = BalanceStart(date: _d(2026, 10, 12), fromAnchor: true);
      expect(s.firstAffectingDay, _d(2026, 10, 13));
      expect(s.isBeforeBalance(_d(2026, 10, 12)), isTrue);
      expect(s.isBeforeBalance(_d(2026, 10, 13)), isFalse);
    });

    test('from a source, its start day already counts', () {
      final s = BalanceStart(date: _d(2026, 6, 1), fromAnchor: false);
      expect(s.firstAffectingDay, _d(2026, 6, 1));
      expect(s.isBeforeBalance(_d(2026, 5, 31)), isTrue);
      expect(s.isBeforeBalance(_d(2026, 6, 1)), isFalse);
    });
  });

  group('the month before, the start month and after (anchor on 12 Oct)', () {
    setUp(() async {
      await anchor(_d(2026, 10, 12), 78000);
      await spend(9800, _d(2026, 9, 24)); // the case found on the emulator
    });

    test('the month before the start has an unknown balance', () async {
      final sep = await h.cashFlow(YearMonth(2026, 9), 'EUR');
      expect(sep.balanceUnknown, isTrue);
      expect(sep.balanceStart!.date, _d(2026, 10, 12));
      // The expense stays visible in the line.
      expect(sep.expenses, const Money(9800));
    });

    test('the start month is computed as before', () async {
      final oct = await h.cashFlow(YearMonth(2026, 10), 'EUR');
      expect(oct.balanceUnknown, isFalse);
      expect(oct.projectedClosingBalance, const Money(78000));
      // The September expense is history: it changes no balance.
      expect(oct.openingBalance, Money.zero);
    });

    test('the month after the start starts from the anchor', () async {
      final nov = await h.cashFlow(YearMonth(2026, 11), 'EUR');
      expect(nov.balanceUnknown, isFalse);
      expect(nov.openingBalance, const Money(78000));
      expect(nov.projectedClosingBalance, const Money(78000));
    });

    test('a month that ENDS on the start day is not unknown', () async {
      await anchor(_d(2026, 10, 31), 1000, code: 'USD');
      final oct = await h.cashFlow(YearMonth(2026, 10), 'USD');
      expect(oct.balanceUnknown, isFalse);
    });
  });

  group('without an anchor', () {
    test('an expense before the first source is history only', () async {
      await h.monthly(
        name: 'Salary',
        minor: 100000,
        day: 5,
        start: _d(2026, 10, 1),
      );
      await spend(9800, _d(2026, 9, 24));
      await spend(500, _d(2026, 10, 3));

      final oct = await h.cashFlow(YearMonth(2026, 10), 'EUR');
      expect(oct.balanceUnknown, isFalse);
      expect(oct.projectedClosingBalance, const Money(100000 - 500));
      expect(oct.openingBalance, Money.zero);

      final sep = await h.cashFlow(YearMonth(2026, 9), 'EUR');
      expect(sep.balanceUnknown, isTrue);
      expect(sep.expenses, const Money(9800));
    });

    test('an expense ON the source start day counts', () async {
      await h.monthly(
        name: 'Salary',
        minor: 100000,
        day: 5,
        start: _d(2026, 10, 1),
      );
      await spend(500, _d(2026, 10, 1));
      final oct = await h.cashFlow(YearMonth(2026, 10), 'EUR');
      expect(oct.projectedClosingBalance, const Money(100000 - 500));
    });

    test('no anchor and no source: nothing is unknown, as before', () async {
      await spend(2000, _d(2026, 9, 3));
      final sep = await h.cashFlow(YearMonth(2026, 9), 'EUR');
      expect(sep.balanceStart, isNull);
      expect(sep.balanceUnknown, isFalse);
      expect(sep.projectedClosingBalance, const Money(-2000));
    });
  });

  test('several currencies: each month is judged by its own start', () async {
    await anchor(_d(2026, 10, 12), 78000);
    await h.monthly(
      name: 'Dollar job',
      minor: 1000,
      day: 5,
      start: _d(2026, 8, 1),
      currency: 'USD',
    );
    final summary = await h.cashFlow.forAllCurrencies(
      YearMonth(2026, 9),
      'EUR',
    );
    final eur = summary.currencies.firstWhere((c) => c.currencyCode == 'EUR');
    final usd = summary.currencies.firstWhere((c) => c.currencyCode == 'USD');
    expect(eur.balanceUnknown, isTrue);
    expect(usd.balanceUnknown, isFalse);
  });
}
