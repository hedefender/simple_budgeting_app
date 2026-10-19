import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:simple_budgeting_app/app/di/service_locator.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/create_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/get_monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/occurrence_actions.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/list_income_sources.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/set_balance_anchor.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/get_primary_currency.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/set_primary_currency.dart';

/// On-device test using a SEPARATE temporary database file (deleted at the
/// end), so the app's real data on the device is never touched:
///   `flutter test integration_test/income_persistence_test.dart -d <device-id>`
///
/// The source and the balance are written, the dependency graph is closed
/// (like a process exit) and rebuilt on the same file, and both must still be
/// there.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('income source and balance survive an app restart', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('income_persistence_');
    final file = File('${dir.path}/test.sqlite');
    final locator = GetIt.instance;
    addTearDown(() async {
      await locator.reset();
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    configureDependencies(locator, databaseExecutor: NativeDatabase(file));
    await locator.get<CreateIncomeSource>()(
      name: 'Test salary',
      type: IncomeType.salary,
      amount: const Money(123456),
      currencyCode: 'EUR',
      schedule: const Monthly.onDay(5),
      startDate: CalendarDate(2026, 1, 1),
    );
    final created = (await locator.get<ListIncomeSources>()()).single;
    // Move the January payment (nominal 5 Jan) to 8 Jan: a pinned actual date.
    await locator.get<ChangeOccurrenceAmount>()(
      sourceId: created.id,
      originalDate: CalendarDate(2026, 1, 5),
      amount: const Money(123456),
      actualDate: CalendarDate(2026, 1, 8),
    );
    await locator.get<SetBalanceAnchor>()(
      date: CalendarDate(2026, 1, 1),
      balance: const Money(50000),
      currencyCode: 'EUR',
    );
    await locator.reset(); // closes the database like a process exit

    configureDependencies(locator, databaseExecutor: NativeDatabase(file));
    final sources = await locator.get<ListIncomeSources>()();
    expect(sources, hasLength(1));
    expect(sources.single.name, 'Test salary');
    expect(sources.single.amount, const Money(123456));
    expect(sources.single.schedule, const Monthly.onDay(5));
    expect(sources.single.startDate, CalendarDate(2026, 1, 1));

    final january = await locator.get<GetMonthlyCashFlow>()(
      YearMonth(2026, 1),
      'EUR',
    );
    expect(january.occurrences, hasLength(1));
    // The pinned date survived the restart; the key is still the nominal date.
    expect(january.occurrences.single.date, CalendarDate(2026, 1, 8));
    expect(january.occurrences.single.nominalDate, CalendarDate(2026, 1, 5));
    // The anchor is the balance at the END of 1 Jan; the payment of the 5th is
    // added on top, so the closing balance is anchor + one payment.
    expect(january.projectedClosingBalance, const Money(50000 + 123456));
  });

  testWidgets('sources in two currencies and the primary survive a restart', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('currency_persistence_');
    final file = File('${dir.path}/test.sqlite');
    final locator = GetIt.instance;
    addTearDown(() async {
      await locator.reset();
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    configureDependencies(locator, databaseExecutor: NativeDatabase(file));
    Future<void> create(String name, int minor, String currency) =>
        locator.get<CreateIncomeSource>()(
          name: name,
          type: IncomeType.salary,
          amount: Money(minor),
          currencyCode: currency,
          schedule: const Monthly.onDay(5),
          startDate: CalendarDate(2026, 1, 1),
        );
    await create('Euro job', 100000, 'EUR');
    await create('Dollar job', 50000, 'USD');
    // The device says USD, but the data decides: the oldest source is EUR.
    expect(await locator.get<GetPrimaryCurrency>()('USD'), 'EUR');
    await locator.get<SetPrimaryCurrency>()('chf');
    await locator.reset(); // closes the database like a process exit

    configureDependencies(locator, databaseExecutor: NativeDatabase(file));
    // A different device currency does not change the stored primary.
    expect(await locator.get<GetPrimaryCurrency>()('GBP'), 'CHF');
    final summary = await locator.get<GetMonthlyCashFlow>().forAllCurrencies(
      YearMonth(2026, 1),
      'CHF',
    );
    expect(summary.currencies.map((f) => f.currencyCode), [
      'CHF',
      'EUR',
      'USD',
    ]);
    expect(summary.occurrences.map((o) => o.source.name), [
      'Dollar job',
      'Euro job',
    ]);
    expect(summary.currencies[1].projectedClosingBalance, const Money(100000));
    expect(summary.currencies[2].projectedClosingBalance, const Money(50000));
  });
}
