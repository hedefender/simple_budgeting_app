import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money_parser.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/usecases/income_validation.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_dialogs.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_labels.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_providers.dart';
import 'package:simple_budgeting_app/features/income/presentation/money_input.dart';
import 'package:simple_budgeting_app/features/settings/presentation/currency_dropdown.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_providers.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

enum _ScheduleKind { oneOff, monthly, several, weekly, yearly }

/// Where a yearly payment sits: a fixed date, Holy Wednesday, or another
/// offset from Orthodox Easter (kept as it is when an existing source has one).
enum _YearlyAnchorKind { fixed, holyWednesday, easterOffset }

enum _RuleKind { day, last, nth }

/// A day rule being edited. [value] is the day (1-31) or the working day
/// number, and unused for the last day.
class _RuleDraft {
  _RuleDraft(this.kind, this.value);

  _RuleKind kind;
  int value;

  factory _RuleDraft.from(DayRule rule) => switch (rule) {
    DayOfMonth(:final day) => _RuleDraft(_RuleKind.day, day),
    LastDay() => _RuleDraft(_RuleKind.last, 1),
    NthWorkingDay(:final n) => _RuleDraft(_RuleKind.nth, n),
  };

  DayRule toRule() => switch (kind) {
    _RuleKind.day => DayOfMonth(value),
    _RuleKind.last => const LastDay(),
    _RuleKind.nth => NthWorkingDay(value),
  };

  /// Two drafts are the same payment day.
  bool sameAs(_RuleDraft other) =>
      kind == other.kind && (kind == _RuleKind.last || value == other.value);
}

/// Add or edit an income source. [source] is null when adding.
class IncomeSourceFormPage extends ConsumerStatefulWidget {
  const IncomeSourceFormPage({super.key, this.source});

  final IncomeSource? source;

  @override
  ConsumerState<IncomeSourceFormPage> createState() =>
      _IncomeSourceFormPageState();
}

const int _maxRules = 6;

class _IncomeSourceFormPageState extends ConsumerState<IncomeSourceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late IncomeType _type;
  late _ScheduleKind _kind;
  late List<_RuleDraft> _rules;
  late int _weekday;
  late ShiftRule _shift;
  late int _yearMonth;
  late int _yearDay;
  _YearlyAnchorKind _anchorKind = _YearlyAnchorKind.fixed;
  int _easterOffset = EasterRelative.holyWednesdayOffset;
  late CalendarDate _oneOffDate;
  late CalendarDate _startDate;
  CalendarDate? _endDate;
  bool _showEndError = false;
  bool _showDuplicateError = false;
  bool _saving = false;

  IncomeSource? get _source => widget.source;

  /// Chosen by the user for a new source; null until then.
  String? _pickedCurrency;

  /// Existing source: fixed. New source: the picked one, else the primary
  /// currency (the device currency while that is still loading).
  String get _currencyCode =>
      _source?.currencyCode ??
      _pickedCurrency ??
      ref.read(primaryCurrencyProvider).value ??
      ref.read(moneyFormatterProvider).currencyCode;

  MoneyParser get _parser => MoneyParser.forCurrency(
    localeTag: ref.read(deviceLocaleProvider).toString(),
    currencyCode: _currencyCode,
  );

  @override
  void initState() {
    super.initState();
    final source = _source;
    final today = ref.read(todayProvider);
    _name = TextEditingController(text: source?.name ?? '');
    _type = source?.type ?? IncomeType.salary;
    _startDate = source?.startDate ?? today;
    _endDate = source?.endDate;
    _oneOffDate = today;
    _rules = <_RuleDraft>[_RuleDraft(_RuleKind.day, today.day)];
    _weekday = today.weekday;
    _yearMonth = today.month;
    _yearDay = today.day;
    _shift = ShiftRule.previousWorkingDay;
    _kind = _ScheduleKind.monthly;
    switch (source?.schedule) {
      case OneOff(:final date):
        _kind = _ScheduleKind.oneOff;
        _oneOffDate = date;
      case Monthly(:final rule, :final shift):
        _rules = <_RuleDraft>[_RuleDraft.from(rule)];
        _shift = shift;
      case SeveralPerMonth(:final rules, :final shift):
        _kind = _ScheduleKind.several;
        _rules = rules.map(_RuleDraft.from).toList();
        _shift = shift;
      case Weekly(:final weekday, :final shift):
        _kind = _ScheduleKind.weekly;
        _weekday = weekday;
        _shift = shift;
      case Yearly(:final anchor, :final shift):
        _kind = _ScheduleKind.yearly;
        _shift = shift;
        switch (anchor) {
          case FixedDate(:final month, :final day):
            _yearMonth = month;
            _yearDay = day;
          case EasterRelative(:final offsetDays):
            _easterOffset = offsetDays;
            _anchorKind = offsetDays == EasterRelative.holyWednesdayOffset
                ? _YearlyAnchorKind.holyWednesday
                : _YearlyAnchorKind.easterOffset;
        }
      case null:
        break;
    }
    _amount = TextEditingController();
    if (source != null) {
      final locale = ref.read(deviceLocaleProvider).toString();
      final digits = MoneyParser.forCurrency(
        localeTag: locale,
        currencyCode: source.currencyCode,
      ).decimalDigits;
      _amount.text = formatMoneyForInput(
        source.amount,
        localeTag: locale,
        decimalDigits: digits,
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  IncomeSchedule get _schedule => switch (_kind) {
    _ScheduleKind.oneOff => OneOff(_oneOffDate),
    _ScheduleKind.monthly => Monthly(_rules.first.toRule(), shift: _shift),
    _ScheduleKind.several => SeveralPerMonth(
      _rules.map((r) => r.toRule()).toList(),
      shift: _shift,
    ),
    _ScheduleKind.weekly => Weekly(_weekday, shift: _shift),
    _ScheduleKind.yearly => Yearly(
      _anchorKind == _YearlyAnchorKind.fixed
          ? FixedDate(_yearMonth, _yearDay)
          : EasterRelative(_easterOffset),
      shift: _shift,
    ),
  };

  bool get _hasEndDate => _kind != _ScheduleKind.oneOff;

  /// The shift rule does not apply when every rule is a Nth working day.
  bool get _showShift => switch (_kind) {
    _ScheduleKind.oneOff => false,
    _ScheduleKind.weekly || _ScheduleKind.yearly => true,
    _ScheduleKind.monthly ||
    _ScheduleKind.several => _rules.any((r) => r.kind != _RuleKind.nth),
  };

  bool get _hasDuplicateRules {
    if (_kind != _ScheduleKind.several) return false;
    for (var i = 0; i < _rules.length; i++) {
      for (var j = i + 1; j < _rules.length; j++) {
        if (_rules[i].sameAs(_rules[j])) return true;
      }
    }
    return false;
  }

  void _selectKind(_ScheduleKind kind) {
    setState(() {
      if (kind == _ScheduleKind.several && _rules.length < 2) {
        final first = _rules.first;
        final other = first.kind == _RuleKind.day && first.value == 15 ? 1 : 15;
        _rules.add(_RuleDraft(_RuleKind.day, other));
      } else if (kind == _ScheduleKind.monthly && _rules.length > 1) {
        _rules = <_RuleDraft>[_rules.first];
      }
      _showDuplicateError = false;
      _kind = kind;
    });
  }

  Future<void> _pick(
    CalendarDate current,
    void Function(CalendarDate) set,
  ) async {
    final picked = await pickCalendarDate(context, current);
    if (picked != null) setState(() => set(picked));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final endBeforeStart =
        _hasEndDate && _endDate != null && _endDate!.isBefore(_startDate);
    final duplicates = _hasDuplicateRules;
    setState(() {
      _showEndError = endBeforeStart;
      _showDuplicateError = duplicates;
    });
    if (!_formKey.currentState!.validate() || endBeforeStart || duplicates) {
      return;
    }

    final amount = tryParseMoney(_parser, _amount.text);
    if (amount == null) return;
    setState(() => _saving = true);
    final actions = ref.read(incomeActionsProvider);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final source = _source;
      if (source == null) {
        await actions.createSource(
          name: _name.text,
          type: _type,
          amount: amount,
          currencyCode: _currencyCode,
          schedule: _schedule,
          startDate: _startDate,
          endDate: _hasEndDate ? _endDate : null,
        );
      } else {
        await actions.updateSource(
          sourceId: source.id,
          name: _name.text,
          type: _type,
          amount: amount,
          schedule: _schedule,
          startDate: _startDate,
          endDate: _hasEndDate ? _endDate : null,
        );
      }
      navigator.pop();
    } on IncomeValidationException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          key: const Key('income-validation-error'),
          content: Text(incomeValidationMessage(l10n, e.error)),
        ),
      );
    }
  }

  Future<void> _archive() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.archiveConfirmTitle),
        content: Text(l10n.archiveConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('archive-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionArchive),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    await ref.read(incomeActionsProvider).archiveSource(_source!.id);
    navigator.pop();
  }

  /// A controlled dropdown (it always shows [value], also after the list of
  /// rules changes).
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

  /// A rule that no other rule uses yet, for the "add" button.
  _RuleDraft _nextFreeRule() {
    for (final day in <int>[1, 15, 10, 20, 5, 25]) {
      final draft = _RuleDraft(_RuleKind.day, day);
      if (!_rules.any(draft.sameAs)) return draft;
    }
    return _RuleDraft(_RuleKind.last, 1);
  }

  Widget _ruleEditor(AppLocalizations l10n, int index) {
    final rule = _rules[index];
    final several = _kind == _ScheduleKind.several;
    final maxValue = rule.kind == _RuleKind.day
        ? 31
        : (rule.value > 20 ? rule.value : 20);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: _dropdown<_RuleKind>(
              fieldKey: Key('income-rule-type-$index'),
              label: several
                  ? l10n.formPaymentDay(index + 1)
                  : l10n.formDayOfMonth,
              value: rule.kind,
              items: <_RuleKind, String>{
                _RuleKind.day: l10n.ruleTypeDay,
                _RuleKind.last: l10n.ruleTypeLast,
                _RuleKind.nth: l10n.ruleTypeNth,
              },
              onChanged: (_RuleKind v) => setState(() {
                rule.kind = v;
                if (v == _RuleKind.day && rule.value > 31) rule.value = 31;
                _showDuplicateError = false;
              }),
            ),
          ),
          if (rule.kind != _RuleKind.last) ...<Widget>[
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _dropdown<int>(
                fieldKey: Key('income-rule-value-$index'),
                label: rule.kind == _RuleKind.day
                    ? l10n.formDayOfMonth
                    : l10n.formWorkingDayNumber,
                value: rule.value.clamp(1, maxValue),
                items: <int, String>{
                  for (var v = 1; v <= maxValue; v++) v: '$v',
                },
                onChanged: (int v) => setState(() {
                  rule.value = v;
                  _showDuplicateError = false;
                }),
              ),
            ),
          ],
          if (several && _rules.length > 2)
            IconButton(
              key: Key('income-rule-remove-$index'),
              tooltip: l10n.formRemoveRule,
              onPressed: () => setState(() {
                _rules.removeAt(index);
                _showDuplicateError = false;
              }),
              icon: const Icon(Icons.remove_circle_outline),
            ),
        ],
      ),
    );
  }

  List<Widget> _yearlyEditor(AppLocalizations l10n) {
    final localeTag = Localizations.localeOf(context).toString();
    final maxDay = DateTime.utc(2024, _yearMonth + 1, 0).day;
    return <Widget>[
      _dropdown<_YearlyAnchorKind>(
        fieldKey: const Key('income-yearly-anchor'),
        label: l10n.formYearlyAnchor,
        value: _anchorKind,
        items: <_YearlyAnchorKind, String>{
          _YearlyAnchorKind.fixed: l10n.yearlyAnchorFixed,
          _YearlyAnchorKind.holyWednesday: l10n.yearlyAnchorHolyWednesday,
          if (_anchorKind == _YearlyAnchorKind.easterOffset ||
              _easterOffset != EasterRelative.holyWednesdayOffset)
            _YearlyAnchorKind.easterOffset: l10n.yearlyAnchorEasterOffset(
              signedDays(_easterOffset),
            ),
        },
        onChanged: (_YearlyAnchorKind v) => setState(() {
          _anchorKind = v;
          if (v == _YearlyAnchorKind.holyWednesday) {
            _easterOffset = EasterRelative.holyWednesdayOffset;
          }
        }),
      ),
      if (_anchorKind == _YearlyAnchorKind.fixed) ...<Widget>[
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: _dropdown<int>(
                fieldKey: const Key('income-yearly-month'),
                label: l10n.formMonth,
                value: _yearMonth,
                items: <int, String>{
                  for (var m = 1; m <= 12; m++)
                    m: DateFormat.MMMM(localeTag).format(DateTime.utc(2024, m)),
                },
                onChanged: (int v) => setState(() {
                  _yearMonth = v;
                  final max = DateTime.utc(2024, v + 1, 0).day;
                  if (_yearDay > max) _yearDay = max;
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _dropdown<int>(
                fieldKey: const Key('income-yearly-day'),
                label: l10n.formDayOfMonth,
                value: _yearDay.clamp(1, maxDay),
                items: <int, String>{for (var d = 1; d <= maxDay; d++) d: '$d'},
                onChanged: (int v) => setState(() => _yearDay = v),
              ),
            ),
          ],
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the primary currency has loaded.
    ref.watch(primaryCurrencyProvider);
    final l10n = AppLocalizations.of(context);
    final dateFormat = MaterialLocalizations.of(context);
    String fmt(CalendarDate d) =>
        dateFormat.formatMediumDate(d.toUtcDateTime());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _source == null ? l10n.incomeAddSource : l10n.incomeEditSource,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              key: const Key('income-name'),
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.formName),
              validator: (String? v) => (v == null || v.trim().isEmpty)
                  ? l10n.errorNameRequired
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IncomeType>(
              key: const Key('income-type'),
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.formType),
              items: <DropdownMenuItem<IncomeType>>[
                for (final type in IncomeType.values)
                  DropdownMenuItem<IncomeType>(
                    value: type,
                    child: Text(incomeTypeLabel(l10n, type)),
                  ),
              ],
              onChanged: (IncomeType? v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 16),
            if (_source == null)
              CurrencyDropdown(
                value: _currencyCode,
                onChanged: (String code) =>
                    setState(() => _pickedCurrency = code),
              )
            else
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.formCurrency,
                  helperText: l10n.formCurrencyLocked,
                  helperMaxLines: 3,
                ),
                child: Text(
                  _currencyCode,
                  key: const Key('income-currency-locked'),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('income-amount'),
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.formAmount,
                suffixText: _currencyCode,
              ),
              validator: (String? v) =>
                  validateMoneyText(l10n, _parser, v, requirePositive: true),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.formSchedule,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<_ScheduleKind>(
              key: const Key('income-schedule-kind'),
              showSelectedIcon: false,
              segments: <ButtonSegment<_ScheduleKind>>[
                ButtonSegment<_ScheduleKind>(
                  value: _ScheduleKind.oneOff,
                  label: Text(l10n.scheduleOneOff),
                ),
                ButtonSegment<_ScheduleKind>(
                  value: _ScheduleKind.monthly,
                  label: Text(l10n.scheduleMonthly),
                ),
                ButtonSegment<_ScheduleKind>(
                  value: _ScheduleKind.several,
                  label: Text(l10n.scheduleSeveral),
                ),
                ButtonSegment<_ScheduleKind>(
                  value: _ScheduleKind.weekly,
                  label: Text(l10n.scheduleWeekly),
                ),
                ButtonSegment<_ScheduleKind>(
                  value: _ScheduleKind.yearly,
                  label: Text(l10n.scheduleYearly),
                ),
              ],
              selected: <_ScheduleKind>{_kind},
              onSelectionChanged: (Set<_ScheduleKind> s) =>
                  _selectKind(s.first),
            ),
            const SizedBox(height: 16),
            if (_kind == _ScheduleKind.oneOff)
              OutlinedButton.icon(
                key: const Key('income-date'),
                onPressed: () => _pick(_oneOffDate, (d) => _oneOffDate = d),
                icon: const Icon(Icons.event_outlined),
                label: Text('${l10n.formDate}: ${fmt(_oneOffDate)}'),
              )
            else ...<Widget>[
              if (_kind == _ScheduleKind.weekly)
                _dropdown<int>(
                  fieldKey: const Key('income-weekday'),
                  label: l10n.formWeekday,
                  value: _weekday,
                  items: <int, String>{
                    for (var d = 1; d <= 7; d++)
                      d: DateFormat.EEEE(
                        Localizations.localeOf(context).toString(),
                      ).format(weekdayDate(d)),
                  },
                  onChanged: (int v) => setState(() => _weekday = v),
                )
              else if (_kind == _ScheduleKind.yearly)
                ..._yearlyEditor(l10n)
              else ...<Widget>[
                for (var i = 0; i < _rules.length; i++) _ruleEditor(l10n, i),
                if (_kind == _ScheduleKind.several) ...<Widget>[
                  if (_rules.length < _maxRules)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: const Key('income-rule-add'),
                        onPressed: () => setState(() {
                          _showDuplicateError = false;
                          _rules.add(_nextFreeRule());
                        }),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.formAddRule),
                      ),
                    ),
                  if (_showDuplicateError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l10n.errorDuplicateRules,
                        key: const Key('income-duplicate-error'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ],
              if (_showShift) ...<Widget>[
                const SizedBox(height: 16),
                _dropdown<ShiftRule>(
                  fieldKey: const Key('income-shift'),
                  label: l10n.formShift,
                  value: _shift,
                  items: <ShiftRule, String>{
                    for (final shift in ShiftRule.values)
                      shift: shiftRuleLabel(l10n, shift),
                  },
                  onChanged: (ShiftRule v) => setState(() => _shift = v),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('income-start-date'),
                onPressed: () => _pick(_startDate, (d) => _startDate = d),
                icon: const Icon(Icons.event_outlined),
                label: Text('${l10n.formStartDate}: ${fmt(_startDate)}'),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('income-end-date'),
                      onPressed: () =>
                          _pick(_endDate ?? _startDate, (d) => _endDate = d),
                      icon: const Icon(Icons.event_busy_outlined),
                      label: Text(
                        '${l10n.formEndDate}: '
                        '${_endDate == null ? l10n.formNoEndDate : fmt(_endDate!)}',
                      ),
                    ),
                  ),
                  if (_endDate != null)
                    IconButton(
                      key: const Key('income-clear-end-date'),
                      tooltip: l10n.formClearEndDate,
                      onPressed: () => setState(() => _endDate = null),
                      icon: const Icon(Icons.clear),
                    ),
                ],
              ),
              if (_showEndError)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.errorEndBeforeStart,
                    key: const Key('income-end-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('income-save'),
              onPressed: _saving ? null : _save,
              child: Text(l10n.actionSave),
            ),
            if (_source != null && !_source!.isArchived) ...<Widget>[
              const SizedBox(height: 8),
              TextButton.icon(
                key: const Key('income-archive'),
                onPressed: _archive,
                icon: const Icon(Icons.archive_outlined),
                label: Text(l10n.actionArchive),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
