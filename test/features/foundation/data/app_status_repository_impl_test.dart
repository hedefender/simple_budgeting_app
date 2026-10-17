import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/foundation/data/app_status_repository_impl.dart';

void main() {
  late AppDatabase db;
  late AppStatusRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = AppStatusRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('first launch starts the counter at 1 and records the date', () async {
    final now = DateTime.utc(2026, 10, 16, 8);
    final status = await repository.recordLaunch(now);

    expect(status.launchCount, 1);
    expect(status.firstLaunchAt, now);
    expect(status.lastStartupMs, isNull);
  });

  test('each launch increments the counter and keeps the first date', () async {
    final first = DateTime.utc(2026, 10, 16, 8);
    await repository.recordLaunch(first);
    final second = await repository.recordLaunch(DateTime.utc(2026, 10, 17));
    final third = await repository.recordLaunch(DateTime.utc(2026, 10, 18));

    expect(second.launchCount, 2);
    expect(third.launchCount, 3);
    expect(third.firstLaunchAt, first);
  });

  test('startup duration saved by one launch is visible to the next', () async {
    await repository.recordLaunch(DateTime.utc(2026, 10, 16));
    await repository.saveStartupDuration(240);

    final next = await repository.recordLaunch(DateTime.utc(2026, 10, 17));
    expect(next.lastStartupMs, 240);
  });

  test('non-UTC input is normalised to UTC', () async {
    final local = DateTime(2026, 10, 16, 8);
    final status = await repository.recordLaunch(local);
    expect(status.firstLaunchAt.isUtc, isTrue);
    expect(status.firstLaunchAt, local.toUtc());
  });
}
