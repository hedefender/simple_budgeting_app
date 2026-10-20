import 'package:simple_budgeting_app/features/documents/domain/repositories/import_source.dart';

/// Lets the user pick the files to import. The implementation opens the
/// system file chooser; tests use a fake.
abstract interface class ImportFilePicker {
  /// The picked files, in the order they were picked. Empty when the user
  /// cancelled.
  Future<List<ImportSource>> pick();
}
