import 'package:simple_budgeting_app/features/foundation/domain/entities/app_status.dart';
import 'package:simple_budgeting_app/features/foundation/domain/entities/core_info.dart';
import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';
import 'package:simple_budgeting_app/features/foundation/domain/services/core_info_service.dart';

/// Stands in for the Rust core, which the host test runner cannot load.
class FakeCoreInfoService implements CoreInfoService {
  @override
  CoreInfo read() =>
      const CoreInfo(crateVersion: '9.9.9', target: 'fake-target');
}

/// In-memory repository for tests that must not touch SQLite.
class FakeAppStatusRepository implements AppStatusRepository {
  int launches = 0;
  int? lastStartupMs;
  DateTime? firstLaunchAt;
  DateTime? lastNowUtc;

  @override
  Future<AppStatus> recordLaunch(DateTime nowUtc) async {
    launches++;
    lastNowUtc = nowUtc;
    firstLaunchAt ??= nowUtc;
    return AppStatus(
      launchCount: launches,
      firstLaunchAt: firstLaunchAt!,
      lastStartupMs: lastStartupMs,
    );
  }

  @override
  Future<void> saveStartupDuration(int milliseconds) async {
    lastStartupMs = milliseconds;
  }
}
