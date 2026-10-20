import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/documents/data/document_repository_impl.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/document_type.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/expenses/data/expense_repository_impl.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';

ImportBatch _batch({String id = 'b1', int files = 3}) => ImportBatch(
  id: id,
  importedAt: DateTime.utc(2026, 10, 20, 12),
  source: ImportBatch.filePicker,
  fileCount: files,
);

ScanDocument _doc(
  String id, {
  String documentId = 'scan-1',
  String importId = 'b1',
  String ocrText = 'ΔΕΗ 84,20',
  String? language,
  DocumentType type = DocumentType.unknown,
  String? pdf,
  List<String> images = const <String>[],
  DateTime? createdAt,
  bool legacy = false,
}) => ScanDocument(
  id: id,
  documentId: documentId,
  importId: importId,
  sourceFileName: '$id.json',
  createdAt: createdAt ?? DateTime.utc(2026, 10, 18, 6, 41, 7),
  ocrText: ocrText,
  language: language,
  documentType: type,
  pdfName: pdf,
  imageNames: images,
  schemaVersion: 1,
  wasLegacy: legacy,
);

Expense _expense(String id, {String? documentId}) => Expense(
  id: id,
  categoryId: 'food',
  date: CalendarDate(2026, 10, 19),
  currencyCode: 'EUR',
  amount: const Money(4500),
  documentId: documentId,
  createdAt: DateTime.utc(2026, 10, 19, 9),
  updatedAt: DateTime.utc(2026, 10, 19, 9),
);

void main() {
  late AppDatabase db;
  late DocumentRepositoryImpl repository;
  late ExpenseRepositoryImpl expenses;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = DocumentRepositoryImpl(db);
    expenses = ExpenseRepositoryImpl(db);
    await repository.addBatch(_batch());
  });

  tearDown(() => db.close());

  group('batches', () {
    test('round trip and counts update', () async {
      final back = (await repository.getBatch('b1'))!;
      expect(back.source, 'file_picker');
      expect(back.importedAt, DateTime.utc(2026, 10, 20, 12));
      expect((back.fileCount, back.importedCount), (3, 0));

      await repository.updateBatch(
        back.withCounts(importedCount: 1, duplicateCount: 1, failedCount: 0),
      );
      final updated = (await repository.getBatch('b1'))!;
      expect(
        (updated.importedCount, updated.duplicateCount, updated.failedCount),
        (1, 1, 0),
      );
      expect(updated.skippedCount, 1);
      expect(await repository.getBatch('nope'), isNull);
    });

    test('counts that do not fit the file count are rejected', () async {
      await expectLater(
        repository.addBatch(
          _batch(
            id: 'b2',
            files: 1,
          ).withCounts(importedCount: 1, duplicateCount: 1, failedCount: 0),
        ),
        throwsA(anything),
      );
      await expectLater(
        repository.addBatch(_batch(id: 'b3', files: -1)),
        throwsA(anything),
      );
    });
  });

  group('documents', () {
    test('every field survives a round trip', () async {
      final doc = _doc(
        'd1',
        language: 'el',
        pdf: 'a.pdf',
        images: ['ά.jpg', 'b "2".jpg'],
        type: DocumentType.utilityBill,
        legacy: true,
      );
      await repository.add(doc);
      final back = (await repository.get('d1'))!;
      expect(back.documentId, 'scan-1');
      expect(back.importId, 'b1');
      expect(back.sourceFileName, 'd1.json');
      expect(back.createdAt, DateTime.utc(2026, 10, 18, 6, 41, 7));
      expect(back.createdAt.isUtc, isTrue);
      expect(back.ocrText, 'ΔΕΗ 84,20');
      expect(back.language, 'el');
      expect(back.documentType, DocumentType.utilityBill);
      expect(back.pdfName, 'a.pdf');
      expect(back.imageNames, ['ά.jpg', 'b "2".jpg']);
      expect(back.schemaVersion, 1);
      expect(back.wasLegacy, isTrue);
    });

    test('optional fields stay empty', () async {
      await repository.add(_doc('d1'));
      final back = (await repository.get('d1'))!;
      expect(back.language, isNull);
      expect(back.pdfName, isNull);
      expect(back.imageNames, isEmpty);
      expect(back.documentType, DocumentType.unknown);
      expect(back.wasLegacy, isFalse);
    });

    test('find by documentId', () async {
      await repository.add(_doc('d1', documentId: 'scan-A'));
      expect((await repository.findByDocumentId('scan-A'))!.id, 'd1');
      expect(await repository.findByDocumentId('scan-B'), isNull);
      expect(await repository.get('missing'), isNull);
    });

    test('documentId is unique', () async {
      await repository.add(_doc('d1'));
      await expectLater(repository.add(_doc('d2')), throwsA(anything));
      expect(await repository.list(), hasLength(1));
    });

    test('a document needs a stored batch', () async {
      await expectLater(
        repository.add(_doc('d1', importId: 'no-such-batch')),
        throwsA(anything),
      );
    });

    test(
      'a blank OCR text or documentId is rejected by the database',
      () async {
        await expectLater(
          repository.add(_doc('d1', ocrText: '  \n ')),
          throwsA(anything),
        );
        await expectLater(
          repository.add(_doc('d2', documentId: '  ')),
          throwsA(anything),
        );
        await expectLater(
          repository.add(_doc('d3', language: ' ')),
          throwsA(anything),
        );
        expect(await repository.list(), isEmpty);
      },
    );

    test('list: newest createdAt first', () async {
      await repository.add(
        _doc('old', documentId: 'a', createdAt: DateTime.utc(2026, 1, 1)),
      );
      await repository.add(
        _doc('new', documentId: 'b', createdAt: DateTime.utc(2026, 9, 1)),
      );
      await repository.add(
        _doc('mid', documentId: 'c', createdAt: DateTime.utc(2026, 5, 1)),
      );
      expect((await repository.list()).map((d) => d.id), ['new', 'mid', 'old']);
    });

    test('an unknown document type in the database reads as unknown', () async {
      await repository.add(_doc('d1', type: DocumentType.invoice));
      await db.customStatement(
        "UPDATE documents SET document_type = 'hologram' WHERE id = 'd1'",
      );
      expect((await repository.get('d1'))!.documentType, DocumentType.unknown);
      await db.customStatement(
        "UPDATE documents SET document_type = '' WHERE id = 'd1'",
      );
      expect((await repository.get('d1'))!.documentType, DocumentType.unknown);
      await db.customStatement(
        "UPDATE documents SET document_type = 'receipt' WHERE id = 'd1'",
      );
      expect((await repository.get('d1'))!.documentType, DocumentType.receipt);
    });

    test('damaged image names read as no names, not a crash', () async {
      await repository.add(_doc('d1', images: ['a.jpg']));
      for (final bad in ['not json', '{"a":1}', '[1, "x", null]']) {
        await db.customStatement(
          "UPDATE documents SET image_names = '$bad' WHERE id = 'd1'",
        );
        final names = (await repository.get('d1'))!.imageNames;
        expect(names, bad == '[1, "x", null]' ? ['x'] : isEmpty);
      }
    });
  });

  group('delete', () {
    test('removes the document; the batch stays', () async {
      await repository.add(_doc('d1'));
      await repository.delete('d1');
      expect(await repository.get('d1'), isNull);
      expect(await repository.getBatch('b1'), isNotNull);
    });

    test('deleting a missing document is harmless', () async {
      await repository.delete('nope');
    });

    test('linked expenses stay and their link is cleared', () async {
      await repository.add(_doc('d1'));
      await repository.add(_doc('d2', documentId: 'scan-2'));
      await expenses.add(_expense('e1', documentId: 'd1'));
      await expenses.add(_expense('e2', documentId: 'd1'));
      await expenses.add(_expense('e3', documentId: 'd2'));
      await expenses.add(_expense('e4'));

      await repository.delete('d1');

      expect((await expenses.get('e1'))!.documentId, isNull);
      expect((await expenses.get('e2'))!.documentId, isNull);
      expect((await expenses.get('e1'))!.amount, const Money(4500));
      expect((await expenses.get('e3'))!.documentId, 'd2');
      expect(await expenses.list(), hasLength(4));
    });

    test('the same documentId can be imported again', () async {
      await repository.add(_doc('d1'));
      await repository.delete('d1');
      await repository.add(_doc('d1b'));
      expect((await repository.findByDocumentId('scan-1'))!.id, 'd1b');
    });
  });

  group('the link on expenses', () {
    test('round trip, listByDocument, documentIdsWithExpenses', () async {
      await repository.add(_doc('d1'));
      await repository.add(_doc('d2', documentId: 'scan-2'));
      await expenses.add(_expense('e1', documentId: 'd1'));
      await expenses.add(_expense('e2', documentId: 'd1'));
      await expenses.add(_expense('e3', documentId: 'd2'));
      await expenses.add(_expense('e4'));

      expect((await expenses.get('e1'))!.documentId, 'd1');
      expect((await expenses.get('e4'))!.documentId, isNull);
      expect((await expenses.listByDocument('d1')).map((e) => e.id).toSet(), {
        'e1',
        'e2',
      });
      expect(await expenses.listByDocument('none'), isEmpty);
      expect(await expenses.documentIdsWithExpenses(), {'d1', 'd2'});
    });

    test('a link to a missing document is a typed error', () async {
      final typed = throwsA(
        isA<ExpenseValidationException>().having(
          (e) => e.error,
          'error',
          ExpenseValidationError.documentNotFound,
        ),
      );
      await expectLater(
        expenses.add(_expense('e1', documentId: 'missing')),
        typed,
      );
      expect(await expenses.get('e1'), isNull);

      await expenses.add(_expense('e2'));
      await expectLater(
        expenses.update(_expense('e2', documentId: 'missing')),
        typed,
      );
      expect((await expenses.get('e2'))!.documentId, isNull);
    });

    test('update keeps or sets the link', () async {
      await repository.add(_doc('d1'));
      await expenses.add(_expense('e1'));
      await expenses.update(_expense('e1', documentId: 'd1'));
      expect((await expenses.get('e1'))!.documentId, 'd1');
    });
  });
}
