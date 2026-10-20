import 'package:simple_budgeting_app/core/clock.dart';
import 'package:simple_budgeting_app/core/id_generator.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_report.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/document_repository.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_source.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/scan_json_parser.dart';

/// The largest JSON file Budget reads (5 MiB). Larger files are refused
/// before they are read.
const int maxImportFileBytes = 5 * 1024 * 1024;

/// The most files one import batch accepts.
const int maxImportFiles = 50;

/// Turns a wall-clock time without zone (`yyyy-MM-ddTHH:mm:ss`) into a UTC
/// instant. The default applies the time zone of the device.
typedef LocalTimeToUtc = DateTime Function(String isoLocal);

DateTime deviceLocalToUtc(String isoLocal) => DateTime.parse(isoLocal).toUtc();

/// Imports the picked Scan JSON files, one at a time. A file that fails does
/// not stop the others, and nothing escapes as an exception: every file gets
/// a result in the report. The text is stored, not analysed.
class ImportScanFiles {
  const ImportScanFiles(
    this._parser,
    this._repository,
    this._clock,
    this._newId, {
    LocalTimeToUtc localToUtc = deviceLocalToUtc,
  }) : _localToUtc = localToUtc;

  final ScanJsonParser _parser;
  final DocumentRepository _repository;
  final Clock _clock;
  final IdGenerator _newId;
  final LocalTimeToUtc _localToUtc;

  /// Throws [TooManyFilesException] for more than [maxImportFiles] files
  /// (nothing is read then).
  Future<ImportReport> call(List<ImportSource> sources) async {
    if (sources.length > maxImportFiles) {
      throw TooManyFilesException(count: sources.length, limit: maxImportFiles);
    }
    if (sources.isEmpty) return const ImportReport(<FileImportResult>[]);

    var batch = ImportBatch(
      id: _newId(),
      importedAt: _clock().toUtc(),
      source: ImportBatch.filePicker,
      fileCount: sources.length,
    );
    var batchStored = true;
    try {
      await _repository.addBatch(batch);
    } on Object {
      batchStored = false;
    }

    final results = <FileImportResult>[];
    for (final source in sources) {
      final ImportOutcome outcome;
      if (!_isJson(source.name)) {
        outcome = const Skipped();
      } else if (!batchStored) {
        outcome = const Failed(ImportFailure(ImportFailureKind.storageError));
      } else {
        outcome = await _importOne(source, batch.id);
      }
      results.add(FileImportResult(source.name, outcome));
    }

    final report = ImportReport(results);
    batch = batch.withCounts(
      importedCount: report.importedCount,
      duplicateCount: report.duplicateCount,
      failedCount: report.failedCount,
    );
    if (batchStored) {
      try {
        await _repository.updateBatch(batch);
      } on Object {
        // The documents are stored; only the counts of the history are lost.
      }
    }
    return report;
  }

  bool _isJson(String name) => name.toLowerCase().endsWith('.json');

  Future<ImportOutcome> _importOne(ImportSource source, String batchId) async {
    try {
      final size = await source.length();
      if (size > maxImportFileBytes) {
        return Failed(
          ImportFailure(
            ImportFailureKind.tooLarge,
            size: size,
            limit: maxImportFileBytes,
          ),
        );
      }
      final text = await source.readText();
      final parsed = await _parser.parse(text);

      final existing = await _repository.findByDocumentId(parsed.documentId);
      if (existing != null) return Duplicate(parsed.documentId, existing);

      final local = parsed.createdAtLocal;
      final document = ScanDocument(
        id: _newId(),
        documentId: parsed.documentId,
        importId: batchId,
        sourceFileName: source.name,
        createdAt: parsed.createdAtUtc ?? _localToUtc(local!),
        ocrText: parsed.ocrText,
        language: parsed.language,
        pdfName: parsed.pdfName,
        imageNames: parsed.imageNames,
        schemaVersion: parsed.schemaVersion,
        wasLegacy: parsed.wasLegacy,
      );
      try {
        await _repository.add(document);
      } on Object {
        return const Failed(ImportFailure(ImportFailureKind.storageError));
      }
      return Imported(document);
    } on ImportFailureException catch (e) {
      return Failed(e.failure);
    } on Object {
      return const Failed(ImportFailure(ImportFailureKind.unexpected));
    }
  }
}
