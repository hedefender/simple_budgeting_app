import 'package:simple_budgeting_app/features/documents/domain/entities/parsed_scan.dart';

/// Parses and validates the text of one Scan JSON file
/// (`docs/scan-json-schema.md`). The implementation calls the Rust core; the
/// domain only knows this interface.
abstract interface class ScanJsonParser {
  /// Throws `ImportFailureException` for a file that is refused.
  Future<ParsedScan> parse(String text);
}
