import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/money/money_parser.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/presentation/money_input.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

MoneyParser _parserFor(
  WidgetRef ref,
  String currencyCode, {
  bool allowNegative = false,
}) {
  return MoneyParser.forCurrency(
    localeTag: ref.read(deviceLocaleProvider).toString(),
    currencyCode: currencyCode,
    allowNegative: allowNegative,
  );
}

/// Date picker that works with [CalendarDate]. The picker's result is read
/// field by field, so no time zone can shift the chosen day.
Future<CalendarDate?> pickCalendarDate(
  BuildContext context,
  CalendarDate initial,
) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime(initial.year, initial.month, initial.day),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (picked == null) return null;
  return CalendarDate(picked.year, picked.month, picked.day);
}

/// Asks for a new amount for one payment. Returns null when cancelled.
Future<Money?> showChangeAmountDialog(
  BuildContext context,
  WidgetRef ref, {
  required String currencyCode,
  required Money initial,
}) {
  final parser = _parserFor(ref, currencyCode);
  return showDialog<Money>(
    context: context,
    builder: (_) => _MoneyDialog(
      title: AppLocalizations.of(context).amountDialogTitle,
      fieldLabel: AppLocalizations.of(context).amountDialogField,
      parser: parser,
      localeTag: ref.read(deviceLocaleProvider).toString(),
      initial: initial,
      requirePositive: true,
    ),
  );
}

class _MoneyDialog extends StatefulWidget {
  const _MoneyDialog({
    required this.title,
    required this.fieldLabel,
    required this.parser,
    required this.localeTag,
    required this.requirePositive,
    this.initial,
  });

  final String title;
  final String fieldLabel;
  final MoneyParser parser;
  final String localeTag;
  final bool requirePositive;
  final Money? initial;

  @override
  State<_MoneyDialog> createState() => _MoneyDialogState();
}

class _MoneyDialogState extends State<_MoneyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial == null
        ? ''
        : formatMoneyForInput(
            widget.initial!,
            localeTag: widget.localeTag,
            decimalDigits: widget.parser.decimalDigits,
          ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(tryParseMoney(widget.parser, _controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('money-dialog-field'),
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          decoration: InputDecoration(labelText: widget.fieldLabel),
          validator: (String? text) => validateMoneyText(
            l10n,
            widget.parser,
            text,
            requirePositive: widget.requirePositive,
          ),
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('money-dialog-save'),
          onPressed: _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

typedef BalanceInput = ({CalendarDate date, Money balance});

/// Asks for the balance at the END of a day. Returns null when cancelled.
Future<BalanceInput?> showBalanceDialog(
  BuildContext context,
  WidgetRef ref, {
  required String currencyCode,
  required CalendarDate today,
}) {
  return showDialog<BalanceInput>(
    context: context,
    builder: (_) => _BalanceDialog(
      parser: _parserFor(ref, currencyCode, allowNegative: true),
      today: today,
    ),
  );
}

class _BalanceDialog extends StatefulWidget {
  const _BalanceDialog({required this.parser, required this.today});

  final MoneyParser parser;
  final CalendarDate today;

  @override
  State<_BalanceDialog> createState() => _BalanceDialogState();
}

class _BalanceDialogState extends State<_BalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  late CalendarDate _date = widget.today;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await pickCalendarDate(context, _date);
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final balance = tryParseMoney(widget.parser, _controller.text);
    if (balance == null) return;
    Navigator.of(context).pop((date: _date, balance: balance));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.balanceDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.balanceDialogHelp),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('balance-field'),
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(labelText: l10n.balanceDialogAmount),
              validator: (String? text) => validateMoneyText(
                l10n,
                widget.parser,
                text,
                requirePositive: false,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('balance-date'),
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(
                '${l10n.balanceDialogDate}: '
                '${MaterialLocalizations.of(context).formatMediumDate(_date.toUtcDateTime())}',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('balance-save'),
          onPressed: _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
