import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/foundation/data/app_status_repository_impl.dart';
import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_app_launch.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_startup_duration.dart';

/// Composition root: the only place that knows which concrete class
/// implements which contract.
///
/// [locator] is passed in (instead of using the global instance) so tests can
/// build an isolated graph with `GetIt.asNewInstance()`.
void configureDependencies(
  GetIt locator, {
  QueryExecutor? databaseExecutor,
  Clock? clock,
}) {
  locator
    ..registerLazySingleton<AppDatabase>(
      () => AppDatabase(
        databaseExecutor ?? driftDatabase(name: 'simple_budgeting_app'),
      ),
      dispose: (AppDatabase db) => db.close(),
    )
    ..registerLazySingleton<AppStatusRepository>(
      () => AppStatusRepositoryImpl(locator<AppDatabase>()),
    )
    ..registerFactory<RecordAppLaunch>(
      () => RecordAppLaunch(
        locator<AppStatusRepository>(),
        clock ?? DateTime.now,
      ),
    )
    ..registerFactory<RecordStartupDuration>(
      () => RecordStartupDuration(locator<AppStatusRepository>()),
    )
    ..registerLazySingleton<Bootstrapper>(
      () => Bootstrapper(
        // Touching the DB makes drift open the file and run migrations.
        openDatabase: () async {
          await locator<AppDatabase>().customSelect('SELECT 1').get();
        },
        recordAppLaunch: locator<RecordAppLaunch>(),
        recordStartupDuration: locator<RecordStartupDuration>(),
      ),
    );
}
