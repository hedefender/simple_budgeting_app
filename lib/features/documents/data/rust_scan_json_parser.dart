import 'package:simple_budgeting_app/features/documents/domain/entities/import_failure.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/parsed_scan.dart';
import 'package:simple_budgeting_app/features/documents/domain/repositories/scan_json_parser.dart';
import 'package:simple_budgeting_app/src/rust/api/scan_json.dart' as bridge;

/// Adapter over the generated Rust bridge: a thin mapping, no logic. The rules
/// live in `rust/src/api/scan_json.rs`.
class RustScanJsonParser implements ScanJsonParser {
  const RustScanJsonParser();

  @override
  Future<ParsedScan> parse(String text) async {
    try {
      return mapParsedScan(await bridge.parseScanJson(text: text));
    } on bridge.ScanJsonError catch (e) {
      throw ImportFailureException(mapScanJsonError(e));
    }
  }
}

/// Visible for tests: the generated classes are plain Dart, so the mapping is
/// tested without loading the native library.
ParsedScan mapParsedScan(bridge.ParsedScan p) {
  final utcMs = p.createdAtUtcMs;
  return ParsedScan(
    schemaVersion: p.schemaVersion,
    documentId: p.documentId,
    ocrText: p.ocrText,
    wasLegacy: p.wasLegacy,
    createdAtUtc: utcMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(utcMs, isUtc: true),
    createdAtLocal: p.createdAtLocal,
    language: p.language,
    pdfName: p.pdfName,
    imageNames: p.imageNames,
  );
}

/// Visible for tests.
ImportFailure mapScanJsonError(bridge.ScanJsonError e) {
  return ImportFailure(
    switch (e.kind) {
      bridge.ScanJsonErrorKind.emptyFile => ImportFailureKind.emptyFile,
      bridge.ScanJsonErrorKind.tooLarge => ImportFailureKind.tooLarge,
      bridge.ScanJsonErrorKind.invalidJson => ImportFailureKind.invalidJson,
      bridge.ScanJsonErrorKind.notAnObject => ImportFailureKind.notAnObject,
      bridge.ScanJsonErrorKind.missingField => ImportFailureKind.missingField,
      bridge.ScanJsonErrorKind.wrongType => ImportFailureKind.wrongType,
      bridge.ScanJsonErrorKind.emptyOcrText => ImportFailureKind.emptyOcrText,
      bridge.ScanJsonErrorKind.invalidDocumentId =>
        ImportFailureKind.invalidDocumentId,
      bridge.ScanJsonErrorKind.invalidDate => ImportFailureKind.invalidDate,
      bridge.ScanJsonErrorKind.emptyFileName => ImportFailureKind.emptyFileName,
      bridge.ScanJsonErrorKind.unsupportedSchemaVersion =>
        ImportFailureKind.unsupportedSchemaVersion,
    },
    field: e.field,
    line: e.line,
    column: e.column,
    size: e.size,
    limit: e.limit,
    foundVersion: e.foundVersion,
    knownVersion: e.knownVersion,
  );
}
