import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';

/// drift-backed implementation of [SettingsRepository] on `app_settings`.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);

  final AppDatabase _db;

  static const String _kPrimaryCurrency = 'primary_currency';

  @override
  Future<String?> getPrimaryCurrency() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.settingKey.equals(_kPrimaryCurrency))).getSingleOrNull();
    return row?.settingValue;
  }

  @override
  Future<void> setPrimaryCurrency(String currencyCode) {
    return _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            settingKey: _kPrimaryCurrency,
            settingValue: currencyCode,
          ),
        );
  }
}
