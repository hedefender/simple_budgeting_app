import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/archive_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/create_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/get_monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/list_income_sources.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/occurrence_actions.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/set_balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/update_income_source.dart';

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

final FutureProvider<MonthlyCashFlow> monthlyCashFlowProvider =
    FutureProvider.autoDispose<MonthlyCashFlow>((Ref ref) {
      final month = ref.watch(selectedMonthProvider);
      final currency = ref.watch(moneyFormatterProvider).currencyCode;
      return ref.watch(serviceLocatorProvider).get<GetMonthlyCashFlow>()(
        month,
        currency,
      );
    });

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
    Money amount,
  ) async {
    await _use<ChangeOccurrenceAmount>()(
      sourceId: sourceId,
      originalDate: originalDate,
      amount: amount,
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
