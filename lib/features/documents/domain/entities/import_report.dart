import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';

/// What happened to one file.
sealed class ImportOutcome {
  const ImportOutcome();
}

/// A new document was stored.
class Imported extends ImportOutcome {
  const Imported(this.document);

  final ScanDocument document;
}

/// The same `documentId` was imported before. Nothing was stored.
class Duplicate extends ImportOutcome {
  const Duplicate(this.documentId, this.existing);

  final String documentId;

  /// The stored document with that id.
  final ScanDocument existing;
}

/// Not a `.json` file (for example the PDF picked together with the JSON).
/// Neutral: not an error.
class Skipped extends ImportOutcome {
  const Skipped();
}

class Failed extends ImportOutcome {
  const Failed(this.failure);

  final ImportFailure failure;
}

class FileImportResult {
  const FileImportResult(this.fileName, this.outcome);

  final String fileName;
  final ImportOutcome outcome;
}

/// The result of one import batch, in the order the files were picked.
class ImportReport {
  const ImportReport(this.results);

  final List<FileImportResult> results;

  int get importedCount => _count<Imported>();
  int get duplicateCount => _count<Duplicate>();
  int get skippedCount => _count<Skipped>();
  int get failedCount => _count<Failed>();

  int _count<T extends ImportOutcome>() =>
      results.where((r) => r.outcome is T).length;
}

/// More files than one batch accepts. Nothing was read.
class TooManyFilesException implements Exception {
  const TooManyFilesException({required this.count, required this.limit});

  final int count;
  final int limit;

  @override
  String toString() => 'TooManyFilesException($count > $limit)';
}
