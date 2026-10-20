import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';

abstract interface class DocumentRepository {
  /// Stores the batch before its documents, which point to it.
  Future<void> addBatch(ImportBatch batch);

  /// Replaces the counts of the stored batch.
  Future<void> updateBatch(ImportBatch batch);

  Future<void> add(ScanDocument document);

  Future<ScanDocument?> get(String id);

  Future<ScanDocument?> findByDocumentId(String documentId);

  /// Newest `createdAt` first, then newest imported first.
  Future<List<ScanDocument>> list();

  /// Deletes the document. Linked expenses stay; their link is cleared. The
  /// batch row is kept (history).
  Future<void> delete(String id);

  /// The stored batch, or null.
  Future<ImportBatch?> getBatch(String id);
}
