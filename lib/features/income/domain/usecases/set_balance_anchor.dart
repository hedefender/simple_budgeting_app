import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/balance_anchor_repository.dart';

/// Sets the user's balance at the END of [date]. A second anchor for the same
/// date and currency replaces the first. A negative balance is allowed.
class SetBalanceAnchor {
  const SetBalanceAnchor(this._repository, this._clock, this._newId);

  final BalanceAnchorRepository _repository;
  final Clock _clock;
  final IdGenerator _newId;

  Future<void> call({
    required CalendarDate date,
    required Money balance,
    required String currencyCode,
  }) => _repository.saveAnchor(
    BalanceAnchor(
      id: _newId(),
      date: date,
      balance: balance,
      currencyCode: currencyCode,
      createdAt: _clock().toUtc(),
    ),
  );
}
