import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/setup/domain/entities/preset_pack.dart';

/// Extra payments of Greek private-sector employees. Rules, sources and what
/// could not be confirmed: `docs/extra-payments.md`.
///
/// Dates are the legal deadlines, moved to the previous working day:
/// Christmas bonus by 21 December, Easter bonus by Holy Wednesday (Orthodox
/// Easter - 4 days). The leave allowance follows the start of the leave, so it
/// has no date here. There is no public-sector line: no official source
/// confirms the current rule.
final PresetPack greekPrivateSectorPack = PresetPack(
  id: 'gr.private',
  lastVerified: CalendarDate(2026, 10, 19),
  lines: const <PresetLine>[
    PresetLine(
      key: 'gr.private.christmas_bonus',
      name: PresetName.christmasBonus,
      amountHint: AmountHint.upToNetSalary,
      schedule: Yearly(FixedDate(12, 21), shift: ShiftRule.previousWorkingDay),
      sources: <String>['S1', 'S4'],
    ),
    PresetLine(
      key: 'gr.private.easter_bonus',
      name: PresetName.easterBonus,
      amountHint: AmountHint.upToHalfNetSalary,
      schedule: Yearly(
        EasterRelative(EasterRelative.holyWednesdayOffset),
        shift: ShiftRule.previousWorkingDay,
      ),
      sources: <String>['S1', 'S3', 'S5'],
    ),
    PresetLine(
      key: 'gr.private.leave_allowance',
      name: PresetName.leaveAllowance,
      amountHint: AmountHint.leaveAllowance,
      sources: <String>['S6'],
    ),
  ],
);
