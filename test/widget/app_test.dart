import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/app.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/features/foundation/domain/services/core_info_service.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_app_launch.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_startup_duration.dart';

import '../support/fakes.dart';
import '../support/income_fakes.dart';

void main() {
  late GetIt locator;
  late FakeAppStatusRepository repository;
  late bool failOpening;

  setUp(() {
    failOpening = false;
    repository = FakeAppStatusRepository();
    locator = GetIt.asNewInstance();
    registerIncomeFakes(locator, clock: () => DateTime.utc(2026, 10, 16, 9));
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
