import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_app_launch.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_startup_duration.dart';

import '../../support/fakes.dart';

Bootstrapper _bootstrapper(
  FakeAppStatusRepository repository, {
  Future<void> Function()? openDatabase,
}) {
  return Bootstrapper(
    openDatabase: openDatabase ?? () async {},
    recordAppLaunch:
        RecordAppLaunch(repository, () => DateTime.utc(2026, 10, 16)),
    recordStartupDuration: RecordStartupDuration(repository),
  );
}

void main() {
  test('reports stages in order and ends at 100%', () async {
    final repository = FakeAppStatusRepository();
    final events = <BootstrapProgress>[];

    await _bootstrapper(repository).run(onProgress: events.add);

    expect(events.map((e) => e.stage), <BootstrapStage>[
      BootstrapStage.openingDatabase,
      BootstrapStage.recordingLaunch,
      BootstrapStage.finishing,
      BootstrapStage.finishing,
    ]);
    final fractions = events.map((e) => e.fraction).toList();
    expect(fractions, orderedEquals(<double>[...fractions]..sort()));
    expect(fractions.last, 1.0);
  });

  test('returns the status and persists the measured duration', () async {
    final repository = FakeAppStatusRepository();

    final result = await _bootstrapper(repository).run();

    expect(result.status.launchCount, 1);
    expect(repository.lastStartupMs, result.elapsed.inMilliseconds);
  });

  test('a failing database stops bootstrap before recording a launch',
      () async {
    final repository = FakeAppStatusRepository();
    final bootstrapper = _bootstrapper(
      repository,
      openDatabase: () async => throw StateError('disk full'),
    );

    await expectLater(bootstrapper.run(), throwsStateError);
    expect(repository.launches, 0);
  });
}
