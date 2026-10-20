import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/document_repository.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/repositories/expense_repository.dart';

class ListDocuments {
  const ListDocuments(this._repository);

  final DocumentRepository _repository;

  Future<List<ScanDocument>> call() => _repository.list();
}

class GetDocument {
  const GetDocument(this._repository);

  final DocumentRepository _repository;

  Future<ScanDocument?> call(String id) => _repository.get(id);
}

/// The import batch that brought a document in (when, from where).
class GetImportBatch {
  const GetImportBatch(this._repository);

  final DocumentRepository _repository;

  Future<ImportBatch?> call(String id) => _repository.getBatch(id);
}

/// The expenses made from one document, newest first.
class ListDocumentExpenses {
  const ListDocumentExpenses(this._expenses);

  final ExpenseRepository _expenses;

  Future<List<Expense>> call(String documentId) =>
      _expenses.listByDocument(documentId);
}

/// The ids of the documents that have at least one expense.
class ListDocumentIdsWithExpenses {
  const ListDocumentIdsWithExpenses(this._expenses);

  final ExpenseRepository _expenses;

  Future<Set<String>> call() => _expenses.documentIdsWithExpenses();
}

/// Deletes a document and keeps its expenses (their link is cleared). The
/// same `documentId` can be imported again afterwards.
class DeleteDocument {
  const DeleteDocument(this._repository, this._expenses);

  final DocumentRepository _repository;
  final ExpenseRepository _expenses;

  /// How many expenses stay without a document: shown in the confirmation.
  Future<int> linkedExpenseCount(String id) async =>
      (await _expenses.listByDocument(id)).length;

  /// Returns the number of expenses that stayed.
  Future<int> call(String id) async {
    final stayed = await linkedExpenseCount(id);
    await _repository.delete(id);
    return stayed;
  }
}
