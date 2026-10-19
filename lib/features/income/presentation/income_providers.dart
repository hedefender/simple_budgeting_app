import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_start.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/archive_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/create_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/get_balance_start.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/get_monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/list_income_sources.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/occurrence_actions.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/set_balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/update_income_source.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_providers.dart';

final Provider<Clock> clockProvider = Provider<Clock>(
  (Ref ref) => ref.watch(serviceLocatorProvider).get<Clock>(),
);

/// Today's calendar day in the user's own time zone.
final Provider<CalendarDate> todayProvider = Provider<CalendarDate>(
  (Ref ref) => CalendarDate.fromInstant(ref.watch(clockProvider)()),
);

class SelectedMonthNotifier extends Notifier<YearMonth> {
  @override
  YearMonth build() => YearMonth.of(ref.read(todayProvider));

  void previous() => state = state.plusMonths(-1);

  void next() => state = state.plusMonths(1);
}

final NotifierProvider<SelectedMonthNotifier, YearMonth> selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, YearMonth>(
      SelectedMonthNotifier.new,
    );

final FutureProvider<List<IncomeSource>> incomeSourcesProvider =
    FutureProvider.autoDispose<List<IncomeSource>>(
      (Ref ref) => ref.watch(serviceLocatorProvider).get<ListIncomeSources>()(),
    );

/// The month in every currency in the data; the primary currency comes first.
final FutureProvider<MonthlyCashFlowSummary> monthlyCashFlowProvider =
    FutureProvider.autoDispose<MonthlyCashFlowSummary>((Ref ref) async {
      final month = ref.watch(selectedMonthProvider);
      final primary = await ref.watch(primaryCurrencyProvider.future);
      return ref
          .watch(serviceLocatorProvider)
          .get<GetMonthlyCashFlow>()
          .forAllCurrencies(month, primary);
    });

/// Where the balance of a currency starts (null: no anchor and no source).
final balanceStartProvider =
    FutureProvider.autoDispose.family<BalanceStart?, String>(
      (Ref ref, String currencyCode) => ref
          .watch(serviceLocatorProvider)
          .get<GetBalanceStart>()(currencyCode),
    );

final Provider<IncomeActions> incomeActionsProvider = Provider<IncomeActions>(
  (Ref ref) => IncomeActions(ref),
);

/// Runs the income use cases and refreshes what the screens show.
class IncomeActions {
  IncomeActions(this._ref);

  final Ref _ref;

  T _use<T extends Object>() => _ref.read(serviceLocatorProvider).get<T>();

  void _refresh() {
    _ref
      ..invalidate(incomeSourcesProvider)
      ..invalidate(balanceStartProvider)
      ..invalidate(monthlyCashFlowProvider);
  }

  Future<void> createSource({
    required String name,
    required IncomeType type,
    required Money amount,
    required String currencyCode,
    required IncomeSchedule schedule,
    required CalendarDate startDate,
    CalendarDate? endDate,
  }) async {
    await _use<CreateIncomeSource>()(
      name: name,
      type: type,
      amount: amount,
      currencyCode: currencyCode,
      schedule: schedule,
      startDate: startDate,
      endDate: endDate,
    );
    _refresh();
  }

  Future<void> updateSource({
    required String sourceId,
    required String name,
    required IncomeType type,
    required Money amount,
    required IncomeSchedule schedule,
    required CalendarDate startDate,
    CalendarDate? endDate,
  }) async {
    await _use<UpdateIncomeSource>()(
      sourceId: sourceId,
      name: name,
      type: type,
      amount: amount,
      schedule: schedule,
      startDate: startDate,
      endDate: endDate,
    );
    _refresh();
  }

  Future<void> archiveSource(String sourceId) async {
    await _use<ArchiveIncomeSource>()(sourceId);
    _refresh();
  }

  Future<void> changeAmount(
    String sourceId,
    CalendarDate originalDate,
    Money amount, {
    CalendarDate? actualDate,
  }) async {
    await _use<ChangeOccurrenceAmount>()(
      sourceId: sourceId,
      originalDate: originalDate,
      amount: amount,
      actualDate: actualDate,
    );
    _refresh();
  }

  Future<void> skip(String sourceId, CalendarDate originalDate) async {
    await _use<SkipOccurrence>()(
      sourceId: sourceId,
      originalDate: originalDate,
    );
    _refresh();
  }

  Future<void> reset(String sourceId, CalendarDate originalDate) async {
    await _use<ResetOccurrence>()(
      sourceId: sourceId,
      originalDate: originalDate,
    );
    _refresh();
  }

  Future<void> setBalance({
    required CalendarDate date,
    required Money balance,
    required String currencyCode,
  }) async {
    await _use<SetBalanceAnchor>()(
      date: date,
      balance: balance,
      currencyCode: currencyCode,
    );
    _refresh();
  }
}
