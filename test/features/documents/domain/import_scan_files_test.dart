import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_batch.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_report.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/import_scan_files.dart';

import '../../../support/document_fakes.dart';

void main() {
  late FakeDocumentRepository repo;
  late FakeScanJsonParser parser;
  late ImportScanFiles import;
  var nextId = 0;
  final now = DateTime.utc(2026, 10, 20, 12);

  /// A source whose text the fake parser resolves to [result].
  FakeImportSource file(
    String name,
    Object result, {
    FakeReadLog? log,
    int? size,
  }) {
    final text = 'text of $name';
    parser.results[text] = result;
    return FakeImportSource(name, text: text, size: size, log: log);
  }

  setUp(() {
    nextId = 0;
    repo = FakeDocumentRepository();
    parser = FakeScanJsonParser();
    import = ImportScanFiles(
      parser,
      repo,
      () => now,
      () => 'id${++nextId}',
      localToUtc: (local) => DateTime.parse('${local}Z').subtract(
        const Duration(hours: 3), // pretend the device is at +03:00
      ),
    );
  });

  ImportOutcome outcomeOf(ImportReport report, int index) =>
      report.results[index].outcome;

  ImportFailureKind kindOf(ImportReport report, int index) =>
      (outcomeOf(report, index) as Failed).failure.kind;

  group('single file', () {
    test(
      'a valid document is stored with everything the file carried',
      () async {
        final report = await import([
          file(
            'a.json',
            parsedScan(
              'doc-1',
              ocrText: 'ΔΕΗ 84,20',
              language: 'el',
              pdfName: 'a.pdf',
              imageNames: ['1.jpg', '2.jpg'],
            ),
          ),
        ]);

        expect(report.importedCount, 1);
        final doc = (outcomeOf(report, 0) as Imported).document;
        expect(repo.documents.values.single, same(doc));
        expect(doc.documentId, 'doc-1');
        expect(doc.sourceFileName, 'a.json');
        expect(doc.ocrText, 'ΔΕΗ 84,20');
        expect(doc.language, 'el');
        expect(doc.pdfName, 'a.pdf');
        expect(doc.imageNames, ['1.jpg', '2.jpg']);
        expect(doc.createdAt, DateTime.utc(2026, 10, 18, 6, 41, 7));
        expect(doc.wasLegacy, isFalse);
      },
    );

    test('the batch is stored first and gets the counts', () async {
      final report = await import([file('a.json', parsedScan('d1'))]);

      expect(report.results, hasLength(1));
      final batch = repo.batches.values.single;
      expect(batch.source, ImportBatch.filePicker);
      expect(batch.importedAt, now);
      expect(batch.fileCount, 1);
      expect(
        (batch.importedCount, batch.duplicateCount, batch.failedCount),
        (1, 0, 0),
      );
      expect(repo.documents.values.single.importId, batch.id);
    });

    test('a createdAt without offset gets the zone of the device', () async {
      await import([
        file('a.json', parsedScan('d1', createdAtLocal: '2026-10-18T09:41:07')),
      ]);
      // The injected conversion is +03:00.
      expect(
        repo.documents.values.single.createdAt,
        DateTime.utc(2026, 10, 18, 6, 41, 7),
      );
    });

    test('the real default conversion reads the text as local time', () {
      final utc = deviceLocalToUtc('2026-10-18T09:41:07');
      final local = DateTime(2026, 10, 18, 9, 41, 7);
      expect(utc, local.toUtc());
      expect(utc.isUtc, isTrue);
    });
  });

  group('several files (Multi Scan)', () {
    test('every file gets a result, in the order they were picked', () async {
      final report = await import([
        file('b.json', parsedScan('d2')),
        file('a.json', parsedScan('d1')),
        file('c.json', parsedScan('d3')),
      ]);
      expect(report.results.map((r) => r.fileName), [
        'b.json',
        'a.json',
        'c.json',
      ]);
      expect(report.importedCount, 3);
      expect(repo.documents, hasLength(3));
    });

    test('a failing file in the middle does not stop the next ones', () async {
      final report = await import([
        file('a.json', parsedScan('d1')),
        file('bad.json', const ImportFailure(ImportFailureKind.emptyOcrText)),
        file('c.json', parsedScan('d3')),
      ]);
      expect(outcomeOf(report, 0), isA<Imported>());
      expect(kindOf(report, 1), ImportFailureKind.emptyOcrText);
      expect(outcomeOf(report, 2), isA<Imported>());
      expect(repo.documents, hasLength(2));
      final batch = repo.batches.values.single;
      expect(
        (batch.fileCount, batch.importedCount, batch.failedCount),
        (3, 2, 1),
      );
    });

    test('files are read one at a time, in order', () async {
      final log = FakeReadLog();
      await import([
        file('a.json', parsedScan('d1'), log: log),
        file('b.json', parsedScan('d2'), log: log),
        file('c.json', parsedScan('d3'), log: log),
      ]);
      expect(log.order, ['a.json', 'b.json', 'c.json']);
      expect(log.overlapped, isFalse);
    });
  });

  group('skipped files', () {
    test(
      'a file that is not .json is skipped, not failed, and not read',
      () async {
        final pdf = FakeImportSource('scan.pdf', text: 'binary');
        final report = await import([pdf, file('a.json', parsedScan('d1'))]);
        expect(outcomeOf(report, 0), isA<Skipped>());
        expect(outcomeOf(report, 1), isA<Imported>());
        expect(pdf.reads, 0);
        expect(parser.parsed, ['text of a.json']);
        expect(report.skippedCount, 1);
        expect(report.failedCount, 0);
      },
    );

    test('the extension check ignores case', () async {
      final report = await import([file('SCAN.JSON', parsedScan('d1'))]);
      expect(outcomeOf(report, 0), isA<Imported>());
    });

    test('only the end of the name counts', () async {
      final report = await import([
        FakeImportSource('data.json.pdf'),
        FakeImportSource('json'),
        FakeImportSource('.json.txt'),
      ]);
      expect(report.skippedCount, 3);
    });

    test('the batch counts skipped files only in the file count', () async {
      await import([
        FakeImportSource('scan.pdf'),
        file('a.json', parsedScan('d1')),
      ]);
      final batch = repo.batches.values.single;
      expect(batch.fileCount, 2);
      expect(batch.skippedCount, 1);
    });
  });

  group('duplicates', () {
    test('the second import of the same documentId stores nothing', () async {
      final first = await import([
        file('a.json', parsedScan('d1', ocrText: 'first')),
      ]);
      final storedId = (outcomeOf(first, 0) as Imported).document.id;

      final second = await import([
        file('a-again.json', parsedScan('d1', ocrText: 'changed')),
      ]);
      final outcome = outcomeOf(second, 0) as Duplicate;
      expect(outcome.documentId, 'd1');
      expect(outcome.existing.id, storedId);
      expect(repo.documents, hasLength(1));
      // The first import wins: the document is not overwritten.
      expect(repo.documents.values.single.ocrText, 'first');
      expect(repo.batches, hasLength(2));
      expect(repo.batches.values.last.duplicateCount, 1);
    });

    test('a duplicate inside the same batch: the first is imported', () async {
      final report = await import([
        file('a.json', parsedScan('same')),
        file('b.json', parsedScan('same')),
      ]);
      expect(outcomeOf(report, 0), isA<Imported>());
      expect(outcomeOf(report, 1), isA<Duplicate>());
      expect(repo.documents, hasLength(1));
    });

    test(
      'after the document is deleted, the id can be imported again',
      () async {
        final first = await import([file('a.json', parsedScan('d1'))]);
        await repo.delete((outcomeOf(first, 0) as Imported).document.id);

        final again = await import([file('a.json', parsedScan('d1'))]);
        expect(outcomeOf(again, 0), isA<Imported>());
        expect(repo.documents, hasLength(1));
      },
    );
  });

  group('every failure becomes a result', () {
    test('each reason of the parser is passed on with its details', () async {
      for (final kind in ImportFailureKind.values) {
        final report = await import([
          file('f.json', ImportFailure(kind, field: 'ocrText')),
        ]);
        final failure = (outcomeOf(report, 0) as Failed).failure;
        expect(failure.kind, kind);
        expect(failure.field, 'ocrText');
        parser.results.clear();
      }
    });

    test('a file over 5 MiB is refused before it is read', () async {
      final big = FakeImportSource(
        'big.json',
        text: 'x',
        size: maxImportFileBytes + 1,
      );
      final report = await import([big]);
      final failure = (outcomeOf(report, 0) as Failed).failure;
      expect(failure.kind, ImportFailureKind.tooLarge);
      expect(failure.size, maxImportFileBytes + 1);
      expect(failure.limit, maxImportFileBytes);
      expect(big.reads, 0);
      expect(parser.parsed, isEmpty);
    });

    test('a file of exactly 5 MiB is read', () async {
      final report = await import([
        file('edge.json', parsedScan('d1'), size: maxImportFileBytes),
      ]);
      expect(outcomeOf(report, 0), isA<Imported>());
    });

    test('an empty file reaches the parser and is reported', () async {
      parser.results[''] = const ImportFailure(ImportFailureKind.emptyFile);
      final report = await import([FakeImportSource('empty.json', size: 0)]);
      expect(kindOf(report, 0), ImportFailureKind.emptyFile);
    });

    test('a read error and a size error', () async {
      final report = await import([
        FakeImportSource(
          'gone.json',
          readFailure: const ImportFailure(ImportFailureKind.readError),
        ),
        FakeImportSource(
          'locked.json',
          lengthFailure: const ImportFailure(ImportFailureKind.readError),
        ),
        FakeImportSource(
          'latin1.json',
          readFailure: const ImportFailure(ImportFailureKind.notUtf8),
        ),
      ]);
      expect(kindOf(report, 0), ImportFailureKind.readError);
      expect(kindOf(report, 1), ImportFailureKind.readError);
      expect(kindOf(report, 2), ImportFailureKind.notUtf8);
    });

    test(
      'an unexpected parser exception is reported, the next file goes on',
      () async {
        parser.crash = StateError('boom');
        final report = await import([file('a.json', parsedScan('d1'))]);
        expect(kindOf(report, 0), ImportFailureKind.unexpected);

        parser.crash = null;
        final next = await import([file('b.json', parsedScan('d2'))]);
        expect(outcomeOf(next, 0), isA<Imported>());
      },
    );

    test(
      'a repository that throws gives a storage error, not a crash',
      () async {
        repo.addError = StateError('disk full');
        final report = await import([
          file('a.json', parsedScan('d1')),
          file('b.json', parsedScan('d2')),
        ]);
        expect(kindOf(report, 0), ImportFailureKind.storageError);
        expect(kindOf(report, 1), ImportFailureKind.storageError);
        expect(repo.documents, isEmpty);
      },
    );

    test('a failing duplicate check is reported as unexpected', () async {
      repo.findError = StateError('locked');
      final report = await import([file('a.json', parsedScan('d1'))]);
      expect(kindOf(report, 0), ImportFailureKind.unexpected);
    });

    test(
      'when the batch cannot be stored, JSON files fail and others skip',
      () async {
        repo.addBatchError = StateError('locked');
        final report = await import([
          file('a.json', parsedScan('d1')),
          FakeImportSource('x.pdf'),
        ]);
        expect(kindOf(report, 0), ImportFailureKind.storageError);
        expect(outcomeOf(report, 1), isA<Skipped>());
        expect(repo.documents, isEmpty);
        expect(parser.parsed, isEmpty);
      },
    );

    test('losing the final counts does not lose the report', () async {
      repo.updateBatchError = StateError('locked');
      final report = await import([file('a.json', parsedScan('d1'))]);
      expect(report.importedCount, 1);
      expect(repo.documents, hasLength(1));
    });
  });

  group('limits of a batch', () {
    test('no files: an empty report and no batch', () async {
      final report = await import(const []);
      expect(report.results, isEmpty);
      expect(repo.batches, isEmpty);
    });

    test('50 files are accepted', () async {
      final report = await import([
        for (var i = 0; i < maxImportFiles; i++)
          file('f$i.json', parsedScan('d$i')),
      ]);
      expect(report.importedCount, maxImportFiles);
    });

    test('51 files are refused before any is read', () async {
      final sources = [
        for (var i = 0; i <= maxImportFiles; i++)
          file('f$i.json', parsedScan('d$i')),
      ];
      await expectLater(
        import(sources),
        throwsA(
          isA<TooManyFilesException>()
              .having((e) => e.count, 'count', 51)
              .having((e) => e.limit, 'limit', 50),
        ),
      );
      expect(parser.parsed, isEmpty);
      expect(repo.batches, isEmpty);
      expect(sources.every((s) => s.reads == 0), isTrue);
    });
  });
}
