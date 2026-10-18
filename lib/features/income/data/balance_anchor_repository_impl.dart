import 'package:drift/drift.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/balance_anchor_repository.dart';

class BalanceAnchorRepositoryImpl implements BalanceAnchorRepository {
  BalanceAnchorRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> saveAnchor(BalanceAnchor anchor) async {
    await _db
        .into(_db.balanceAnchors)
        .insert(
          BalanceAnchorsCompanion.insert(
            id: anchor.id,
            anchorDate: anchor.date.toString(),
            balanceMinor: anchor.balance.minorUnits,
            currencyCode: anchor.currencyCode,
            createdAt: anchor.createdAt,
          ),
          onConflict: DoUpdate(
            (_) => BalanceAnchorsCompanion(
              balanceMinor: Value(anchor.balance.minorUnits),
              createdAt: Value(anchor.createdAt),
            ),
            target: [
              _db.balanceAnchors.anchorDate,
              _db.balanceAnchors.currencyCode,
            ],
          ),
        );
  }

  @override
  Future<List<BalanceAnchor>> listAnchors(String currencyCode) async {
    final rows =
        await (_db.select(_db.balanceAnchors)
              ..where((t) => t.currencyCode.equals(currencyCode))
              ..orderBy([(t) => OrderingTerm.asc(t.anchorDate)]))
            .get();
    return rows
        .map(
          (r) => BalanceAnchor(
            id: r.id,
            date: CalendarDate.parse(r.anchorDate),
            balance: Money(r.balanceMinor),
            currencyCode: r.currencyCode,
            createdAt: r.createdAt.toUtc(),
          ),
        )
        .toList();
  }
}
