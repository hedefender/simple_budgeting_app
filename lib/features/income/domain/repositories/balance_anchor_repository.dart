import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';

abstract interface class BalanceAnchorRepository {
  /// Inserts the anchor, or replaces the anchor of the same date and currency.
  Future<void> saveAnchor(BalanceAnchor anchor);

  Future<List<BalanceAnchor>> listAnchors(String currencyCode);
}
