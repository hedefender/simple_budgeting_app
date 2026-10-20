import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/features/documents/data/document_repository_impl.dart';
import 'package:simple_budgeting_app/features/documents/data/rust_scan_json_parser.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/document_type.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_report.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/import_scan_files.dart';
import 'package:simple_budgeting_app/src/rust/api/scan_json.dart' as bridge;

import '../../../support/document_fakes.dart';

/// Rust rule (c): every field is tested over the whole path, from the parser
/// output to the database and back. Host tests cannot load the native
/// library, so the parser output is built as the generated bridge class and
/// goes through the real mapping, use case and repository. The same sample
/// through the REAL parser is `integration_test/document_import_test.dart`.
void main() {
  late AppDatabase db;
  late DocumentRepositoryImpl repository;
  late FakeScanJsonParser parser;
  late ImportScanFiles import;
  var n = 0;

  setUp(() {
    n = 0;
    db = AppDatabase(NativeDatabase.memory());
    repository = DocumentRepositoryImpl(db);
    parser = FakeScanJsonParser();
    import = ImportScanFiles(
      parser,
      repository,
      () => DateTime.utc(2026, 10, 20, 12),
      () => 'id${++n}',
    );
  });

  tearDown(() => db.close());

  Future<ImportReport> run(String name, bridge.ParsedScan raw) {
    parser.results['text of $name'] = mapParsedScan(raw);
    return import([FakeImportSource(name, text: 'text of $name')]);
  }

  test('a full canonical document: every field comes back', () async {
    final report = await run(
      'full.json',
      const bridge.ParsedScan(
        schemaVersion: 1,
        documentId: '3f2b6c1e',
        createdAtUtcMs: 1792305667000,
        ocrText: 'ΔΕΗ Α.Ε.\nΣΥΝΟΛΟ 84,20 EUR',
        language: 'el',
        pdfName: 'scan.pdf',
        imageNames: ['p1.jpg', 'p2.jpg'],
        wasLegacy: false,
      ),
    );
    expect(report.importedCount, 1);

    final doc = (await repository.findByDocumentId('3f2b6c1e'))!;
    expect(doc.documentId, '3f2b6c1e');
    expect(doc.sourceFileName, 'full.json');
    expect(doc.createdAt, DateTime.utc(2026, 10, 18, 6, 41, 7));
    expect(doc.ocrText, 'ΔΕΗ Α.Ε.\nΣΥΝΟΛΟ 84,20 EUR');
    expect(doc.language, 'el');
    expect(doc.documentType, DocumentType.unknown);
    expect(doc.pdfName, 'scan.pdf');
    expect(doc.imageNames, ['p1.jpg', 'p2.jpg']);
    expect(doc.schemaVersion, 1);
    expect(doc.wasLegacy, isFalse);

    final batch = (await repository.getBatch(doc.importId))!;
    expect(batch.importedAt, DateTime.utc(2026, 10, 20, 12));
    expect(batch.source, 'file_picker');
    expect((batch.fileCount, batch.importedCount), (1, 1));
  });

  test('a legacy document without zone and without optional fields', () async {
    await run(
      'old.json',
      const bridge.ParsedScan(
        schemaVersion: 1,
        documentId: 'legacy-0123456789abcdef0123456789abcdef',
        createdAtLocal: '2026-10-18T09:41:07',
        ocrText: 'Cosmote 29,90',
        imageNames: [],
        wasLegacy: true,
      ),
    );
    final doc = (await repository.list()).single;
    // The device zone applies to a time without zone.
    expect(doc.createdAt, DateTime(2026, 10, 18, 9, 41, 7).toUtc());
    expect(doc.wasLegacy, isTrue);
    expect(doc.language, isNull);
    expect(doc.pdfName, isNull);
    expect(doc.imageNames, isEmpty);
    expect(doc.documentId, startsWith('legacy-'));
  });

  test('importing the same file twice leaves one document', () async {
    const raw = bridge.ParsedScan(
      schemaVersion: 1,
      documentId: 'same',
      createdAtUtcMs: 0,
      ocrText: 'x',
      imageNames: [],
      wasLegacy: false,
    );
    await run('a.json', raw);
    final second = await run('a.json', raw);
    expect(second.duplicateCount, 1);
    expect(await repository.list(), hasLength(1));
    final rows = await db
        .customSelect('SELECT COUNT(*) AS c FROM imports')
        .getSingle();
    expect(rows.read<int>('c'), 2);
  });
}
