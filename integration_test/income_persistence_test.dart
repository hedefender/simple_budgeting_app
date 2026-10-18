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
import 'package:simple_budgeting_app/features/income/domain/usecases/list_income_sources.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/set_balance_anchor.dart';

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
    // The anchor is the balance at the END of 1 Jan; the payment of the 5th is
    // added on top, so the closing balance is anchor + one payment.
    expect(january.projectedClosingBalance, const Money(50000 + 123456));
  });
}
