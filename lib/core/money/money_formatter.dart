import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:simple_budgeting_app/core/money/money.dart';

/// Formats [Money] using a locale (and, by default, that locale's currency).
///
/// The locale tag should be the full device locale (for example `el_GR` or
/// `en_US`), not the app's resolved UI language, because the region decides
/// the currency. A language-only tag such as `en` falls back to USD.
class MoneyFormatter {
  MoneyFormatter({required String localeTag, String? currencyCode})
      : _format = currencyCode == null
            ? NumberFormat.simpleCurrency(locale: localeTag)
            : NumberFormat.simpleCurrency(locale: localeTag, name: currencyCode);

  final NumberFormat _format;

  /// ISO 4217 code in use, for example `EUR`.
  String get currencyCode => _format.currencyName ?? '';

  /// Formats [money]. The division to a major-unit double happens only here,
  /// for display; stored amounts stay integers.
  String format(Money money) {
    final digits = _format.decimalDigits ?? 2;
    final divisor = math.pow(10, digits).toInt();
    return _format.format(money.minorUnits / divisor);
  }
}
