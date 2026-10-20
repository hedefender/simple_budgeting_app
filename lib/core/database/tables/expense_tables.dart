import 'package:drift/drift.dart';
import 'package:simple_budgeting_app/core/database/tables/document_tables.dart';

// Domain tables use UUID text primary keys, with one documented exception:
// built-in categories use their stable key as id (the same on every device,
// for the later sync). Calendar days are text `yyyy-MM-dd` (see CalendarDate).
// Amounts are integer minor units next to a currency code.

@DataClassName('CategoryRow')
class Categories extends Table {
  /// Built-in categories: equal to [categoryKey]. User categories (Phase 5):
  /// a UUID.
  TextColumn get id => text()();

  /// Stable key; the display name of a built-in category comes from the ARB
  /// files by this key. (Not called `key`, which is an SQL keyword.)
  TextColumn get categoryKey => text()();

  IntColumn get sortOrder => integer()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {categoryKey},
  ];
}

@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();

  TextColumn get description => text().nullable()();

  TextColumn get categoryId => text().references(Categories, #id)();

  /// Calendar day, `yyyy-MM-dd`.
  TextColumn get expenseDate => text()();

  /// Currency of the account that was charged. Always set, also when the
  /// expense is pending.
  TextColumn get currencyCode => text()();

  /// What left the user's pocket, in [currencyCode]. Null: the expense is
  /// pending ("awaiting amount") and counts nowhere.
  IntColumn get amountMinor => integer().nullable()();

  /// Informational: the amount and currency on the receipt (24.50 GBP).
  IntColumn get originalAmountMinor => integer().nullable()();

  TextColumn get originalCurrencyCode => text().nullable()();

  /// Informational: the part of [amountMinor] that is VAT/taxes. Added to no
  /// sum.
  IntColumn get taxAmountMinor => integer().nullable()();

  /// The scanned document this expense was made from (Phase 3), or null.
  /// Deleting the document keeps the expense and clears the link.
  TextColumn get documentId => text().nullable().references(
    Documents,
    #id,
    onDelete: KeyAction.setNull,
  )();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // A CHECK that evaluates to NULL passes in SQLite, so every nullable column
  // is handled explicitly with IS NULL / IS NOT NULL.
  @override
  List<String> get customConstraints => [
    'CHECK (amount_minor IS NOT NULL OR '
        '(original_amount_minor IS NOT NULL '
        'AND original_currency_code IS NOT NULL))',
    'CHECK ((original_amount_minor IS NULL) = '
        '(original_currency_code IS NULL))',
    'CHECK (amount_minor IS NULL OR amount_minor > 0)',
    'CHECK (original_amount_minor IS NULL OR original_amount_minor > 0)',
    'CHECK (tax_amount_minor IS NULL OR tax_amount_minor > 0)',
  ];
}
