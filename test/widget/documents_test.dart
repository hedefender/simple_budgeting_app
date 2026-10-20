import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/scan_document.dart';
import 'package:simple_budgeting_app/features/documents/presentation/document_detail_page.dart';
import 'package:simple_budgeting_app/features/documents/presentation/documents_page.dart';
import 'package:simple_budgeting_app/features/expenses/domain/entities/expense.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/balance_anchor.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

import '../support/document_fakes.dart';
import '../support/income_fakes.dart';

/// "Today" is 2026-10-16. Documents are created at 12:00 UTC, so their local
/// day is the same in every time zone the tests may run in.
void main() {
  late GetIt locator;
  late dynamic fakes;
  final created = DateTime.utc(2026, 10, 18, 12, 0, 0);

  setUp(() {
    locator = GetIt.asNewInstance();
    fakes = registerIncomeFakes(
      locator,
      clock: () => DateTime.utc(2026, 10, 16, 9),
    );
    fakes.settings.primaryCurrency = 'EUR';
    fakes.documents.batches['b1'] = ImportBatch(
      id: 'b1',
      importedAt: DateTime.utc(2026, 10, 20, 12),
      source: ImportBatch.filePicker,
      fileCount: 1,
      importedCount: 1,
    );
  });

  tearDown(() => locator.reset());

  Future<void> pump(
    WidgetTester tester,
    Widget page, {
    Locale locale = const Locale('en', 'US'),
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceLocatorProvider.overrideWithValue(locator),
          deviceLocaleProvider.overrideWithValue(locale),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: page,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<ScanDocument> seed(
    String id, {
    String text = 'ΔΕΗ Α.Ε.\nΣΥΝΟΛΟ 84,20 EUR',
    String? language,
    String? pdf,
    List<String> images = const [],
    bool legacy = false,
    DateTime? at,
  }) async {
    final doc = ScanDocument(
      id: id,
      documentId: 'scan-$id',
      importId: 'b1',
      sourceFileName: '$id.json',
      createdAt: at ?? created,
      ocrText: text,
      language: language,
      pdfName: pdf,
      imageNames: images,
      schemaVersion: 1,
      wasLegacy: legacy,
    );
    await fakes.documents.add(doc);
    return doc;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  /// A file the fake parser turns into [result].
  FakeImportSource pick(String name, Object result) {
    final text = 'text of $name';
    fakes.parser.results[text] = result;
    return FakeImportSource(name, text: text);
  }

  group('the list', () {
    testWidgets('empty: an explanation and the import button', (tester) async {
      await pump(tester, const DocumentsPage());
      expect(find.byKey(const Key('documents-empty')), findsOneWidget);
      expect(find.text('No documents yet'), findsOneWidget);
      expect(find.byKey(const Key('documents-empty-import')), findsOneWidget);
      expect(find.byKey(const Key('document-import')), findsOneWidget);
    });

    testWidgets('a document: first line, day, file, legacy mark', (
      tester,
    ) async {
      await seed('a', legacy: true);
      await pump(tester, const DocumentsPage());
      expect(find.byKey(const Key('documents-empty')), findsNothing);
      final tile = find.byKey(const Key('document-tile-a'));
      expect(
        find.descendant(of: tile, matching: find.text('ΔΕΗ Α.Ε.')),
        findsOne,
      );
      expect(
        find.descendant(
          of: tile,
          matching: find.textContaining(
            'Oct 18, 2026 · a.json · Legacy format',
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('newest first', (tester) async {
      await seed('old', text: 'Old one', at: DateTime.utc(2026, 1, 5, 12));
      await seed('new', text: 'New one', at: DateTime.utc(2026, 9, 5, 12));
      await pump(tester, const DocumentsPage());
      final newTop = tester.getTopLeft(
        find.byKey(const Key('document-tile-new')),
      );
      final oldTop = tester.getTopLeft(
        find.byKey(const Key('document-tile-old')),
      );
      expect(newTop.dy, lessThan(oldTop.dy));
    });

    testWidgets('a document with an expense shows the chip', (tester) async {
      await seed('a');
      await seed('b', text: 'Other');
      await fakes.expenses.add(
        Expense(
          id: 'e1',
          categoryId: 'food',
          date: CalendarDate(2026, 10, 18),
          currencyCode: 'EUR',
          amount: const Money(100),
          documentId: 'a',
          createdAt: created,
          updatedAt: created,
        ),
      );
      await pump(tester, const DocumentsPage());
      expect(find.byKey(const Key('document-linked-a')), findsOneWidget);
      expect(find.byKey(const Key('document-linked-b')), findsNothing);
    });

    testWidgets('a text without a line shows a placeholder title', (
      tester,
    ) async {
      await seed('a', text: ' \n\t');
      await pump(tester, const DocumentsPage());
      expect(find.text('(no text)'), findsOneWidget);
    });

    testWidgets('Greek', (tester) async {
      await seed('a');
      await pump(
        tester,
        const DocumentsPage(),
        locale: const Locale('el', 'GR'),
      );
      expect(find.text('Έγγραφα'), findsOneWidget);
    });
  });

  group('import', () {
    testWidgets('one file: the report, then the document in the list', (
      tester,
    ) async {
      fakes.picker.next = [
        pick('scan.json', parsedScan('d1', ocrText: 'Cosmote 29,90')),
      ];
      await pump(tester, const DocumentsPage());

      await tapKey(tester, 'document-import');

      expect(find.text('Import report'), findsOneWidget);
      expect(find.byKey(const Key('import-summary')), findsOneWidget);
      expect(find.text('Imported: 1'), findsOneWidget);
      expect(find.text('scan.json'), findsOneWidget);
      expect(find.text('Imported'), findsOneWidget);

      await tapKey(tester, 'import-done');
      expect(find.text('Cosmote 29,90'), findsOneWidget);
      expect(find.byKey(const Key('documents-empty')), findsNothing);
    });

    testWidgets('the empty state button imports too', (tester) async {
      fakes.picker.next = [pick('scan.json', parsedScan('d1'))];
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'documents-empty-import');
      expect(find.text('Import report'), findsOneWidget);
    });

    testWidgets('several files: one row each, in order, with the reasons', (
      tester,
    ) async {
      await seed('known', text: 'Known');
      fakes.documents.documents['known'] = ScanDocument(
        id: 'known',
        documentId: 'dup',
        importId: 'b1',
        sourceFileName: 'known.json',
        createdAt: created,
        ocrText: 'Known',
        schemaVersion: 1,
        wasLegacy: false,
      );
      fakes.picker.next = [
        pick('ok.json', parsedScan('d-ok', ocrText: 'Fresh one')),
        pick('again.json', parsedScan('dup')),
        FakeImportSource('receipt.pdf', text: 'binary'),
        pick('bad.json', const ImportFailure(ImportFailureKind.emptyOcrText)),
        pick(
          'future.json',
          const ImportFailure(
            ImportFailureKind.unsupportedSchemaVersion,
            foundVersion: 2,
            knownVersion: 1,
          ),
        ),
        pick(
          'typo.json',
          const ImportFailure(ImportFailureKind.wrongType, field: 'ocrText'),
        ),
        pick(
          'broken.json',
          const ImportFailure(
            ImportFailureKind.invalidJson,
            line: 3,
            column: 7,
          ),
        ),
        pick(
          'huge.json',
          const ImportFailure(
            ImportFailureKind.tooLarge,
            size: 6 * 1024 * 1024,
            limit: 5 * 1024 * 1024,
          ),
        ),
        pick('empty.json', const ImportFailure(ImportFailureKind.emptyFile)),
      ];
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'document-import');

      expect(
        find.text('Imported: 1 · Already imported: 1 · Failed: 6 · Skipped: 1'),
        findsOneWidget,
      );
      String subtitle(int i) => tester
          .widget<ListTile>(find.byKey(Key('import-result-$i')))
          .subtitle!
          .toString();
      Finder row(int i, String text) => find.descendant(
        of: find.byKey(Key('import-result-$i')),
        matching: find.text(text),
      );
      expect(row(0, 'ok.json'), findsOneWidget);
      expect(row(0, 'Imported'), findsOneWidget);
      expect(row(1, 'Already imported'), findsOneWidget);
      expect(row(2, 'Skipped: not a JSON file'), findsOneWidget);
      expect(row(3, 'The OCR text is empty.'), findsOneWidget);
      expect(
        row(
          4,
          'This file uses schema version 2; this app understands up to version 1. Update the app. Nothing was imported.',
        ),
        findsOneWidget,
      );
      expect(row(5, 'The field ocrText has the wrong type.'), findsOneWidget);
      expect(row(6, 'Not valid JSON (line 3, column 7).'), findsOneWidget);
      expect(
        row(7, 'The file is too large (6.0 MB; the limit is 5.0 MB).'),
        findsOneWidget,
      );
      expect(row(8, 'The file is empty.'), findsOneWidget);
      expect(subtitle(0), isNotEmpty);
      // The valid file was stored although others failed before and after it.
      expect(
        fakes.documents.documents.values.map((ScanDocument d) => d.documentId),
        containsAll(<String>['d-ok', 'dup']),
      );
    });

    testWidgets('every failure kind has a readable message', (tester) async {
      // One file per kind. The messages must not be empty or fall back to
      // the raw enum name.
      final kinds = ImportFailureKind.values;
      fakes.picker.next = [
        for (final k in kinds)
          pick(
            '${k.name}.json',
            ImportFailure(k, field: 'f', line: 1, column: 1, size: 1, limit: 1),
          ),
      ];
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'document-import');
      for (var i = 0; i < kinds.length; i++) {
        final tile = tester.widget<ListTile>(
          find.byKey(Key('import-result-$i')),
        );
        final message = (tile.subtitle! as Text).data!;
        expect(message.length, greaterThan(8), reason: kinds[i].name);
        expect(message, isNot(contains(kinds[i].name)));
      }
    });

    testWidgets('Greek report', (tester) async {
      fakes.picker.next = [
        pick('a.json', parsedScan('d1')),
        FakeImportSource('b.pdf'),
        pick('c.json', const ImportFailure(ImportFailureKind.emptyFile)),
      ];
      await pump(
        tester,
        const DocumentsPage(),
        locale: const Locale('el', 'GR'),
      );
      await tapKey(tester, 'document-import');
      expect(find.text('Αναφορά εισαγωγής'), findsOneWidget);
      expect(
        find.text('Εισήχθησαν: 1 · Με σφάλμα: 1 · Παραλείφθηκαν: 1'),
        findsOneWidget,
      );
      expect(find.text('Παραλείφθηκε: δεν είναι αρχείο JSON'), findsOneWidget);
      expect(find.text('Το αρχείο είναι κενό.'), findsOneWidget);
    });

    testWidgets('cancelling the chooser does nothing', (tester) async {
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'document-import');
      expect(fakes.picker.calls, 1);
      expect(find.text('Import report'), findsNothing);
      expect(fakes.documents.batches, hasLength(1)); // only the seeded one
    });

    testWidgets('a chooser that fails shows a message, not a crash', (
      tester,
    ) async {
      fakes.picker.error = StateError('no chooser');
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'document-import');
      expect(find.byKey(const Key('import-pick-error')), findsOneWidget);
      expect(find.text('Import report'), findsNothing);
    });

    testWidgets('more than 50 files are refused with a message', (
      tester,
    ) async {
      fakes.picker.next = [
        for (var i = 0; i < 51; i++) FakeImportSource('f$i.json', text: 'x'),
      ];
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'document-import');
      expect(find.byKey(const Key('import-too-many')), findsOneWidget);
      expect(
        find.text('Too many files: choose at most 50 at a time.'),
        findsOneWidget,
      );
      expect(find.text('Import report'), findsNothing);
      expect(fakes.parser.parsed, isEmpty);
    });

    testWidgets('a row of the report opens the document', (tester) async {
      fakes.picker.next = [
        pick('scan.json', parsedScan('d1', ocrText: 'Open me')),
      ];
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'document-import');
      await tapKey(tester, 'import-result-0');
      expect(find.byKey(const Key('document-text')), findsOneWidget);
      expect(find.text('Open me'), findsOneWidget);
    });
  });

  group('the detail', () {
    testWidgets('shows what the file carried', (tester) async {
      await seed(
        'a',
        language: 'el',
        pdf: 'a.pdf',
        images: ['1.jpg', '2.jpg'],
        legacy: true,
      );
      await pump(tester, const DocumentDetailPage(documentId: 'a'));
      expect(find.textContaining('Created: Oct 18, 2026'), findsOneWidget);
      expect(find.text('Imported from a.json on Oct 20, 2026'), findsOneWidget);
      expect(find.byKey(const Key('document-legacy')), findsOneWidget);
      expect(find.text('Language: el'), findsOneWidget);
      expect(find.textContaining('scan-a'), findsOneWidget);
      expect(find.text('PDF: a.pdf'), findsOneWidget);
      expect(find.text('Images (2): 1.jpg, 2.jpg'), findsOneWidget);
      expect(
        find.text('These files are not stored in the app.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('document-text')), findsOneWidget);
    });

    testWidgets('without optional fields those lines are absent', (
      tester,
    ) async {
      await seed('a');
      await pump(tester, const DocumentDetailPage(documentId: 'a'));
      expect(find.byKey(const Key('document-legacy')), findsNothing);
      expect(find.byKey(const Key('document-language')), findsNothing);
      expect(find.byKey(const Key('document-pdf')), findsNothing);
      expect(find.byKey(const Key('document-images')), findsNothing);
      expect(find.text('These files are not stored in the app.'), findsNothing);
    });

    testWidgets('a long text is cut, and "Show all" shows the rest', (
      tester,
    ) async {
      final text = '${'a' * ocrPreviewChars}END';
      await seed('a', text: text);
      await pump(tester, const DocumentDetailPage(documentId: 'a'));

      String shown() => tester
          .widget<SelectableText>(find.byKey(const Key('document-text')))
          .data!;
      expect(shown().length, ocrPreviewChars);
      expect(shown(), isNot(contains('END')));
      expect(find.byKey(const Key('document-truncated')), findsOneWidget);
      expect(
        find.text('Showing the first 20000 of 20003 characters.'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.byKey(const Key('document-show-all')));
      await tapKey(tester, 'document-show-all');
      expect(shown(), text);
      expect(find.byKey(const Key('document-truncated')), findsNothing);
      expect(find.byKey(const Key('document-show-all')), findsNothing);
    });

    testWidgets('a text of exactly the limit is not cut', (tester) async {
      await seed('a', text: 'b' * ocrPreviewChars);
      await pump(tester, const DocumentDetailPage(documentId: 'a'));
      expect(find.byKey(const Key('document-show-all')), findsNothing);
    });

    testWidgets('a missing document says so', (tester) async {
      await pump(tester, const DocumentDetailPage(documentId: 'nope'));
      expect(find.byKey(const Key('document-missing')), findsOneWidget);
      expect(find.byKey(const Key('document-delete')), findsNothing);
    });

    testWidgets('Greek', (tester) async {
      await seed('a', language: 'el');
      await pump(
        tester,
        const DocumentDetailPage(documentId: 'a'),
        locale: const Locale('el', 'GR'),
      );
      expect(find.text('Γλώσσα: el'), findsOneWidget);
      expect(find.text('Δημιουργία εξόδου'), findsOneWidget);
    });
  });

  group('create an expense from a document', () {
    Future<void> openForm(WidgetTester tester) async {
      await pump(tester, const DocumentDetailPage(documentId: 'a'));
      await tester.ensureVisible(
        find.byKey(const Key('document-create-expense')),
      );
      await tapKey(tester, 'document-create-expense');
    }

    testWidgets('the date and the description are pre-filled, not the amount', (
      tester,
    ) async {
      await seed('a', text: '\n  ΔΕΗ Α.Ε.  \nΣΥΝΟΛΟ 84,20 EUR');
      await openForm(tester);

      expect(find.text('Add expense'), findsOneWidget);
      final description = tester.widget<TextFormField>(
        find.byKey(const Key('expense-description')),
      );
      expect(description.controller!.text, 'ΔΕΗ Α.Ε.');
      expect(find.textContaining('Oct 18, 2026'), findsWidgets);
      final amount = tester.widget<TextFormField>(
        find.byKey(const Key('expense-amount')),
      );
      expect(amount.controller!.text, isEmpty);
      expect(find.byKey(const Key('expense-document-banner')), findsOneWidget);
      expect(find.text('From the document of Oct 18, 2026'), findsOneWidget);
    });

    testWidgets('the balance-start warning of Phase 2 applies to that date', (
      tester,
    ) async {
      // The balance starts on 25 October; the document is of 18 October.
      await fakes.anchors.saveAnchor(
        BalanceAnchor(
          id: 'a1',
          date: CalendarDate(2026, 10, 25),
          balance: const Money(78000),
          currencyCode: 'EUR',
          createdAt: created,
        ),
      );
      await seed('a');
      await openForm(tester);
      expect(find.byKey(const Key('expense-before-start-warning')), findsOne);
      await tapKey(tester, 'expense-use-start-date');
      expect(
        find.byKey(const Key('expense-before-start-warning')),
        findsNothing,
      );
    });

    testWidgets('no warning when the document is after the balance start', (
      tester,
    ) async {
      await fakes.anchors.saveAnchor(
        BalanceAnchor(
          id: 'a1',
          date: CalendarDate(2026, 10, 1),
          balance: const Money(78000),
          currencyCode: 'EUR',
          createdAt: created,
        ),
      );
      await seed('a');
      await openForm(tester);
      expect(
        find.byKey(const Key('expense-before-start-warning')),
        findsNothing,
      );
    });

    testWidgets('a long first line is cut to 80 characters', (tester) async {
      await seed('a', text: 'x' * 200);
      await openForm(tester);
      final description = tester.widget<TextFormField>(
        find.byKey(const Key('expense-description')),
      );
      expect(description.controller!.text, 'x' * 80);
    });

    testWidgets('saving links the expense; the detail and the list show it', (
      tester,
    ) async {
      await seed('a');
      await openForm(tester);
      await tester.enterText(find.byKey(const Key('expense-amount')), '84,20');
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('expense-save')));
      await tapKey(tester, 'expense-save');

      final expense =
          (fakes.expenses.expenses.values as Iterable<Expense>).single;
      expect(expense.documentId, 'a');
      expect(expense.description, 'ΔΕΗ Α.Ε.');
      expect(expense.date, CalendarDate(2026, 10, 18));
      expect(expense.amount, const Money(8420));

      // Back on the detail: the expense is listed.
      expect(find.text('Expenses from this document'), findsOneWidget);
      expect(find.byKey(Key('document-expense-${expense.id}')), findsOneWidget);
    });

    testWidgets('an expense can be made without an amount being guessed', (
      tester,
    ) async {
      await seed('a');
      await openForm(tester);
      await tester.ensureVisible(find.byKey(const Key('expense-save')));
      await tapKey(tester, 'expense-save');
      // The form asks for an amount; nothing is stored.
      expect(fakes.expenses.expenses, isEmpty);
    });

    testWidgets('the banner opens the document from the form', (tester) async {
      await seed('a');
      await openForm(tester);
      await tapKey(tester, 'expense-open-document');
      expect(find.text('Document'), findsOneWidget);
      expect(find.byKey(const Key('document-text')), findsOneWidget);
    });

    testWidgets('editing a linked expense keeps the banner and the link', (
      tester,
    ) async {
      await seed('a');
      final expense = Expense(
        id: 'e1',
        categoryId: 'food',
        date: CalendarDate(2026, 10, 18),
        currencyCode: 'EUR',
        amount: const Money(8420),
        documentId: 'a',
        createdAt: created,
        updatedAt: created,
      );
      await fakes.expenses.add(expense);
      await pump(tester, const DocumentDetailPage(documentId: 'a'));
      await tester.ensureVisible(find.byKey(const Key('document-expense-e1')));
      await tapKey(tester, 'document-expense-e1');
      expect(find.byKey(const Key('expense-document-banner')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('expense-amount')), '90,00');
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('expense-save')));
      await tapKey(tester, 'expense-save');
      final saved = (await fakes.expenses.get('e1')) as Expense;
      expect(saved.amount, const Money(9000));
      expect(saved.documentId, 'a');
    });
  });

  group('delete', () {
    Expense linked(String id) => Expense(
      id: id,
      categoryId: 'food',
      date: CalendarDate(2026, 10, 18),
      currencyCode: 'EUR',
      amount: const Money(100),
      documentId: 'a',
      createdAt: created,
      updatedAt: created,
    );

    testWidgets('the confirmation names the expenses that stay', (
      tester,
    ) async {
      await seed('a');
      await fakes.expenses.add(linked('e1'));
      await fakes.expenses.add(linked('e2'));
      await pump(tester, const DocumentDetailPage(documentId: 'a'));
      await tapKey(tester, 'document-delete');
      expect(find.text('Delete this document?'), findsOneWidget);
      expect(
        find.textContaining('2 linked expenses stay, without the link'),
        findsOneWidget,
      );
    });

    testWidgets('one expense uses the singular, none omits the sentence', (
      tester,
    ) async {
      await seed('a');
      await fakes.expenses.add(linked('e1'));
      await pump(tester, const DocumentDetailPage(documentId: 'a'));
      await tapKey(tester, 'document-delete');
      expect(
        find.textContaining('1 linked expense stays, without the link'),
        findsOneWidget,
      );
      await tapKey(tester, 'document-delete-cancel');

      await fakes.expenses.delete('e1');
      await tapKey(tester, 'document-delete');
      expect(find.textContaining('linked expense'), findsNothing);
    });

    testWidgets('Cancel keeps the document', (tester) async {
      await seed('a');
      await pump(tester, const DocumentDetailPage(documentId: 'a'));
      await tapKey(tester, 'document-delete');
      await tapKey(tester, 'document-delete-cancel');
      expect(fakes.documents.documents, hasLength(1));
      expect(find.byKey(const Key('document-text')), findsOneWidget);
    });

    testWidgets('Delete removes the document and keeps the expenses', (
      tester,
    ) async {
      await seed('a');
      await seed('b', text: 'Stays');
      await fakes.expenses.add(linked('e1'));
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'document-tile-a');
      await tapKey(tester, 'document-delete');
      await tapKey(tester, 'document-delete-confirm');

      // Back on the list, with a message.
      expect(find.byKey(const Key('document-deleted')), findsOneWidget);
      expect(find.byKey(const Key('document-tile-a')), findsNothing);
      expect(find.byKey(const Key('document-tile-b')), findsOneWidget);
      expect(fakes.documents.documents.keys, ['b']);
      final expense = (await fakes.expenses.get('e1')) as Expense;
      expect(expense.documentId, isNull);
      expect(expense.amount, const Money(100));
    });

    testWidgets('the same document can be imported again afterwards', (
      tester,
    ) async {
      fakes.picker.next = [
        pick('scan.json', parsedScan('d1', ocrText: 'Again')),
      ];
      await pump(tester, const DocumentsPage());
      await tapKey(tester, 'document-import');
      await tapKey(tester, 'import-done');
      final storedId = fakes.documents.documents.keys.single as String;
      await tapKey(tester, 'document-tile-$storedId');
      await tapKey(tester, 'document-delete');
      await tapKey(tester, 'document-delete-confirm');
      expect(fakes.documents.documents, isEmpty);

      fakes.picker.next = [
        pick('scan.json', parsedScan('d1', ocrText: 'Again')),
      ];
      await tapKey(tester, 'document-import');
      expect(find.text('Imported: 1'), findsOneWidget);
      expect(find.text('Already imported: 1'), findsNothing);
    });
  });
}
