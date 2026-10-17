import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/foundation/domain/entities/app_status.dart';
import 'package:simple_budgeting_app/features/foundation/domain/repositories/app_status_repository.dart';

/// drift-backed implementation of [AppStatusRepository].
class AppStatusRepositoryImpl implements AppStatusRepository {
  AppStatusRepositoryImpl(this._db);

  final AppDatabase _db;

  static const String _kLaunchCount = 'launch_count';
  static const String _kFirstLaunchAt = 'first_launch_at';
  static const String _kLastStartupMs = 'last_startup_ms';

  @override
  Future<AppStatus> recordLaunch(DateTime nowUtc) {
    final now = nowUtc.toUtc();
    return _db.transaction(() async {
      final previousCount = int.tryParse(await _read(_kLaunchCount) ?? '') ?? 0;
      final newCount = previousCount + 1;

      final storedFirst = await _read(_kFirstLaunchAt);
      final firstLaunchAt =
          storedFirst == null ? now : DateTime.parse(storedFirst).toUtc();
      if (storedFirst == null) {
        await _write(_kFirstLaunchAt, now.toIso8601String());
      }

      await _write(_kLaunchCount, '$newCount');

      final lastStartupMs = int.tryParse(await _read(_kLastStartupMs) ?? '');

      return AppStatus(
        launchCount: newCount,
        firstLaunchAt: firstLaunchAt,
        lastStartupMs: lastStartupMs,
      );
    });
  }

  @override
  Future<void> saveStartupDuration(int milliseconds) =>
      _write(_kLastStartupMs, '$milliseconds');

  Future<String?> _read(String key) async {
    final row = await (_db.select(_db.appSettings)
          ..where((t) => t.settingKey.equals(key)))
        .getSingleOrNull();
    return row?.settingValue;
  }

  Future<void> _write(String key, String value) {
    return _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(settingKey: key, settingValue: value),
        );
  }
}
