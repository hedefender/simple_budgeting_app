abstract interface class SettingsRepository {
  /// ISO 4217 code of the primary currency, or null before it is first set.
  Future<String?> getPrimaryCurrency();

  Future<void> setPrimaryCurrency(String currencyCode);
}
