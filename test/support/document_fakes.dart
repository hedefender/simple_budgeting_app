import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/parsed_scan.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/document_repository.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_file_picker.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_source.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/scan_json_parser.dart';

import 'expense_fakes.dart';

/// In-memory document repository for tests that must not touch SQLite.
class FakeDocumentRepository implements DocumentRepository {
  FakeDocumentRepository({this.expenses});

  /// When set, deleting a document clears the link of its expenses, like the
  /// database does.
  final FakeExpenseRepository? expenses;

  final Map<String, ScanDocument> documents = <String, ScanDocument>{};
  final Map<String, ImportBatch> batches = <String, ImportBatch>{};

  /// Make a method fail, to test the error handling.
  Object? addBatchError;
  Object? updateBatchError;
  Object? addError;
  Object? findError;

  @override
  Future<void> addBatch(ImportBatch batch) async {
    if (addBatchError != null) throw addBatchError!;
    batches[batch.id] = batch;
  }

  @override
  Future<void> updateBatch(ImportBatch batch) async {
    if (updateBatchError != null) throw updateBatchError!;
    batches[batch.id] = batch;
  }

  @override
  Future<ImportBatch?> getBatch(String id) async => batches[id];

  @override
  Future<void> add(ScanDocument document) async {
    if (addError != null) throw addError!;
    documents[document.id] = document;
  }

  @override
  Future<ScanDocument?> get(String id) async => documents[id];

  @override
  Future<ScanDocument?> findByDocumentId(String documentId) async {
    if (findError != null) throw findError!;
    for (final d in documents.values) {
      if (d.documentId == documentId) return d;
    }
    return null;
  }

  @override
  Future<List<ScanDocument>> list() async {
    final all = documents.values.toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  @override
  Future<void> delete(String id) async {
    documents.remove(id);
    expenses?.clearDocumentLink(id);
  }
}

/// Returns a prepared result per text: a [ParsedScan] or an [ImportFailure]
/// (which is thrown as the real adapter does). An unknown text is invalid
/// JSON. Host tests never load the native library, so this stands in for the
/// Rust parser.
class FakeScanJsonParser implements ScanJsonParser {
  final Map<String, Object> results = <String, Object>{};
  final List<String> parsed = <String>[];

  /// Thrown (instead of a result) for every call when set.
  Object? crash;

  @override
  Future<ParsedScan> parse(String text) async {
    parsed.add(text);
    if (crash != null) throw crash!;
    final result =
        results[text] ?? const ImportFailure(ImportFailureKind.invalidJson);
    if (result is ImportFailure) throw ImportFailureException(result);
    return result as ParsedScan;
  }
}

/// The file chooser: returns the files the test prepared, or none (the user
/// cancelled).
class FakeImportFilePicker implements ImportFilePicker {
  List<ImportSource> next = <ImportSource>[];
  int calls = 0;

  /// Thrown by [pick] when set.
  Object? error;

  @override
  Future<List<ImportSource>> pick() async {
    calls++;
    if (error != null) throw error!;
    final files = next;
    next = <ImportSource>[];
    return files;
  }
}

/// A picked file. Records the order of the reads and whether two reads
/// overlapped.
class FakeImportSource implements ImportSource {
  FakeImportSource(
    this.name, {
    this.text = '',
    int? size,
    this.lengthFailure,
    this.readFailure,
    this.log,
  }) : size = size ?? text.length;

  @override
  final String name;
  final String text;
  final int size;
  final ImportFailure? lengthFailure;
  final ImportFailure? readFailure;
  final FakeReadLog? log;

  int reads = 0;

  @override
  Future<int> length() async {
    if (lengthFailure != null) throw ImportFailureException(lengthFailure!);
    return size;
  }

  @override
  Future<String> readText() async {
    reads++;
    log?.start(name);
    // Give a concurrent caller the chance to overlap.
    await Future<void>.delayed(Duration.zero);
    log?.end(name);
    if (readFailure != null) throw ImportFailureException(readFailure!);
    return text;
  }
}

class FakeReadLog {
  final List<String> order = <String>[];
  int _active = 0;
  bool overlapped = false;

  void start(String name) {
    order.add(name);
    _active++;
    if (_active > 1) overlapped = true;
  }

  void end(String name) => _active--;
}

ParsedScan parsedScan(
  String documentId, {
  String ocrText = 'Some text',
  DateTime? createdAtUtc,
  String? createdAtLocal,
  String? language,
  String? pdfName,
  List<String> imageNames = const <String>[],
  bool wasLegacy = false,
}) {
  final hasUtc = createdAtUtc != null;
  final hasLocal = createdAtLocal != null;
  return ParsedScan(
    schemaVersion: 1,
    documentId: documentId,
    ocrText: ocrText,
    wasLegacy: wasLegacy,
    createdAtUtc: hasUtc || hasLocal
        ? createdAtUtc
        : DateTime.utc(2026, 10, 18, 6, 41, 7),
    createdAtLocal: createdAtLocal,
    language: language,
    pdfName: pdfName,
    imageNames: imageNames,
  );
}
