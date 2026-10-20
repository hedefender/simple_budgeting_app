import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/app/home_shell.dart';
import 'package:simple_budgeting_app/features/documents/presentation/documents_page.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expenses_page.dart';
import 'package:simple_budgeting_app/features/foundation/domain/entities/app_status.dart';
import 'package:simple_budgeting_app/features/foundation/domain/services/core_info_service.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/fakes.dart';
import '../support/income_fakes.dart';

/// The bottom bar has four tabs and all of them stay alive.
void main() {
  late GetIt locator;

  setUp(() async {
    locator = GetIt.asNewInstance();
    final fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    fakes.settings.primaryCurrency = 'EUR';
    await fakes.settings.markSetupCompleted();
    locator.registerSingleton<CoreInfoService>(FakeCoreInfoService());
  });

  tearDown(() => locator.reset());

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en', 'US'),
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
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
          home: HomeShell(
            result: BootstrapResult(
              status: AppStatus(
                launchCount: 1,
                firstLaunchAt: DateTime.utc(2026, 10, 16),
              ),
              elapsed: const Duration(milliseconds: 500),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('four destinations, in order', (tester) async {
    await pump(tester);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.destinations, hasLength(4));
    for (final key in [
      'nav-home',
      'nav-income',
      'nav-expenses',
      'nav-documents',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Documents'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the Documents tab opens the documents page', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('nav-documents')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    expect(find.text('No documents yet'), findsOneWidget);
  });

  testWidgets('every tab shows its own page and keeps its state', (
    tester,
  ) async {
    await pump(tester);
    // IndexedStack keeps all four pages built.
    expect(find.byType(IncomePage, skipOffstage: false), findsOneWidget);
    expect(find.byType(ExpensesPage, skipOffstage: false), findsOneWidget);
    expect(find.byType(DocumentsPage, skipOffstage: false), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-expenses')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('expense-add')), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-documents')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('document-import')), findsOneWidget);
  });

  testWidgets('no hero tag clashes between the floating buttons', (
    tester,
  ) async {
    // Both tabs have a floating button and stay alive; a shared hero tag
    // breaks every page transition (found in Phase 2).
    await pump(tester);
    await tester.tap(find.byKey(const Key('nav-documents')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('document-import')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Greek label', (tester) async {
    await pump(tester, locale: const Locale('el', 'GR'));
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Έγγραφα'),
      ),
      findsOneWidget,
    );
  });
}
