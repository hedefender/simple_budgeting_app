import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/core/money/money_formatter.dart';
import 'package:simple_budgeting_app/features/foundation/domain/services/core_info_service.dart';

/// Bridge between get_it (builds services) and Riverpod (feeds the UI).
/// Tests override this with an isolated `GetIt.asNewInstance()`.
final Provider<GetIt> serviceLocatorProvider =
    Provider<GetIt>((Ref ref) => GetIt.instance);

final Provider<Bootstrapper> bootstrapperProvider = Provider<Bootstrapper>(
  (Ref ref) => ref.watch(serviceLocatorProvider).get<Bootstrapper>(),
);

final Provider<CoreInfoService> coreInfoServiceProvider =
    Provider<CoreInfoService>(
  (Ref ref) => ref.watch(serviceLocatorProvider).get<CoreInfoService>(),
);

/// The device's full locale (language + region). Read through the binding so
/// widget tests can fake it.
final Provider<Locale> deviceLocaleProvider = Provider<Locale>(
  (Ref ref) => WidgetsBinding.instance.platformDispatcher.locale,
);

final Provider<MoneyFormatter> moneyFormatterProvider =
    Provider<MoneyFormatter>(
  (Ref ref) => MoneyFormatter(
    localeTag: ref.watch(deviceLocaleProvider).toString(),
  ),
);
