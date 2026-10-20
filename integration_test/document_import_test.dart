import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/service_locator.dart';
import 'package:simple_budgeting_app/features/documents/data/rust_scan_json_parser.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/document_type.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_report.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/import_source.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/document_usecases.dart';
import 'package:simple_budgeting_app/features/documents/domain/usecases/import_scan_files.dart';

/// On-device test using a SEPARATE temporary database file (deleted at the
/// end), so the app's real data on the device is never touched:
///   `flutter test integration_test/document_import_test.dart -d <device-id>`
///
/// It runs the REAL Rust parser (host tests cannot load the native library):
/// the whole path sample -> parser -> database -> read, for every field, plus
/// duplicates, malformed files, a restart and a delete.
class _Text implements ImportSource {
  _Text(this.name, this.text, {int? size}) : size = size ?? text.length;

  @override
  final String name;
  final String text;
  final int size;

  @override
  Future<int> length() async => size;

  @override
  Future<String> readText() async => text;
}

const String _full = '''
{
  "schemaVersion": 1,
  "documentId": "3f2b6c1e-8a5d-4a43-9d1e-6f0c2a7b9e10",
  "createdAt": "2026-10-18T09:41:07+03:00",
  "language": "el",
  "ocrText": "ΔΕΗ Α.Ε.\\nΣΥΝΟΛΟ ΠΛΗΡΩΤΕΟ 84,20 EUR",
  "pdfPath": "/storage/emulated/0/Scan/scan-0941.pdf",
  "imagePaths": ["scan-0941-1.jpg", "C:\\\\Scans\\\\scan-0941-2.jpg"],
  "unknownField": {"ignored": true}
}''';

const String _legacy = '''
{
  "version": 1,
  "created": "2026-10-18T09:41:07",
  "ocr_text": "ΕΥΔΑΠ\\nΣΥΝΟΛΟ 31,40 EUR",
  "image_paths": ["old-1.jpg"],
  "pdf_path": "old.pdf"
}''';

/// One line per file of the report, for the failure message of a test.
String _describe(ImportReport report) {
  return report.results
      .map((r) {
        final o = r.outcome;
        final what = switch (o) {
          Imported() => 'Imported',
          Duplicate() => 'Duplicate',
          Skipped() => 'Skipped',
          Failed(:final failure) =>
            'Failed(${failure.kind.name}) ${ImportFailureException(failure)}',
        };
        return '  ${r.fileName}: $what';
      })
      .join('\n');
}

/// Calls the real parser directly, so the failure message shows the underlying
/// error that `ImportScanFiles` hides behind `Failed(unexpected)`.
Future<String> _probeParser() async {
  try {
    final parsed = await const RustScanJsonParser().parse(_full);
    return 'parser ok: ${parsed.documentId}';
  } on Object catch (e) {
    return 'parser threw ${e.runtimeType}: $e';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the real parser: import, duplicates, errors, restart, delete', (
    tester,
  ) async {
    final dir = await Directory.systemTemp.createTemp('document_import_');
    final file = File('${dir.path}/test.sqlite');
    final locator = GetIt.instance;
    addTearDown(() async {
      await locator.reset();
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    configureDependencies(locator, databaseExecutor: NativeDatabase(file));
    // Loads the Rust library through the path the app uses at startup.
    await locator.get<Bootstrapper>().run();
    final import = locator.get<ImportScanFiles>();

    final report = await import([
      _Text('full.json', _full),
      _Text('legacy.json', _legacy),
      _Text(
        'bom.json',
        '\u{feff}{"schemaVersion":1,"documentId":"bom-1",'
            '"createdAt":"2026-10-18T09:41:07Z","ocrText":"With a BOM"}',
      ),
      _Text('receipt.pdf', 'not read'),
      _Text('broken.json', '{ oops'),
      _Text('empty.json', ''),
      _Text(
        'future.json',
        '{"schemaVersion":2,"documentId":"f","createdAt":"x","ocrText":"y"}',
      ),
      _Text(
        'blank.json',
        '{"schemaVersion":1,"documentId":"b","createdAt":"2026-10-18T09:41:07Z","ocrText":"  "}',
      ),
      _Text(
        'wrong.json',
        '{"schemaVersion":1,"documentId":"w","createdAt":"2026-10-18T09:41:07Z","ocrText":7}',
      ),
      _Text('array.json', '[1,2,3]'),
    ]);

    final detail = '${_describe(report)}\n${await _probeParser()}';
    expect(report.importedCount, 3, reason: detail);
    expect(report.skippedCount, 1, reason: detail);
    expect(report.failedCount, 6, reason: detail);
    ImportFailureKind kind(int i) =>
        (report.results[i].outcome as Failed).failure.kind;
    expect(kind(4), ImportFailureKind.invalidJson);
    expect(kind(5), ImportFailureKind.emptyFile);
    expect(kind(6), ImportFailureKind.unsupportedSchemaVersion);
    expect(kind(7), ImportFailureKind.emptyOcrText);
    expect(kind(8), ImportFailureKind.wrongType);
    expect(kind(9), ImportFailureKind.notAnObject);

    // The whole path: every field of the canonical sample.
    final docs = await locator.get<ListDocuments>()();
    final full = docs.firstWhere((d) => d.documentId.startsWith('3f2b6c1e'));
    expect(full.createdAt, DateTime.utc(2026, 10, 18, 6, 41, 7));
    expect(full.ocrText, 'ΔΕΗ Α.Ε.\nΣΥΝΟΛΟ ΠΛΗΡΩΤΕΟ 84,20 EUR');
    expect(full.language, 'el');
    expect(full.documentType, DocumentType.unknown);
    expect(full.pdfName, 'scan-0941.pdf');
    expect(full.imageNames, ['scan-0941-1.jpg', 'scan-0941-2.jpg']);
    expect(full.wasLegacy, isFalse);
    expect(full.sourceFileName, 'full.json');

    // Legacy: a stable id, no language, a zone-less time read in the zone of
    // the device.
    final legacy = docs.firstWhere((d) => d.wasLegacy);
    expect(legacy.documentId, startsWith('legacy-'));
    expect(legacy.language, isNull);
    expect(legacy.pdfName, 'old.pdf');
    expect(legacy.createdAt, DateTime(2026, 10, 18, 9, 41, 7).toUtc());
    final legacyId = legacy.documentId;

    // The same files again: duplicates, nothing new.
    final again = await import([
      _Text('full-again.json', _full),
      _Text('legacy-again.json', _legacy),
    ]);
    expect(again.duplicateCount, 2);
    expect(await locator.get<ListDocuments>()(), hasLength(3));

    // A file over 5 MiB, built here (no big file in the repository): refused
    // by the size check, and by the parser itself as a second guard.
    final big = _Text('big.json', '{}', size: maxImportFileBytes + 1);
    final bigReport = await import([big]);
    expect(
      (bigReport.results.single.outcome as Failed).failure.kind,
      ImportFailureKind.tooLarge,
    );
    final huge = '{"ocrText":"${'a' * (maxImportFileBytes + 1)}"}';
    await expectLater(
      const RustScanJsonParser().parse(huge),
      throwsA(
        isA<ImportFailureException>().having(
          (e) => e.failure.kind,
          'kind',
          ImportFailureKind.tooLarge,
        ),
      ),
    );

    // Restart: the documents, the batches and the ids are still there.
    await locator.reset();
    configureDependencies(locator, databaseExecutor: NativeDatabase(file));
    // Loads the Rust library through the path the app uses at startup.
    await locator.get<Bootstrapper>().run();
    final restored = await locator.get<ListDocuments>()();
    expect(restored, hasLength(3));
    expect(restored.any((d) => d.documentId == legacyId), isTrue);
    final batch = await locator.get<GetImportBatch>()(full.importId);
    expect(batch!.fileCount, 10);
    expect(
      (batch.importedCount, batch.duplicateCount, batch.failedCount),
      (3, 0, 6),
    );
    expect(batch.skippedCount, 1);

    // Delete, then the same file imports again.
    final stayed = await locator.get<DeleteDocument>()(full.id);
    expect(stayed, 0);
    final reimport = await locator.get<ImportScanFiles>()([
      _Text('full.json', _full),
    ]);
    expect(reimport.importedCount, 1);
    expect(await locator.get<ListDocuments>()(), hasLength(3));
  });
}
