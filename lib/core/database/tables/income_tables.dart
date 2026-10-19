import 'package:drift/drift.dart';

// Domain tables use UUID text primary keys. Calendar days are text
// `yyyy-MM-dd` (see CalendarDate); instants are drift DateTime columns (UTC).
// Amounts are integer minor units next to a currency code.

@DataClassName('IncomeSourceRow')
class IncomeSources extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  /// `IncomeType.name`.
  TextColumn get type => text()();

  IntColumn get amountMinor => integer()();

  TextColumn get currencyCode => text()();

  /// Versioned JSON, see IncomeScheduleCodec.
  TextColumn get scheduleJson => text()();

  TextColumn get startDate => text()();

  TextColumn get endDate => text().nullable()();

  /// History up to and including this day lives in income_entries.
  TextColumn get frozenThrough => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('IncomeEntryRow')
class IncomeEntries extends Table {
  TextColumn get id => text()();

  TextColumn get sourceId => text().references(IncomeSources, #id)();

  /// The date the schedule produced for the payment this row replaces.
  TextColumn get originalDate => text()();

  /// The date the payment is paid, when it is pinned (frozen history or a
  /// date the user changed). Null: the date is computed from the schedule.
  TextColumn get actualDate => text().nullable()();

  /// `IncomeEntryStatus.name`: received or skipped.
  TextColumn get status => text()();

  IntColumn get amountMinor => integer()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {sourceId, originalDate},
  ];
}

@DataClassName('BalanceAnchorRow')
class BalanceAnchors extends Table {
  TextColumn get id => text()();

  /// The balance is the one at the END of this day.
  TextColumn get anchorDate => text()();

  IntColumn get balanceMinor => integer()();

  TextColumn get currencyCode => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {anchorDate, currencyCode},
  ];
}
