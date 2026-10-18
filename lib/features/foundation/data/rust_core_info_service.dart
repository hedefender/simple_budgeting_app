import 'package:simple_budgeting_app/features/foundation/domain/entities/core_info.dart';
import 'package:simple_budgeting_app/features/foundation/domain/services/core_info_service.dart';
import 'package:simple_budgeting_app/src/rust/api/core_info.dart' as bridge;

/// Adapter over the generated Rust bridge.
class RustCoreInfoService implements CoreInfoService {
  @override
  CoreInfo read() {
    final info = bridge.coreInfo();
    return CoreInfo(crateVersion: info.crateVersion, target: info.target);
  }
}
