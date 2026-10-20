import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/document_type.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/document_usecases.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/create_expense.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/expense_validation.dart';
import 'package:simple_budgeting_app/features/expenses/domain/usecases/update_expense.dart';

import '../../../support/document_fakes.dart';
import '../../../support/expense_fakes.dart';

void main() {
  late FakeExpenseRepository expenses;
  late FakeDocumentRepository documents;
  final at = DateTime.utc(2026, 10, 20);

  ScanDocument doc(String id, {DateTime? createdAt}) => ScanDocument(
    id: id,
    documentId: 'scan-$id',
    importId: 'i1',
    sourceFileName: '$id.json',
    createdAt: createdAt ?? at,
    ocrText: 'text $id',
    schemaVersion: 1,
    wasLegacy: false,
  );

  Expense expense(String id, {String? documentId, int day = 1}) => Expense(
    id: id,
    categoryId: 'food',
    date: CalendarDate(2026, 10, day),
    currencyCode: 'EUR',
    amount: const Money(100),
    documentId: documentId,
    createdAt: at,
    updatedAt: at,
  );

  setUp(() {
    expenses = FakeExpenseRepository();
    documents = FakeDocumentRepository(expenses: expenses);
  });

  group('DocumentType', () {
    test('reads its own names', () {
      for (final type in DocumentType.values) {
        expect(DocumentType.fromName(type.name), type);
      }
    });

    test('an unknown or missing name reads as unknown', () {
      expect(DocumentType.fromName('passport'), DocumentType.unknown);
      expect(DocumentType.fromName(''), DocumentType.unknown);
      expect(DocumentType.fromName(null), DocumentType.unknown);
      expect(DocumentType.fromName('Receipt'), DocumentType.unknown);
    });

    test('has the agreed values, unknown first', () {
      expect(DocumentType.values.map((t) => t.name), [
        'unknown',
        'receipt',
        'utilityBill',
        'invoice',
        'statement',
        'contract',
        'genericDocument',
      ]);
    });
  });

  test('ListDocuments: newest createdAt first', () async {
    await documents.add(doc('old', createdAt: DateTime.utc(2026, 1, 1)));
    await documents.add(doc('new', createdAt: DateTime.utc(2026, 9, 1)));
    final list = await ListDocuments(documents)();
    expect(list.map((d) => d.id), ['new', 'old']);
  });

  test('GetDocument: found and missing', () async {
    await documents.add(doc('a'));
    expect((await GetDocument(documents)('a'))!.id, 'a');
    expect(await GetDocument(documents)('zzz'), isNull);
  });

  group('expenses linked to a document', () {
    setUp(() async {
      await expenses.add(expense('e1', documentId: 'a', day: 3));
      await expenses.add(expense('e2', documentId: 'a', day: 5));
      await expenses.add(expense('e3', documentId: 'b'));
      await expenses.add(expense('e4'));
    });

    test('ListDocumentExpenses: only that document, newest first', () async {
      final list = await ListDocumentExpenses(expenses)('a');
      expect(list.map((e) => e.id), ['e2', 'e1']);
      expect(await ListDocumentExpenses(expenses)('none'), isEmpty);
    });

    test('ListDocumentIdsWithExpenses', () async {
      expect(await ListDocumentIdsWithExpenses(expenses)(), {'a', 'b'});
    });
  });

  group('DeleteDocument', () {
    setUp(() async {
      await documents.add(doc('a'));
      await expenses.add(expense('e1', documentId: 'a'));
      await expenses.add(expense('e2', documentId: 'a', day: 2));
      await expenses.add(expense('e3'));
    });

    test('counts the expenses that stay, for the confirmation', () async {
      final use = DeleteDocument(documents, expenses);
      expect(await use.linkedExpenseCount('a'), 2);
      expect(await use.linkedExpenseCount('none'), 0);
      expect(documents.documents, isNotEmpty); // counting deletes nothing
    });

    test('deletes the document, keeps the expenses, clears the link', () async {
      final stayed = await DeleteDocument(documents, expenses)('a');
      expect(stayed, 2);
      expect(documents.documents, isEmpty);
      expect(expenses.expenses, hasLength(3));
      expect(
        expenses.expenses.values.every((e) => e.documentId == null),
        isTrue,
      );
    });

    test('a document without expenses: zero stay', () async {
      await documents.add(doc('lonely'));
      expect(await DeleteDocument(documents, expenses)('lonely'), 0);
      expect(documents.documents.keys, ['a']);
    });
  });

  group('the link from an expense', () {
    late CreateExpense create;
    late UpdateExpense update;
    var n = 0;

    setUp(() {
      n = 0;
      expenses.knownDocumentIds = {'a'};
      create = CreateExpense(
        expenses,
        FakeCategoryRepository(),
        () => at,
        () => 'x${++n}',
      );
      update = UpdateExpense(expenses, FakeCategoryRepository(), () => at);
    });

    test('CreateExpense stores the link', () async {
      final e = await create(
        categoryId: 'food',
        date: CalendarDate(2026, 10, 18),
        currencyCode: 'EUR',
        amount: const Money(8420),
        description: 'ΔΕΗ',
        documentId: 'a',
      );
      expect(e.documentId, 'a');
      expect((await expenses.get(e.id))!.documentId, 'a');
    });

    test('without a document the link is null', () async {
      final e = await create(
        categoryId: 'food',
        date: CalendarDate(2026, 10, 18),
        currencyCode: 'EUR',
        amount: const Money(100),
      );
      expect(e.documentId, isNull);
    });

    test('a link to a missing document is a typed error', () async {
      await expectLater(
        create(
          categoryId: 'food',
          date: CalendarDate(2026, 10, 18),
          currencyCode: 'EUR',
          amount: const Money(100),
          documentId: 'missing',
        ),
        throwsA(
          isA<ExpenseValidationException>().having(
            (e) => e.error,
            'error',
            ExpenseValidationError.documentNotFound,
          ),
        ),
      );
      expect(expenses.expenses, isEmpty);
    });

    test('editing an expense keeps its link', () async {
      final e = await create(
        categoryId: 'food',
        date: CalendarDate(2026, 10, 18),
        currencyCode: 'EUR',
        amount: const Money(100),
        documentId: 'a',
      );
      final edited = await update(
        expenseId: e.id,
        categoryId: 'health',
        date: CalendarDate(2026, 10, 19),
        currencyCode: 'EUR',
        amount: const Money(250),
      );
      expect(edited.documentId, 'a');
      expect((await expenses.get(e.id))!.categoryId, 'health');
    });
  });
}
