/// A category an expense can be filed under. Built-in categories have a
/// stable [key] (also their id); the display name comes from the ARB files by
/// that key. User categories arrive in Phase 5.
class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.key,
    required this.sortOrder,
  });

  /// The category the expense form preselects.
  static const String otherKey = 'other';

  final String id;
  final String key;
  final int sortOrder;
}
