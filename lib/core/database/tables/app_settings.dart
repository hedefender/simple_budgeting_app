import 'package:drift/drift.dart';

/// Small key/value store for app-level facts (launch counter, timings, ...).
///
/// Domain tables added in later phases (income, expenses, categories) use
/// UUID text primary keys so a future PC version can sync without ID clashes.
class AppSettings extends Table {
  TextColumn get settingKey => text()();

  TextColumn get settingValue => text()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}
