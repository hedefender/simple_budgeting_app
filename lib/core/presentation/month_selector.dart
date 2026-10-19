import 'package:flutter/material.dart';
import 'package:simple_budgeting_app/core/time/year_month.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// Previous / next buttons around the name of [month]. The keys are
/// `<keyPrefix>-previous`, `<keyPrefix>-label` and `<keyPrefix>-next`.
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    this.keyPrefix = 'month',
  });

  final YearMonth month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: <Widget>[
        IconButton(
          key: Key('$keyPrefix-previous'),
          tooltip: l10n.incomePreviousMonth,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            l10n.incomeMonthLabel(month.firstDay.toUtcDateTime()),
            key: Key('$keyPrefix-label'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          key: Key('$keyPrefix-next'),
          tooltip: l10n.incomeNextMonth,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
