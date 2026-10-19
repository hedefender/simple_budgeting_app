import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/balance_anchor_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/services/income_calculator.dart';

/// Income side of a month's cash flow (no expenses yet).
///
/// Amounts of different currencies are never added: [call] handles one
/// currency, [forAllCurrencies] returns one cash flow per currency.
///
/// Balance at the end of day D = the last anchor dated on or before D, plus
/// all non-skipped income dated after that anchor and on or before D. Without
/// an anchor the balance starts at 0 and all income counts.
class GetMonthlyCashFlow {
  const GetMonthlyCashFlow(
    this._incomeRepository,
    this._anchorRepository,
    this._calculator,
    this._clock,
  );

  final IncomeRepository _incomeRepository;
  final BalanceAnchorRepository _anchorRepository;
  final IncomeCalculator _calculator;
  final Clock _clock;

  /// The month in every currency found in sources and anchors, plus
  /// [primaryCurrency] (always present, even when empty).
  Future<MonthlyCashFlowSummary> forAllCurrencies(
    YearMonth month,
    String primaryCurrency,
  ) async {
    final sources = await _incomeRepository.listSources(includeArchived: true);
    final others = <String>{
      ...sources.map((s) => s.currencyCode),
      ...await _anchorRepository.listCurrencyCodes(),
    }..remove(primaryCurrency);
    final codes = <String>[primaryCurrency, ...others.toList()..sort()];

    final flows = <MonthlyCashFlow>[
      for (final code in codes) await call(month, code),
    ];
    final occurrences = <IncomeOccurrence>[
      for (final flow in flows) ...flow.occurrences,
    ]..sort(_byDateThenName);
    return MonthlyCashFlowSummary(
      month: month,
      currencies: flows,
      occurrences: occurrences,
    );
  }

  /// One currency only; sources and anchors in other currencies are ignored.
  Future<MonthlyCashFlow> call(YearMonth month, String currencyCode) async {
    final today = CalendarDate.fromInstant(_clock());
    final sources = (await _incomeRepository.listSources(
      includeArchived: true,
    )).where((s) => s.currencyCode == currencyCode).toList();
    final entries = await _incomeRepository.listEntries();
    final anchors = await _anchorRepository.listAnchors(currencyCode);

    final occurrences = <IncomeOccurrence>[
      for (final source in sources)
        ..._calculator.occurrencesInMonth(
          source: source,
          entries: entries,
          month: month,
          today: today,
        ),
    ]..sort(_byDateThenName);

    var received = Money.zero;
    var expected = Money.zero;
    for (final o in occurrences) {
      switch (o.state) {
        case OccurrenceState.received:
          received += o.amount;
        case OccurrenceState.expected:
          expected += o.amount;
        case OccurrenceState.skipped:
          break;
      }
    }

    final dayBefore = month.firstDay.addDays(-1);
    return MonthlyCashFlow(
      month: month,
      currencyCode: currencyCode,
      occurrences: occurrences,
      openingBalance: _balanceAt(dayBefore, sources, entries, anchors, today),
      receivedIncome: received,
      expectedIncome: expected,
      projectedClosingBalance: _balanceAt(
        month.lastDay,
        sources,
        entries,
        anchors,
        today,
      ),
    );
  }

  Money _balanceAt(
    CalendarDate day,
    List<IncomeSource> sources,
    List<IncomeEntry> entries,
    List<BalanceAnchor> anchors,
    CalendarDate today,
  ) {
    BalanceAnchor? anchor;
    for (final candidate in anchors) {
      if (candidate.date.isAfter(day)) continue;
      if (anchor == null || candidate.date.isAfter(anchor.date)) {
        anchor = candidate;
      }
    }
    var balance = anchor?.balance ?? Money.zero;
    for (final source in sources) {
      for (final o in _calculator.occurrencesThrough(
        source: source,
        entries: entries,
        through: day,
        today: today,
      )) {
        if (o.state == OccurrenceState.skipped) continue;
        if (anchor != null && !o.date.isAfter(anchor.date)) continue;
        balance += o.amount;
      }
    }
    return balance;
  }

  static int _byDateThenName(IncomeOccurrence a, IncomeOccurrence b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.source.name.compareTo(b.source.name);
  }
}
