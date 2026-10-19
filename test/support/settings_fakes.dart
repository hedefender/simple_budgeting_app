import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  String? primaryCurrency;

  @override
  Future<String?> getPrimaryCurrency() async => primaryCurrency;

  @override
  Future<void> setPrimaryCurrency(String currencyCode) async =>
      primaryCurrency = currencyCode;
}
