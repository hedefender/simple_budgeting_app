import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';

/// What kind of earner the user is. Chosen once in the setup wizard.
enum WorkerProfile { employee, freelancer, sideHustle }

/// Which name the wizard proposes for a preset line (the text itself lives in
/// the localization files).
enum PresetName { christmasBonus, easterBonus, leaveAllowance }

/// Help shown under the empty amount field of a preset line.
enum AmountHint { upToNetSalary, upToHalfNetSalary, leaveAllowance }

/// One suggested extra payment. It never carries an amount: the user types it.
class PresetLine {
  const PresetLine({
    required this.key,
    required this.name,
    required this.amountHint,
    this.schedule,
    this.sources = const <String>[],
  });

  /// Stable id, for example `gr.private.christmas_bonus`. Used for tests and
  /// the research notes only; it is NOT stored in the database.
  final String key;
  final PresetName name;
  final AmountHint amountHint;

  /// When the payment is due. Null when the user must give the date (the
  /// leave allowance follows the start of the leave).
  final Yearly? schedule;

  /// Ids of the official sources in `docs/extra-payments.md`.
  final List<String> sources;

  bool get needsDate => schedule == null;
}

/// A set of suggestions for one country and sector, with the day its rules
/// were last checked.
class PresetPack {
  const PresetPack({
    required this.id,
    required this.lastVerified,
    required this.lines,
  });

  final String id;
  final CalendarDate lastVerified;
  final List<PresetLine> lines;

  /// The suggested lines of [profile]. Only employees get lines: the sources
  /// say nothing about extra payments for the self-employed.
  List<PresetLine> linesFor(WorkerProfile profile) =>
      profile == WorkerProfile.employee ? lines : const <PresetLine>[];
}
