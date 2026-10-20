import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_report.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_file_picker.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_source.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/document_usecases.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/import_scan_files.dart';
import 'package:simple_budgeting_app/features/expenses/presentation/expense_providers.dart';

/// Every document, newest first.
final FutureProvider<List<ScanDocument>> documentListProvider =
    FutureProvider.autoDispose<List<ScanDocument>>(
      (Ref ref) => ref.watch(serviceLocatorProvider).get<ListDocuments>()(),
    );

/// One document by its local id, or null when it no longer exists.
final documentProvider = FutureProvider.autoDispose
    .family<ScanDocument?, String>(
      (Ref ref, String id) =>
          ref.watch(serviceLocatorProvider).get<GetDocument>()(id),
    );

/// The import batch of a document, by the batch id.
final importBatchProvider = FutureProvider.autoDispose
    .family<ImportBatch?, String>(
      (Ref ref, String id) =>
          ref.watch(serviceLocatorProvider).get<GetImportBatch>()(id),
    );

final Provider<ImportFilePicker> importFilePickerProvider =
    Provider<ImportFilePicker>(
      (Ref ref) => ref.watch(serviceLocatorProvider).get<ImportFilePicker>(),
    );

final Provider<DocumentActions> documentActionsProvider =
    Provider<DocumentActions>((Ref ref) => DocumentActions(ref));

/// Runs the document use cases and refreshes what the screens show.
class DocumentActions {
  DocumentActions(this._ref);

  final Ref _ref;

  T _use<T extends Object>() => _ref.read(serviceLocatorProvider).get<T>();

  void _refresh() {
    _ref
      ..invalidate(documentListProvider)
      ..invalidate(documentProvider)
      ..invalidate(documentIdsWithExpensesProvider)
      ..invalidate(documentExpensesProvider)
      ..invalidate(expenseListProvider);
  }

  /// Lets the user pick files. Empty when the user cancelled.
  Future<List<ImportSource>> pick() =>
      _ref.read(importFilePickerProvider).pick();

  /// Throws [TooManyFilesException] for more files than one batch accepts.
  Future<ImportReport> import(List<ImportSource> sources) async {
    try {
      return await _use<ImportScanFiles>()(sources);
    } finally {
      _refresh();
    }
  }

  /// Deletes the document; returns how many expenses stayed without it.
  Future<int> delete(String id) async {
    final stayed = await _use<DeleteDocument>()(id);
    _refresh();
    return stayed;
  }

  /// How many expenses are linked to the document (for the confirmation).
  Future<int> linkedExpenseCount(String id) =>
      _use<DeleteDocument>().linkedExpenseCount(id);

  /// Refreshes the screens after an expense was made from a document.
  void expenseCreated() => _refresh();
}
