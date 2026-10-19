import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/settings/data/settings_repository_impl.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SettingsRepositoryImpl(db);
  });

  tearDown(() => db.close());

  test('primary currency is null before it is set', () async {
    expect(await repository.getPrimaryCurrency(), isNull);
  });

  test('primary currency round trips and can be replaced', () async {
    await repository.setPrimaryCurrency('EUR');
    expect(await repository.getPrimaryCurrency(), 'EUR');

    await repository.setPrimaryCurrency('USD');
    expect(await repository.getPrimaryCurrency(), 'USD');
  });
}
