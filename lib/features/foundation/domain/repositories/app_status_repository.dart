import 'package:simple_budgeting_app/features/foundation/domain/entities/app_status.dart';

/// Persistence contract for [AppStatus]. The domain layer owns this
/// interface; the data layer implements it.
abstract interface class AppStatusRepository {
  /// Registers a new launch at [nowUtc] and returns the updated status.
  /// [AppStatus.lastStartupMs] is the value saved by the previous launch.
  Future<AppStatus> recordLaunch(DateTime nowUtc);

  /// Saves how long this launch took to become ready.
  Future<void> saveStartupDuration(int milliseconds);
}
