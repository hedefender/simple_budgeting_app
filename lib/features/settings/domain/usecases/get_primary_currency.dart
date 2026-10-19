import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';

/// Returns the primary currency. On the first call it is chosen and stored:
/// the currency of the oldest existing source (an install from before this
/// setting), otherwise [deviceCurrency]. After that it never changes unless
/// the user changes it.
class GetPrimaryCurrency {
  const GetPrimaryCurrency(this._settings, this._incomeRepository);

  final SettingsRepository _settings;
  final IncomeRepository _incomeRepository;

  Future<String> call(String deviceCurrency) async {
    final stored = await _settings.getPrimaryCurrency();
    if (stored != null) return stored;

    final sources = await _incomeRepository.listSources(includeArchived: true);
    var chosen = deviceCurrency;
    if (sources.isNotEmpty) {
      final oldest = sources.reduce(
        (a, b) => b.createdAt.isBefore(a.createdAt) ? b : a,
      );
      chosen = oldest.currencyCode;
    }
    await _settings.setPrimaryCurrency(chosen);
    return chosen;
  }
}
