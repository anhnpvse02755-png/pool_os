import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';

final trainingCenterRepositoryProvider =
    Provider<TrainingCenterRepository>((ref) {
  return TrainingCenterRepository(ref.watch(databaseProvider));
});

/// Task 09 — the only gateway between the Training Center presentation layer and
/// Drift. Maps the four practice tables (custom drills, training sessions, drill
/// runs, favourites) to/from the pure domain models. Never touches the LOCKED
/// recording pipeline tables.
class TrainingCenterRepository {
  final db.AppDatabase _db;

  TrainingCenterRepository(this._db);

  // --- Custom drills (Phần 3) ---------------------------------------------

  Future<List<CustomDrill>> getCustomDrills() async {
    final rows = await (_db.select(_db.customDrills)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    return rows.map(_mapCustomDrill).toList();
  }

  Future<CustomDrill?> getCustomDrillById(int id) async {
    final row = await (_db.select(_db.customDrills)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapCustomDrill(row);
  }

  Future<int> createCustomDrill(CustomDrill drill) async {
    return _db.into(_db.customDrills).insert(
          db.CustomDrillsCompanion.insert(
            name: drill.name,
            category: drill.category,
            targetReps: Value(drill.targetReps),
            successCriteria: Value(drill.successCriteria),
            createdAt: drill.createdAt,
          ),
        );
  }

  Future<bool> updateCustomDrill(CustomDrill drill) async {
    final updated = await (_db.update(_db.customDrills)
          ..where((t) => t.id.equals(drill.id!)))
        .write(
      db.CustomDrillsCompanion(
        name: Value(drill.name),
        category: Value(drill.category),
        targetReps: Value(drill.targetReps),
        successCriteria: Value(drill.successCriteria),
      ),
    );
    return updated > 0;
  }

  Future<int> deleteCustomDrill(int id) {
    // Soft-ref only: existing DrillRuns keep their denormalised name/category,
    // so deleting a custom drill never cascades away practice history.
    return (_db.delete(_db.customDrills)..where((t) => t.id.equals(id))).go();
  }

  // --- Training sessions (Phần 2) -----------------------------------------

  Future<int> createSession(TrainingSession session) async {
    return _db.into(_db.trainingCenterSessions).insert(
          db.TrainingCenterSessionsCompanion.insert(
            playerId: Value(session.playerId),
            startedAt: session.startedAt,
            completedAt: Value(session.completedAt),
            notes: Value(session.notes),
          ),
        );
  }

  Future<int> completeSession(int id, {String? notes}) {
    return (_db.update(_db.trainingCenterSessions)
          ..where((t) => t.id.equals(id)))
        .write(
      db.TrainingCenterSessionsCompanion(
        completedAt: Value(DateTime.now()),
        notes: notes == null ? const Value.absent() : Value(notes),
      ),
    );
  }

  Future<int> deleteSession(int id) async {
    // Remove the session and its runs together (soft ref, manual cascade).
    await (_db.delete(_db.drillRuns)..where((t) => t.sessionId.equals(id))).go();
    return (_db.delete(_db.trainingCenterSessions)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<List<TrainingSession>> getRecentSessions({int limit = 20}) async {
    final rows = await (_db.select(_db.trainingCenterSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .get();
    return rows.map(_mapSession).toList();
  }

  // --- Drill runs (Phần 2) -------------------------------------------------

  Future<int> addDrillRun(DrillRun run) async {
    return _db.into(_db.drillRuns).insert(
          db.DrillRunsCompanion.insert(
            sessionId: run.sessionId,
            drillCode: Value(run.drillCode),
            customDrillId: Value(run.customDrillId),
            drillName: run.drillName,
            category: run.category,
            targetReps: Value(run.targetReps),
            attempts: Value(run.attempts),
            successes: Value(run.successes),
            createdAt: run.createdAt,
          ),
        );
  }

  Future<List<DrillRun>> getRunsForSession(int sessionId) async {
    final rows = await (_db.select(_db.drillRuns)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_mapRun).toList();
  }

  /// All runs, newest first — used by progress + recent drills.
  Future<List<DrillRun>> getAllRuns({int? limit}) async {
    final query = _db.select(_db.drillRuns)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (limit != null) query.limit(limit);
    final rows = await query.get();
    return rows.map(_mapRun).toList();
  }

  // --- Favorites (Phần 5) --------------------------------------------------

  Future<Set<String>> getFavoriteKeys() async {
    final rows = await _db.select(_db.drillFavorites).get();
    return rows.map((r) => r.drillKey).toSet();
  }

  Future<void> setFavorite(String drillKey, bool favorite) async {
    if (favorite) {
      // Avoid duplicate rows for the same key.
      final existing = await (_db.select(_db.drillFavorites)
            ..where((t) => t.drillKey.equals(drillKey)))
          .getSingleOrNull();
      if (existing != null) return;
      await _db.into(_db.drillFavorites).insert(
            db.DrillFavoritesCompanion.insert(
              drillKey: drillKey,
              createdAt: DateTime.now(),
            ),
          );
    } else {
      await (_db.delete(_db.drillFavorites)
            ..where((t) => t.drillKey.equals(drillKey)))
          .go();
    }
  }

  // --- Mappers -------------------------------------------------------------

  CustomDrill _mapCustomDrill(db.CustomDrill row) => CustomDrill(
        id: row.id,
        name: row.name,
        category: row.category,
        targetReps: row.targetReps,
        successCriteria: row.successCriteria,
        createdAt: row.createdAt,
      );

  TrainingSession _mapSession(db.TrainingCenterSession row) => TrainingSession(
        id: row.id,
        playerId: row.playerId,
        startedAt: row.startedAt,
        completedAt: row.completedAt,
        notes: row.notes,
      );

  DrillRun _mapRun(db.DrillRun row) => DrillRun(
        id: row.id,
        sessionId: row.sessionId,
        drillCode: row.drillCode,
        customDrillId: row.customDrillId,
        drillName: row.drillName,
        category: row.category,
        targetReps: row.targetReps,
        attempts: row.attempts,
        successes: row.successes,
        createdAt: row.createdAt,
      );
}
