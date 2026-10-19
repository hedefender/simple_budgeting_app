import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/services/holiday_calendar.dart';
import 'package:simple_budgeting_app/features/income/domain/services/income_calculator.dart';
import 'package:simple_budgeting_app/features/income/domain/services/schedule_engine.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/archive_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/create_income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/get_monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/list_income_sources.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/occurrence_actions.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/set_balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/update_income_source.dart';

import 'income_fakes.dart';

/// Real use cases over in-memory repositories, with a clock the test moves.
class IncomeHarness {
  IncomeHarness({DateTime? now, HolidayCalendar? holidays})
    : now = now ?? DateTime.utc(2026, 10, 18, 9),
      calculator = IncomeCalculator(
        ScheduleEngine(holidays ?? const NoHolidays()),
      );

  /// "Now" for every use case. Tests assign it to move time.
  DateTime now;

  final income = FakeIncomeRepository();
  final anchors = FakeBalanceAnchorRepository();
  final _newId = sequentialIds();
  final IncomeCalculator calculator;

  DateTime _clock() => now;

  CreateIncomeSource get create => CreateIncomeSource(income, _clock, _newId);
  UpdateIncomeSource get update =>
      UpdateIncomeSource(income, calculator, _clock, _newId);
  ArchiveIncomeSource get archive => ArchiveIncomeSource(income, _clock);
  ListIncomeSources get list => ListIncomeSources(income);
  GetMonthlyCashFlow get cashFlow =>
      GetMonthlyCashFlow(income, anchors, calculator, _clock);
  ChangeOccurrenceAmount get changeAmount =>
      ChangeOccurrenceAmount(income, _clock, _newId);
  SkipOccurrence get skip => SkipOccurrence(income, _clock, _newId);
  ResetOccurrence get reset => ResetOccurrence(income);
  SetBalanceAnchor get setAnchor => SetBalanceAnchor(anchors, _clock, _newId);

  CalendarDate get today => CalendarDate.fromInstant(now);

  /// Creates a monthly source, in EUR unless told otherwise.
  Future<IncomeSource> monthly({
    required String name,
    required int minor,
    required int day,
    required CalendarDate start,
    CalendarDate? end,
    String currency = 'EUR',
  }) {
    return create(
      name: name,
      type: IncomeType.salary,
      amount: Money(minor),
      currencyCode: currency,
      schedule: Monthly.onDay(day),
      startDate: start,
      endDate: end,
    );
  }
}
