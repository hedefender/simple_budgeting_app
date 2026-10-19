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
      expect(textOf(tester, 'cash-received-USD'), r'$1,000.00');
      expect(textOf(tester, 'cash-expected-USD'), r'$500.00');
    });

    testWidgets('marking a payment as not received changes the totals', (
      tester,
    ) async {
      await income.addSource(source('a', 'Salary', 100000, 5));
      await pumpIncome(tester);
      expect(textOf(tester, 'cash-received-USD'), r'$1,000.00');
      expect(textOf(tester, 'cash-closing-USD'), r'$1,000.00');

      await tester.tap(find.byKey(const Key('occurrence-menu-a-2026-10-05')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark as not received'));
      await tester.pumpAndSettle();

      expect(textOf(tester, 'cash-received-USD'), r'$0.00');
      expect(textOf(tester, 'cash-closing-USD'), r'$0.00');
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
      expect(textOf(tester, 'cash-closing-USD'), r'$500.00');

      await tester.tap(find.byKey(const Key('set-balance-USD')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('balance-field')), '250.50');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();

      // Balance at the end of 16 Oct, plus the payment of the 25th.
      expect(anchors.anchors, hasLength(1));
      expect(anchors.anchors.single.balance, const Money(25050));
      expect(anchors.anchors.single.date, CalendarDate(2026, 10, 16));
      expect(textOf(tester, 'cash-closing-USD'), r'$750.50');
    });

    testWidgets('the balance dialog rejects an invalid amount', (tester) async {
      await pumpIncome(tester);

      await tester.tap(find.byKey(const Key('set-balance-USD')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('balance-field')), 'abc');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid amount'), findsOneWidget);
      expect(anchors.anchors, isEmpty);
    });
  });

  Future<void> choose(WidgetTester tester, String key, String label) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> selectKind(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Finder field(String key) => find.byKey(Key(key));

  group('source form: frequency, rules and shift', () {
    Future<void> openForm(WidgetTester tester, {IncomeSource? source}) =>
        pumpPage(tester, english, opened: IncomeSourceFormPage(source: source));

    testWidgets('choosing a frequency shows the matching fields', (
      tester,
    ) async {
      await openForm(tester);

      // Monthly is the default: one rule, a shift rule, no weekday.
      expect(field('income-rule-type-0'), findsOneWidget);
      expect(field('income-rule-type-1'), findsNothing);
      expect(field('income-shift'), findsOneWidget);
      expect(field('income-weekday'), findsNothing);

      await selectKind(tester, 'Several a month');
      expect(field('income-rule-type-0'), findsOneWidget);
      expect(field('income-rule-type-1'), findsOneWidget);
      expect(field('income-rule-add'), findsOneWidget);

      await selectKind(tester, 'Weekly');
      expect(field('income-weekday'), findsOneWidget);
      expect(field('income-rule-type-0'), findsNothing);
      expect(field('income-shift'), findsOneWidget);

      await selectKind(tester, 'Once');
      expect(field('income-date'), findsOneWidget);
      expect(field('income-shift'), findsNothing);
      expect(field('income-start-date'), findsNothing);

      await selectKind(tester, 'Monthly');
      expect(field('income-rule-type-0'), findsOneWidget);
      expect(field('income-rule-add'), findsNothing);
    });

    testWidgets('rules can be added and removed (at least two stay)', (
      tester,
    ) async {
      await openForm(tester);
      await selectKind(tester, 'Several a month');

      // Two rules: nothing to remove.
      expect(field('income-rule-remove-0'), findsNothing);

      await tester.ensureVisible(field('income-rule-add'));
      await tester.tap(field('income-rule-add'));
      await tester.pumpAndSettle();
      expect(field('income-rule-type-2'), findsOneWidget);
      expect(field('income-rule-remove-0'), findsOneWidget);

      await tester.ensureVisible(field('income-rule-remove-2'));
      await tester.tap(field('income-rule-remove-2'));
      await tester.pumpAndSettle();
      expect(field('income-rule-type-2'), findsNothing);
      expect(field('income-rule-remove-0'), findsNothing);
    });

    testWidgets('the shift rule is hidden when every rule is a working day', (
      tester,
    ) async {
      await openForm(tester);
      expect(field('income-shift'), findsOneWidget);

      await choose(tester, 'income-rule-type-0', 'Working day of the month');
      expect(field('income-shift'), findsNothing);

      await choose(tester, 'income-rule-type-0', 'Last day of the month');
      expect(field('income-shift'), findsOneWidget);

      // Several: one working-day rule and one day rule -> shift still shown.
      await selectKind(tester, 'Several a month');
      await choose(tester, 'income-rule-type-0', 'Working day of the month');
      expect(field('income-shift'), findsOneWidget);
      await choose(tester, 'income-rule-type-1', 'Working day of the month');
      expect(field('income-shift'), findsNothing);
    });

    testWidgets('equal payment days are rejected, different ones are saved', (
      tester,
    ) async {
      await openForm(tester);
      await fill(tester, 'income-name', 'Salary');
      await fill(tester, 'income-amount', '500');
      await selectKind(tester, 'Several a month');
      // The default rules are day 16 and day 15; make them both 15.
      await choose(tester, 'income-rule-value-0', '15');

      await save(tester);

      expect(field('income-duplicate-error'), findsOneWidget);
      expect(find.text('Two payment days are the same'), findsOneWidget);
      expect(income.sources, isEmpty);

      await choose(tester, 'income-rule-value-0', '20');
      await save(tester);

      expect(field('income-duplicate-error'), findsNothing);
      expect(
        income.sources.values.single.schedule,
        SeveralPerMonth(const [
          DayOfMonth(20),
          DayOfMonth(15),
        ], shift: ShiftRule.previousWorkingDay),
      );
    });

    testWidgets('a weekly source with a chosen shift rule is saved', (
      tester,
    ) async {
      await openForm(tester);
      await fill(tester, 'income-name', 'Pocket money');
      await fill(tester, 'income-amount', '20');
      await selectKind(tester, 'Weekly');
      await choose(tester, 'income-weekday', 'Friday');
      await choose(tester, 'income-shift', 'Pay on the next working day');

      await save(tester);

      expect(
        income.sources.values.single.schedule,
        const Weekly(DateTime.friday, shift: ShiftRule.nextWorkingDay),
      );
    });

    testWidgets('a monthly source on the Nth working day is saved', (
      tester,
    ) async {
      await openForm(tester);
      await fill(tester, 'income-name', 'Rent');
      await fill(tester, 'income-amount', '300');
      await choose(tester, 'income-rule-type-0', 'Working day of the month');
      await choose(tester, 'income-rule-value-0', '3');

      await save(tester);

      final schedule = income.sources.values.single.schedule as Monthly;
      expect(schedule.rule, const NthWorkingDay(3));
    });

    testWidgets('"Do not move" is saved as ShiftRule.none', (tester) async {
      await openForm(tester);
      await fill(tester, 'income-name', 'Salary');
      await fill(tester, 'income-amount', '1000');
      await choose(tester, 'income-shift', 'Do not move');

      await save(tester);

      final schedule = income.sources.values.single.schedule as Monthly;
      expect(schedule.shift, ShiftRule.none);
      expect(schedule.rule, const DayOfMonth(16));
    });

    testWidgets('editing loads the rules of a several-per-month source', (
      tester,
    ) async {
      final existing = IncomeSource(
        id: 's1',
        name: 'Salary',
        type: IncomeType.salary,
        amount: const Money(100000),
        currencyCode: 'USD',
        schedule: SeveralPerMonth(const [
          DayOfMonth(1),
          NthWorkingDay(3),
        ], shift: ShiftRule.nextWorkingDay),
        startDate: CalendarDate(2026, 10, 1),
        createdAt: DateTime.utc(2026, 10, 1),
      );
      await income.addSource(existing);
      await openForm(tester, source: existing);

      expect(field('income-rule-type-1'), findsOneWidget);
      expect(find.text('Working day of the month'), findsWidgets);
      expect(find.text('Pay on the next working day'), findsOneWidget);
    });
  });

  group('change payment dialog', () {
    Future<void> openDialog(WidgetTester tester) async {
      await income.addSource(source('a', 'Salary', 100000, 5));
      await pumpPage(tester, english, home: const IncomePage());
      await tester.tap(field('occurrence-menu-a-2026-10-05'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change amount or date'));
      await tester.pumpAndSettle();
    }

    testWidgets('changing only the amount does not pin the date', (
      tester,
    ) async {
      await openDialog(tester);

      await tester.enterText(field('money-dialog-field'), '950');
      await tester.tap(field('money-dialog-save'));
      await tester.pumpAndSettle();

      final entry = income.entries.single;
      expect(entry.amount, const Money(95000));
      expect(entry.originalDate, CalendarDate(2026, 10, 5));
      expect(entry.actualDate, isNull);
    });

    testWidgets('changing the date pins it; the nominal date stays the key', (
      tester,
    ) async {
      await openDialog(tester);

      await tester.tap(field('payment-date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(field('money-dialog-save'));
      await tester.pumpAndSettle();

      final entry = income.entries.single;
      expect(entry.originalDate, CalendarDate(2026, 10, 5));
      expect(entry.actualDate, CalendarDate(2026, 10, 12));
      // Still the same tile (keyed on the nominal date), now dated the 12th.
      expect(
        find.descendant(
          of: field('occurrence-a-2026-10-05'),
          matching: find.textContaining('Oct 12, 2026'),
        ),
        findsOneWidget,
      );
    });
  });
}
