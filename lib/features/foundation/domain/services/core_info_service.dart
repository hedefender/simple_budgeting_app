import 'package:simple_budgeting_app/features/foundation/domain/entities/core_info.dart';

/// Reports information about the native core. Only usable after the native
/// library was initialized during bootstrap.
abstract interface class CoreInfoService {
  CoreInfo read();
}
