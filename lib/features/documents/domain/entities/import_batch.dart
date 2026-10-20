/// One press of the file picker. Skipped files (not JSON) are
/// `fileCount - importedCount - duplicateCount - failedCount`.
class ImportBatch {
  const ImportBatch({
    required this.id,
    required this.importedAt,
    required this.source,
    required this.fileCount,
    this.importedCount = 0,
    this.duplicateCount = 0,
    this.failedCount = 0,
  });

  /// The only source for now.
  static const String filePicker = 'file_picker';

  final String id;
  final DateTime importedAt;
  final String source;
  final int fileCount;
  final int importedCount;
  final int duplicateCount;
  final int failedCount;

  int get skippedCount =>
      fileCount - importedCount - duplicateCount - failedCount;

  ImportBatch withCounts({
    required int importedCount,
    required int duplicateCount,
    required int failedCount,
  }) => ImportBatch(
    id: id,
    importedAt: importedAt,
    source: source,
    fileCount: fileCount,
    importedCount: importedCount,
    duplicateCount: duplicateCount,
    failedCount: failedCount,
  );
}
