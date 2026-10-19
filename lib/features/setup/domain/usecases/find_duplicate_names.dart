import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';

String _normalize(String name) => name.trim().toLowerCase();

/// The members of [proposed] that already exist as an active (not archived)
/// source with the same name, ignoring case and surrounding spaces. Used to
/// warn when the wizard runs again; it never blocks.
Set<String> findDuplicateNames(
  Iterable<IncomeSource> existing,
  Iterable<String> proposed,
) {
  final taken = <String>{
    for (final source in existing)
      if (!source.isArchived) _normalize(source.name),
  };
  return <String>{
    for (final name in proposed)
      if (taken.contains(_normalize(name))) name,
  };
}
