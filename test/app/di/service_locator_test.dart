import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/service_locator.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';

void main() {
  test('the dependency graph resolves and runs end to end', () async {
    final locator = GetIt.asNewInstance();
    addTearDown(locator.reset);
    configureDependencies(
      locator,
      databaseExecutor: NativeDatabase.memory(),
      clock: () => DateTime.utc(2026, 10, 16),
    );

    expect(locator<AppDatabase>(), isA<AppDatabase>());
    expect(locator<AppStatusRepository>(), isA<AppStatusRepository>());

    final result = await locator<Bootstrapper>().run();
    expect(result.status.launchCount, 1);
  });

  test('database and bootstrapper are singletons', () {
    final locator = GetIt.asNewInstance();
    addTearDown(locator.reset);
    configureDependencies(locator, databaseExecutor: NativeDatabase.memory());

    expect(identical(locator<AppDatabase>(), locator<AppDatabase>()), isTrue);
    expect(
      identical(locator<Bootstrapper>(), locator<Bootstrapper>()),
      isTrue,
    );
  });
}
