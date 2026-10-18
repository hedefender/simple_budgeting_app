import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';

abstract interface class IncomeRepository {
  Future<void> addSource(IncomeSource source);

  /// Replaces the stored source with the same id. [freezeEntries] are saved in
  /// the same transaction (they keep the old history intact).
  Future<void> updateSource(
    IncomeSource source, {
    List<IncomeEntry> freezeEntries = const <IncomeEntry>[],
  });

  Future<void> archiveSource(String id, DateTime archivedAtUtc);

  Future<IncomeSource?> getSource(String id);

  Future<List<IncomeSource>> listSources({bool includeArchived = false});

  Future<List<IncomeEntry>> listEntries();

  /// Inserts the entry, or replaces the entry of the same source and
  /// original date.
  Future<void> saveEntry(IncomeEntry entry);

  Future<void> removeEntry(String sourceId, CalendarDate originalDate);
}
