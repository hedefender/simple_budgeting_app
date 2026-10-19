import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/money/money_formatter.dart';
import 'package:simple_budgeting_app/core/presentation/fab_clearance.dart';
import 'package:simple_budgeting_app/core/presentation/month_selector.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_dialogs.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_labels.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_providers.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_source_form_page.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_button.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

class IncomePage extends ConsumerWidget {
  const IncomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(selectedMonthProvider);
    final cashFlow = ref.watch(monthlyCashFlowProvider);
    final sources = ref.watch(incomeSourcesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.incomeTitle),
        actions: const <Widget>[SettingsButton()],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('income-add'),
        tooltip: l10n.incomeAddSource,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const IncomeSourceFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, fabListBottomPadding(context)),
        children: <Widget>[
          MonthSelector(
            month: month,
            onPrevious: ref.read(selectedMonthProvider.notifier).previous,
            onNext: ref.read(selectedMonthProvider.notifier).next,
          ),
          cashFlow.when(
            data: (MonthlyCashFlowSummary summary) =>
                _CashFlowSection(summary: summary),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace _) => _LoadError(
              onRetry: () => ref.invalidate(monthlyCashFlowProvider),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.incomeSourcesHeader,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          sources.when(
            data: (List<IncomeSource> list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.incomeNoSources,
                      key: const Key('income-no-sources'),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      for (final source in list) _SourceTile(source: source),
                    ],
                  ),
            loading: () => const SizedBox.shrink(),
            error: (Object error, StackTrace _) => _LoadError(
              onRetry: () => ref.invalidate(incomeSourcesProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          Text(l10n.incomeLoadError, key: const Key('income-load-error')),
          TextButton(onPressed: onRetry, child: Text(l10n.incomeRetry)),
        ],
      ),
    );
  }
}

class _CashFlowSection extends StatelessWidget {
  const _CashFlowSection({required this.summary});

  final MonthlyCashFlowSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final codes = <String>[for (final f in summary.currencies) f.currencyCode];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final flow in summary.currencies)
          _CurrencyBlock(flow: flow, currencyCodes: codes),
        const SizedBox(height: 16),
        Text(
          l10n.incomePaymentsHeader,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (summary.occurrences.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.incomeNoPayments,
              key: const Key('income-no-payments'),
            ),
          )
        else
          for (final occurrence in summary.occurrences)
            _OccurrenceTile(occurrence: occurrence),
      ],
    );
  }
}

/// Cash flow card of one currency. Keys end with the currency code.
class _CurrencyBlock extends ConsumerWidget {
  const _CurrencyBlock({required this.flow, required this.currencyCodes});

  final MonthlyCashFlow flow;
  final List<String> currencyCodes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final code = flow.currencyCode;
    final formatter = MoneyFormatter(
      localeTag: ref.watch(deviceLocaleProvider).toString(),
      currencyCode: code,
    );

    // [unknown]: the balance is not known on that day, so no number is shown.
    Widget row(String key, String label, Money value, {bool unknown = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label)),
              Text(
                unknown ? '—' : formatter.format(value),
                key: Key('$key-$code'),
              ),
            ],
          ),
        );
    final unknown = flow.balanceUnknown;

    return Card(
      key: Key('cash-block-$code'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(code, style: Theme.of(context).textTheme.titleSmall),
            ),
            row(
              'cash-opening',
              l10n.cashFlowOpening,
              flow.openingBalance,
              unknown: unknown,
            ),
            row('cash-received', l10n.cashFlowReceived, flow.receivedIncome),
            row('cash-expected', l10n.cashFlowExpected, flow.expectedIncome),
            row('cash-expenses', l10n.cashFlowExpenses, flow.expenses),
            if (flow.pendingExpenseCount > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.cashFlowPendingExpenses(flow.pendingExpenseCount),
                  key: Key('cash-pending-$code'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const Divider(),
            row(
              'cash-closing',
              l10n.cashFlowClosing,
              flow.projectedClosingBalance,
              unknown: unknown,
            ),
            if (unknown)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.cashFlowBalanceStarts(
                    flow.balanceStart!.date.toUtcDateTime(),
                  ),
                  key: Key('cash-balance-start-note-$code'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: Key('set-balance-$code'),
                onPressed: () async {
                  final input = await showBalanceDialog(
                    context,
                    ref,
                    currencyCode: code,
                    currencyCodes: currencyCodes,
                    today: ref.read(todayProvider),
                  );
                  if (input == null) return;
                  await ref
                      .read(incomeActionsProvider)
                      .setBalance(
                        date: input.date,
                        balance: input.balance,
                        currencyCode: input.currencyCode,
                      );
                },
                child: Text(l10n.cashFlowSetBalance),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccurrenceTile extends ConsumerWidget {
  const _OccurrenceTile({required this.occurrence});

  final IncomeOccurrence occurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final source = occurrence.source;
    final formatter = MoneyFormatter(
      localeTag: ref.watch(deviceLocaleProvider).toString(),
      currencyCode: source.currencyCode,
    );
    final skipped = occurrence.state == OccurrenceState.skipped;
    final actions = ref.read(incomeActionsProvider);

    return Card(
      child: ListTile(
        key: Key('occurrence-${source.id}-${occurrence.nominalDate}'),
        title: Text(source.name),
        subtitle: Text(
          l10n.occurrenceSubtitle(
            occurrence.date.toUtcDateTime(),
            occurrenceStateLabel(l10n, occurrence.state),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              formatter.format(occurrence.amount),
              style: skipped
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            PopupMenuButton<String>(
              key: Key(
                'occurrence-menu-${source.id}-${occurrence.nominalDate}',
              ),
              onSelected: (String choice) async {
                switch (choice) {
                  case 'amount':
                    final change = await showChangePaymentDialog(
                      context,
                      ref,
                      currencyCode: source.currencyCode,
                      initial: occurrence.amount,
                      date: occurrence.date,
                    );
                    if (change != null) {
                      await actions.changeAmount(
                        source.id,
                        occurrence.nominalDate,
                        change.amount,
                        // Pin the date only when the user really changed it.
                        actualDate: change.date == occurrence.date
                            ? null
                            : change.date,
                      );
                    }
                  case 'skip':
                    await actions.skip(source.id, occurrence.nominalDate);
                  case 'reset':
                    await actions.reset(source.id, occurrence.nominalDate);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'amount',
                  child: Text(l10n.occurrenceChangeAmount),
                ),
                if (!skipped)
                  PopupMenuItem<String>(
                    value: 'skip',
                    child: Text(l10n.occurrenceSkip),
                  ),
                if (occurrence.isStored)
                  PopupMenuItem<String>(
                    value: 'reset',
                    child: Text(l10n.occurrenceReset),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends ConsumerWidget {
  const _SourceTile({required this.source});

  final IncomeSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = MoneyFormatter(
      localeTag: ref.watch(deviceLocaleProvider).toString(),
      currencyCode: source.currencyCode,
    );
    return Card(
      child: ListTile(
        key: Key('source-${source.id}'),
        title: Text(source.name),
        subtitle: Text(
          l10n.sourceSubtitle(
            incomeTypeLabel(l10n, source.type),
            scheduleSummary(l10n, source.schedule),
          ),
        ),
        trailing: Text(formatter.format(source.amount)),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => IncomeSourceFormPage(source: source),
          ),
        ),
      ),
    );
  }
}
