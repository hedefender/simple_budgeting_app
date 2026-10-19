abstract interface class SettingsRepository {
  /// ISO 4217 code of the primary currency, or null before it is first set.
  Future<String?> getPrimaryCurrency();

  Future<void> setPrimaryCurrency(String currencyCode);

  /// Whether the first-run setup wizard was finished or skipped.
  Future<bool> isSetupCompleted();

  Future<void> markSetupCompleted();
}
