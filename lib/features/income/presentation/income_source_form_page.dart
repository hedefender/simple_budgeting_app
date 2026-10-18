import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

enum _ScheduleKind { oneOff, monthly }

/// Add or edit an income source. [source] is null when adding.
class IncomeSourceFormPage extends ConsumerStatefulWidget {
  const IncomeSourceFormPage({super.key, this.source});

  final IncomeSource? source;

  @override
  ConsumerState<IncomeSourceFormPage> createState() =>
      _IncomeSourceFormPageState();
}

/// Value of the day-of-month dropdown that means "last day".
const int _lastDayValue = 0;

class _IncomeSourceFormPageState extends ConsumerState<IncomeSourceFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late IncomeType _type;
  late _ScheduleKind _kind;
  late int _day;
  late CalendarDate _oneOffDate;
  late CalendarDate _startDate;
  CalendarDate? _endDate;
  bool _showEndError = false;
  bool _saving = false;

  IncomeSource? get _source => widget.source;

  String get _currencyCode =>
      _source?.currencyCode ?? ref.read(moneyFormatterProvider).currencyCode;

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
    _day = today.day;
    _kind = _ScheduleKind.monthly;
    switch (source?.schedule) {
      case OneOff(:final date):
        _kind = _ScheduleKind.oneOff;
        _oneOffDate = date;
      case Monthly(:final dayOfMonth):
        _day = dayOfMonth ?? _lastDayValue;
      case SeveralPerMonth() || Weekly():
        // Phase 1b stage 2 adds the form; no UI can create these yet.
        throw UnimplementedError('Phase 1b stage 2');
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
    _ScheduleKind.monthly =>
      _day == _lastDayValue ? const Monthly.onLastDay() : Monthly.onDay(_day),
  };

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
        _kind == _ScheduleKind.monthly &&
        _endDate != null &&
        _endDate!.isBefore(_startDate);
    setState(() => _showEndError = endBeforeStart);
    if (!_formKey.currentState!.validate() || endBeforeStart) return;

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
          endDate: _kind == _ScheduleKind.monthly ? _endDate : null,
        );
      } else {
        await actions.updateSource(
          sourceId: source.id,
          name: _name.text,
          type: _type,
          amount: amount,
          schedule: _schedule,
          startDate: _startDate,
          endDate: _kind == _ScheduleKind.monthly ? _endDate : null,
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

  @override
  Widget build(BuildContext context) {
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
              segments: <ButtonSegment<_ScheduleKind>>[
                ButtonSegment<_ScheduleKind>(
                  value: _ScheduleKind.oneOff,
                  label: Text(l10n.scheduleOneOff),
                ),
                ButtonSegment<_ScheduleKind>(
                  value: _ScheduleKind.monthly,
                  label: Text(l10n.scheduleMonthly),
                ),
              ],
              selected: <_ScheduleKind>{_kind},
              onSelectionChanged: (Set<_ScheduleKind> s) =>
                  setState(() => _kind = s.first),
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
              DropdownButtonFormField<int>(
                key: const Key('income-day'),
                initialValue: _day,
                decoration: InputDecoration(labelText: l10n.formDayOfMonth),
                items: <DropdownMenuItem<int>>[
                  for (var d = 1; d <= 31; d++)
                    DropdownMenuItem<int>(value: d, child: Text('$d')),
                  DropdownMenuItem<int>(
                    value: _lastDayValue,
                    child: Text(l10n.formLastDay),
                  ),
                ],
                onChanged: (int? v) => setState(() => _day = v ?? _day),
              ),
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
