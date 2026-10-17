import 'package:simple_budgeting_app/features/foundation/domain/entities/app_status.dart';
import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';

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
