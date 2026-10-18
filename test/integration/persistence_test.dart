import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/service_locator.dart';

/// Integration test (runs on the host with `flutter test`): wires the REAL
/// graph (DI, drift, repository, use cases, bootstrapper) against a real
/// SQLite file and simulates app restarts by closing and re-opening it.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sba_persistence_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  /// One "app process": build the graph, bootstrap, then shut down.
  Future<BootstrapResult> launch(File file, DateTime now) async {
    final locator = GetIt.asNewInstance();
    configureDependencies(
      locator,
      databaseExecutor: NativeDatabase(file),
      clock: () => now,
      initNative: () async {},
    );
    try {
      return await locator<Bootstrapper>().run();
    } finally {
      await locator.reset(); // closes the database
    }
  }

  test('launch count and first-launch date survive restarts', () async {
    final file = File('${tempDir.path}/budget.sqlite');

    final first = await launch(file, DateTime.utc(2026, 10, 16, 8));
    final second = await launch(file, DateTime.utc(2026, 10, 17, 8));
    final third = await launch(file, DateTime.utc(2026, 10, 18, 8));

    expect(first.status.launchCount, 1);
    expect(second.status.launchCount, 2);
    expect(third.status.launchCount, 3);
    expect(third.status.firstLaunchAt, DateTime.utc(2026, 10, 16, 8));
  });

  test('each launch sees the previous launch startup time', () async {
    final file = File('${tempDir.path}/budget.sqlite');

    final first = await launch(file, DateTime.utc(2026, 10, 16));
    final second = await launch(file, DateTime.utc(2026, 10, 17));

    expect(first.status.lastStartupMs, isNull);
    expect(second.status.lastStartupMs, first.elapsed.inMilliseconds);
  });

  test('cold start (create file, migrate, record) is within budget', () async {
    final file = File('${tempDir.path}/fresh.sqlite');

    final result = await launch(file, DateTime.utc(2026, 10, 16));

    // Generous ceiling for slow CI machines. The real target is measured on
    // a device (see docs/manual-validation.md).
    // ignore: avoid_print
    print('Cold start on host: ${result.elapsed.inMilliseconds} ms');
    expect(result.elapsed, lessThan(const Duration(seconds: 5)));
    expect(file.existsSync(), isTrue);
  });
}
