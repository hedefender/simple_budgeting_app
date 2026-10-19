import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  String? primaryCurrency;
  bool setupCompleted = false;

  @override
  Future<String?> getPrimaryCurrency() async => primaryCurrency;

  @override
  Future<void> setPrimaryCurrency(String currencyCode) async =>
      primaryCurrency = currencyCode;

  @override
  Future<bool> isSetupCompleted() async => setupCompleted;

  @override
  Future<void> markSetupCompleted() async => setupCompleted = true;
}
