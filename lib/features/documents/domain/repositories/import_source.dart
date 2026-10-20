/// One file picked by the user, read lazily so that files are processed one
/// at a time and a too large file is never read.
abstract interface class ImportSource {
  String get name;

  /// Size in bytes. Throws `ImportFailureException(readError)` when it
  /// cannot be read.
  Future<int> length();

  /// The text of the file (UTF-8). Throws `ImportFailureException` with
  /// `notUtf8` or `readError`.
  Future<String> readText();
}
