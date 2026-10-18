import 'package:drift/drift.dart';
import 'package:simple_budgeting_app/core/database/app_database.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/core/time/calendar_date.dart';
import 'package:simple_budgeting_app/features/income/data/income_schedule_codec.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_entry.dart';
import 'package:simple_budgeting_app/features/income/domain/entities/income_source.dart';
import 'package:simple_budgeting_app/features/income/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  IncomeRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> addSource(IncomeSource source) async {
    await _db.into(_db.incomeSources).insert(_sourceCompanion(source));
  }

  @override
  Future<void> updateSource(
    IncomeSource source, {
    List<IncomeEntry> freezeEntries = const <IncomeEntry>[],
  }) {
    return _db.transaction(() async {
      for (final entry in freezeEntries) {
        await _upsertEntry(entry);
      }
      await (_db.update(
        _db.incomeSources,
      )..where((t) => t.id.equals(source.id))).write(_sourceCompanion(source));
    });
  }

  @override
  Future<void> archiveSource(String id, DateTime archivedAtUtc) async {
    await (_db.update(_db.incomeSources)..where((t) => t.id.equals(id))).write(
      IncomeSourcesCompanion(archivedAt: Value(archivedAtUtc)),
    );
  }

  @override
  Future<IncomeSource?> getSource(String id) async {
    final row = await (_db.select(
      _db.incomeSources,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toSource(row);
  }

  @override
  Future<List<IncomeSource>> listSources({bool includeArchived = false}) async {
    final query = _db.select(_db.incomeSources)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    if (!includeArchived) query.where((t) => t.archivedAt.isNull());
    return (await query.get()).map(_toSource).toList();
  }

  @override
  Future<List<IncomeEntry>> listEntries() async {
    final rows = await _db.select(_db.incomeEntries).get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<void> saveEntry(IncomeEntry entry) => _upsertEntry(entry);

  @override
  Future<void> removeEntry(String sourceId, CalendarDate originalDate) async {
    await (_db.delete(_db.incomeEntries)..where(
          (t) =>
              t.sourceId.equals(sourceId) &
              t.originalDate.equals(originalDate.toString()),
        ))
        .go();
  }

  Future<void> _upsertEntry(IncomeEntry entry) async {
    await _db
        .into(_db.incomeEntries)
        .insert(
          IncomeEntriesCompanion.insert(
            id: entry.id,
            sourceId: entry.sourceId,
            originalDate: entry.originalDate.toString(),
            status: entry.status.name,
            amountMinor: entry.amount.minorUnits,
            createdAt: entry.createdAt,
          ),
          onConflict: DoUpdate(
            (_) => IncomeEntriesCompanion(
              status: Value(entry.status.name),
              amountMinor: Value(entry.amount.minorUnits),
              createdAt: Value(entry.createdAt),
            ),
            target: [
              _db.incomeEntries.sourceId,
              _db.incomeEntries.originalDate,
            ],
          ),
        );
  }

  IncomeSourcesCompanion _sourceCompanion(IncomeSource s) {
    return IncomeSourcesCompanion(
      id: Value(s.id),
      name: Value(s.name),
      type: Value(s.type.name),
      amountMinor: Value(s.amount.minorUnits),
      currencyCode: Value(s.currencyCode),
      scheduleJson: Value(IncomeScheduleCodec.encode(s.schedule)),
      startDate: Value(s.startDate.toString()),
      endDate: Value(s.endDate?.toString()),
      frozenThrough: Value(s.frozenThrough?.toString()),
      createdAt: Value(s.createdAt),
      archivedAt: Value(s.archivedAt),
    );
  }

  /// Throws [ScheduleDecodeException] when the stored schedule is unknown.
  IncomeSource _toSource(IncomeSourceRow row) {
    return IncomeSource(
      id: row.id,
      name: row.name,
      type: IncomeType.values.byName(row.type),
      amount: Money(row.amountMinor),
      currencyCode: row.currencyCode,
      schedule: IncomeScheduleCodec.decode(row.scheduleJson),
      startDate: CalendarDate.parse(row.startDate),
      endDate: row.endDate == null ? null : CalendarDate.parse(row.endDate!),
      frozenThrough: row.frozenThrough == null
          ? null
          : CalendarDate.parse(row.frozenThrough!),
      createdAt: row.createdAt.toUtc(),
      archivedAt: row.archivedAt?.toUtc(),
    );
  }

  IncomeEntry _toEntry(IncomeEntryRow row) {
    return IncomeEntry(
      id: row.id,
      sourceId: row.sourceId,
      originalDate: CalendarDate.parse(row.originalDate),
      status: IncomeEntryStatus.values.byName(row.status),
      amount: Money(row.amountMinor),
      createdAt: row.createdAt.toUtc(),
    );
  }
}
