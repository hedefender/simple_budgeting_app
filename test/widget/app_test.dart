import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/app.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/foundation/domain/services/core_info_service.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_app_launch.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_startup_duration.dart';

import '../support/fakes.dart';
import '../support/income_fakes.dart';
import '../support/settings_fakes.dart';

void main() {
  late GetIt locator;
  late FakeAppStatusRepository repository;
  late bool failOpening;
  late FakeIncomeRepository income;
  late FakeSettingsRepository settings;

  setUp(() {
    failOpening = false;
    repository = FakeAppStatusRepository();
    locator = GetIt.asNewInstance();
    final fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    income = fakes.income;
    settings = fakes.settings;
    // The wizard has its own tests (setup_wizard_test.dart); most tests here
    // are about the splash and the home screen.
    settings.setupCompleted = true;
    locator
      ..registerSingleton<CoreInfoService>(FakeCoreInfoService())
      ..registerSingleton<Bootstrapper>(
        Bootstrapper(
          initNative: () async {},
          openDatabase: () async {
            if (failOpening) throw StateError('boom');
          },
          recordAppLaunch: RecordAppLaunch(
            repository,
            () => DateTime.utc(2026, 10, 16, 9),
          ),
          recordStartupDuration: RecordStartupDuration(repository),
        ),
      );
  });

  tearDown(() => locator.reset());

  Widget buildApp(Locale deviceLocale) {
    return ProviderScope(
      overrides: [
        serviceLocatorProvider.overrideWithValue(locator),
        deviceLocaleProvider.overrideWithValue(deviceLocale),
      ],
      child: const BudgetApp(),
    );
  }

  testWidgets('shows the splash first, then the English home screen', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
    tester.platformDispatcher.localesTestValue = const <Locale>[
      Locale('en', 'US'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(buildApp(const Locale('en', 'US')));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('launch-count')), findsOneWidget);
    expect(find.text('Launch #1'), findsOneWidget);
    expect(find.text('Rust core: v9.9.9 (fake-target)'), findsOneWidget);
    expect(find.textContaining(r'$1,234.56'), findsOneWidget);
    expect(find.textContaining('USD'), findsOneWidget);
  });

  group('first-run setup wizard', () {
    Future<void> start(WidgetTester tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      tester.platformDispatcher.localesTestValue = const <Locale>[
        Locale('en', 'US'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(buildApp(const Locale('en', 'US')));
      await tester.pumpAndSettle();
    }

    testWidgets('opens on a fresh install and is not shown again', (
      tester,
    ) async {
      settings.setupCompleted = false;
      await start(tester);
      expect(find.byKey(const Key('setup-finish')), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('setup-skip')));
      await tester.tap(find.byKey(const Key('setup-skip')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('setup-finish')), findsNothing);
      expect(find.byKey(const Key('launch-count')), findsOneWidget);
      expect(settings.setupCompleted, isTrue);
    });

    testWidgets('does not open when the setup was completed', (tester) async {
      await start(tester);
      expect(find.byKey(const Key('setup-finish')), findsNothing);
    });

    testWidgets('does not open on an install that already has sources', (
      tester,
    ) async {
      settings.setupCompleted = false;
      income.sources['s'] = IncomeSource(
        id: 's',
        name: 'Salary',
        type: IncomeType.salary,
        amount: const Money(100000),
        currencyCode: 'USD',
        schedule: const Monthly.onDay(1),
        startDate: CalendarDate(2026, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await start(tester);
      expect(find.byKey(const Key('setup-finish')), findsNothing);
    });
  });

  testWidgets('follows a Greek device: Greek text and euro formatting', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('el', 'GR');
    tester.platformDispatcher.localesTestValue = const <Locale>[
      Locale('el', 'GR'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(buildApp(const Locale('el', 'GR')));
    await tester.pumpAndSettle();

    expect(find.text('Εκκίνηση #1'), findsOneWidget);
    expect(find.text('Πυρήνας Rust: v9.9.9 (fake-target)'), findsOneWidget);
    expect(find.textContaining('1.234,56'), findsOneWidget);
    expect(find.textContaining('EUR'), findsOneWidget);
  });

  testWidgets('shows a retry button when startup fails and recovers', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
    tester.platformDispatcher.localesTestValue = const <Locale>[
      Locale('en', 'US'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    failOpening = true;

    await tester.pumpWidget(buildApp(const Locale('en', 'US')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('bootstrap-retry')), findsOneWidget);
    expect(find.byKey(const Key('launch-count')), findsNothing);

    failOpening = false;
    await tester.tap(find.byKey(const Key('bootstrap-retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('launch-count')), findsOneWidget);
  });
}
