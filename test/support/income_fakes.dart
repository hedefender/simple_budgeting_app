import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
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
import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/get_primary_currency.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/set_primary_currency.dart';

import 'settings_fakes.dart';

/// In-memory income repository for tests that must not touch SQLite.
class FakeIncomeRepository implements IncomeRepository {
  final Map<String, IncomeSource> sources = <String, IncomeSource>{};
  final List<IncomeEntry> entries = <IncomeEntry>[];

  @override
  Future<void> addSource(IncomeSource source) async {
    sources[source.id] = source;
  }

  @override
  Future<void> updateSource(
    IncomeSource source, {
    List<IncomeEntry> freezeEntries = const <IncomeEntry>[],
  }) async {
    freezeEntries.forEach(_upsert);
    sources[source.id] = source;
  }

  @override
  Future<void> archiveSource(String id, DateTime archivedAtUtc) async {
    sources[id] = sources[id]!.copyWith(archivedAt: archivedAtUtc);
  }

  @override
  Future<IncomeSource?> getSource(String id) async => sources[id];

  @override
  Future<List<IncomeSource>> listSources({
    bool includeArchived = false,
  }) async =>
      sources.values.where((s) => includeArchived || !s.isArchived).toList();

  @override
  Future<List<IncomeEntry>> listEntries() async =>
      List<IncomeEntry>.of(entries);

  @override
  Future<void> saveEntry(IncomeEntry entry) async => _upsert(entry);

  @override
  Future<void> removeEntry(String sourceId, CalendarDate originalDate) async {
    entries.removeWhere(
      (e) => e.sourceId == sourceId && e.originalDate == originalDate,
    );
  }

  void _upsert(IncomeEntry entry) {
    entries.removeWhere(
      (e) =>
          e.sourceId == entry.sourceId && e.originalDate == entry.originalDate,
    );
    entries.add(entry);
  }
}

class FakeBalanceAnchorRepository implements BalanceAnchorRepository {
  final List<BalanceAnchor> anchors = <BalanceAnchor>[];

  @override
  Future<void> saveAnchor(BalanceAnchor anchor) async {
    anchors.removeWhere(
      (a) => a.date == anchor.date && a.currencyCode == anchor.currencyCode,
    );
    anchors.add(anchor);
  }

  @override
  Future<List<BalanceAnchor>> listAnchors(String currencyCode) async =>
      anchors.where((a) => a.currencyCode == currencyCode).toList();

  @override
  Future<Set<String>> listCurrencyCodes() async =>
      anchors.map((a) => a.currencyCode).toSet();
}

/// A deterministic id generator: `id-1`, `id-2`, ...
IdGenerator sequentialIds() {
  var n = 0;
  return () => 'id-${++n}';
}

/// Registers the income services (in-memory repositories + real use cases)
/// in [locator]. Returns the repositories so tests can inspect them.
({
  FakeIncomeRepository income,
  FakeBalanceAnchorRepository anchors,
  FakeSettingsRepository settings,
})
registerIncomeFakes(GetIt locator, {required Clock clock}) {
  final income = FakeIncomeRepository();
  final anchors = FakeBalanceAnchorRepository();
  final settings = FakeSettingsRepository();
  final newId = sequentialIds();
  const calculator = IncomeCalculator(ScheduleEngine());
  locator
    ..registerSingleton<Clock>(clock)
    ..registerSingleton<IncomeRepository>(income)
    ..registerSingleton<BalanceAnchorRepository>(anchors)
    ..registerSingleton<SettingsRepository>(settings)
    ..registerFactory<GetPrimaryCurrency>(
      () => GetPrimaryCurrency(settings, income),
    )
    ..registerFactory<SetPrimaryCurrency>(() => SetPrimaryCurrency(settings))
    ..registerFactory<CreateIncomeSource>(
      () => CreateIncomeSource(income, clock, newId),
    )
    ..registerFactory<UpdateIncomeSource>(
      () => UpdateIncomeSource(income, calculator, clock, newId),
    )
    ..registerFactory<ArchiveIncomeSource>(
      () => ArchiveIncomeSource(income, clock),
    )
    ..registerFactory<ListIncomeSources>(() => ListIncomeSources(income))
    ..registerFactory<GetMonthlyCashFlow>(
      () => GetMonthlyCashFlow(income, anchors, calculator, clock),
    )
    ..registerFactory<ChangeOccurrenceAmount>(
      () => ChangeOccurrenceAmount(income, clock, newId),
    )
    ..registerFactory<SkipOccurrence>(
      () => SkipOccurrence(income, clock, newId),
    )
    ..registerFactory<ResetOccurrence>(() => ResetOccurrence(income))
    ..registerFactory<SetBalanceAnchor>(
      () => SetBalanceAnchor(anchors, clock, newId),
    );
  return (income: income, anchors: anchors, settings: settings);
}
