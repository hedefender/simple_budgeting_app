import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/documents/domain/entities/document_type.dart';

/// A scanned document imported from a Scan JSON file: its OCR text and the
/// facts the file carried. The text is stored, not analysed.
class ScanDocument {
  const ScanDocument({
    required this.id,
    required this.documentId,
    required this.importId,
    required this.sourceFileName,
    required this.createdAt,
    required this.ocrText,
    required this.schemaVersion,
    required this.wasLegacy,
    this.language,
    this.documentType = DocumentType.unknown,
    this.pdfName,
    this.imageNames = const <String>[],
  });

  /// Local id (UUID).
  final String id;

  /// The `documentId` of the Scan JSON: the duplicate key.
  final String documentId;

  /// The import batch that brought the document in.
  final String importId;

  /// The JSON file it came from.
  final String sourceFileName;

  /// UTC instant: when Scan created the document.
  final DateTime createdAt;

  final String ocrText;

  /// BCP-47 tag, or null when the file did not say.
  final String? language;

  final DocumentType documentType;

  /// File names, only labels. Budget does not have these files.
  final String? pdfName;
  final List<String> imageNames;

  /// The `schemaVersion` of the file; 1 for a legacy file.
  final int schemaVersion;
  final bool wasLegacy;

  /// The calendar day of [createdAt] in the time zone of the device.
  CalendarDate get createdLocalDay {
    final local = createdAt.toLocal();
    return CalendarDate(local.year, local.month, local.day);
  }

  /// The first line of the text that has something in it, trimmed and cut to
  /// [maxLength] characters. Empty when the text has no such line.
  String firstLine({int maxLength = 80}) {
    for (final line in ocrText.split(RegExp(r'\r\n|\r|\n'))) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final runes = trimmed.runes;
      if (runes.length <= maxLength) return trimmed;
      return String.fromCharCodes(runes.take(maxLength)).trimRight();
    }
    return '';
  }
}
