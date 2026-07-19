import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/coach_memory/domain/coach_memory.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final coachMemoryRepositoryProvider = Provider<CoachMemoryRepository>((ref) {
  return CoachMemoryRepository(ref.watch(databaseProvider));
});

class CoachMemoryRepository {
  final db.AppDatabase _db;

  CoachMemoryRepository(this._db);

  /// Idempotently reconciles the current patterns. Rebuilding from unchanged
  /// evidence never inflates occurrenceCount; a changed signature counts as a
  /// new observation. Missing managed patterns become resolved, not deleted.
  Future<void> synchronize(
    List<MemoryObservation> observations, {
    DateTime? observedAt,
  }) async {
    final now = observedAt ?? DateTime.now();
    final activeKeys = observations.map((item) => item.memoryKey).toSet();
    await _db.transaction(() async {
      for (final observation in observations) {
        final existing = await (_db.select(_db.coachMemories)
              ..where((row) => row.memoryKey.equals(observation.memoryKey)))
            .getSingleOrNull();
        if (existing == null) {
          await _db.into(_db.coachMemories).insert(
                db.CoachMemoriesCompanion.insert(
                  memoryKey: observation.memoryKey,
                  kind: observation.kind.name,
                  sourceMetricId: observation.sourceMetricId,
                  latestValue: Value(observation.latestValue),
                  sampleSize: Value(observation.sampleSize),
                  confidence: Value(observation.confidence),
                  evidenceSignature: observation.evidenceSignature,
                  firstObservedAt: now,
                  lastObservedAt: now,
                ),
              );
          continue;
        }

        final unchanged =
            existing.evidenceSignature == observation.evidenceSignature &&
                existing.status == CoachMemoryStatus.active.name;
        if (unchanged) continue;

        await (_db.update(_db.coachMemories)
              ..where((row) => row.id.equals(existing.id)))
            .write(db.CoachMemoriesCompanion(
          kind: Value(observation.kind.name),
          sourceMetricId: Value(observation.sourceMetricId),
          latestValue: Value(observation.latestValue),
          sampleSize: Value(observation.sampleSize),
          confidence: Value(observation.confidence),
          occurrenceCount: Value(existing.occurrenceCount + 1),
          evidenceSignature: Value(observation.evidenceSignature),
          status: Value(CoachMemoryStatus.active.name),
          lastObservedAt: Value(now),
          revision: Value(existing.revision + 1),
        ));
      }

      final existingActive = await (_db.select(_db.coachMemories)
            ..where((row) => row.status.equals(CoachMemoryStatus.active.name)))
          .get();
      for (final row in existingActive) {
        final managed = row.memoryKey.startsWith('performance.') ||
            row.memoryKey.startsWith('mastery.');
        if (!managed || activeKeys.contains(row.memoryKey)) continue;
        await (_db.update(_db.coachMemories)
              ..where((item) => item.id.equals(row.id)))
            .write(db.CoachMemoriesCompanion(
          status: Value(CoachMemoryStatus.resolved.name),
          lastObservedAt: Value(now),
          revision: Value(row.revision + 1),
        ));
      }
    });
  }

  Future<List<CoachMemory>> getAll({bool activeOnly = false}) async {
    final query = _db.select(_db.coachMemories)
      ..orderBy([(row) => OrderingTerm.desc(row.lastObservedAt)]);
    if (activeOnly) {
      query.where((row) => row.status.equals(CoachMemoryStatus.active.name));
    }
    final rows = await query.get();
    return rows.map(_map).toList(growable: false);
  }

  CoachMemory _map(db.CoachMemory row) => CoachMemory(
        id: row.id,
        memoryKey: row.memoryKey,
        kind: CoachMemoryKind.values.byName(row.kind),
        sourceMetricId: row.sourceMetricId,
        latestValue: row.latestValue,
        sampleSize: row.sampleSize,
        confidence: row.confidence,
        occurrenceCount: row.occurrenceCount,
        evidenceSignature: row.evidenceSignature,
        status: CoachMemoryStatus.values.byName(row.status),
        firstObservedAt: row.firstObservedAt,
        lastObservedAt: row.lastObservedAt,
        revision: row.revision,
      );
}
