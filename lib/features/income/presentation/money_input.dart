import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/money/money_parser.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// Validates typed money text for a form field. Returns the localized error,
/// or null when the text is a valid amount.
String? validateMoneyText(
  AppLocalizations l10n,
  MoneyParser parser,
  String? text, {
  required bool requirePositive,
}) {
  switch (parser.parse(text ?? '')) {
    case MoneyParsed(:final money):
      if (requirePositive && money.minorUnits <= 0) {
        return l10n.errorAmountPositive;
      }
      return null;
    case MoneyParseError(:final failure):
      return switch (failure) {
        MoneyParseFailure.tooManyDecimals => l10n.errorAmountDecimals(
          parser.decimalDigits,
        ),
        MoneyParseFailure.negative => l10n.errorAmountPositive,
        _ => l10n.errorAmountInvalid,
      };
  }
}

/// The parsed amount, or null when [text] is not valid.
Money? tryParseMoney(MoneyParser parser, String text) =>
    switch (parser.parse(text)) {
      MoneyParsed(:final money) => money,
      MoneyParseError() => null,
    };
