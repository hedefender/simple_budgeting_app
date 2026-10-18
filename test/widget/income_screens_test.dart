import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_page.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_source_form_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/income_fakes.dart';

/// "Today" in these tests is 2026-10-16.
void main() {
  late GetIt locator;
  late FakeIncomeRepository income;
  late FakeBalanceAnchorRepository anchors;

  setUp(() {
    locator = GetIt.asNewInstance();
    final fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    income = fakes.income;
    anchors = fakes.anchors;
  });

  tearDown(() => locator.reset());

  IncomeSource source(
    String id,
    String name,
    int minor,
    int day, {
    DateTime? archivedAt,
  }) => IncomeSource(
    id: id,
    name: name,
    type: IncomeType.salary,
    amount: Money(minor),
    currencyCode: 'USD',
    schedule: Monthly.onDay(day),
    startDate: CalendarDate(2026, 10, 1),
    createdAt: DateTime.utc(2026, 10, 1),
    archivedAt: archivedAt,
  );

  void bigScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// A home with a button that opens [page], so the page can pop normally.
  Future<void> pumpPage(
    WidgetTester tester,
    Locale locale, {
    Widget? opened,
    Widget? home,
  }) async {
    bigScreen(tester);
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
          home:
              home ??
              Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      key: const Key('open'),
                      onPressed: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute<void>(builder: (_) => opened!)),
                      child: const Text('open'),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
    if (home == null) {
      await tester.tap(find.byKey(const Key('open')));
    }
    await tester.pumpAndSettle();
  }

  const greek = Locale('el', 'GR');
  const english = Locale('en', 'US');

  Future<void> fill(WidgetTester tester, String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('income-save')));
    await tester.tap(find.byKey(const Key('income-save')));
    await tester.pumpAndSettle();
  }

  group('source form', () {
    testWidgets('rejects an empty name and an invalid amount', (tester) async {
      await pumpPage(tester, english, opened: const IncomeSourceFormPage());

      await fill(tester, 'income-amount', 'abc');
      await save(tester);

      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.text('Enter a valid amount'), findsOneWidget);
      expect(income.sources, isEmpty);
    });

    testWidgets('rejects a zero amount', (tester) async {
      await pumpPage(tester, english, opened: const IncomeSourceFormPage());

      await fill(tester, 'income-name', 'Salary');
      await fill(tester, 'income-amount', '0');
      await save(tester);

      expect(find.text('The amount must be greater than zero'), findsOneWidget);
      expect(income.sources, isEmpty);
    });

    for (final typed in <String>['12,50', '12.50']) {
      testWidgets('accepts "$typed" as 12,50 in a Greek locale', (
        tester,
      ) async {
        await pumpPage(tester, greek, opened: const IncomeSourceFormPage());

        await fill(tester, 'income-name', 'Μισθός');
        await fill(tester, 'income-amount', typed);
        await save(tester);

        expect(income.sources, hasLength(1));
        expect(income.sources.values.single.amount, const Money(1250));
        expect(income.sources.values.single.currencyCode, 'EUR');
        expect(find.byType(IncomeSourceFormPage), findsNothing);
      });
    }

    testWidgets('shows an error when the end date is before the start date', (
      tester,
    ) async {
      await pumpPage(tester, english, opened: const IncomeSourceFormPage());
      await fill(tester, 'income-name', 'Contract');
      await fill(tester, 'income-amount', '100');

      // Start: 20 Oct. End: 10 Oct.
      await tester.ensureVisible(find.byKey(const Key('income-start-date')));
      await tester.tap(find.byKey(const Key('income-start-date')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('income-end-date')));
      await tester.tap(find.byKey(const Key('income-end-date')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('10'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await save(tester);

      expect(find.byKey(const Key('income-end-error')), findsOneWidget);
      expect(
        find.text('The end date is before the start date'),
        findsOneWidget,
      );
      expect(income.sources, isEmpty);
    });

    testWidgets('a use case validation error has its own message', (
      tester,
    ) async {
      final existing = source('s1', 'Salary', 100000, 5);
      await income.addSource(existing);
      await pumpPage(
        tester,
        english,
        opened: IncomeSourceFormPage(source: existing),
      );

      // The source gets archived elsewhere while the form is open.
      await income.archiveSource('s1', DateTime.utc(2026, 10, 16, 9));
      await save(tester);

      expect(
        find.text(
          'This income source is archived and can no longer be changed',
        ),
        findsOneWidget,
      );
      expect(find.text('Could not read your income data'), findsNothing);
      expect(find.byType(IncomeSourceFormPage), findsOneWidget);
    });

    testWidgets('the same error is shown in Greek', (tester) async {
      final existing = source('s1', 'Salary', 100000, 5);
      await income.addSource(existing);
      await pumpPage(
        tester,
        greek,
        opened: IncomeSourceFormPage(source: existing),
      );

      await income.archiveSource('s1', DateTime.utc(2026, 10, 16, 9));
      await save(tester);

      expect(
        find.text(
          'Αυτή η πηγή εισοδήματος είναι αρχειοθετημένη και δεν μπορεί πλέον να αλλάξει',
        ),
        findsOneWidget,
      );
    });
  });

  group('income page', () {
    Future<void> pumpIncome(WidgetTester tester) =>
        pumpPage(tester, english, home: const IncomePage());

    String textOf(WidgetTester tester, String key) =>
        tester.widget<Text>(find.byKey(Key(key))).data!;

    testWidgets('shows past payments as received and later ones as expected', (
      tester,
    ) async {
      await income.addSource(source('a', 'Salary', 100000, 5));
      await income.addSource(source('b', 'Bonus', 50000, 25));

      await pumpIncome(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('occurrence-a-2026-10-05')),
          matching: find.textContaining('Received'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('occurrence-b-2026-10-25')),
          matching: find.textContaining('Expected'),
        ),
        findsOneWidget,
      );
      expect(textOf(tester, 'cash-received'), r'$1,000.00');
      expect(textOf(tester, 'cash-expected'), r'$500.00');
    });

    testWidgets('marking a payment as not received changes the totals', (
      tester,
    ) async {
      await income.addSource(source('a', 'Salary', 100000, 5));
      await pumpIncome(tester);
      expect(textOf(tester, 'cash-received'), r'$1,000.00');
      expect(textOf(tester, 'cash-closing'), r'$1,000.00');

      await tester.tap(find.byKey(const Key('occurrence-menu-a-2026-10-05')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark as not received'));
      await tester.pumpAndSettle();

      expect(textOf(tester, 'cash-received'), r'$0.00');
      expect(textOf(tester, 'cash-closing'), r'$0.00');
      expect(
        find.descendant(
          of: find.byKey(const Key('occurrence-a-2026-10-05')),
          matching: find.textContaining('Not received'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the balance dialog saves and the amount is shown', (
      tester,
    ) async {
      await income.addSource(source('b', 'Bonus', 50000, 25));
      await pumpIncome(tester);
      expect(textOf(tester, 'cash-closing'), r'$500.00');

      await tester.tap(find.byKey(const Key('set-balance')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('balance-field')), '250.50');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();

      // Balance at the end of 16 Oct, plus the payment of the 25th.
      expect(anchors.anchors, hasLength(1));
      expect(anchors.anchors.single.balance, const Money(25050));
      expect(anchors.anchors.single.date, CalendarDate(2026, 10, 16));
      expect(textOf(tester, 'cash-closing'), r'$750.50');
    });

    testWidgets('the balance dialog rejects an invalid amount', (tester) async {
      await pumpIncome(tester);

      await tester.tap(find.byKey(const Key('set-balance')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('balance-field')), 'abc');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid amount'), findsOneWidget);
      expect(anchors.anchors, isEmpty);
    });
  });
}
