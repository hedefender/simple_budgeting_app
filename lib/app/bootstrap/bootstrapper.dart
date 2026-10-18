import 'package:flutter/foundation.dart';
import 'package:simple_budgeting_app/features/foundation/domain/entities/app_status.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_app_launch.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_startup_duration.dart';

/// Named stages of startup. The UI maps these to localized text, so this
/// layer contains no user-facing strings.
enum BootstrapStage {
  startingCore,
  openingDatabase,
  recordingLaunch,
  finishing,
}

@immutable
class BootstrapProgress {
  const BootstrapProgress(this.stage, this.fraction);

  final BootstrapStage stage;

  /// 0.0 to 1.0.
  final double fraction;
}

@immutable
class BootstrapResult {
  const BootstrapResult({required this.status, required this.elapsed});

  final AppStatus status;

  /// Time from the start of bootstrapping until the app was ready.
  final Duration elapsed;
}

typedef ProgressCallback = void Function(BootstrapProgress progress);

/// Runs the cold-start work (load the native core, open DB and run migrations,
/// record the launch) while measuring how long it takes.
class Bootstrapper {
  Bootstrapper({
    required Future<void> Function() initNative,
    required Future<void> Function() openDatabase,
    required RecordAppLaunch recordAppLaunch,
    required RecordStartupDuration recordStartupDuration,
  })  : _initNative = initNative,
        _openDatabase = openDatabase,
        _recordAppLaunch = recordAppLaunch,
        _recordStartupDuration = recordStartupDuration;

  final Future<void> Function() _initNative;
  final Future<void> Function() _openDatabase;
  final RecordAppLaunch _recordAppLaunch;
  final RecordStartupDuration _recordStartupDuration;

  Future<BootstrapResult> run({ProgressCallback? onProgress}) async {
    final stopwatch = Stopwatch()..start();

    onProgress?.call(const BootstrapProgress(BootstrapStage.startingCore, 0));
    await _initNative();

    onProgress?.call(const BootstrapProgress(BootstrapStage.openingDatabase, 0.3));
    await _openDatabase();

    onProgress?.call(const BootstrapProgress(BootstrapStage.recordingLaunch, 0.6));
    final status = await _recordAppLaunch();

    onProgress?.call(const BootstrapProgress(BootstrapStage.finishing, 0.9));
    stopwatch.stop();
    await _recordStartupDuration(stopwatch.elapsed);

    onProgress?.call(const BootstrapProgress(BootstrapStage.finishing, 1));
    debugPrint('Bootstrap finished in ${stopwatch.elapsedMilliseconds} ms');
    return BootstrapResult(status: status, elapsed: stopwatch.elapsed);
  }
}
