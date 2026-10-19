import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/setup/presentation/setup_wizard_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/income_fakes.dart';
import '../support/settings_fakes.dart';

/// "Today" in these tests is 2026-10-16 (a Friday).
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
  const greek = Locale('el', 'GR');

  Future<void> pumpWizard(WidgetTester tester, Locale locale) async {
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
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('open'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SetupWizardPage(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester, String key, String text) async {
    await tester.enterText(find.byKey(Key(key)), text);
    await tester.pump();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  List<IncomeSource> created() => income.sources.values.toList();

  IncomeSource byName(String name) =>
      created().firstWhere((s) => s.name == name);

  const christmas = 'gr.private.christmas_bonus';
  const easter = 'gr.private.easter_bonus';
  const leave = 'gr.private.leave_allowance';

  group('what the wizard shows', () {
    testWidgets('an employee sees three suggestions with empty amounts', (
      tester,
    ) async {
      await pumpWizard(tester, english);

      for (final id in [christmas, easter, leave]) {
        expect(find.byKey(Key('setup-$id-suggested')), findsOneWidget);
        expect(find.text('Suggested'), findsNWidgets(3));
        final amount = tester.widget<TextFormField>(
          find.byKey(Key('setup-$id-amount')),
        );
        expect(amount.controller!.text, isEmpty, reason: id);
        final check = tester.widget<Checkbox>(
          find.byKey(Key('setup-$id-check')),
        );
        expect(check.value, isFalse, reason: id);
      }
      expect(find.byKey(const Key('setup-private-note')), findsOneWidget);
      expect(
        find.text('Roughly up to your net monthly salary'),
        findsOneWidget,
      );
      expect(
        find.text('Roughly up to half of your net monthly salary'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('setup-last-verified')), findsOneWidget);
      expect(find.textContaining('Oct 19, 2026'), findsOneWidget);
      // Showing suggestions saves nothing.
      expect(created(), isEmpty);
    });

    testWidgets('the schedules show the 21 December and Holy Wednesday dates', (
      tester,
    ) async {
      await pumpWizard(tester, english);
      expect(find.textContaining('December 21'), findsOneWidget);
      expect(find.textContaining('Holy Wednesday'), findsOneWidget);
    });

    testWidgets('a freelancer has no suggestions and no private-sector note', (
      tester,
    ) async {
      await pumpWizard(tester, english);
      await tester.tap(find.text('Freelancer'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('setup-$christmas-check')), findsNothing);
      expect(find.byKey(const Key('setup-private-note')), findsNothing);
      expect(find.byKey(const Key('setup-last-verified')), findsNothing);
      // The regular income line takes the profile's name.
      expect(
        tester
            .widget<TextFormField>(find.byKey(const Key('setup-main-name')))
            .controller!
            .text,
        'Freelance',
      );
    });

    testWidgets('Greek labels', (tester) async {
      await pumpWizard(tester, greek);
      expect(find.text('Προτεινόμενο'), findsNWidgets(3));
      expect(find.text('Δώρο Χριστουγέννων'), findsOneWidget);
      expect(find.text('Δώρο Πάσχα'), findsOneWidget);
      expect(find.text('Επίδομα αδείας'), findsOneWidget);
      expect(find.text('Ενδεικτικά έως ο καθαρός μισθός'), findsOneWidget);
    });
  });

  group('what the wizard creates', () {
    testWidgets('only the ticked lines with an amount, as ordinary sources', (
      tester,
    ) async {
      await pumpWizard(tester, english);
      await fill(tester, 'setup-main-amount', '1500');
      await fill(tester, 'setup-$christmas-amount', '1200');
      await fill(tester, 'setup-$easter-amount', '600');
      // The leave allowance stays unticked.
      await tapKey(tester, 'setup-finish');

      expect(created(), hasLength(3));
      final salary = byName('Salary');
      expect(salary.type, IncomeType.salary);
      expect(salary.amount, const Money(150000));
      expect(
        salary.schedule,
        const Monthly.onDay(1, shift: ShiftRule.previousWorkingDay),
      );
      expect(salary.startDate, CalendarDate(2026, 10, 16));

      final xmas = byName('Christmas bonus');
      expect(xmas.type, IncomeType.extraPayment);
      expect(xmas.amount, const Money(120000));
      expect(
        xmas.schedule,
        const Yearly(FixedDate(12, 21), shift: ShiftRule.previousWorkingDay),
      );

      final eas = byName('Easter bonus');
      expect(eas.type, IncomeType.extraPayment);
      expect(eas.amount, const Money(60000));
      expect(
        eas.schedule,
        const Yearly(
          EasterRelative(EasterRelative.holyWednesdayOffset),
          shift: ShiftRule.previousWorkingDay,
        ),
      );
      expect(created().any((s) => s.name == 'Leave allowance'), isFalse);
      expect(settings.setupCompleted, isTrue);
      expect(find.byKey(const Key('setup-finish')), findsNothing);
    });

    testWidgets('typing an amount ticks the line', (tester) async {
      await pumpWizard(tester, english);
      await fill(tester, 'setup-$easter-amount', '300');
      expect(
        tester
            .widget<Checkbox>(find.byKey(const Key('setup-$easter-check')))
            .value,
        isTrue,
      );
    });

    testWidgets('a ticked line without an amount is an error; nothing saved', (
      tester,
    ) async {
      await pumpWizard(tester, english);
      await tapKey(tester, 'setup-$christmas-check');
      await tapKey(tester, 'setup-finish');

      expect(find.text('Enter a valid amount'), findsOneWidget);
      expect(created(), isEmpty);
      expect(settings.setupCompleted, isFalse);
      expect(find.byKey(const Key('setup-finish')), findsOneWidget);
    });

    testWidgets('an unticked line keeps its amount out of the database', (
      tester,
    ) async {
      await pumpWizard(tester, english);
      await fill(tester, 'setup-$christmas-amount', '900');
      await tapKey(tester, 'setup-$christmas-check'); // untick again
      await tapKey(tester, 'setup-finish');

      expect(created(), isEmpty);
      expect(settings.setupCompleted, isTrue);
    });

    testWidgets('the leave allowance uses the date the user gives', (
      tester,
    ) async {
      await pumpWizard(tester, english);
      await fill(tester, 'setup-$leave-amount', '500');
      await tapKey(tester, 'setup-finish');

      final allowance = byName('Leave allowance');
      expect(allowance.type, IncomeType.extraPayment);
      // The pickers start on today (16 October).
      expect(
        allowance.schedule,
        const Yearly(FixedDate(10, 16), shift: ShiftRule.previousWorkingDay),
      );
    });

    testWidgets('"Add another yearly payment" makes a 13th/14th salary line', (
      tester,
    ) async {
      await pumpWizard(tester, english);
      await tapKey(tester, 'setup-add-yearly');
      await fill(tester, 'setup-custom-1-name', '13th salary');
      await fill(tester, 'setup-custom-1-amount', '1400');
      await tapKey(tester, 'setup-finish');

      final extra = byName('13th salary');
      expect(extra.type, IncomeType.extraPayment);
      expect(extra.amount, const Money(140000));
      expect(extra.schedule, isA<Yearly>());
    });

    testWidgets('a custom line can be removed', (tester) async {
      await pumpWizard(tester, english);
      await tapKey(tester, 'setup-add-yearly');
      expect(find.byKey(const Key('setup-custom-1-name')), findsOneWidget);
      await tapKey(tester, 'setup-custom-1-remove');
      expect(find.byKey(const Key('setup-custom-1-name')), findsNothing);
    });

    testWidgets('skipping creates nothing and completes the setup', (
      tester,
    ) async {
      await pumpWizard(tester, english);
      await fill(tester, 'setup-main-amount', '1000');
      await tapKey(tester, 'setup-skip');

      expect(created(), isEmpty);
      expect(settings.setupCompleted, isTrue);
      expect(find.byKey(const Key('setup-skip')), findsNothing);
    });
  });

  group('running the wizard again', () {
    testWidgets('warns when a source with the same name exists', (
      tester,
    ) async {
      income.sources['old'] = IncomeSource(
        id: 'old',
        name: ' christmas BONUS ',
        type: IncomeType.extraPayment,
        amount: const Money(100000),
        currencyCode: 'USD',
        schedule: const Yearly(FixedDate(12, 21)),
        startDate: CalendarDate(2026, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await pumpWizard(tester, english);
      expect(find.byKey(const Key('setup-$christmas-duplicate')), findsNothing);

      await tapKey(tester, 'setup-$christmas-check');
      expect(
        find.byKey(const Key('setup-$christmas-duplicate')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('setup-$easter-duplicate')), findsNothing);
    });

    testWidgets('an archived source does not trigger the warning', (
      tester,
    ) async {
      income.sources['old'] = IncomeSource(
        id: 'old',
        name: 'Christmas bonus',
        type: IncomeType.extraPayment,
        amount: const Money(100000),
        currencyCode: 'USD',
        schedule: const Yearly(FixedDate(12, 21)),
        startDate: CalendarDate(2026, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1),
        archivedAt: DateTime.utc(2026, 6, 1),
      );
      await pumpWizard(tester, english);
      await tapKey(tester, 'setup-$christmas-check');
      expect(find.byKey(const Key('setup-$christmas-duplicate')), findsNothing);
    });

    testWidgets('the warning does not block saving', (tester) async {
      income.sources['old'] = IncomeSource(
        id: 'old',
        name: 'Christmas bonus',
        type: IncomeType.extraPayment,
        amount: const Money(100000),
        currencyCode: 'USD',
        schedule: const Yearly(FixedDate(12, 21)),
        startDate: CalendarDate(2026, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await pumpWizard(tester, english);
      await fill(tester, 'setup-$christmas-amount', '800');
      await tapKey(tester, 'setup-finish');
      expect(created(), hasLength(2));
    });
  });
}
