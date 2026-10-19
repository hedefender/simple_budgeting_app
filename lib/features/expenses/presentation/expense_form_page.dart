import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/money/money_parser.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_category.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_labels.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_providers.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_start.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_dialogs.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_providers.dart';
import 'package:simple_budgeting_app/features/income/presentation/money_input.dart';
import 'package:simple_budgeting_app/features/settings/domain/common_currencies.dart';
import 'package:simple_budgeting_app/features/settings/presentation/currency_dropdown.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_providers.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// Add or edit an expense. [expense] is null when adding.
///
/// One total and one category. The amount charged is in the currency of the
/// account; the original amount and the VAT/taxes are informational. With only
/// an original amount the expense is saved as "awaiting amount".
class ExpenseFormPage extends ConsumerStatefulWidget {
  const ExpenseFormPage({super.key, this.expense});

  final Expense? expense;

  @override
  ConsumerState<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends ConsumerState<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late final TextEditingController _originalAmount;
  late final TextEditingController _tax;
  late CalendarDate _date;
  String? _categoryId;
  String? _pickedCurrency;
  String? _pickedOriginalCurrency;
  bool _showAmountError = false;
  bool _saving = false;

  Expense? get _expense => widget.expense;

  /// Existing expense: its own. New: the picked one, else the primary currency
  /// (the device currency while that is still loading).
  String get _currencyCode =>
      _pickedCurrency ??
      _expense?.currencyCode ??
      ref.read(primaryCurrencyProvider).value ??
      ref.read(moneyFormatterProvider).currencyCode;

  /// The picked one, else the one of the existing expense, else the first
  /// common currency that differs from the account currency.
  String get _originalCurrency =>
      _pickedOriginalCurrency ??
      _expense?.original?.currencyCode ??
      commonCurrencyCodes.firstWhere((c) => c != _currencyCode);

  String get _localeTag => ref.read(deviceLocaleProvider).toString();

  MoneyParser _parserFor(String code) =>
      MoneyParser.forCurrency(localeTag: _localeTag, currencyCode: code);

  @override
  void initState() {
    super.initState();
    final e = _expense;
    _date = e?.date ?? ref.read(todayProvider);
    _categoryId = e?.categoryId;
    _description = TextEditingController(text: e?.description ?? '');
    _amount = TextEditingController();
    _originalAmount = TextEditingController();
    _tax = TextEditingController();
    if (e != null) {
      String input(Money m, String code) => formatMoneyForInput(
        m,
        localeTag: _localeTag,
        decimalDigits: _parserFor(code).decimalDigits,
      );
      if (e.amount != null) _amount.text = input(e.amount!, e.currencyCode);
      if (e.original != null) {
        _originalAmount.text = input(
          e.original!.amount,
          e.original!.currencyCode,
        );
      }
      if (e.tax != null) _tax.text = input(e.tax!, e.currencyCode);
    }
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _originalAmount.dispose();
    _tax.dispose();
    super.dispose();
  }

  bool get _hasAmount => _amount.text.trim().isNotEmpty;

  bool get _hasOriginal => _originalAmount.text.trim().isNotEmpty;

  /// Only an original amount: the expense is saved as awaiting amount.
  bool get _willBePending => !_hasAmount && _hasOriginal;

  Money? _parse(String text, String code) {
    if (text.trim().isEmpty) return null;
    return tryParseMoney(_parserFor(code), text);
  }

  String? _optionalMoneyError(
    AppLocalizations l10n,
    String code,
    String? text,
  ) {
    if (text == null || text.trim().isEmpty) return null;
    return validateMoneyText(
      l10n,
      _parserFor(code),
      text,
      requirePositive: true,
    );
  }

  Future<void> _pickDate() async {
    final picked = await pickCalendarDate(context, _date);
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final neither = !_hasAmount && !_hasOriginal;
    setState(() => _showAmountError = neither);
    if (!_formKey.currentState!.validate() || neither) return;

    final categories = ref.read(expenseCategoriesProvider).value ?? [];
    final categoryId =
        _categoryId ??
        categories
            .firstWhere(
              (c) => c.key == ExpenseCategory.otherKey,
              orElse: () => categories.first,
            )
            .id;
    final account = _currencyCode;
    setState(() => _saving = true);
    final actions = ref.read(expenseActionsProvider);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final original = _hasOriginal ? _originalCurrency : null;
    try {
      final amount = _parse(_amount.text, account);
      final originalAmount = original == null
          ? null
          : _parse(_originalAmount.text, original);
      final tax = _parse(_tax.text, account);
      final expense = _expense;
      if (expense == null) {
        await actions.create(
          categoryId: categoryId,
          date: _date,
          currencyCode: account,
          amount: amount,
          originalAmount: originalAmount,
          originalCurrencyCode: original,
          tax: tax,
          description: _description.text,
        );
      } else {
        await actions.update(
          expenseId: expense.id,
          categoryId: categoryId,
          date: _date,
          currencyCode: account,
          amount: amount,
          originalAmount: originalAmount,
          originalCurrencyCode: original,
          tax: tax,
          description: _description.text,
        );
      }
      navigator.pop();
    } on ExpenseValidationException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          key: const Key('expense-validation-error'),
          content: Text(expenseValidationMessage(l10n, e.error)),
        ),
      );
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.expenseDeleteTitle),
        content: Text(l10n.expenseDeleteBody),
        actions: <Widget>[
          TextButton(
            key: const Key('expense-delete-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('expense-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    await ref.read(expenseActionsProvider).delete(_expense!.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the primary currency, the categories and the known
    // currencies have loaded.
    ref.watch(primaryCurrencyProvider);
    final categories =
        ref.watch(expenseCategoriesProvider).value ?? <ExpenseCategory>[];
    final known = ref.watch(knownCurrenciesProvider).value ?? <String>[];
    final l10n = AppLocalizations.of(context);
    final account = _currencyCode;
    final selectedCategory = categories.any((c) => c.id == _categoryId)
        ? _categoryId
        : categories
              .where((c) => c.key == ExpenseCategory.otherKey)
              .map((c) => c.id)
              .firstOrNull;
    final error = Theme.of(context).colorScheme.error;
    final start = ref.watch(balanceStartProvider(account)).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_expense == null ? l10n.expenseAdd : l10n.expenseEditTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              key: const Key('expense-description'),
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.expenseDescription),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.expensesCategoryLabel,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  key: const Key('expense-category'),
                  value: selectedCategory,
                  isExpanded: true,
                  isDense: true,
                  items: <DropdownMenuItem<String>>[
                    for (final category in categories)
                      DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(categoryLabel(l10n, category)),
                      ),
                  ],
                  onChanged: (String? v) => setState(() => _categoryId = v),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              key: const Key('expense-date'),
              onPressed: _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(
                '${l10n.formDate}: '
                '${MaterialLocalizations.of(context).formatMediumDate(_date.toUtcDateTime())}',
              ),
            ),
            if (start != null && start.isBeforeBalance(_date))
              _BeforeBalanceWarning(
                start: start,
                onUse: () => setState(() => _date = start.firstAffectingDay),
              ),
            const SizedBox(height: 16),
            CurrencyDropdown(
              fieldKey: const Key('expense-currency'),
              label: l10n.expenseAccountCurrency,
              value: account,
              options: known.isEmpty ? <String>[account] : known,
              onChanged: (String code) =>
                  setState(() => _pickedCurrency = code),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('expense-amount'),
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.expenseAmountCharged,
                suffixText: account,
                helperText: l10n.expenseAmountChargedHelp,
                helperMaxLines: 3,
              ),
              onChanged: (_) => setState(() {}),
              validator: (String? v) => _optionalMoneyError(l10n, account, v),
            ),
            if (_showAmountError && !_hasAmount && !_hasOriginal)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.errorExpenseAmountRequired,
                  key: const Key('expense-amount-error'),
                  style: TextStyle(color: error),
                ),
              ),
            if (_willBePending)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Card(
                  key: const Key('expense-pending-notice'),
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(l10n.expensePendingNotice),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ExpansionTile(
              key: const Key('expense-original-section'),
              initiallyExpanded: _expense?.original != null,
              maintainState: true,
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.expenseOriginalSection),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.expenseOriginalHelp,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                CurrencyDropdown(
                  fieldKey: const Key('expense-original-currency'),
                  label: l10n.expenseOriginalCurrency,
                  value: _originalCurrency,
                  onChanged: (String code) =>
                      setState(() => _pickedOriginalCurrency = code),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('expense-original-amount'),
                  controller: _originalAmount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.expenseOriginalAmount,
                    suffixText: _originalCurrency,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (String? v) =>
                      _optionalMoneyError(l10n, _originalCurrency, v),
                ),
              ],
            ),
            ExpansionTile(
              key: const Key('expense-tax-section'),
              initiallyExpanded: _expense?.tax != null,
              maintainState: true,
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.expenseTaxSection),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: <Widget>[
                TextFormField(
                  key: const Key('expense-tax'),
                  controller: _tax,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.expenseTaxAmount,
                    suffixText: account,
                    helperText: l10n.expenseTaxHelp,
                    helperMaxLines: 2,
                  ),
                  validator: (String? v) =>
                      _optionalMoneyError(l10n, account, v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('expense-save'),
              onPressed: _saving ? null : _save,
              child: Text(l10n.actionSave),
            ),
            if (_expense != null) ...<Widget>[
              const SizedBox(height: 8),
              TextButton.icon(
                key: const Key('expense-delete'),
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.actionDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Not blocking: saving is allowed. Computed on every build, never stored.
class _BeforeBalanceWarning extends StatelessWidget {
  const _BeforeBalanceWarning({required this.start, required this.onUse});

  final BalanceStart start;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suggested = start.firstAffectingDay;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        key: const Key('expense-before-start-warning'),
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.expenseBeforeBalanceWarning(
                  start.date.toUtcDateTime(),
                  suggested.toUtcDateTime(),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('expense-use-start-date'),
                  onPressed: onUse,
                  child: Text(
                    l10n.expenseUseBalanceStart(suggested.toUtcDateTime()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
