import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';

/// Computes when a schedule pays. Pure Dart; knows nothing about sources,
/// start/end dates or stored entries.
class ScheduleEngine {
  const ScheduleEngine();

  /// The payment dates of [schedule] that fall inside [month], ascending.
  List<CalendarDate> occurrencesInMonth(
    IncomeSchedule schedule,
    YearMonth month,
  ) {
    return switch (schedule) {
      OneOff(:final date) =>
        month.contains(date) ? <CalendarDate>[date] : <CalendarDate>[],
      Monthly(:final dayOfMonth) => <CalendarDate>[
        dayOfMonth == null ? month.lastDay : month.dayClamped(dayOfMonth),
      ],
    };
  }
}
