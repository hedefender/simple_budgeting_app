/// The result of parsing one Scan JSON file, in the canonical shape (a legacy
/// file is converted by the parser). Mirrors the Rust `ParsedScan`.
class ParsedScan {
  const ParsedScan({
    required this.schemaVersion,
    required this.documentId,
    required this.ocrText,
    required this.wasLegacy,
    this.createdAtUtc,
    this.createdAtLocal,
    this.language,
    this.pdfName,
    this.imageNames = const <String>[],
  }) : assert(
         (createdAtUtc == null) != (createdAtLocal == null),
         'exactly one of createdAtUtc and createdAtLocal is set',
       );

  final int schemaVersion;
  final String documentId;
  final String ocrText;
  final bool wasLegacy;

  /// Set when the file had an offset or `Z`: an exact instant.
  final DateTime? createdAtUtc;

  /// Set when the file had no offset: the wall-clock time as written,
  /// `yyyy-MM-ddTHH:mm:ss`. The device time zone applies to it.
  final String? createdAtLocal;

  final String? language;
  final String? pdfName;
  final List<String> imageNames;
}
