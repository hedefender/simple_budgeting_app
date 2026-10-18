import 'package:intl/intl.dart';
import 'package:simple_budgeting_app/core/money/money.dart';

enum MoneyParseFailure { empty, invalid, negative, tooManyDecimals, tooLarge }

sealed class MoneyParseResult {
  const MoneyParseResult();
}

class MoneyParsed extends MoneyParseResult {
  const MoneyParsed(this.money);

  final Money money;
}

class MoneyParseError extends MoneyParseResult {
  const MoneyParseError(this.failure);

  final MoneyParseFailure failure;
}

/// [money] as editable text in the locale's own style, without grouping:
/// `1234,50` in el, `1234.50` in en. The inverse of [MoneyParser.parse].
String formatMoneyForInput(
  Money money, {
  required String localeTag,
  required int decimalDigits,
}) {
  final separator = NumberFormat.decimalPattern(localeTag).symbols.DECIMAL_SEP;
  final abs = money.minorUnits.abs();
  final divisor = List<int>.filled(
    decimalDigits,
    10,
  ).fold<int>(1, (a, b) => a * b);
  final sign = money.minorUnits < 0 ? '-' : '';
  if (decimalDigits == 0) return '$sign$abs';
  final integer = abs ~/ divisor;
  final fraction = (abs % divisor).toString().padLeft(decimalDigits, '0');
  return '$sign$integer$separator$fraction';
}

/// Parses user-typed amounts into [Money], using integer arithmetic only.
///
/// Rules:
/// - The number of decimals comes from the currency (EUR 2, JPY 0, KWD 3).
/// - Both `.` and `,` are accepted; the locale decides what each means when
///   it is ambiguous:
///   - Both present: the last one is the decimal separator, the other one
///     groups thousands (`1.234,56`, `1,234.56`).
///   - One separator, repeated: it is a group separator (`1.234.567`) and
///     every group after the first must have exactly 3 digits.
///   - One separator, once: if exactly 3 digits follow, the integer part has
///     1-3 digits and does not start with 0, AND it is the locale's GROUP
///     separator, it groups thousands (`1.234` in el is 1234.00, `1,234` in en
///     is 1234.00). Otherwise it is a decimal separator, so `12.50` in el is
///     12,50 and `12,50` in en is 12.50.
/// - More decimals than the currency allows is an error (no rounding).
/// - Negative amounts are only accepted when [allowNegative] is true.
class MoneyParser {
  MoneyParser({
    required String localeTag,
    required this.decimalDigits,
    this.allowNegative = false,
  }) : _groupSeparator = NumberFormat.decimalPattern(
         localeTag,
       ).symbols.GROUP_SEP;

  /// Decimals taken from [currencyCode] (as the currency formatter does).
  factory MoneyParser.forCurrency({
    required String localeTag,
    required String currencyCode,
    bool allowNegative = false,
  }) {
    final digits =
        NumberFormat.simpleCurrency(
          locale: localeTag,
          name: currencyCode,
        ).decimalDigits ??
        2;
    return MoneyParser(
      localeTag: localeTag,
      decimalDigits: digits,
      allowNegative: allowNegative,
    );
  }

  static const int _maxIntegerDigits = 12;

  final int decimalDigits;
  final bool allowNegative;
  final String _groupSeparator;

  MoneyParseResult parse(String input) {
    var text = input.replaceAll(RegExp(r'[\s  ]'), '');
    if (text.isEmpty) return const MoneyParseError(MoneyParseFailure.empty);

    var negative = false;
    if (text.startsWith('-') || text.startsWith('−')) {
      negative = true;
      text = text.substring(1);
    }
    if (text.isEmpty || !RegExp(r'^[0-9.,]+$').hasMatch(text)) {
      return const MoneyParseError(MoneyParseFailure.invalid);
    }

    final split = _split(text);
    if (split == null) return const MoneyParseError(MoneyParseFailure.invalid);
    final (integerPart, fraction) = split;

    if (integerPart.length > _maxIntegerDigits) {
      return const MoneyParseError(MoneyParseFailure.tooLarge);
    }
    if (fraction.length > decimalDigits) {
      return const MoneyParseError(MoneyParseFailure.tooManyDecimals);
    }
    if (integerPart.isEmpty && fraction.isEmpty) {
      return const MoneyParseError(MoneyParseFailure.invalid);
    }

    final minor = int.parse(
      '${integerPart.isEmpty ? '0' : integerPart}'
      '${fraction.padRight(decimalDigits, '0')}',
    );
    if (negative && minor != 0) {
      if (!allowNegative) {
        return const MoneyParseError(MoneyParseFailure.negative);
      }
      return MoneyParsed(Money(-minor));
    }
    return MoneyParsed(Money(minor));
  }

  /// Returns (digits of the integer part, digits of the fraction) or null.
  (String, String)? _split(String text) {
    final lastDot = text.lastIndexOf('.');
    final lastComma = text.lastIndexOf(',');

    if (lastDot >= 0 && lastComma >= 0) {
      final decimalIndex = lastDot > lastComma ? lastDot : lastComma;
      final groupChar = lastDot > lastComma ? ',' : '.';
      final integerText = text.substring(0, decimalIndex);
      final fraction = text.substring(decimalIndex + 1);
      final integerPart = _ungroup(integerText, groupChar);
      if (integerPart == null || !_isDigits(fraction, allowEmpty: false)) {
        return null;
      }
      return (integerPart, fraction);
    }

    final separator = lastDot >= 0 ? '.' : (lastComma >= 0 ? ',' : null);
    if (separator == null) return (text, '');

    final count = separator.allMatches(text).length;
    if (count > 1) {
      final integerPart = _ungroup(text, separator);
      return integerPart == null ? null : (integerPart, '');
    }

    final index = text.indexOf(separator);
    final before = text.substring(0, index);
    final after = text.substring(index + 1);
    if (!_isDigits(before, allowEmpty: true) ||
        !_isDigits(after, allowEmpty: false)) {
      return null;
    }
    final looksLikeGroup =
        after.length == 3 &&
        before.isNotEmpty &&
        before.length <= 3 &&
        !before.startsWith('0');
    if (looksLikeGroup && separator == _groupSeparator) {
      return ('$before$after', '');
    }
    return (before, after);
  }

  /// Removes [groupChar] when [text] is a valid thousands grouping
  /// (1-3 digits, then groups of exactly 3). Returns null otherwise.
  String? _ungroup(String text, String groupChar) {
    final parts = text.split(groupChar);
    if (parts.first.isEmpty || parts.first.length > 3) return null;
    if (!_isDigits(parts.first, allowEmpty: false)) return null;
    for (final part in parts.skip(1)) {
      if (part.length != 3 || !_isDigits(part, allowEmpty: false)) return null;
    }
    return parts.join();
  }

  bool _isDigits(String text, {required bool allowEmpty}) =>
      text.isEmpty ? allowEmpty : RegExp(r'^[0-9]+$').hasMatch(text);
}
