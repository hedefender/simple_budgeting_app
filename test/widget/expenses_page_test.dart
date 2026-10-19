import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expenses_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/expense_fakes.dart';
import '../support/income_fakes.dart';
import '../support/settings_fakes.dart';

/// "Today" is 2026-10-16.
void main() {
  late GetIt locator;
  late FakeExpenseRepository expenses;
  late FakeSettingsRepository settings;
  final at = DateTime.utc(2026, 10, 1);

  setUp(() {
    locator = GetIt.asNewInstance();
    final fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    expenses = fakes.expenses;
    settings = fakes.settings;
    settings.primaryCurrency = 'EUR';
  });

  tearDown(() => locator.reset());

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en', 'US'),
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceLocatorProvider.overrideWithValue(locator),
          deviceLocaleProvider.overrideWithValue(locale),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ExpensesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Expense expense(
    String id, {
    int? minor = 1000,
    String category = 'food',
    String currency = 'EUR',
    int month = 10,
    int day = 5,
    String? description,
    OriginalAmount? original,
  }) => Expense(
    id: id,
    description: description,
    categoryId: category,
    date: CalendarDate(2026, month, day),
    currencyCode: currency,
    amount: minor == null ? null : Money(minor),
    original: original,
    createdAt: at,
    updatedAt: at,
  );

  String textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  testWidgets('an empty month says so', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('expenses-empty')), findsOneWidget);
    expect(find.text('No expenses this month'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
  });

  testWidgets('lists the month newest first with the total per currency', (
    tester,
  ) async {
    await expenses.add(expense('a', minor: 4500, day: 3, description: 'Shop'));
    await expenses.add(expense('b', minor: 1500, day: 12));
    await expenses.add(expense('c', minor: 700, day: 8, currency: 'USD'));
    await expenses.add(expense('old', minor: 999, month: 9, day: 30));

    await pump(tester);

    expect(find.byKey(const Key('expense-tile-old')), findsNothing);
    final top = <double>[
      for (final id in ['b', 'c', 'a'])
        tester.getTopLeft(find.byKey(Key('expense-tile-$id'))).dy,
    ];
    expect(top, [...top]..sort());
    expect(textOf(tester, 'expense-total-EUR'), '€60.00');
    expect(textOf(tester, 'expense-total-USD'), r'$7.00');
    expect(textOf(tester, 'expense-amount-a'), '€45.00');
    expect(find.text('Shop'), findsOneWidget);
    // Without a description the category names the row.
    expect(find.text('Food'), findsWidgets);
  });

  testWidgets('the primary currency total comes first', (tester) async {
    settings.primaryCurrency = 'USD';
    await expenses.add(expense('a', currency: 'EUR'));
    await expenses.add(expense('b', currency: 'USD'));
    await pump(tester);
    expect(
      tester.getTopLeft(find.byKey(const Key('expense-total-USD'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('expense-total-EUR'))).dy,
      ),
    );
  });

  testWidgets('month navigation shows another month', (tester) async {
    await expenses.add(expense('sep', month: 9, day: 30, minor: 999));
    await pump(tester);
    expect(find.byKey(const Key('expense-tile-sep')), findsNothing);

    await tester.tap(find.byKey(const Key('expense-month-previous')));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.byKey(const Key('expense-tile-sep')), findsOneWidget);

    await tester.tap(find.byKey(const Key('expense-month-next')));
    await tester.tap(find.byKey(const Key('expense-month-next')));
    await tester.pumpAndSettle();
    expect(find.text('November 2026'), findsOneWidget);
  });

  testWidgets('a pending expense is listed, marked, and not in the total', (
    tester,
  ) async {
    await expenses.add(expense('a', minor: 1000));
    await expenses.add(
      expense(
        'p',
        minor: null,
        original: const OriginalAmount(Money(2450), 'GBP'),
      ),
    );

    await pump(tester);

    expect(find.byKey(const Key('expense-pending-p')), findsOneWidget);
    expect(find.text('Awaiting amount'), findsOneWidget);
    expect(find.byKey(const Key('expense-amount-p')), findsNothing);
    expect(textOf(tester, 'expense-total-EUR'), '€10.00');
    expect(
      find.text('1 expense awaits an amount (not counted)'),
      findsOneWidget,
    );
    // The original amount is shown, informational.
    expect(find.textContaining('£24.50'), findsOneWidget);
  });

  testWidgets('a month with only a pending expense is not shown as empty', (
    tester,
  ) async {
    await expenses.add(
      expense(
        'p',
        minor: null,
        original: const OriginalAmount(Money(2450), 'GBP'),
      ),
    );
    await pump(tester);
    expect(find.byKey(const Key('expenses-empty')), findsNothing);
    expect(find.byKey(const Key('expense-pending-p')), findsOneWidget);
    expect(textOf(tester, 'expense-total-EUR'), '€0.00');
  });

  group('category filter', () {
    Future<void> choose(WidgetTester tester, String label) async {
      await tester.tap(find.byKey(const Key('expense-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    testWidgets('narrows the list and the totals', (tester) async {
      await expenses.add(expense('f', category: 'food', minor: 1000));
      await expenses.add(expense('h', category: 'health', minor: 2500));
      await pump(tester);
      expect(textOf(tester, 'expense-total-EUR'), '€35.00');

      await choose(tester, 'Health');

      expect(find.byKey(const Key('expense-tile-h')), findsOneWidget);
      expect(find.byKey(const Key('expense-tile-f')), findsNothing);
      expect(textOf(tester, 'expense-total-EUR'), '€25.00');
    });

    testWidgets('"All categories" shows everything again', (tester) async {
      await expenses.add(expense('f', category: 'food'));
      await expenses.add(expense('h', category: 'health'));
      await pump(tester);
      await choose(tester, 'Health');
      await choose(tester, 'All categories');
      expect(find.byKey(const Key('expense-tile-f')), findsOneWidget);
      expect(find.byKey(const Key('expense-tile-h')), findsOneWidget);
    });

    testWidgets('an empty filtered month has its own message', (tester) async {
      await expenses.add(expense('f', category: 'food'));
      await pump(tester);
      await choose(tester, 'Insurance');
      expect(
        find.text('No expenses in this category this month'),
        findsOneWidget,
      );
    });

    testWidgets('lists all eight categories', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('expense-filter')));
      await tester.pumpAndSettle();
      for (final name in [
        'Energy',
        'Water',
        'Telecommunications',
        'Food',
        'Fuel / Transport',
        'Health',
        'Insurance',
        'Other',
      ]) {
        expect(find.text(name), findsWidgets, reason: name);
      }
    });
  });

  testWidgets('Greek labels', (tester) async {
    await expenses.add(expense('a', category: 'energy'));
    await pump(tester, locale: const Locale('el', 'GR'));
    expect(find.text('Έξοδα'), findsWidgets);
    expect(find.text('Ενέργεια'), findsWidgets);
    expect(find.textContaining('Σύνολο'), findsOneWidget);
  });
}
