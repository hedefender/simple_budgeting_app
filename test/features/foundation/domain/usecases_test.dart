import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_app_launch.dart';
import 'package:simple_budgeting_app/features/foundation/domain/usecases/record_startup_duration.dart';

import '../../../support/fakes.dart';

void main() {
  test('RecordAppLaunch passes the clock time to the repository as UTC',
      () async {
    final repository = FakeAppStatusRepository();
    final local = DateTime(2026, 10, 16, 9, 30);
    final useCase = RecordAppLaunch(repository, () => local);

    final status = await useCase();

    expect(repository.lastNowUtc, local.toUtc());
    expect(repository.lastNowUtc!.isUtc, isTrue);
    expect(status.launchCount, 1);
  });

  test('RecordStartupDuration saves whole milliseconds', () async {
    final repository = FakeAppStatusRepository();
    await RecordStartupDuration(repository)(
      const Duration(milliseconds: 321, microseconds: 900),
    );
    expect(repository.lastStartupMs, 321);
  });
}
