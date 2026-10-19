import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';
import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';

/// Decides whether the first-run setup wizard opens by itself.
class ShouldShowSetup {
  const ShouldShowSetup(this._settings, this._incomeRepository);

  final SettingsRepository _settings;
  final IncomeRepository _incomeRepository;

  /// True only on a fresh install: the wizard was never finished or skipped
  /// and there is no income source yet (an install from before the wizard
  /// already has its data).
  Future<bool> call() async {
    if (await _settings.isSetupCompleted()) return false;
    final sources = await _incomeRepository.listSources(includeArchived: true);
    return sources.isEmpty;
  }
}

/// Records that the wizard was finished or skipped, so it does not open again
/// by itself.
class CompleteSetup {
  const CompleteSetup(this._settings);

  final SettingsRepository _settings;

  Future<void> call() => _settings.markSetupCompleted();
}
