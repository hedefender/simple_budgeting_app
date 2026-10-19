import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money_formatter.dart';
import 'package:simple_budgeting_app/core/presentation/fab_clearance.dart';
import 'package:simple_budgeting_app/core/presentation/month_selector.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_category.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense_totals.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_form_page.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_labels.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_providers.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_button.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// History of the expenses: a month selector, a category filter, totals per
/// currency and the list. Pending expenses are always listed, marked, and left
/// out of the totals.
class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(expenseMonthProvider);
    final list = ref.watch(expenseListProvider);
    final categories =
        ref.watch(expenseCategoriesProvider).value ?? <ExpenseCategory>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expensesTitle),
        actions: const <Widget>[SettingsButton()],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('expense-add'),
        // The Income tab has a button too and both tabs are alive in the
        // shell: a shared default hero tag breaks every page transition.
        heroTag: 'expense-add-fab',
        tooltip: l10n.expenseAdd,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ExpenseFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, fabListBottomPadding(context)),
        children: <Widget>[
          MonthSelector(
            keyPrefix: 'expense-month',
            month: month,
            onPrevious: ref.read(expenseMonthProvider.notifier).previous,
            onNext: ref.read(expenseMonthProvider.notifier).next,
          ),
          _CategoryFilter(categories: categories),
          const SizedBox(height: 8),
          list.when(
            data: (ExpenseListResult result) => _ExpenseList(
              result: result,
              categories: categories,
              filtered: ref.watch(expenseCategoryFilterProvider) != null,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: <Widget>[
                  Text(
                    l10n.incomeLoadError,
                    key: const Key('expenses-load-error'),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(expenseListProvider),
                    child: Text(l10n.incomeRetry),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  const _CategoryFilter({required this.categories});

  final List<ExpenseCategory> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(expenseCategoryFilterProvider);
    return InputDecorator(
      decoration: InputDecoration(labelText: l10n.expensesCategoryLabel),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          key: const Key('expense-filter'),
          value: categories.any((c) => c.id == selected) ? selected : null,
          isExpanded: true,
          isDense: true,
          items: <DropdownMenuItem<String?>>[
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n.expensesAllCategories),
            ),
            for (final category in categories)
              DropdownMenuItem<String?>(
                value: category.id,
                child: Text(categoryLabel(l10n, category)),
              ),
          ],
          onChanged: ref.read(expenseCategoryFilterProvider.notifier).select,
        ),
      ),
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({
    required this.result,
    required this.categories,
    required this.filtered,
  });

  final ExpenseListResult result;
  final List<ExpenseCategory> categories;
  final bool filtered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeTag = ref.watch(deviceLocaleProvider).toString();

    if (result.expenses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          filtered ? l10n.expensesNoneInCategory : l10n.expensesNone,
          key: const Key('expenses-empty'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final total in result.totals)
          _TotalRow(total: total, localeTag: localeTag),
        const Divider(),
        for (final expense in result.expenses)
          _ExpenseTile(
            expense: expense,
            categories: categories,
            localeTag: localeTag,
          ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.total, required this.localeTag});

  final ExpenseCurrencyTotal total;
  final String localeTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final code = total.currencyCode;
    final formatter = MoneyFormatter(localeTag: localeTag, currencyCode: code);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${l10n.expensesTotal} ($code)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Text(
                formatter.format(total.total),
                key: Key('expense-total-$code'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          if (total.pendingCount > 0)
            Text(
              l10n.cashFlowPendingExpenses(total.pendingCount),
              key: Key('expense-total-pending-$code'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.categories,
    required this.localeTag,
  });

  final Expense expense;
  final List<ExpenseCategory> categories;
  final String localeTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = categoryById(categories, expense.categoryId);
    final categoryName = category == null
        ? expense.categoryId
        : categoryLabel(l10n, category);
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(expense.date.toUtcDateTime());

    final original = expense.original;
    final originalText = original == null
        ? null
        : MoneyFormatter(
            localeTag: localeTag,
            currencyCode: original.currencyCode,
          ).format(original.amount);

    final amount = expense.amount;
    return ListTile(
      key: Key('expense-tile-${expense.id}'),
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ExpenseFormPage(expense: expense),
        ),
      ),
      title: Text(expense.description ?? categoryName),
      subtitle: Text(
        <String>[
          date,
          if (expense.description != null) categoryName,
          ?originalText,
        ].join(' · '),
      ),
      trailing: amount == null
          ? Chip(
              key: Key('expense-pending-${expense.id}'),
              label: Text(l10n.expenseAwaitingAmount),
              visualDensity: VisualDensity.compact,
            )
          : Text(
              MoneyFormatter(
                localeTag: localeTag,
                currencyCode: expense.currencyCode,
              ).format(amount),
              key: Key('expense-amount-${expense.id}'),
            ),
    );
  }
}
