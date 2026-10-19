import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money_parser.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_labels.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_providers.dart';
import 'package:simple_budgeting_app/features/income/presentation/money_input.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/setup_status.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_providers.dart';
import 'package:simple_budgeting_app/features/setup/domain/entities/preset_pack.dart';
import 'package:simple_budgeting_app/features/setup/domain/greek_preset_pack.dart';
import 'package:simple_budgeting_app/features/setup/domain/usecases/find_duplicate_names.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

enum _LineKind { main, preset, custom }

/// One row of the wizard. A source is created from it only when [checked] and
/// the amount is filled.
class _Line {
  _Line({
    required this.id,
    required this.kind,
    required String name,
    this.preset,
    this.month = 1,
    this.day = 1,
  }) : name = TextEditingController(text: name),
       amount = TextEditingController();

  final String id;
  final _LineKind kind;
  final PresetLine? preset;
  final TextEditingController name;
  final TextEditingController amount;
  bool checked = false;

  /// Main income: only [day] (day of the month). Preset without a date and
  /// custom lines: [month] and [day] of the yearly payment.
  int month;
  int day;

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}

/// First-run wizard: pick a profile, then tick the lines that apply and enter
/// their amounts. Suggestions have an empty amount and exist only on screen
/// until a source is created from them.
class SetupWizardPage extends ConsumerStatefulWidget {
  const SetupWizardPage({super.key});

  @override
  ConsumerState<SetupWizardPage> createState() => _SetupWizardPageState();
}

class _SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  final _formKey = GlobalKey<FormState>();
  final PresetPack _pack = greekPrivateSectorPack;
  WorkerProfile _profile = WorkerProfile.employee;
  final List<_Line> _lines = <_Line>[];
  int _customCounter = 0;
  bool _saving = false;

  /// The localized default name of the main income line of [_profile], used to
  /// tell whether the user renamed it.
  String _mainName(AppLocalizations l10n, WorkerProfile profile) =>
      switch (profile) {
        WorkerProfile.employee => l10n.typeSalary,
        WorkerProfile.freelancer => l10n.typeFreelance,
        WorkerProfile.sideHustle => l10n.typeSideHustle,
      };

  String _presetName(AppLocalizations l10n, PresetName name) => switch (name) {
    PresetName.christmasBonus => l10n.presetChristmasBonus,
    PresetName.easterBonus => l10n.presetEasterBonus,
    PresetName.leaveAllowance => l10n.presetLeaveAllowance,
  };

  String _hint(AppLocalizations l10n, AmountHint hint) => switch (hint) {
    AmountHint.upToNetSalary => l10n.amountHintChristmas,
    AmountHint.upToHalfNetSalary => l10n.amountHintEaster,
    AmountHint.leaveAllowance => l10n.amountHintLeave,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lines.isEmpty) {
      final l10n = AppLocalizations.of(context);
      _lines.add(
        _Line(
          id: 'main',
          kind: _LineKind.main,
          name: _mainName(l10n, _profile),
        ),
      );
      _addPresetLines(l10n);
    }
  }

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  void _addPresetLines(AppLocalizations l10n) {
    final today = ref.read(todayProvider);
    var at = 1;
    for (final preset in _pack.linesFor(_profile)) {
      _lines.insert(
        at++,
        _Line(
          id: preset.key,
          kind: _LineKind.preset,
          preset: preset,
          name: _presetName(l10n, preset.name),
          month: today.month,
          day: today.day,
        ),
      );
    }
  }

  void _selectProfile(WorkerProfile profile) {
    if (profile == _profile) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      final main = _lines.first;
      if (main.name.text == _mainName(l10n, _profile)) {
        main.name.text = _mainName(l10n, profile);
      }
      _lines.removeWhere((line) {
        final isPreset = line.kind == _LineKind.preset;
        if (isPreset) line.dispose();
        return isPreset;
      });
      _profile = profile;
      _addPresetLines(l10n);
    });
  }

  void _addCustomLine() {
    final l10n = AppLocalizations.of(context);
    final today = ref.read(todayProvider);
    setState(() {
      _lines.add(
        _Line(
          id: 'custom-${++_customCounter}',
          kind: _LineKind.custom,
          name: l10n.setupCustomName,
          month: today.month,
          day: today.day,
        )..checked = true,
      );
    });
  }

  void _removeLine(_Line line) {
    setState(() {
      _lines.remove(line);
      line.dispose();
    });
  }

  String get _currencyCode =>
      ref.read(primaryCurrencyProvider).value ??
      ref.read(moneyFormatterProvider).currencyCode;

  MoneyParser get _parser => MoneyParser.forCurrency(
    localeTag: ref.read(deviceLocaleProvider).toString(),
    currencyCode: _currencyCode,
  );

  IncomeSchedule _scheduleOf(_Line line) {
    return switch (line.kind) {
      _LineKind.main => Monthly.onDay(
        line.day,
        shift: ShiftRule.previousWorkingDay,
      ),
      _LineKind.preset when line.preset!.schedule != null =>
        line.preset!.schedule!,
      _ => Yearly(
        FixedDate(line.month, line.day),
        shift: ShiftRule.previousWorkingDay,
      ),
    };
  }

  IncomeType _typeOf(_Line line) {
    if (line.kind != _LineKind.main) return IncomeType.extraPayment;
    return switch (_profile) {
      WorkerProfile.employee => IncomeType.salary,
      WorkerProfile.freelancer => IncomeType.freelance,
      WorkerProfile.sideHustle => IncomeType.sideHustle,
    };
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final actions = ref.read(incomeActionsProvider);
    final today = ref.read(todayProvider);
    final currency = _currencyCode;
    final parser = _parser;
    final navigator = Navigator.of(context);
    final complete = ref.read(serviceLocatorProvider).get<CompleteSetup>();
    for (final line in _lines.where((line) => line.checked)) {
      final amount = tryParseMoney(parser, line.amount.text);
      if (amount == null) continue;
      await actions.createSource(
        name: line.name.text,
        type: _typeOf(line),
        amount: amount,
        currencyCode: currency,
        schedule: _scheduleOf(line),
        startDate: today,
      );
    }
    await complete();
    ref.invalidate(shouldShowSetupProvider);
    navigator.pop();
  }

  Future<void> _skip() async {
    final navigator = Navigator.of(context);
    await ref.read(serviceLocatorProvider).get<CompleteSetup>()();
    ref.invalidate(shouldShowSetupProvider);
    navigator.pop();
  }

  Widget _dropdown<T>({
    required Key fieldKey,
    required String label,
    required T value,
    required Map<T, String> items,
    required void Function(T) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          key: fieldKey,
          value: value,
          isExpanded: true,
          isDense: true,
          items: <DropdownMenuItem<T>>[
            for (final entry in items.entries)
              DropdownMenuItem<T>(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: (T? v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _dayPickers(AppLocalizations l10n, _Line line, {required bool both}) {
    final localeTag = Localizations.localeOf(context).toString();
    final maxDay = both ? DateTime.utc(2024, line.month + 1, 0).day : 31;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (both) ...<Widget>[
          Expanded(
            flex: 3,
            child: _dropdown<int>(
              fieldKey: Key('setup-${line.id}-month'),
              label: l10n.formMonth,
              value: line.month,
              items: <int, String>{
                for (var m = 1; m <= 12; m++)
                  m: DateFormat.MMMM(localeTag).format(DateTime.utc(2024, m)),
              },
              onChanged: (int v) => setState(() {
                line.month = v;
                final max = DateTime.utc(2024, v + 1, 0).day;
                if (line.day > max) line.day = max;
              }),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 2,
          child: _dropdown<int>(
            fieldKey: Key('setup-${line.id}-day'),
            label: l10n.formDayOfMonth,
            value: line.day.clamp(1, maxDay),
            items: <int, String>{for (var d = 1; d <= maxDay; d++) d: '$d'},
            onChanged: (int v) => setState(() => line.day = v),
          ),
        ),
      ],
    );
  }

  Widget _lineCard(
    AppLocalizations l10n,
    _Line line,
    List<IncomeSource> existing,
  ) {
    final preset = line.preset;
    final duplicates = line.checked
        ? findDuplicateNames(existing, <String>[line.name.text])
        : const <String>{};
    final askDate =
        line.kind == _LineKind.custom || (preset?.needsDate ?? false);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  key: Key('setup-${line.id}-check'),
                  value: line.checked,
                  onChanged: (bool? v) =>
                      setState(() => line.checked = v ?? false),
                ),
                Expanded(
                  child: TextFormField(
                    key: Key('setup-${line.id}-name'),
                    controller: line.name,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: l10n.formName),
                    onChanged: (_) => setState(() {}),
                    validator: (String? v) =>
                        line.checked && (v == null || v.trim().isEmpty)
                        ? l10n.errorNameRequired
                        : null,
                  ),
                ),
                if (line.kind == _LineKind.custom)
                  IconButton(
                    key: Key('setup-${line.id}-remove'),
                    tooltip: l10n.setupRemoveLine,
                    onPressed: () => _removeLine(line),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            if (preset != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Chip(
                      key: Key('setup-${line.id}-suggested'),
                      label: Text(l10n.setupSuggested),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (preset.schedule != null)
                      Text(
                        scheduleSummary(l10n, preset.schedule!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            TextFormField(
              key: Key('setup-${line.id}-amount'),
              controller: line.amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.formAmount,
                suffixText: _currencyCode,
                helperText: preset == null
                    ? null
                    : _hint(l10n, preset.amountHint),
                helperMaxLines: 3,
              ),
              onChanged: (String v) {
                // Typing an amount means the user wants the line.
                if (v.trim().isNotEmpty && !line.checked) {
                  setState(() => line.checked = true);
                }
              },
              validator: (String? v) => line.checked
                  ? validateMoneyText(l10n, _parser, v, requirePositive: true)
                  : null,
            ),
            if (line.kind == _LineKind.main) ...<Widget>[
              const SizedBox(height: 12),
              _dayPickers(l10n, line, both: false),
            ],
            if (askDate) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                l10n.setupLeaveDate,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              _dayPickers(l10n, line, both: true),
            ],
            for (final name in duplicates)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.setupDuplicateWarning(name),
                  key: Key('setup-${line.id}-duplicate'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Rebuild when the primary currency has loaded.
    ref.watch(primaryCurrencyProvider);
    final existing = ref.watch(incomeSourcesProvider).value ?? <IncomeSource>[];
    final extras = _lines.where((l) => l.kind != _LineKind.main).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(l10n.setupIntro),
              const SizedBox(height: 16),
              Text(
                l10n.setupProfileLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SegmentedButton<WorkerProfile>(
                key: const Key('setup-profile'),
                showSelectedIcon: false,
                segments: <ButtonSegment<WorkerProfile>>[
                  ButtonSegment<WorkerProfile>(
                    value: WorkerProfile.employee,
                    label: Text(l10n.profileEmployee),
                  ),
                  ButtonSegment<WorkerProfile>(
                    value: WorkerProfile.freelancer,
                    label: Text(l10n.profileFreelancer),
                  ),
                  ButtonSegment<WorkerProfile>(
                    value: WorkerProfile.sideHustle,
                    label: Text(l10n.profileSideHustle),
                  ),
                ],
                selected: <WorkerProfile>{_profile},
                onSelectionChanged: (Set<WorkerProfile> s) =>
                    _selectProfile(s.first),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.setupMainSection,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _lineCard(l10n, _lines.first, existing),
              const SizedBox(height: 8),
              Text(
                l10n.setupExtraSection,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (_profile == WorkerProfile.employee) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  l10n.setupPrivateSectorNote,
                  key: const Key('setup-private-note'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              for (final line in extras) _lineCard(l10n, line, existing),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('setup-add-yearly'),
                  onPressed: _addCustomLine,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.setupAddYearly),
                ),
              ),
              if (_profile == WorkerProfile.employee) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  l10n.setupLastVerified(_pack.lastVerified.toUtcDateTime()),
                  key: const Key('setup-last-verified'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('setup-finish'),
                onPressed: _saving ? null : _finish,
                child: Text(l10n.setupFinish),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('setup-skip'),
                onPressed: _saving ? null : _skip,
                child: Text(l10n.setupSkip),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
