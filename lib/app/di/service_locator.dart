import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/features/foundation/data/app_status_repository_impl.dart';
import 'package:simple_budgeting_app/features/income/data/balance_anchor_repository_impl.dart';
import 'package:simple_budgeting_app/features/income/data/greek_holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/data/income_repository_impl.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/balance_anchor_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/services/income_calculator.dart';
import 'package:simple_budgeting_app/features/income/domain/services/schedule_engine.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/archive_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/create_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/get_monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/list_income_sources.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/occurrence_actions.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/set_balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/update_income_source.dart';
import 'package:simple_budgeting_app/features/foundation/data/rust_core_info_service.dart';
import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';
import 'package:simple_budgeting_app/features/foundation/domain/services/core_info_service.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_app_launch.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_startup_duration.dart';
import 'package:simple_budgeting_app/features/settings/data/settings_repository_impl.dart';
import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/get_primary_currency.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/set_primary_currency.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/setup_status.dart';
import 'package:simple_budgeting_app/src/rust/frb_generated.dart';

/// flutter_rust_bridge throws if initialized twice, so a bootstrap retry (or an
/// in-process restart in integration tests) must skip it once it succeeded.
Future<void> _initRustLib() async {
  if (!RustLib.instance.initialized) await RustLib.init();
}

/// Composition root: the only place that knows which concrete class
/// implements which contract.
///
/// [locator] is passed in (instead of using the global instance) so tests can
/// build an isolated graph with `GetIt.asNewInstance()`.
void configureDependencies(
  GetIt locator, {
  QueryExecutor? databaseExecutor,
  Clock? clock,
  Future<void> Function()? initNative,
  IdGenerator? idGenerator,
}) {
  final now = clock ?? DateTime.now;
  final newId = idGenerator ?? generateUuidV4;
  locator
    ..registerLazySingleton<Clock>(() => now)
    ..registerLazySingleton<CoreInfoService>(RustCoreInfoService.new)
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
      () => RecordAppLaunch(locator<AppStatusRepository>(), now),
    )
    ..registerLazySingleton<IncomeRepository>(
      () => IncomeRepositoryImpl(locator<AppDatabase>()),
    )
    ..registerLazySingleton<BalanceAnchorRepository>(
      () => BalanceAnchorRepositoryImpl(locator<AppDatabase>()),
    )
    ..registerLazySingleton<IncomeCalculator>(
      () => IncomeCalculator(ScheduleEngine(GreekHolidayCalendar())),
    )
    ..registerFactory<CreateIncomeSource>(
      () => CreateIncomeSource(locator<IncomeRepository>(), now, newId),
    )
    ..registerFactory<UpdateIncomeSource>(
      () => UpdateIncomeSource(
        locator<IncomeRepository>(),
        locator<IncomeCalculator>(),
        now,
        newId,
      ),
    )
    ..registerFactory<ArchiveIncomeSource>(
      () => ArchiveIncomeSource(locator<IncomeRepository>(), now),
    )
    ..registerFactory<ListIncomeSources>(
      () => ListIncomeSources(locator<IncomeRepository>()),
    )
    ..registerFactory<GetMonthlyCashFlow>(
      () => GetMonthlyCashFlow(
        locator<IncomeRepository>(),
        locator<BalanceAnchorRepository>(),
        locator<IncomeCalculator>(),
        now,
      ),
    )
    ..registerFactory<ChangeOccurrenceAmount>(
      () => ChangeOccurrenceAmount(locator<IncomeRepository>(), now, newId),
    )
    ..registerFactory<SkipOccurrence>(
      () => SkipOccurrence(locator<IncomeRepository>(), now, newId),
    )
    ..registerFactory<ResetOccurrence>(
      () => ResetOccurrence(locator<IncomeRepository>()),
    )
    ..registerFactory<SetBalanceAnchor>(
      () => SetBalanceAnchor(locator<BalanceAnchorRepository>(), now, newId),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(locator<AppDatabase>()),
    )
    ..registerFactory<GetPrimaryCurrency>(
      () => GetPrimaryCurrency(
        locator<SettingsRepository>(),
        locator<IncomeRepository>(),
      ),
    )
    ..registerFactory<SetPrimaryCurrency>(
      () => SetPrimaryCurrency(locator<SettingsRepository>()),
    )
    ..registerFactory<ShouldShowSetup>(
      () => ShouldShowSetup(
        locator<SettingsRepository>(),
        locator<IncomeRepository>(),
      ),
    )
    ..registerFactory<CompleteSetup>(
      () => CompleteSetup(locator<SettingsRepository>()),
    )
    ..registerFactory<RecordStartupDuration>(
      () => RecordStartupDuration(locator<AppStatusRepository>()),
    )
    ..registerLazySingleton<Bootstrapper>(
      () => Bootstrapper(
        initNative: initNative ?? _initRustLib,
        // Touching the DB makes drift open the file and run migrations.
        openDatabase: () async {
          await locator<AppDatabase>().customSelect('SELECT 1').get();
        },
        recordAppLaunch: locator<RecordAppLaunch>(),
        recordStartupDuration: locator<RecordStartupDuration>(),
      ),
    );
}
