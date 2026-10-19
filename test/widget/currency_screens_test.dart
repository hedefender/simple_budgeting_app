import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/balance_anchor_repository.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_dialogs.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_page.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_source_form_page.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/income_fakes.dart';
import '../support/settings_fakes.dart';

/// "Today" in these tests is 2026-10-16.
void main() {
  late GetIt locator;
  late FakeIncomeRepository income;
  late FakeSettingsRepository settings;

  setUp(() {
    locator = GetIt.asNewInstance();
    final fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    income = fakes.income;
    settings = fakes.settings;
  });

  tearDown(() => locator.reset());

  const english = Locale('en', 'US');

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceLocatorProvider.overrideWithValue(locator),
          deviceLocaleProvider.overrideWithValue(english),
        ],
        child: MaterialApp(
          locale: english,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                key: const Key('open'),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => page)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  Future<void> chooseCurrency(WidgetTester tester, String label) async {
    await tester.tap(find.byKey(const Key('currency-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> saveNew(WidgetTester tester, {String amount = '100'}) async {
    await tester.enterText(find.byKey(const Key('income-name')), 'Job');
    await tester.enterText(find.byKey(const Key('income-amount')), amount);
    await tester.ensureVisible(find.byKey(const Key('income-save')));
    await tester.tap(find.byKey(const Key('income-save')));
    await tester.pumpAndSettle();
  }

  group('source form currency', () {
    testWidgets('a new source defaults to the primary, not the device', (
      tester,
    ) async {
      settings.primaryCurrency = 'EUR'; // the device (en_US) says USD

      await pump(tester, const IncomeSourceFormPage());

      expect(find.text('EUR'), findsWidgets);
      await saveNew(tester);

      expect(income.sources.values.single.currencyCode, 'EUR');
    });

    testWidgets('the currency can be chosen from the list', (tester) async {
      settings.primaryCurrency = 'EUR';
      await pump(tester, const IncomeSourceFormPage());

      await chooseCurrency(tester, 'GBP');
      await saveNew(tester);

      expect(income.sources.values.single.currencyCode, 'GBP');
      expect(income.sources.values.single.amount, const Money(10000));
    });

    testWidgets('another code can be typed, and a bad one is refused', (
      tester,
    ) async {
      settings.primaryCurrency = 'EUR';
      await pump(tester, const IncomeSourceFormPage());

      await chooseCurrency(tester, 'Other…');
      await tester.enterText(
        find.byKey(const Key('currency-other-field')),
        'ab',
      );
      await tester.tap(find.byKey(const Key('currency-other-save')));
      await tester.pumpAndSettle();
      expect(find.text('Enter a 3-letter currency code'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('currency-other-field')),
        'nzd',
      );
      await tester.tap(find.byKey(const Key('currency-other-save')));
      await tester.pumpAndSettle();
      await saveNew(tester);

      expect(income.sources.values.single.currencyCode, 'NZD');
    });

    testWidgets('an existing source shows its currency, read only', (
      tester,
    ) async {
      settings.primaryCurrency = 'USD';
      final existing = IncomeSource(
        id: 'a',
        name: 'Salary',
        type: IncomeType.salary,
        amount: const Money(100000),
        currencyCode: 'EUR',
        schedule: const Monthly.onDay(5),
        startDate: CalendarDate(2026, 10, 1),
        createdAt: DateTime.utc(2026, 10, 1),
      );
      await income.addSource(existing);

      await pump(tester, IncomeSourceFormPage(source: existing));

      expect(find.byKey(const Key('currency-dropdown')), findsNothing);
      expect(find.byKey(const Key('income-currency-locked')), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('income-currency-locked')))
            .data,
        'EUR',
      );
    });
  });

  group('balance dialog currency', () {
    BalanceInput? result;

    Widget opener(List<String> codes) => Consumer(
      builder: (context, ref, _) => Scaffold(
        body: ElevatedButton(
          key: const Key('show'),
          onPressed: () async {
            result = await showBalanceDialog(
              context,
              ref,
              currencyCode: 'EUR',
              currencyCodes: codes,
              today: CalendarDate(2026, 10, 16),
            );
          },
          child: const Text('show'),
        ),
      ),
    );

    setUp(() => result = null);

    testWidgets('with several currencies the user can switch', (tester) async {
      await pump(tester, opener(<String>['EUR', 'USD']));
      await tester.tap(find.byKey(const Key('show')));
      await tester.pumpAndSettle();

      await chooseCurrency(tester, 'USD');
      await tester.enterText(find.byKey(const Key('balance-field')), '250.50');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();

      expect(result?.currencyCode, 'USD');
      expect(result?.balance, const Money(25050));
    });

    testWidgets('with one currency there is no picker', (tester) async {
      await pump(tester, opener(<String>['EUR']));
      await tester.tap(find.byKey(const Key('show')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('currency-dropdown')), findsNothing);
      await tester.enterText(find.byKey(const Key('balance-field')), '10');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();

      expect(result?.currencyCode, 'EUR');
    });
  });

  group('Income page with several currencies', () {
    IncomeSource source(String id, String name, int minor, int day, String c) =>
        IncomeSource(
          id: id,
          name: name,
          type: IncomeType.salary,
          amount: Money(minor),
          currencyCode: c,
          schedule: Monthly.onDay(day),
          startDate: CalendarDate(2026, 10, 1),
          createdAt: DateTime.utc(2026, 10, 1),
        );

    String textOf(WidgetTester tester, String key) =>
        tester.widget<Text>(find.byKey(Key(key))).data!;

    testWidgets('data in another currency than the device is not hidden', (
      tester,
    ) async {
      // Device is en_US (USD) but the data is in EUR, primary EUR.
      settings.primaryCurrency = 'EUR';
      await income.addSource(source('a', 'Salary', 100000, 5, 'EUR'));

      await pump(tester, const IncomePage());

      expect(find.byKey(const Key('income-no-payments')), findsNothing);
      expect(find.byKey(const Key('occurrence-a-2026-10-05')), findsOneWidget);
      expect(textOf(tester, 'cash-received-EUR'), '€1,000.00');
      expect(find.byKey(const Key('cash-block-USD')), findsNothing);
    });

    testWidgets('one block per currency, primary first, all payments listed', (
      tester,
    ) async {
      settings.primaryCurrency = 'USD';
      await income.addSource(source('a', 'Salary', 100000, 5, 'EUR'));
      await income.addSource(source('b', 'Bonus', 50000, 25, 'USD'));

      await pump(tester, const IncomePage());

      final usdTop = tester.getTopLeft(find.byKey(const Key('cash-block-USD')));
      final eurTop = tester.getTopLeft(find.byKey(const Key('cash-block-EUR')));
      expect(usdTop.dy, lessThan(eurTop.dy));
      expect(textOf(tester, 'cash-received-EUR'), '€1,000.00');
      expect(textOf(tester, 'cash-expected-USD'), r'$500.00');
      expect(textOf(tester, 'cash-received-USD'), r'$0.00');
      expect(find.byKey(const Key('occurrence-a-2026-10-05')), findsOneWidget);
      expect(find.byKey(const Key('occurrence-b-2026-10-25')), findsOneWidget);
    });

    testWidgets('the primary block shows even when it has no data', (
      tester,
    ) async {
      settings.primaryCurrency = 'GBP';
      await income.addSource(source('a', 'Salary', 100000, 5, 'EUR'));

      await pump(tester, const IncomePage());

      expect(find.byKey(const Key('cash-block-GBP')), findsOneWidget);
      expect(find.byKey(const Key('cash-block-EUR')), findsOneWidget);
    });

    testWidgets('set balance in a block starts in that currency', (
      tester,
    ) async {
      settings.primaryCurrency = 'EUR';
      await income.addSource(source('a', 'Salary', 100000, 5, 'EUR'));
      await income.addSource(source('b', 'Bonus', 50000, 25, 'USD'));
      await pump(tester, const IncomePage());

      await tester.ensureVisible(find.byKey(const Key('set-balance-USD')));
      await tester.tap(find.byKey(const Key('set-balance-USD')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('balance-field')), '100');
      await tester.tap(find.byKey(const Key('balance-save')));
      await tester.pumpAndSettle();

      final anchors = locator<BalanceAnchorRepository>();
      expect(await anchors.listCurrencyCodes(), {'USD'});
      expect(textOf(tester, 'cash-closing-USD'), r'$600.00');
    });
  });

  group('Settings page', () {
    testWidgets('shows the primary currency and saves a new choice', (
      tester,
    ) async {
      settings.primaryCurrency = 'EUR';
      await pump(tester, const SettingsPage());

      expect(find.text('Primary currency'), findsOneWidget);
      await chooseCurrency(tester, 'CHF');

      expect(settings.primaryCurrency, 'CHF');
    });

    testWidgets('another code can be typed', (tester) async {
      settings.primaryCurrency = 'EUR';
      await pump(tester, const SettingsPage());

      await chooseCurrency(tester, 'Other…');
      await tester.enterText(
        find.byKey(const Key('currency-other-field')),
        'nok',
      );
      await tester.tap(find.byKey(const Key('currency-other-save')));
      await tester.pumpAndSettle();

      expect(settings.primaryCurrency, 'NOK');
    });

    testWidgets('opens from the Income page and reorders its blocks', (
      tester,
    ) async {
      settings.primaryCurrency = 'EUR';
      await income.addSource(
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
      await pump(tester, const IncomePage());
      expect(find.byKey(const Key('cash-block-USD')), findsNothing);

      await tester.tap(find.byKey(const Key('open-settings')));
      await tester.pumpAndSettle();
      await chooseCurrency(tester, 'USD');
      await tester.pageBack();
      await tester.pumpAndSettle();

      final usd = tester.getTopLeft(find.byKey(const Key('cash-block-USD')));
      final eur = tester.getTopLeft(find.byKey(const Key('cash-block-EUR')));
      expect(usd.dy, lessThan(eur.dy));
    });
  });
}
