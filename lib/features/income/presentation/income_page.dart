import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/money/money_formatter.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_dialogs.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_labels.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_providers.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_source_form_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

class IncomePage extends ConsumerWidget {
  const IncomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(selectedMonthProvider);
    final cashFlow = ref.watch(monthlyCashFlowProvider);
    final sources = ref.watch(incomeSourcesProvider);
    final deviceFormatter = ref.watch(moneyFormatterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.incomeTitle)),
      floatingActionButton: FloatingActionButton(
        key: const Key('income-add'),
        tooltip: l10n.incomeAddSource,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const IncomeSourceFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                key: const Key('month-previous'),
                tooltip: l10n.incomePreviousMonth,
                onPressed: ref.read(selectedMonthProvider.notifier).previous,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  l10n.incomeMonthLabel(month.firstDay.toUtcDateTime()),
                  key: const Key('month-label'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                key: const Key('month-next'),
                tooltip: l10n.incomeNextMonth,
                onPressed: ref.read(selectedMonthProvider.notifier).next,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          cashFlow.when(
            data: (MonthlyCashFlow flow) =>
                _CashFlowSection(flow: flow, formatter: deviceFormatter),
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

class _CashFlowSection extends ConsumerWidget {
  const _CashFlowSection({required this.flow, required this.formatter});

  final MonthlyCashFlow flow;
  final MoneyFormatter formatter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    Widget row(String key, String label, Money value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(formatter.format(value), key: Key(key)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                row('cash-opening', l10n.cashFlowOpening, flow.openingBalance),
                row(
                  'cash-received',
                  l10n.cashFlowReceived,
                  flow.receivedIncome,
                ),
                row(
                  'cash-expected',
                  l10n.cashFlowExpected,
                  flow.expectedIncome,
                ),
                const Divider(),
                row(
                  'cash-closing',
                  l10n.cashFlowClosing,
                  flow.projectedClosingBalance,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    key: const Key('set-balance'),
                    onPressed: () async {
                      final input = await showBalanceDialog(
                        context,
                        ref,
                        currencyCode: flow.currencyCode,
                        today: ref.read(todayProvider),
                      );
                      if (input == null) return;
                      await ref
                          .read(incomeActionsProvider)
                          .setBalance(
                            date: input.date,
                            balance: input.balance,
                            currencyCode: flow.currencyCode,
                          );
                    },
                    child: Text(l10n.cashFlowSetBalance),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.incomePaymentsHeader,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (flow.occurrences.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.incomeNoPayments,
              key: const Key('income-no-payments'),
            ),
          )
        else
          for (final occurrence in flow.occurrences)
            _OccurrenceTile(occurrence: occurrence),
      ],
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
