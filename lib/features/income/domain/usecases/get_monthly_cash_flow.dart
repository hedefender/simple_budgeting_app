import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_start.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/monthly_cash_flow.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/balance_anchor_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/services/income_calculator.dart';

/// A month's cash flow: income and registered expenses.
///
/// Amounts of different currencies are never added: [call] handles one
/// currency, [forAllCurrencies] returns one cash flow per currency.
///
/// Balance at the end of day D = the last anchor dated on or before D, plus
/// all non-skipped income dated after that anchor and on or before D. Without
/// an anchor the balance starts at 0 and all income counts.
///
/// Registered expenses are subtracted the same way: only those dated AFTER the
/// anchor count (the anchor is the balance at the END of its day, so an expense
/// dated on the anchor day is already inside it). Pending expenses (awaiting
/// the amount that was charged) never count; they are only counted in
/// [MonthlyCashFlow.pendingExpenseCount]. Expenses dated before the start of
/// the balance (see [BalanceStart]) are history: they never change a balance,
/// also when there is no anchor. A month that ends before the start has no
/// known balance ([MonthlyCashFlow.balanceUnknown]).
class GetMonthlyCashFlow {
  const GetMonthlyCashFlow(
    this._incomeRepository,
    this._anchorRepository,
    this._expenseRepository,
    this._calculator,
    this._clock,
  );

  final IncomeRepository _incomeRepository;
  final BalanceAnchorRepository _anchorRepository;
  final ExpenseRepository _expenseRepository;
  final IncomeCalculator _calculator;
  final Clock _clock;

  /// The month in every currency found in sources, anchors and expenses, plus
  /// [primaryCurrency] (always present, even when empty).
  Future<MonthlyCashFlowSummary> forAllCurrencies(
    YearMonth month,
    String primaryCurrency,
  ) async {
    final sources = await _incomeRepository.listSources(includeArchived: true);
    final others = <String>{
      ...sources.map((s) => s.currencyCode),
      ...await _anchorRepository.listCurrencyCodes(),
      ...await _expenseRepository.listCurrencyCodes(),
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

  /// One currency only; sources, anchors and expenses in other currencies are
  /// ignored.
  Future<MonthlyCashFlow> call(YearMonth month, String currencyCode) async {
    final today = CalendarDate.fromInstant(_clock());
    final sources = (await _incomeRepository.listSources(
      includeArchived: true,
    )).where((s) => s.currencyCode == currencyCode).toList();
    final entries = await _incomeRepository.listEntries();
    final anchors = await _anchorRepository.listAnchors(currencyCode);
    final expenses = (await _expenseRepository.list())
        .where((e) => e.currencyCode == currencyCode)
        .toList();

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

    var monthExpenses = Money.zero;
    var pendingCount = 0;
    for (final e in expenses) {
      if (!month.contains(e.date)) continue;
      final amount = e.amount;
      if (amount == null) {
        pendingCount++;
      } else {
        monthExpenses += amount;
      }
    }

    final start = computeBalanceStart(anchors, sources);
    final dayBefore = month.firstDay.addDays(-1);
    return MonthlyCashFlow(
      month: month,
      currencyCode: currencyCode,
      occurrences: occurrences,
      openingBalance: _balanceAt(
        dayBefore,
        sources,
        entries,
        expenses,
        anchors,
        start,
        today,
      ),
      receivedIncome: received,
      expectedIncome: expected,
      expenses: monthExpenses,
      pendingExpenseCount: pendingCount,
      projectedClosingBalance: _balanceAt(
        month.lastDay,
        sources,
        entries,
        expenses,
        anchors,
        start,
        today,
      ),
      balanceStart: start,
    );
  }

  Money _balanceAt(
    CalendarDate day,
    List<IncomeSource> sources,
    List<IncomeEntry> entries,
    List<Expense> expenses,
    List<BalanceAnchor> anchors,
    BalanceStart? start,
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
    for (final e in expenses) {
      final amount = e.amount;
      if (amount == null) continue; // pending: counts nowhere
      if (e.date.isAfter(day)) continue;
      // Before the balance starts an expense is history only.
      if (start != null && e.date.isBefore(start.date)) continue;
      if (anchor != null && !e.date.isAfter(anchor.date)) continue;
      balance -= amount;
    }
    return balance;
  }

  static int _byDateThenName(IncomeOccurrence a, IncomeOccurrence b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : a.source.name.compareTo(b.source.name);
  }
}
