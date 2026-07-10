import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final shotRepositoryProvider = Provider<ShotRepository>((ref) {
  return ShotRepository(ref.watch(databaseProvider));
});

class ShotRepository {
  final db.AppDatabase _db;

  ShotRepository(this._db);

  Future<List<Shot>> getShotsByRackId(int rackId) async {
    final results = await (_db.select(_db.shots)
          ..where((s) => s.rackId.equals(rackId))
          ..orderBy([(s) => OrderingTerm.asc(s.shotNumber)]))
        .get();
    return results.map(_mapToShot).toList();
  }

  Future<Shot?> getShotById(int id) async {
    final result = await (_db.select(_db.shots)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToShot(result);
  }

  Future<int> createShot(Shot shot) async {
    return _db.into(_db.shots).insert(
      db.ShotsCompanion.insert(
        rackId: shot.rackId,
        shotNumber: shot.shotNumber,
        shotType: shot.shotType,
        difficulty: shot.difficulty,
        result: shot.result,
        positionQuality: Value(shot.positionQuality),
        decision: Value(shot.decision),
        confidence: Value(shot.confidence),
        playerNote: Value(shot.playerNote),
        createdAt: Value(shot.createdAt),
      ),
    );
  }

  Future<bool> updateShot(Shot shot) async {
    return _db.update(_db.shots).replace(
      db.ShotsCompanion(
        id: Value(shot.id!),
        rackId: Value(shot.rackId),
        shotNumber: Value(shot.shotNumber),
        shotType: Value(shot.shotType),
        difficulty: Value(shot.difficulty),
        result: Value(shot.result),
        positionQuality: Value(shot.positionQuality),
        decision: Value(shot.decision),
        confidence: Value(shot.confidence),
        playerNote: Value(shot.playerNote),
        createdAt: Value(shot.createdAt),
      ),
    );
  }

  Future<int> deleteShot(int id) async {
    return (_db.delete(_db.shots)..where((s) => s.id.equals(id))).go();
  }

  Future<int> getShotCountByRackId(int rackId) async {
    final count = _db.shots.id.count();
    final query = _db.selectOnly(_db.shots)
      ..addColumns([count])
      ..where(_db.shots.rackId.equals(rackId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> getMadeShotCountByRackId(int rackId) async {
    final count = _db.shots.id.count();
    final query = _db.selectOnly(_db.shots)
      ..addColumns([count])
      ..where(_db.shots.rackId.equals(rackId) & _db.shots.result.equals(ShotResult.made));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> getNextShotNumber(int rackId) async {
    final count = await getShotCountByRackId(rackId);
    return count + 1;
  }

  /// RFC-301: verify a Shot row actually exists before an Event is attached to
  /// it. Used by the recording pipeline to reject orphan Events.
  Future<bool> shotExists(int shotId) async {
    final result = await (_db.select(_db.shots)..where((s) => s.id.equals(shotId)))
        .getSingleOrNull();
    return result != null;
  }

  Future<Map<String, int>> getShotTypeStats() async {
    final results = await _db.select(_db.shots).get();
    final stats = <String, int>{};
    for (final shot in results) {
      stats[shot.shotType] = (stats[shot.shotType] ?? 0) + 1;
    }
    return stats;
  }

  Shot _mapToShot(db.Shot data) {
    return Shot(
      id: data.id,
      rackId: data.rackId,
      shotNumber: data.shotNumber,
      shotType: data.shotType,
      difficulty: data.difficulty,
      result: data.result,
      positionQuality: data.positionQuality,
      decision: data.decision,
      confidence: data.confidence,
      playerNote: data.playerNote,
      createdAt: data.createdAt,
    );
  }

  Future<List<Shot>> getShotsByPlayerId(int playerId) async {
    final results = await (_db.select(_db.shots).get());
    return results.map(_mapToShot).toList();
  }
}
