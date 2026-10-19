import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/expense_fakes.dart';
import '../support/income_fakes.dart';
import '../support/settings_fakes.dart';

/// "Today" is 2026-10-16.
void main() {
  late GetIt locator;
  late FakeIncomeRepository income;
  late FakeExpenseRepository expenses;
  late FakeSettingsRepository settings;
  late FakeBalanceAnchorRepository anchors;
  final at = DateTime.utc(2026, 10, 1);

  setUp(() {
    locator = GetIt.asNewInstance();
    final fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    income = fakes.income;
    expenses = fakes.expenses;
    settings = fakes.settings;
    anchors = fakes.anchors;
    settings.primaryCurrency = 'EUR';
  });

  tearDown(() => locator.reset());

  Future<void> pump(WidgetTester tester, Locale locale) async {
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
          home: const IncomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Expense spent(String id, int minor, int day, {String currency = 'EUR'}) =>
      Expense(
        id: id,
        categoryId: 'food',
        date: CalendarDate(2026, 10, day),
        currencyCode: currency,
        amount: Money(minor),
        createdAt: at,
        updatedAt: at,
      );

  Expense pending(String id, int day, {String currency = 'EUR'}) => Expense(
    id: id,
    categoryId: 'food',
    date: CalendarDate(2026, 10, day),
    currencyCode: currency,
    original: const OriginalAmount(Money(2450), 'GBP'),
    createdAt: at,
    updatedAt: at,
  );

  String textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> salary() => income.addSource(
    IncomeSource(
      id: 'a',
      name: 'Salary',
      type: IncomeType.salary,
      amount: const Money(100000),
      currencyCode: 'EUR',
      schedule: const Monthly.onDay(5),
      startDate: CalendarDate(2026, 10, 1),
      createdAt: DateTime.utc(2026, 10, 1),
    ),
  );

  testWidgets(
    'shows an Expenses line and subtracts it from the closing balance',
    (tester) async {
      await salary();
      await expenses.add(spent('x1', 4500, 8));
      await expenses.add(spent('x2', 1500, 20)); // later than today

      await pump(tester, const Locale('en', 'US'));

      expect(find.text('Expenses'), findsOneWidget);
      expect(textOf(tester, 'cash-expenses-EUR'), '€60.00');
      expect(textOf(tester, 'cash-closing-EUR'), '€940.00');
      expect(find.byKey(const Key('cash-pending-EUR')), findsNothing);
    },
  );

  testWidgets('the Expenses line is shown also when there are none', (
    tester,
  ) async {
    await salary();
    await pump(tester, const Locale('en', 'US'));
    expect(textOf(tester, 'cash-expenses-EUR'), '€0.00');
  });

  testWidgets('pending expenses are announced and do not change the balance', (
    tester,
  ) async {
    await salary();
    await expenses.add(pending('p1', 9));
    await expenses.add(pending('p2', 10));

    await pump(tester, const Locale('en', 'US'));

    expect(
      find.text('2 expenses await an amount (not counted)'),
      findsOneWidget,
    );
    expect(textOf(tester, 'cash-expenses-EUR'), '€0.00');
    expect(textOf(tester, 'cash-closing-EUR'), '€1,000.00');
  });

  testWidgets('one pending expense uses the singular', (tester) async {
    await expenses.add(pending('p1', 9));
    await pump(tester, const Locale('en', 'US'));
    expect(
      find.text('1 expense awaits an amount (not counted)'),
      findsOneWidget,
    );
  });

  testWidgets('a currency that has only expenses gets its own block', (
    tester,
  ) async {
    await expenses.add(spent('x1', 900, 8, currency: 'CHF'));
    await pump(tester, const Locale('en', 'US'));
    expect(find.byKey(const Key('cash-block-CHF')), findsOneWidget);
    expect(textOf(tester, 'cash-expenses-CHF'), 'CHF9.00');
  });

  testWidgets('Greek labels', (tester) async {
    await expenses.add(pending('p1', 9));
    await expenses.add(pending('p2', 10));
    await pump(tester, const Locale('el', 'GR'));
    expect(find.text('Έξοδα'), findsOneWidget);
    expect(find.text('2 έξοδα αναμένουν ποσό (δεν μετρούν)'), findsOneWidget);
  });

  group('balance start', () {
    // The case found on the emulator: 780 on 12 October, an expense of 98
    // on 24 September.
    Future<void> anchorAndSeptemberExpense() async {
      await anchors.saveAnchor(
        BalanceAnchor(
          id: 'a1',
          date: CalendarDate(2026, 10, 12),
          balance: const Money(78000),
          currencyCode: 'EUR',
          createdAt: at,
        ),
      );
      await expenses.add(
        Expense(
          id: 'sep',
          categoryId: 'food',
          date: CalendarDate(2026, 9, 24),
          currencyCode: 'EUR',
          amount: const Money(9800),
          createdAt: at,
          updatedAt: at,
        ),
      );
    }

    testWidgets('the month before shows a dash and the start date', (
      tester,
    ) async {
      await anchorAndSeptemberExpense();
      await pump(tester, const Locale('en', 'US'));
      await tester.tap(find.byKey(const Key('month-previous')));
      await tester.pumpAndSettle();

      expect(textOf(tester, 'cash-opening-EUR'), '—');
      expect(textOf(tester, 'cash-closing-EUR'), '—');
      expect(find.text('The balance starts on Oct 12, 2026'), findsOneWidget);
      // The income and expense lines stay visible.
      expect(textOf(tester, 'cash-expenses-EUR'), '€98.00');
      expect(textOf(tester, 'cash-received-EUR'), '€0.00');
      expect(find.textContaining('-€98.00'), findsNothing);
    });

    testWidgets('the start month shows numbers and no note', (tester) async {
      await anchorAndSeptemberExpense();
      await pump(tester, const Locale('en', 'US'));

      expect(textOf(tester, 'cash-closing-EUR'), '€780.00');
      expect(textOf(tester, 'cash-opening-EUR'), '€0.00');
      expect(
        find.byKey(const Key('cash-balance-start-note-EUR')),
        findsNothing,
      );
    });

    testWidgets('the month after starts from the anchor', (tester) async {
      await anchorAndSeptemberExpense();
      await pump(tester, const Locale('en', 'US'));
      await tester.tap(find.byKey(const Key('month-next')));
      await tester.pumpAndSettle();

      expect(textOf(tester, 'cash-opening-EUR'), '€780.00');
      expect(textOf(tester, 'cash-closing-EUR'), '€780.00');
      expect(
        find.byKey(const Key('cash-balance-start-note-EUR')),
        findsNothing,
      );
    });

    testWidgets('Greek note', (tester) async {
      await anchorAndSeptemberExpense();
      await pump(tester, const Locale('el', 'GR'));
      await tester.tap(find.byKey(const Key('month-previous')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Το υπόλοιπο ξεκινά στις 12'), findsOneWidget);
    });

    testWidgets('without anchor or source there is no note', (tester) async {
      await expenses.add(spent('x1', 900, 8));
      await pump(tester, const Locale('en', 'US'));
      await tester.tap(find.byKey(const Key('month-previous')));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'cash-closing-EUR'), '€0.00');
      expect(
        find.byKey(const Key('cash-balance-start-note-EUR')),
        findsNothing,
      );
    });
  });
}
