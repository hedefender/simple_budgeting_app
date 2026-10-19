import 'package:simple_budgeting_app/features/income/domain/entities/balance_start.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/balance_anchor_repository.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';

/// Where the balance of [currencyCode] starts, or null when it has no anchor
/// and no income source. Never stored: computed on every call.
class GetBalanceStart {
  const GetBalanceStart(this._incomeRepository, this._anchorRepository);

  final IncomeRepository _incomeRepository;
  final BalanceAnchorRepository _anchorRepository;

  Future<BalanceStart?> call(String currencyCode) async {
    final anchors = await _anchorRepository.listAnchors(currencyCode);
    final sources = (await _incomeRepository.listSources(
      includeArchived: true,
    )).where((s) => s.currencyCode == currencyCode);
    return computeBalanceStart(anchors, sources);
  }
}
