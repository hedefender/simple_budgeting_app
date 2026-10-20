/// What kind of document a scan is. Phase 3 does not classify (no rule
/// engine yet), so every document is `unknown`; the column and the enum are
/// there for the later phases. Add new values at the END.
enum DocumentType {
  unknown,
  receipt,
  utilityBill,
  invoice,
  statement,
  contract,
  genericDocument;

  /// The type stored under [name]. A missing or unknown name (for example one
  /// written by a newer version of the app) reads as [unknown].
  static DocumentType fromName(String? name) {
    for (final type in values) {
      if (type.name == name) return type;
    }
    return unknown;
  }
}
