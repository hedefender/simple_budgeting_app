import 'package:simple_budgeting_app/features/settings/domain/repositories/settings_repository.dart';

class InvalidCurrencyCodeException implements Exception {
  const InvalidCurrencyCodeException(this.input);

  final String input;

  @override
  String toString() => 'InvalidCurrencyCodeException($input)';
}

final RegExp _currencyCodePattern = RegExp(r'^[A-Z]{3}$');

/// Trims and upper-cases [input]; null when it is not three letters. Only the
/// format is checked, not whether the code exists in ISO 4217.
String? normalizeCurrencyCode(String input) {
  final code = input.trim().toUpperCase();
  return _currencyCodePattern.hasMatch(code) ? code : null;
}

/// Stores the primary currency, the default for new sources.
class SetPrimaryCurrency {
  const SetPrimaryCurrency(this._settings);

  final SettingsRepository _settings;

  /// Returns the stored (normalized) code.
  Future<String> call(String input) async {
    final code = normalizeCurrencyCode(input);
    if (code == null) throw InvalidCurrencyCodeException(input);
    await _settings.setPrimaryCurrency(code);
    return code;
  }
}
