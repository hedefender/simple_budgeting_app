import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_budgeting_app/features/documents/data/file_selector_import.dart';
import 'package:simple_budgeting_app/features/documents/data/rust_scan_json_parser.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/src/rust/api/scan_json.dart' as bridge;

/// The mapping is tested without the native library: the generated classes
/// are plain Dart. The real parser is tested by `cargo test` and by the
/// on-device integration test.
void main() {
  group('mapParsedScan', () {
    test('an instant becomes a UTC DateTime', () {
      final parsed = mapParsedScan(
        const bridge.ParsedScan(
          schemaVersion: 1,
          documentId: 'd1',
          createdAtUtcMs: 1792305667000,
          ocrText: 'text',
          language: 'el',
          pdfName: 'a.pdf',
          imageNames: ['1.jpg'],
          wasLegacy: false,
        ),
      );
      expect(parsed.createdAtUtc, DateTime.utc(2026, 10, 18, 6, 41, 7));
      expect(parsed.createdAtUtc!.isUtc, isTrue);
      expect(parsed.createdAtLocal, isNull);
      expect(parsed.language, 'el');
      expect(parsed.pdfName, 'a.pdf');
      expect(parsed.imageNames, ['1.jpg']);
    });

    test('a time without zone stays text', () {
      final parsed = mapParsedScan(
        const bridge.ParsedScan(
          schemaVersion: 1,
          documentId: 'legacy-x',
          createdAtLocal: '2026-10-18T09:41:07',
          ocrText: 'text',
          imageNames: [],
          wasLegacy: true,
        ),
      );
      expect(parsed.createdAtUtc, isNull);
      expect(parsed.createdAtLocal, '2026-10-18T09:41:07');
      expect(parsed.wasLegacy, isTrue);
      expect(parsed.language, isNull);
    });
  });

  group('mapScanJsonError', () {
    test('every Rust kind has a domain kind of the same name', () {
      for (final kind in bridge.ScanJsonErrorKind.values) {
        final mapped = mapScanJsonError(bridge.ScanJsonError(kind: kind));
        expect(mapped.kind.name, kind.name);
      }
    });

    test('the details are passed on', () {
      final f = mapScanJsonError(
        const bridge.ScanJsonError(
          kind: bridge.ScanJsonErrorKind.unsupportedSchemaVersion,
          foundVersion: 2,
          knownVersion: 1,
        ),
      );
      expect((f.foundVersion, f.knownVersion), (2, 1));

      final j = mapScanJsonError(
        const bridge.ScanJsonError(
          kind: bridge.ScanJsonErrorKind.invalidJson,
          line: 3,
          column: 7,
        ),
      );
      expect((j.line, j.column), (3, 7));

      final t = mapScanJsonError(
        const bridge.ScanJsonError(
          kind: bridge.ScanJsonErrorKind.tooLarge,
          size: 6000000,
          limit: 5242880,
        ),
      );
      expect((t.size, t.limit), (6000000, 5242880));

      final w = mapScanJsonError(
        const bridge.ScanJsonError(
          kind: bridge.ScanJsonErrorKind.wrongType,
          field: 'ocrText',
        ),
      );
      expect(w.field, 'ocrText');
      expect(w.kind, ImportFailureKind.wrongType);
    });
  });

  group('FileSelectorImportSource', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('scan_json_test'));
    tearDown(() => dir.deleteSync(recursive: true));

    /// A real file: `XFile.fromData` ignores the name on the device.
    FileSelectorImportSource source(List<int> bytes, {String name = 'a.json'}) {
      final file = File('${dir.path}${Platform.pathSeparator}$name')
        ..writeAsBytesSync(bytes);
      return FileSelectorImportSource(XFile(file.path));
    }

    test('name, length and text', () async {
      final bytes = utf8.encode('{"ocrText":"ΔΕΗ"}');
      final s = source(bytes, name: 'scan.JSON');
      expect(s.name, 'scan.JSON');
      expect(await s.length(), bytes.length);
      expect(await s.readText(), '{"ocrText":"ΔΕΗ"}');
    });

    test('a BOM does not reach the parser as text noise', () async {
      // Dart's UTF-8 decoder drops a leading BOM; the Rust parser removes it
      // too, for text that arrives by another way.
      final s = source([0xEF, 0xBB, 0xBF, ...utf8.encode('{}')]);
      expect(await s.readText(), '{}');
      expect(await s.length(), 5);
    });

    test('bytes that are not UTF-8 are a notUtf8 failure', () async {
      final s = source([0x7B, 0xE9, 0x7D]); // "{é}" in Latin-1
      await expectLater(
        s.readText(),
        throwsA(
          isA<ImportFailureException>().having(
            (e) => e.failure.kind,
            'kind',
            ImportFailureKind.notUtf8,
          ),
        ),
      );
    });

    test('an empty file reads as an empty text', () async {
      final s = source(const []);
      expect(await s.length(), 0);
      expect(await s.readText(), '');
    });

    test('a file that disappeared is a readError failure', () async {
      final s = source(utf8.encode('{}'));
      File('${dir.path}${Platform.pathSeparator}a.json').deleteSync();
      for (final read in [s.length, s.readText]) {
        await expectLater(
          read(),
          throwsA(
            isA<ImportFailureException>().having(
              (e) => e.failure.kind,
              'kind',
              ImportFailureKind.readError,
            ),
          ),
        );
      }
    });
  });
}
