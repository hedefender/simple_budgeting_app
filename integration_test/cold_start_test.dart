import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:simple_budgeting_app/app/app.dart';
import 'package:simple_budgeting_app/app/di/service_locator.dart';
import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:simple_budgeting_app/src/rust/api/core_info.dart';

/// On-device test using the REAL database file. Run on an emulator/phone:
///   `flutter test integration_test/cold_start_test.dart -d <device-id>`
///
/// The launch counter lives in the app's real database, so the test only
/// checks that it increases by exactly one per simulated restart.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Timed out waiting for $finder');
  }

  Future<int> startApp(WidgetTester tester) async {
    configureDependencies(GetIt.instance);
    // The first-run wizard would cover the home screen on a fresh install.
    await GetIt.instance<SettingsRepository>().markSetupCompleted();
    await tester.pumpWidget(
      ProviderScope(key: UniqueKey(), child: const BudgetApp()),
    );
    final tile = find.byKey(const Key('launch-count'));
    await pumpUntilFound(tester, tile);

    // Locale-independent: take the digits from "Launch #5" / "Εκκίνηση #5".
    final text =
        (tester
                    .widget<ListTile>(
                      find.descendant(
                        of: tile,
                        matching: find.byType(ListTile),
                      ),
                    )
                    .title!
                as Text)
            .data!;
    return int.parse(RegExp(r'\d+').firstMatch(text)!.group(0)!);
  }

  Future<void> shutDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await GetIt.instance.reset(); // closes the database like a process exit
  }

  testWidgets('the real Rust core answers core_info()', (tester) async {
    await startApp(tester);

    // Rust is initialized by the Bootstrapper; this calls the real library.
    final info = coreInfo();
    expect(info.crateVersion, isNotEmpty);
    expect(info.target, contains('-'));
    expect(
      find
              .text('Rust core: v${info.crateVersion} (${info.target})')
              .evaluate()
              .isNotEmpty ||
          find
              .text('Πυρήνας Rust: v${info.crateVersion} (${info.target})')
              .evaluate()
              .isNotEmpty,
      isTrue,
    );
    await shutDown(tester);
  });

  testWidgets('cold start reaches home and the counter persists restarts', (
    tester,
  ) async {
    final first = await startApp(tester);
    await shutDown(tester);

    final second = await startApp(tester);
    await shutDown(tester);

    expect(second, first + 1);
  });
}
