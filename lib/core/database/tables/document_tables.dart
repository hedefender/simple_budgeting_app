import 'package:drift/drift.dart';

// Domain tables use UUID text primary keys. Instants are drift DateTime
// columns (UTC, stored with second precision).

/// One row per import batch: one press of the file picker. Per-file details
/// are not stored (the user sees them once, in the import report).
@DataClassName('ImportRow')
class Imports extends Table {
  TextColumn get id => text()();

  DateTimeColumn get importedAt => dateTime()();

  /// Where the batch came from. `file_picker` for now.
  TextColumn get source => text()();

  /// Files picked. Skipped files (not JSON) are
  /// `file_count - imported - duplicate - failed`.
  IntColumn get fileCount => integer()();

  IntColumn get importedCount => integer()();

  IntColumn get duplicateCount => integer()();

  IntColumn get failedCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (file_count >= 0 AND imported_count >= 0 '
        'AND duplicate_count >= 0 AND failed_count >= 0)',
    'CHECK (imported_count + duplicate_count + failed_count <= file_count)',
  ];
}

/// A scanned document and its OCR text, from a Scan JSON file. The text is
/// stored, not analysed (the rule engine is Phase 4).
@DataClassName('DocumentRow')
class Documents extends Table {
  TextColumn get id => text()();

  /// The `documentId` of the Scan JSON: the duplicate key.
  TextColumn get documentId => text().unique()();

  TextColumn get importId => text().references(Imports, #id)();

  /// The JSON file the document came from.
  TextColumn get sourceFileName => text()();

  /// The `createdAt` instant, UTC.
  DateTimeColumn get createdAtUtc => dateTime()();

  TextColumn get ocrText => text()();

  /// BCP-47 tag, or null when the file did not say.
  TextColumn get language => text().nullable()();

  /// `DocumentType.name`. No constraint: a value written by a newer version
  /// of the app must not make the row unreadable (it reads as `unknown`).
  TextColumn get documentType =>
      text().withDefault(const Constant('unknown'))();

  /// File names (labels, never paths), cut to their last segment.
  TextColumn get pdfName => text().nullable()();

  /// A JSON array of strings.
  TextColumn get imageNames => text().withDefault(const Constant('[]'))();

  /// The `schemaVersion` of the file; 1 for a legacy file.
  IntColumn get schemaVersion => integer()();

  BoolColumn get wasLegacy => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // A CHECK that evaluates to NULL passes in SQLite, so nullable columns are
  // handled explicitly with IS NULL. SQLite's trim() removes only spaces by
  // default, so tab and line breaks are listed (the parser rejects all
  // Unicode white space; this is the second guard). The strings are literals
  // on purpose: drift reads this list at build time and drops entries it
  // cannot evaluate, such as an interpolated constant.
  @override
  List<String> get customConstraints => [
    "CHECK (length(trim(ocr_text, ' ' || char(9) || char(10) || char(13))) > 0)",
    "CHECK (length(trim(document_id, ' ' || char(9) || char(10) || char(13))) > 0)",
    'CHECK (schema_version >= 1)',
    "CHECK (language IS NULL OR length(trim(language, ' ' || char(9) || char(10) || char(13))) > 0)",
  ];
}
