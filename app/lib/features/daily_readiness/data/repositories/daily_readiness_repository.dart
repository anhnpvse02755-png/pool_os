import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final dailyReadinessRepositoryProvider =
    Provider<DailyReadinessRepository>((ref) {
  return DailyReadinessRepository(ref.watch(databaseProvider));
});

class DailyReadinessRepository {
  final db.AppDatabase _db;

  DailyReadinessRepository(this._db);

  Future<DailyReadinessModel?> getByDate(String date) async {
    final row = await (_db.select(_db.dailyReadinessEntries)
          ..where((entry) => entry.date.equals(date)))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  Future<List<DailyReadinessModel>> getByDateRange(
      String startDate, String endDate) async {
    final rows = await (_db.select(_db.dailyReadinessEntries)
          ..where((entry) =>
              entry.date.isBiggerOrEqualValue(startDate) &
              entry.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(entry) => OrderingTerm.asc(entry.date)]))
        .get();
    return rows.map(_mapRow).toList(growable: false);
  }

  Future<List<DailyReadinessModel>> getRecentDays(int days) async {
    final rows = await (_db.select(_db.dailyReadinessEntries)
          ..orderBy([(entry) => OrderingTerm.desc(entry.date)])
          ..limit(days))
        .get();
    return rows.map(_mapRow).toList(growable: false);
  }

  Future<int> upsert(DailyReadinessModel readiness) {
    return _db.transaction(() async {
      final existing = await (_db.select(_db.dailyReadinessEntries)
            ..where((entry) => entry.date.equals(readiness.date)))
          .getSingleOrNull();
      final now = DateTime.now();
      if (existing == null) {
        return _db.into(_db.dailyReadinessEntries).insert(
              db.DailyReadinessEntriesCompanion.insert(
                date: readiness.date,
                sleepHours: Value(readiness.sleepHours),
                energyLevel: Value(readiness.energyLevel),
                focusLevel: Value(readiness.focusLevel),
                confidenceLevel: Value(readiness.confidenceLevel),
                mood: Value(readiness.mood),
                stressLevel: Value(readiness.stressLevel),
                shoulderCondition: Value(readiness.shoulderCondition),
                wristCondition: Value(readiness.wristCondition),
                backCondition: Value(readiness.backCondition),
                equipment: Value(readiness.equipment),
                playingLocation: Value(readiness.playingLocation),
                tableSpeed: Value(readiness.tableSpeed),
                todayGoal: Value(readiness.todayGoal),
                notes: Value(readiness.notes),
                createdAt: readiness.createdAt,
                updatedAt: now,
              ),
            );
      }

      await (_db.update(_db.dailyReadinessEntries)
            ..where((entry) => entry.id.equals(existing.id)))
          .write(
        db.DailyReadinessEntriesCompanion(
          sleepHours: Value(readiness.sleepHours),
          energyLevel: Value(readiness.energyLevel),
          focusLevel: Value(readiness.focusLevel),
          confidenceLevel: Value(readiness.confidenceLevel),
          mood: Value(readiness.mood),
          stressLevel: Value(readiness.stressLevel),
          shoulderCondition: Value(readiness.shoulderCondition),
          wristCondition: Value(readiness.wristCondition),
          backCondition: Value(readiness.backCondition),
          equipment: Value(readiness.equipment),
          playingLocation: Value(readiness.playingLocation),
          tableSpeed: Value(readiness.tableSpeed),
          todayGoal: Value(readiness.todayGoal),
          notes: Value(readiness.notes),
          updatedAt: Value(now),
        ),
      );
      return existing.id;
    });
  }

  Future<int> delete(int id) async {
    return (_db.delete(_db.dailyReadinessEntries)
          ..where((entry) => entry.id.equals(id)))
        .go();
  }

  DailyReadinessModel _mapRow(db.DailyReadinessEntry row) {
    return DailyReadinessModel(
      id: row.id,
      date: row.date,
      sleepHours: row.sleepHours,
      energyLevel: row.energyLevel,
      focusLevel: row.focusLevel,
      confidenceLevel: row.confidenceLevel,
      mood: row.mood,
      stressLevel: row.stressLevel,
      shoulderCondition: row.shoulderCondition,
      wristCondition: row.wristCondition,
      backCondition: row.backCondition,
      equipment: row.equipment,
      playingLocation: row.playingLocation,
      tableSpeed: row.tableSpeed,
      todayGoal: row.todayGoal,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
