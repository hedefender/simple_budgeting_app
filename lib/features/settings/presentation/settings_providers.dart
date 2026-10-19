import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/get_primary_currency.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/setup_status.dart';

/// Whether the first-run setup wizard should open by itself (see
/// [ShouldShowSetup]).
final FutureProvider<bool> shouldShowSetupProvider =
    FutureProvider.autoDispose<bool>(
      (Ref ref) => ref.watch(serviceLocatorProvider).get<ShouldShowSetup>()(),
    );

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
