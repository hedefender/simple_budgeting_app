import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expenses_page.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_providers.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/expense_fakes.dart';
import '../support/income_fakes.dart';
import '../support/settings_fakes.dart';

/// "Today" is 2026-10-16.
void main() {
  late GetIt locator;
  late FakeExpenseRepository expenses;
  late FakeSettingsRepository settings;
  late FakeBalanceAnchorRepository anchors;
  late FakeIncomeRepository income;
  final at = DateTime.utc(2026, 10, 1);

  setUp(() {
    locator = GetIt.asNewInstance();
    final fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    expenses = fakes.expenses;
    settings = fakes.settings;
    anchors = fakes.anchors;
    income = fakes.income;
    settings.primaryCurrency = 'EUR';
  });

  tearDown(() => locator.reset());

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en', 'US'),
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
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

  Future<void> openAdd(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('expense-add')));
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  Future<void> choose(WidgetTester tester, String key, String label) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) => tapKey(tester, 'expense-save');

  Expense stored() => expenses.expenses.values.single;

  Expense seeded(
    String id, {
    int? minor = 4500,
    String category = 'food',
    String currency = 'EUR',
    OriginalAmount? original,
    Money? tax,
    String? description,
  }) => Expense(
    id: id,
    description: description,
    categoryId: category,
    date: CalendarDate(2026, 10, 5),
    currencyCode: currency,
    amount: minor == null ? null : Money(minor),
    original: original,
    tax: tax,
    createdAt: at,
    updatedAt: at,
  );

  group('adding', () {
    testWidgets('one total, one category; defaults are Other, today, primary', (
      tester,
    ) async {
      await pump(tester);
      await openAdd(tester);
      expect(find.text('Add expense'), findsWidgets);

      await fill(tester, 'expense-amount', '45.00');
      await save(tester);

      final e = stored();
      expect(e.amount, const Money(4500));
      expect(e.categoryId, 'other');
      expect(e.currencyCode, 'EUR');
      expect(e.date, CalendarDate(2026, 10, 16));
      expect(e.isPending, isFalse);
      expect(e.original, isNull);
      expect(e.tax, isNull);
      // Back on the list, the expense is there.
      expect(find.byKey(Key('expense-tile-${e.id}')), findsOneWidget);
      expect(find.byKey(const Key('expense-total-EUR')), findsOneWidget);
    });

    testWidgets('a chosen category, a description and a currency', (
      tester,
    ) async {
      await expenses.add(seeded('chf', currency: 'CHF'));
      await pump(tester);
      await openAdd(tester);

      await fill(tester, 'expense-description', '  Pharmacy ');
      await choose(tester, 'expense-category', 'Health');
      await choose(tester, 'expense-currency', 'CHF');
      await fill(tester, 'expense-amount', '12.50');
      await save(tester);

      final e = expenses.expenses.values.firstWhere((e) => e.id != 'chf');
      expect(e.description, 'Pharmacy');
      expect(e.categoryId, 'health');
      expect(e.currencyCode, 'CHF');
      expect(e.amount, const Money(1250));
    });

    testWidgets('the account currencies are those in the app, primary first', (
      tester,
    ) async {
      await expenses.add(seeded('chf', currency: 'CHF'));
      await pump(tester);
      await openAdd(tester);
      await tester.tap(find.byKey(const Key('expense-currency')));
      await tester.pumpAndSettle();
      expect(find.text('EUR'), findsWidgets);
      expect(find.text('CHF'), findsWidgets);
      expect(find.text('USD'), findsNothing);
      expect(find.text('Other…'), findsOneWidget);
    });

    testWidgets('"Other…" accepts a 3-letter code and rejects others', (
      tester,
    ) async {
      await pump(tester);
      await openAdd(tester);
      await choose(tester, 'expense-currency', 'Other…');
      await fill(tester, 'currency-other-field', 'ab');
      await tapKey(tester, 'currency-other-save');
      expect(find.text('Enter a 3-letter currency code'), findsOneWidget);

      await fill(tester, 'currency-other-field', 'sek');
      await tapKey(tester, 'currency-other-save');
      await fill(tester, 'expense-amount', '10');
      await save(tester);
      expect(stored().currencyCode, 'SEK');
    });

    testWidgets('neither an amount nor an original amount is an error', (
      tester,
    ) async {
      await pump(tester);
      await openAdd(tester);
      await save(tester);

      expect(find.byKey(const Key('expense-amount-error')), findsOneWidget);
      expect(expenses.expenses, isEmpty);
      expect(find.byKey(const Key('expense-save')), findsOneWidget);
    });

    testWidgets('an invalid or zero amount is rejected', (tester) async {
      await pump(tester);
      await openAdd(tester);
      await fill(tester, 'expense-amount', 'abc');
      await save(tester);
      expect(find.text('Enter a valid amount'), findsOneWidget);
      await fill(tester, 'expense-amount', '0');
      await save(tester);
      expect(find.text('The amount must be greater than zero'), findsOneWidget);
      expect(expenses.expenses, isEmpty);
    });
  });

  group('original amount and VAT/taxes', () {
    testWidgets('both sections are collapsed and optional', (tester) async {
      await pump(tester);
      await openAdd(tester);
      expect(find.byKey(const Key('expense-original-amount')), findsNothing);
      expect(find.byKey(const Key('expense-tax')), findsNothing);
      await fill(tester, 'expense-amount', '10');
      await save(tester);
      expect(stored().original, isNull);
      expect(stored().tax, isNull);
    });

    testWidgets('the original amount is stored next to the amount charged', (
      tester,
    ) async {
      await pump(tester);
      await openAdd(tester);
      await fill(tester, 'expense-amount', '28.90');
      await tapKey(tester, 'expense-original-section');
      await choose(tester, 'expense-original-currency', 'GBP');
      await fill(tester, 'expense-original-amount', '24.50');
      await save(tester);

      final e = stored();
      expect(e.amount, const Money(2890));
      expect(e.original, const OriginalAmount(Money(2450), 'GBP'));
      expect(e.isPending, isFalse);
    });

    testWidgets('VAT/taxes are stored, informational, and not added', (
      tester,
    ) async {
      await pump(tester);
      await openAdd(tester);
      await fill(tester, 'expense-amount', '100');
      await tapKey(tester, 'expense-tax-section');
      await fill(tester, 'expense-tax', '24');
      await save(tester);

      expect(stored().tax, const Money(2400));
      expect(
        tester.widget<Text>(find.byKey(const Key('expense-total-EUR'))).data,
        '€100.00',
      );
    });

    testWidgets('VAT/taxes larger than the total are rejected', (tester) async {
      await pump(tester);
      await openAdd(tester);
      await fill(tester, 'expense-amount', '10');
      await tapKey(tester, 'expense-tax-section');
      await fill(tester, 'expense-tax', '10.01');
      await save(tester);

      expect(
        find.text('VAT/taxes cannot be more than the total'),
        findsOneWidget,
      );
      expect(expenses.expenses, isEmpty);
    });

    testWidgets('the original currency must differ from the account', (
      tester,
    ) async {
      await pump(tester);
      await openAdd(tester);
      await fill(tester, 'expense-amount', '10');
      await tapKey(tester, 'expense-original-section');
      await choose(tester, 'expense-original-currency', 'GBP');
      await choose(tester, 'expense-currency', 'Other…');
      await fill(tester, 'currency-other-field', 'gbp');
      await tapKey(tester, 'currency-other-save');
      await fill(tester, 'expense-original-amount', '9');
      await save(tester);

      expect(
        find.text(
          'The original currency must differ from the account currency',
        ),
        findsOneWidget,
      );
      expect(expenses.expenses, isEmpty);
    });
  });

  group('pending (awaiting amount)', () {
    testWidgets('only an original amount: the form says so and saves it', (
      tester,
    ) async {
      await pump(tester);
      await openAdd(tester);
      expect(find.byKey(const Key('expense-pending-notice')), findsNothing);

      await tapKey(tester, 'expense-original-section');
      await choose(tester, 'expense-original-currency', 'GBP');
      await fill(tester, 'expense-original-amount', '24.50');

      expect(find.byKey(const Key('expense-pending-notice')), findsOneWidget);
      expect(find.textContaining('awaiting amount'), findsOneWidget);

      await save(tester);

      final e = stored();
      expect(e.isPending, isTrue);
      expect(e.amount, isNull);
      expect(e.original, const OriginalAmount(Money(2450), 'GBP'));
      expect(e.currencyCode, 'EUR');
      // Listed and marked, but not in the total.
      expect(find.byKey(Key('expense-pending-${e.id}')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('expense-total-EUR'))).data,
        '€0.00',
      );
    });

    testWidgets('entering the amount that was charged completes it', (
      tester,
    ) async {
      await expenses.add(
        seeded(
          'p',
          minor: null,
          original: const OriginalAmount(Money(2450), 'GBP'),
        ),
      );
      await pump(tester);
      expect(find.byKey(const Key('expense-pending-p')), findsOneWidget);

      await tester.tap(find.byKey(const Key('expense-tile-p')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('expense-pending-notice')), findsOneWidget);

      await fill(tester, 'expense-amount', '28.90');
      expect(find.byKey(const Key('expense-pending-notice')), findsNothing);
      await save(tester);

      final e = expenses.expenses['p']!;
      expect(e.isPending, isFalse);
      expect(e.amount, const Money(2890));
      expect(e.original, const OriginalAmount(Money(2450), 'GBP'));
      expect(find.byKey(const Key('expense-pending-p')), findsNothing);
      expect(
        tester.widget<Text>(find.byKey(const Key('expense-total-EUR'))).data,
        '€28.90',
      );
    });

    testWidgets('clearing both amounts of a pending expense is an error', (
      tester,
    ) async {
      await expenses.add(
        seeded(
          'p',
          minor: null,
          original: const OriginalAmount(Money(2450), 'GBP'),
        ),
      );
      await pump(tester);
      await tester.tap(find.byKey(const Key('expense-tile-p')));
      await tester.pumpAndSettle();
      await fill(tester, 'expense-original-amount', '');
      await save(tester);
      expect(find.byKey(const Key('expense-amount-error')), findsOneWidget);
      expect(expenses.expenses['p']!.isPending, isTrue);
    });
  });

  group('editing and deleting', () {
    testWidgets('the form loads the expense and saves changes', (tester) async {
      await expenses.add(
        seeded(
          'a',
          description: 'ΔΕΗ',
          category: 'energy',
          tax: const Money(560),
          original: const OriginalAmount(Money(4000), 'GBP'),
        ),
      );
      await pump(tester);
      await tester.tap(find.byKey(const Key('expense-tile-a')));
      await tester.pumpAndSettle();

      expect(find.text('Edit expense'), findsOneWidget);
      String value(String key) =>
          tester.widget<TextFormField>(find.byKey(Key(key))).controller!.text;
      expect(value('expense-description'), 'ΔΕΗ');
      expect(value('expense-amount'), '45.00');
      expect(value('expense-original-amount'), '40.00');
      expect(value('expense-tax'), '5.60');

      await fill(tester, 'expense-amount', '50');
      await save(tester);

      final e = expenses.expenses['a']!;
      expect(e.amount, const Money(5000));
      expect(e.categoryId, 'energy');
      expect(e.tax, const Money(560));
      expect(e.date, CalendarDate(2026, 10, 5));
      expect(e.createdAt, at);
      expect(e.updatedAt, DateTime.utc(2026, 10, 16, 9));
    });

    testWidgets('delete asks first; cancel keeps the expense', (tester) async {
      await expenses.add(seeded('a'));
      await pump(tester);
      await tester.tap(find.byKey(const Key('expense-tile-a')));
      await tester.pumpAndSettle();

      await tapKey(tester, 'expense-delete');
      expect(find.text('Delete this expense?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('expense-delete-cancel')));
      await tester.pumpAndSettle();

      expect(expenses.expenses, contains('a'));
      expect(find.byKey(const Key('expense-save')), findsOneWidget);
    });

    testWidgets('confirming deletes the expense and updates the list', (
      tester,
    ) async {
      await expenses.add(seeded('a'));
      await pump(tester);
      await tester.tap(find.byKey(const Key('expense-tile-a')));
      await tester.pumpAndSettle();

      await tapKey(tester, 'expense-delete');
      await tester.tap(find.byKey(const Key('expense-delete-confirm')));
      await tester.pumpAndSettle();

      expect(expenses.expenses, isEmpty);
      expect(find.byKey(const Key('expense-tile-a')), findsNothing);
      expect(find.byKey(const Key('expenses-empty')), findsOneWidget);
    });

    testWidgets('a new expense has no delete button', (tester) async {
      await pump(tester);
      await openAdd(tester);
      expect(find.byKey(const Key('expense-delete')), findsNothing);
    });
  });

  group('before the balance starts', () {
    Future<void> anchorOn(int day, {String code = 'EUR'}) => anchors.saveAnchor(
      BalanceAnchor(
        id: 'a$day',
        date: CalendarDate(2026, 10, day),
        balance: const Money(78000),
        currencyCode: code,
        createdAt: at,
      ),
    );

    Future<void> openExpenseDated(
      WidgetTester tester,
      int month,
      int day, {
      String currency = 'EUR',
    }) async {
      await expenses.add(
        Expense(
          id: 'e',
          categoryId: 'food',
          date: CalendarDate(2026, month, day),
          currencyCode: currency,
          amount: const Money(9800),
          createdAt: at,
          updatedAt: at,
        ),
      );
      await pump(tester);
      if (month == 9) {
        await tester.tap(find.byKey(const Key('expense-month-previous')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('expense-tile-e')));
      await tester.pumpAndSettle();
    }

    const warning = Key('expense-before-start-warning');

    testWidgets('a date before the anchor shows the warning and a button', (
      tester,
    ) async {
      await anchorOn(12);
      await openExpenseDated(tester, 9, 24);

      expect(find.byKey(warning), findsOneWidget);
      expect(
        find.textContaining('The balance starts on Oct 12, 2026'),
        findsOneWidget,
      );
      expect(find.text('Use Oct 13, 2026'), findsOneWidget);
    });

    testWidgets('the button sets the day after the anchor; warning goes', (
      tester,
    ) async {
      await anchorOn(12);
      await openExpenseDated(tester, 9, 24);

      await tapKey(tester, 'expense-use-start-date');

      expect(find.byKey(warning), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const Key('expense-date')),
          matching: find.textContaining('Oct 13'),
        ),
        findsOneWidget,
      );
      await save(tester);
      expect(expenses.expenses['e']!.date, CalendarDate(2026, 10, 13));
    });

    testWidgets('the anchor day itself is inside the anchor: warning', (
      tester,
    ) async {
      await anchorOn(12);
      await openExpenseDated(tester, 10, 12);
      expect(find.byKey(warning), findsOneWidget);
    });

    testWidgets('the day after the anchor has no warning', (tester) async {
      await anchorOn(12);
      await openExpenseDated(tester, 10, 13);
      expect(find.byKey(warning), findsNothing);
    });

    testWidgets('saving is allowed and keeps the date', (tester) async {
      await anchorOn(12);
      await openExpenseDated(tester, 9, 24);
      await fill(tester, 'expense-amount', '98');
      await save(tester);

      expect(find.byKey(const Key('expense-save')), findsNothing);
      expect(expenses.expenses['e']!.date, CalendarDate(2026, 9, 24));
    });

    testWidgets('from a source start, the start day itself is allowed', (
      tester,
    ) async {
      await income.addSource(
        IncomeSource(
          id: 's',
          name: 'Salary',
          type: IncomeType.salary,
          amount: const Money(100000),
          currencyCode: 'EUR',
          schedule: const Monthly.onDay(5),
          startDate: CalendarDate(2026, 10, 1),
          createdAt: at,
        ),
      );
      await openExpenseDated(tester, 9, 24);

      expect(find.byKey(warning), findsOneWidget);
      expect(find.text('Use Oct 1, 2026'), findsOneWidget);
      await tapKey(tester, 'expense-use-start-date');
      expect(find.byKey(warning), findsNothing);
    });

    testWidgets('no anchor and no source: no warning', (tester) async {
      await openExpenseDated(tester, 9, 24);
      expect(find.byKey(warning), findsNothing);
    });

    testWidgets('changing the account currency recomputes the warning', (
      tester,
    ) async {
      await anchorOn(12);
      await expenses.add(
        Expense(
          id: 'chf',
          categoryId: 'food',
          date: CalendarDate(2026, 10, 5),
          currencyCode: 'CHF',
          amount: const Money(100),
          createdAt: at,
          updatedAt: at,
        ),
      );
      await openExpenseDated(tester, 9, 24);
      expect(find.byKey(warning), findsOneWidget);

      await choose(tester, 'expense-currency', 'CHF');
      expect(find.byKey(warning), findsNothing);

      await choose(tester, 'expense-currency', 'EUR');
      expect(find.byKey(warning), findsOneWidget);
    });

    testWidgets('Greek text', (tester) async {
      await anchorOn(12);
      await expenses.add(
        Expense(
          id: 'e',
          categoryId: 'food',
          date: CalendarDate(2026, 9, 24),
          currencyCode: 'EUR',
          amount: const Money(9800),
          createdAt: at,
          updatedAt: at,
        ),
      );
      await pump(tester, locale: const Locale('el', 'GR'));
      await tester.tap(find.byKey(const Key('expense-month-previous')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('expense-tile-e')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Το υπόλοιπο ξεκινά στις 12'), findsOneWidget);
      expect(find.textContaining('Χρήση 13'), findsOneWidget);
    });
  });

  testWidgets('saving refreshes the cash flow of the Income page', (
    tester,
  ) async {
    await pump(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ExpensesPage)),
    );
    final before = await container.read(monthlyCashFlowProvider.future);
    expect(before.currencies.first.expenses, Money.zero);
    expect(before.month, YearMonth(2026, 10));

    await openAdd(tester);
    await fill(tester, 'expense-amount', '45');
    await save(tester);

    final after = await container.read(monthlyCashFlowProvider.future);
    expect(after.currencies.first.expenses, const Money(4500));
    expect(after.currencies.first.projectedClosingBalance, const Money(-4500));
  });

  testWidgets('Greek labels', (tester) async {
    await pump(tester, locale: const Locale('el', 'GR'));
    await openAdd(tester);
    expect(find.text('Προσθήκη εξόδου'), findsWidgets);
    expect(find.text('Ποσό που χρεώθηκε'), findsOneWidget);
    expect(find.text('Νόμισμα λογαριασμού'), findsOneWidget);
    await tapKey(tester, 'expense-original-section');
    await fill(tester, 'expense-original-amount', '24,50');
    expect(find.textContaining('αναμένει ποσό'), findsOneWidget);
  });
}
