import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/get_primary_currency.dart';

/// The primary currency: the default for new sources. Chosen once from the
/// data or the device (see [GetPrimaryCurrency]); never follows the device
/// afterwards.
final FutureProvider<String> primaryCurrencyProvider =
    FutureProvider.autoDispose<String>((Ref ref) {
      final deviceCurrency = ref.watch(moneyFormatterProvider).currencyCode;
      return ref.watch(serviceLocatorProvider).get<GetPrimaryCurrency>()(
        deviceCurrency,
      );
    });
