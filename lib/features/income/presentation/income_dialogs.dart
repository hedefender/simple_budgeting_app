import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/money/money_parser.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/presentation/money_input.dart';
import 'package:simple_budgeting_app/features/settings/presentation/currency_dropdown.dart';
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

typedef PaymentChange = ({Money amount, CalendarDate date});

/// Asks for a new amount and/or paid date for one payment. Returns null when
/// cancelled. [date] is the day the payment is paid now.
Future<PaymentChange?> showChangePaymentDialog(
  BuildContext context,
  WidgetRef ref, {
  required String currencyCode,
  required Money initial,
  required CalendarDate date,
}) {
  return showDialog<PaymentChange>(
    context: context,
    builder: (_) => _PaymentDialog(
      parser: _parserFor(ref, currencyCode),
      localeTag: ref.read(deviceLocaleProvider).toString(),
      initial: initial,
      date: date,
    ),
  );
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.parser,
    required this.localeTag,
    required this.initial,
    required this.date,
  });

  final MoneyParser parser;
  final String localeTag;
  final Money initial;
  final CalendarDate date;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: formatMoneyForInput(
      widget.initial,
      localeTag: widget.localeTag,
      decimalDigits: widget.parser.decimalDigits,
    ),
  );
  late CalendarDate _date = widget.date;

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
    final amount = tryParseMoney(widget.parser, _controller.text);
    if (amount == null) return;
    Navigator.of(context).pop((amount: amount, date: _date));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.amountDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              key: const Key('money-dialog-field'),
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.amountDialogField),
              validator: (String? text) => validateMoneyText(
                l10n,
                widget.parser,
                text,
                requirePositive: true,
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('payment-date'),
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(
                '${l10n.occurrenceDateLabel}: '
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
          key: const Key('money-dialog-save'),
          onPressed: _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

typedef BalanceInput = ({
  CalendarDate date,
  Money balance,
  String currencyCode,
});

/// Asks for the balance at the END of a day, in one currency. Returns null
/// when cancelled. [currencyCode] is the initial choice; with more than one
/// entry in [currencyCodes] the user can switch between them.
Future<BalanceInput?> showBalanceDialog(
  BuildContext context,
  WidgetRef ref, {
  required String currencyCode,
  List<String> currencyCodes = const <String>[],
  required CalendarDate today,
}) {
  return showDialog<BalanceInput>(
    context: context,
    builder: (_) => _BalanceDialog(
      localeTag: ref.read(deviceLocaleProvider).toString(),
      currencyCode: currencyCode,
      currencyCodes: <String>{currencyCode, ...currencyCodes}.toList(),
      today: today,
    ),
  );
}

class _BalanceDialog extends StatefulWidget {
  const _BalanceDialog({
    required this.localeTag,
    required this.currencyCode,
    required this.currencyCodes,
    required this.today,
  });

  final String localeTag;
  final String currencyCode;
  final List<String> currencyCodes;
  final CalendarDate today;

  @override
  State<_BalanceDialog> createState() => _BalanceDialogState();
}

class _BalanceDialogState extends State<_BalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  late CalendarDate _date = widget.today;
  late String _currency = widget.currencyCode;

  MoneyParser get _parser => MoneyParser.forCurrency(
    localeTag: widget.localeTag,
    currencyCode: _currency,
    allowNegative: true,
  );

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
    final balance = tryParseMoney(_parser, _controller.text);
    if (balance == null) return;
    Navigator.of(
      context,
    ).pop((date: _date, balance: balance, currencyCode: _currency));
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
            if (widget.currencyCodes.length > 1) ...<Widget>[
              CurrencyDropdown(
                value: _currency,
                options: widget.currencyCodes,
                allowOther: false,
                onChanged: (String code) => setState(() => _currency = code),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              key: const Key('balance-field'),
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.balanceDialogAmount,
                suffixText: _currency,
              ),
              validator: (String? text) => validateMoneyText(
                l10n,
                _parser,
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
