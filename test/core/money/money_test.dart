import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/money/money_formatter.dart';

void main() {
  group('Money', () {
    test('adds and subtracts exactly, with no floating point drift', () {
      // 0.1 + 0.2 != 0.3 with doubles; with minor units it is exact.
      expect(const Money(10) + const Money(20), const Money(30));
      expect(const Money(30) - const Money(10), const Money(20));
    });

    test('negation and sign', () {
      expect(-const Money(500), const Money(-500));
      expect(const Money(-1).isNegative, isTrue);
      expect(Money.zero.isNegative, isFalse);
    });

    test('equality, hashCode and ordering', () {
      expect(const Money(5), const Money(5));
      expect(const Money(5).hashCode, const Money(5).hashCode);
      expect(const Money(5).compareTo(const Money(7)), lessThan(0));
    });
  });

  group('MoneyFormatter', () {
    test('en_US uses dollars and a dot decimal separator', () {
      final f = MoneyFormatter(localeTag: 'en_US');
      expect(f.currencyCode, 'USD');
      expect(f.format(const Money(123456)), r'$1,234.56');
    });

    test('el_GR uses euros and a comma decimal separator', () {
      final f = MoneyFormatter(localeTag: 'el_GR');
      expect(f.currencyCode, 'EUR');
      final text = f.format(const Money(123456));
      expect(text, contains('1.234,56'));
      expect(text, contains('€'));
    });

    test('explicit currency overrides the locale default', () {
      final f = MoneyFormatter(localeTag: 'en_US', currencyCode: 'EUR');
      expect(f.currencyCode, 'EUR');
      expect(f.format(const Money(450)), contains('4.50'));
    });

    test('negative amounts keep their sign', () {
      final f = MoneyFormatter(localeTag: 'en_US');
      expect(f.format(const Money(-450)), contains('4.50'));
      expect(f.format(const Money(-450)), contains('-'));
    });

    test('currencies without minor units are not divided by 100', () {
      final f = MoneyFormatter(localeTag: 'ja_JP');
      expect(f.currencyCode, 'JPY');
      expect(f.format(const Money(1500)), contains('1,500'));
    });
  });
}
