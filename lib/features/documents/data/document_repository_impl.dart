import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/document_type.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> addBatch(ImportBatch batch) async {
    await _db.into(_db.imports).insert(_batchCompanion(batch));
  }

  @override
  Future<void> updateBatch(ImportBatch batch) async {
    await (_db.update(
      _db.imports,
    )..where((t) => t.id.equals(batch.id))).write(_batchCompanion(batch));
  }

  @override
  Future<ImportBatch?> getBatch(String id) async {
    final row = await (_db.select(
      _db.imports,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toBatch(row);
  }

  @override
  Future<void> add(ScanDocument document) async {
    await _db.into(_db.documents).insert(_companion(document));
  }

  @override
  Future<ScanDocument?> get(String id) async {
    final row = await (_db.select(
      _db.documents,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDocument(row);
  }

  @override
  Future<ScanDocument?> findByDocumentId(String documentId) async {
    final row = await (_db.select(
      _db.documents,
    )..where((t) => t.documentId.equals(documentId))).getSingleOrNull();
    return row == null ? null : _toDocument(row);
  }

  @override
  Future<List<ScanDocument>> list() async {
    final query = _db.select(_db.documents)
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAtUtc),
        (t) => OrderingTerm.desc(t.id),
      ]);
    return (await query.get()).map(_toDocument).toList();
  }

  /// The foreign key of `expenses.document_id` (`ON DELETE SET NULL`) clears
  /// the links; the database turns foreign keys on in `beforeOpen`.
  @override
  Future<void> delete(String id) async {
    await (_db.delete(_db.documents)..where((t) => t.id.equals(id))).go();
  }

  ImportsCompanion _batchCompanion(ImportBatch b) => ImportsCompanion(
    id: Value(b.id),
    importedAt: Value(b.importedAt),
    source: Value(b.source),
    fileCount: Value(b.fileCount),
    importedCount: Value(b.importedCount),
    duplicateCount: Value(b.duplicateCount),
    failedCount: Value(b.failedCount),
  );

  ImportBatch _toBatch(ImportRow row) => ImportBatch(
    id: row.id,
    importedAt: row.importedAt.toUtc(),
    source: row.source,
    fileCount: row.fileCount,
    importedCount: row.importedCount,
    duplicateCount: row.duplicateCount,
    failedCount: row.failedCount,
  );

  DocumentsCompanion _companion(ScanDocument d) => DocumentsCompanion(
    id: Value(d.id),
    documentId: Value(d.documentId),
    importId: Value(d.importId),
    sourceFileName: Value(d.sourceFileName),
    createdAtUtc: Value(d.createdAt),
    ocrText: Value(d.ocrText),
    language: Value(d.language),
    documentType: Value(d.documentType.name),
    pdfName: Value(d.pdfName),
    imageNames: Value(jsonEncode(d.imageNames)),
    schemaVersion: Value(d.schemaVersion),
    wasLegacy: Value(d.wasLegacy),
  );

  ScanDocument _toDocument(DocumentRow row) => ScanDocument(
    id: row.id,
    documentId: row.documentId,
    importId: row.importId,
    sourceFileName: row.sourceFileName,
    createdAt: row.createdAtUtc.toUtc(),
    ocrText: row.ocrText,
    language: row.language,
    documentType: DocumentType.fromName(row.documentType),
    pdfName: row.pdfName,
    imageNames: _decodeNames(row.imageNames),
    schemaVersion: row.schemaVersion,
    wasLegacy: row.wasLegacy,
  );

  /// Names are labels: a damaged value reads as no names, never as a crash.
  List<String> _decodeNames(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return decoded.whereType<String>().toList();
    } on FormatException {
      // fall through
    }
    return const <String>[];
  }
}
