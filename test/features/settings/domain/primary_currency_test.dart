import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_schedule.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/get_primary_currency.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/set_primary_currency.dart';

import '../../../support/income_fakes.dart';
import '../../../support/settings_fakes.dart';

IncomeSource _source(String id, String currency, DateTime createdAt) =>
    IncomeSource(
      id: id,
      name: id,
      type: IncomeType.salary,
      amount: const Money(100000),
      currencyCode: currency,
      schedule: const Monthly.onDay(5),
      startDate: CalendarDate(2026, 1, 1),
      createdAt: createdAt,
    );

void main() {
  late FakeSettingsRepository settings;
  late FakeIncomeRepository incomes;
  late GetPrimaryCurrency getPrimary;

  setUp(() {
    settings = FakeSettingsRepository();
    incomes = FakeIncomeRepository();
    getPrimary = GetPrimaryCurrency(settings, incomes);
  });

  group('GetPrimaryCurrency', () {
    test('first start without sources uses the device currency', () async {
      expect(await getPrimary('EUR'), 'EUR');
      expect(settings.primaryCurrency, 'EUR');
    });

    test('existing install uses the currency of the oldest source', () async {
      await incomes.addSource(_source('b', 'USD', DateTime.utc(2026, 3)));
      await incomes.addSource(_source('a', 'EUR', DateTime.utc(2026, 1)));

      expect(await getPrimary('GBP'), 'EUR');
      expect(settings.primaryCurrency, 'EUR');
    });

    test('is stable when the device currency changes', () async {
      expect(await getPrimary('EUR'), 'EUR');
      expect(await getPrimary('USD'), 'EUR');
    });

    test('a stored value wins over sources and device', () async {
      settings.primaryCurrency = 'CHF';
      await incomes.addSource(_source('a', 'EUR', DateTime.utc(2026, 1)));

      expect(await getPrimary('USD'), 'CHF');
    });
  });

  group('SetPrimaryCurrency', () {
    test('stores a normalized code', () async {
      final saved = await SetPrimaryCurrency(settings)(' usd ');
      expect(saved, 'USD');
      expect(settings.primaryCurrency, 'USD');
    });

    test('rejects codes that are not three letters', () async {
      for (final bad in <String>['', 'EU', 'EURO', 'E1R', '123']) {
        await expectLater(
          SetPrimaryCurrency(settings)(bad),
          throwsA(isA<InvalidCurrencyCodeException>()),
        );
      }
      expect(settings.primaryCurrency, isNull);
    });
  });
}
