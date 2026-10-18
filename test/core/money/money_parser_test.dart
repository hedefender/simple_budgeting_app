import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/money/money_parser.dart';

MoneyParser _el({bool allowNegative = false, int digits = 2}) => MoneyParser(
  localeTag: 'el_GR',
  decimalDigits: digits,
  allowNegative: allowNegative,
);

MoneyParser _en({bool allowNegative = false, int digits = 2}) => MoneyParser(
  localeTag: 'en_US',
  decimalDigits: digits,
  allowNegative: allowNegative,
);

Money? _ok(MoneyParser p, String text) => switch (p.parse(text)) {
  MoneyParsed(:final money) => money,
  MoneyParseError() => null,
};

MoneyParseFailure? _fail(MoneyParser p, String text) => switch (p.parse(text)) {
  MoneyParsed() => null,
  MoneyParseError(:final failure) => failure,
};

void main() {
  group('Greek locale', () {
    final p = _el();

    test('1.234,56 is 1234,56', () {
      expect(_ok(p, '1.234,56'), const Money(123456));
    });

    test('decimal comma and no grouping', () {
      expect(_ok(p, '12,5'), const Money(1250));
      expect(_ok(p, '1234,56'), const Money(123456));
      expect(_ok(p, '0,05'), const Money(5));
      expect(_ok(p, ',5'), const Money(50));
    });

    test('12.50 is accepted as 12,50', () {
      expect(_ok(p, '12.50'), const Money(1250));
      expect(_ok(p, '12.5'), const Money(1250));
    });

    test('1.234 is a thousands group (1234,00), by the locale rule', () {
      expect(_ok(p, '1.234'), const Money(123400));
      expect(_ok(p, '999.999'), const Money(99999900));
    });

    test('a leading zero or a long integer part is a decimal, not a group', () {
      expect(_fail(p, '0.123'), MoneyParseFailure.tooManyDecimals);
      expect(_fail(p, '1234.567'), MoneyParseFailure.tooManyDecimals);
    });

    test('repeated separators group thousands', () {
      expect(_ok(p, '1.234.567'), const Money(123456700));
      expect(_ok(p, '1.234.567,89'), const Money(123456789));
      expect(_fail(p, '1.23.567'), MoneyParseFailure.invalid);
    });
  });

  group('English locale', () {
    final p = _en();

    test('1,234.56 is 1234.56', () {
      expect(_ok(p, '1,234.56'), const Money(123456));
    });

    test('decimal point and no grouping', () {
      expect(_ok(p, '12.5'), const Money(1250));
      expect(_ok(p, '1234.56'), const Money(123456));
    });

    test('1,234 is a thousands group', () {
      expect(_ok(p, '1,234'), const Money(123400));
    });

    test('12,50 is accepted as 12.50', () {
      expect(_ok(p, '12,50'), const Money(1250));
    });
  });

  group('currency digits', () {
    test('0 decimals (JPY style)', () {
      final p = _en(digits: 0);
      expect(_ok(p, '1500'), const Money(1500));
      expect(_fail(p, '15.5'), MoneyParseFailure.tooManyDecimals);
    });

    test('3 decimals (KWD style)', () {
      final p = _en(digits: 3);
      expect(_ok(p, '1.5'), const Money(1500));
      expect(_ok(p, '1.505'), const Money(1505));
      expect(_fail(p, '1.5055'), MoneyParseFailure.tooManyDecimals);
    });

    test('forCurrency takes the digits from the currency', () {
      expect(
        MoneyParser.forCurrency(
          localeTag: 'el_GR',
          currencyCode: 'EUR',
        ).decimalDigits,
        2,
      );
      expect(
        MoneyParser.forCurrency(
          localeTag: 'en_US',
          currencyCode: 'JPY',
        ).decimalDigits,
        0,
      );
    });
  });

  group('failures', () {
    final p = _el();

    test('empty and blank', () {
      expect(_fail(p, ''), MoneyParseFailure.empty);
      expect(_fail(p, '   '), MoneyParseFailure.empty);
    });

    test('garbage', () {
      expect(_fail(p, 'abc'), MoneyParseFailure.invalid);
      expect(_fail(p, '12,5x'), MoneyParseFailure.invalid);
      expect(_fail(p, '12,'), MoneyParseFailure.invalid);
      expect(_fail(p, ','), MoneyParseFailure.invalid);
      expect(_fail(p, '1,2,3'), MoneyParseFailure.invalid);
      expect(_fail(p, '12,34,56'), MoneyParseFailure.invalid);
    });

    test('more decimals than the currency allows is never rounded', () {
      expect(_fail(p, '1,234'), MoneyParseFailure.tooManyDecimals);
      expect(_fail(p, '1,999'), MoneyParseFailure.tooManyDecimals);
    });

    test('too large', () {
      expect(_fail(p, '1234567890123'), MoneyParseFailure.tooLarge);
    });

    test('spaces are ignored', () {
      expect(_ok(p, ' 1 234,50 '), const Money(123450));
    });
  });

  group('negative amounts are controlled by a parameter', () {
    test('rejected by default', () {
      expect(_fail(_el(), '-5,00'), MoneyParseFailure.negative);
      expect(_fail(_en(), '-5.00'), MoneyParseFailure.negative);
    });

    test('accepted when allowed', () {
      expect(_ok(_el(allowNegative: true), '-5,25'), const Money(-525));
      expect(_ok(_en(allowNegative: true), '-1,234.50'), const Money(-123450));
      expect(_ok(_el(allowNegative: true), '−5'), const Money(-500));
    });

    test('minus zero is zero and never negative', () {
      expect(_ok(_el(), '-0'), Money.zero);
    });
  });

  group('formatMoneyForInput', () {
    test('uses the locale decimal separator without grouping', () {
      expect(
        formatMoneyForInput(
          const Money(123456),
          localeTag: 'el_GR',
          decimalDigits: 2,
        ),
        '1234,56',
      );
      expect(
        formatMoneyForInput(
          const Money(123456),
          localeTag: 'en_US',
          decimalDigits: 2,
        ),
        '1234.56',
      );
      expect(
        formatMoneyForInput(
          const Money(5),
          localeTag: 'en_US',
          decimalDigits: 2,
        ),
        '0.05',
      );
      expect(
        formatMoneyForInput(
          const Money(-1250),
          localeTag: 'en_US',
          decimalDigits: 2,
        ),
        '-12.50',
      );
      expect(
        formatMoneyForInput(
          const Money(1500),
          localeTag: 'en_US',
          decimalDigits: 0,
        ),
        '1500',
      );
    });

    test('round trips through the parser', () {
      for (final minor in <int>[0, 1, 99, 100, 123456, 99999999]) {
        final text = formatMoneyForInput(
          Money(minor),
          localeTag: 'el_GR',
          decimalDigits: 2,
        );
        expect(_ok(_el(), text), Money(minor), reason: text);
      }
    });
  });
}
