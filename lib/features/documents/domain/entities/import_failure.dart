/// Why one file was not imported. Each kind has one message in the app.
enum ImportFailureKind {
  emptyFile,
  tooLarge,
  notUtf8,
  invalidJson,
  notAnObject,
  missingField,
  wrongType,
  emptyOcrText,
  invalidDocumentId,
  invalidDate,
  emptyFileName,
  unsupportedSchemaVersion,

  /// The file could not be read (permission, removed while importing).
  readError,

  /// The document could not be stored.
  storageError,

  /// Anything unexpected. Never a crash: the file is reported and the next
  /// one is imported.
  unexpected,
}

/// A failure with the details that belong to its kind (the others are null).
class ImportFailure {
  const ImportFailure(
    this.kind, {
    this.field,
    this.line,
    this.column,
    this.size,
    this.limit,
    this.foundVersion,
    this.knownVersion,
  });

  final ImportFailureKind kind;

  /// `missingField`, `wrongType`, `emptyFileName`.
  final String? field;

  /// `invalidJson`, 1-based.
  final int? line;
  final int? column;

  /// `tooLarge`, in bytes.
  final int? size;
  final int? limit;

  /// `unsupportedSchemaVersion`.
  final int? foundVersion;
  final int? knownVersion;

  @override
  String toString() => 'ImportFailure($kind, field: $field)';
}

/// Thrown by a `ScanJsonParser` or an `ImportSource` for a file that cannot
/// be imported.
class ImportFailureException implements Exception {
  const ImportFailureException(this.failure);

  final ImportFailure failure;

  @override
  String toString() => 'ImportFailureException($failure)';
}
