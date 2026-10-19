import 'package:flutter/material.dart';
import 'package:simple_budgeting_app/features/settings/domain/common_currencies.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/set_primary_currency.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

const String _otherValue = 'other';

/// Picks a currency from [options] (default: the common ISO 4217 codes). With
/// [allowOther] the user can also type any 3-letter code. [value] is always
/// listed, even when it is not one of the options.
class CurrencyDropdown extends StatelessWidget {
  const CurrencyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = commonCurrencyCodes,
    this.allowOther = true,
    this.label,
    this.fieldKey = const Key('currency-dropdown'),
  });

  final String value;
  final ValueChanged<String> onChanged;
  final List<String> options;
  final bool allowOther;
  final String? label;

  /// The key of the dropdown itself; give each one a different key when a
  /// form has more than one.
  final Key fieldKey;

  Future<void> _onSelected(BuildContext context, String? selected) async {
    if (selected == null || selected == value) return;
    if (selected != _otherValue) {
      onChanged(selected);
      return;
    }
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _OtherCurrencyDialog(),
    );
    if (code != null) onChanged(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final codes = <String>[...options];
    if (!codes.contains(value)) codes.insert(0, value);
    return InputDecorator(
      decoration: InputDecoration(labelText: label ?? l10n.formCurrency),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: fieldKey,
          value: value,
          isDense: true,
          isExpanded: true,
          items: <DropdownMenuItem<String>>[
            for (final code in codes)
              DropdownMenuItem<String>(value: code, child: Text(code)),
            if (allowOther)
              DropdownMenuItem<String>(
                value: _otherValue,
                child: Text(l10n.currencyOther),
              ),
          ],
          onChanged: (String? selected) => _onSelected(context, selected),
        ),
      ),
    );
  }
}

class _OtherCurrencyDialog extends StatefulWidget {
  const _OtherCurrencyDialog();

  @override
  State<_OtherCurrencyDialog> createState() => _OtherCurrencyDialogState();
}

class _OtherCurrencyDialogState extends State<_OtherCurrencyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(normalizeCurrencyCode(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.currencyOtherTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('currency-other-field'),
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: l10n.currencyOtherField),
          validator: (String? text) => normalizeCurrencyCode(text ?? '') == null
              ? l10n.currencyInvalid
              : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('currency-other-save'),
          onPressed: _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
