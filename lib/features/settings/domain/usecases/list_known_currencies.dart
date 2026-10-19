import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/balance_anchor_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';

/// The currencies that exist in the app: the primary one, and those of income
/// sources (archived too), balance anchors and expenses.
class ListKnownCurrencies {
  const ListKnownCurrencies(
    this._incomeRepository,
    this._anchorRepository,
    this._expenseRepository,
  );

  final IncomeRepository _incomeRepository;
  final BalanceAnchorRepository _anchorRepository;
  final ExpenseRepository _expenseRepository;

  /// [primaryCurrency] first, the others sorted by code.
  Future<List<String>> call(String primaryCurrency) async {
    final sources = await _incomeRepository.listSources(includeArchived: true);
    final others = <String>{
      ...sources.map((s) => s.currencyCode),
      ...await _anchorRepository.listCurrencyCodes(),
      ...await _expenseRepository.listCurrencyCodes(),
    }..remove(primaryCurrency);
    return <String>[primaryCurrency, ...others.toList()..sort()];
  }
}
