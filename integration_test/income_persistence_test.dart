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

/// On-device test using the REAL database file:
///   `flutter test integration_test/income_persistence_test.dart -d <device-id>`
///
/// The source and the balance are written, the dependency graph is closed
/// (like a process exit) and rebuilt, and both must still be there. The test
/// uses a unique name and an unrealistic currency so it cannot clash with the
/// user's data on the device.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const currency = 'CHF';

  testWidgets('income source and balance survive an app restart', (
    tester,
  ) async {
    final name = 'Test salary ${DateTime.now().microsecondsSinceEpoch}';
    final locator = GetIt.instance;

    configureDependencies(locator);
    await locator.get<CreateIncomeSource>()(
      name: name,
      type: IncomeType.salary,
      amount: const Money(123456),
      currencyCode: currency,
      schedule: const Monthly.onDay(5),
      startDate: CalendarDate(2026, 1, 1),
    );
    await locator.get<SetBalanceAnchor>()(
      date: CalendarDate(2026, 1, 1),
      balance: const Money(50000),
      currencyCode: currency,
    );
    await locator.reset(); // closes the database like a process exit

    configureDependencies(locator);
    final sources = await locator.get<ListIncomeSources>()();
    final mine = sources.where((s) => s.name == name).toList();
    expect(mine, hasLength(1));
    expect(mine.single.amount, const Money(123456));
    expect(mine.single.schedule, const Monthly.onDay(5));
    expect(mine.single.startDate, CalendarDate(2026, 1, 1));

    final flow = await locator.get<GetMonthlyCashFlow>()(
      YearMonth(2026, 1),
      currency,
    );
    expect(flow.occurrences.where((o) => o.source.name == name), hasLength(1));
    // The anchor (end of 1 Jan) is the opening balance of February.
    final february = await locator.get<GetMonthlyCashFlow>()(
      YearMonth(2026, 2),
      currency,
    );
    expect(february.openingBalance.minorUnits, greaterThanOrEqualTo(50000));

    await locator.reset();
  });
}
