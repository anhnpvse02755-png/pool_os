import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final rackRepositoryProvider = Provider<RackRepository>((ref) {
  return RackRepository(ref.watch(databaseProvider));
});

class RackRepository {
  final db.AppDatabase _db;

  RackRepository(this._db);

  Future<List<Rack>> getRacksByMatchId(int matchId) async {
    final results = await (_db.select(_db.racks)
          ..where((r) => r.matchId.equals(matchId))
          ..orderBy([(r) => OrderingTerm.asc(r.rackNumber)]))
        .get();
    return results.map(_mapToRack).toList();
  }

  Future<Rack?> getRackById(int id) async {
    final result = await (_db.select(_db.racks)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToRack(result);
  }

  Future<int> createRack(Rack rack) async {
    // RFC-301: Rack Match-Mode fields are now real columns (schema v11), not a
    // __RACK_DATA__ JSON blob smuggled into `notes`. Map straight to columns.
    return _db.into(_db.racks).insert(
      db.RacksCompanion.insert(
        matchId: rack.matchId,
        rackNumber: rack.rackNumber,
        result: rack.result,
        notes: Value(rack.notes),
        createdAt: Value(rack.createdAt),
        biggestMistake: Value(rack.biggestMistake),
        biggestStrength: Value(rack.biggestStrength),
        confidence: Value(rack.confidence),
        ballsPotted: Value(rack.ballsPotted),
        largestRun: Value(rack.largestRun),
        breakSuccess: Value(rack.breakSuccess),
        breakScratch: Value(rack.breakScratch),
        breakFoul: Value(rack.breakFoul),
        easyMissCount: Value(rack.easyMissCount),
        hardMissCount: Value(rack.hardMissCount),
        scratchErrorCount: Value(rack.scratchErrorCount),
        positionErrorCount: Value(rack.positionErrorCount),
        safetyErrorCount: Value(rack.safetyErrorCount),
        kickErrorCount: Value(rack.kickErrorCount),
        jumpErrorCount: Value(rack.jumpErrorCount),
        bestStrengths: Value(jsonEncode(rack.bestStrengths)),
        biggestMistakes: Value(jsonEncode(rack.biggestMistakes)),
      ),
    );
  }

  Future<bool> updateRack(Rack rack) async {
    final updatedRows = await (_db.update(_db.racks)
          ..where((r) => r.id.equals(rack.id!)))
        .write(
      db.RacksCompanion(
        matchId: Value(rack.matchId),
        rackNumber: Value(rack.rackNumber),
        result: Value(rack.result),
        notes: Value(rack.notes),
        biggestMistake: Value(rack.biggestMistake),
        biggestStrength: Value(rack.biggestStrength),
        confidence: Value(rack.confidence),
        ballsPotted: Value(rack.ballsPotted),
        largestRun: Value(rack.largestRun),
        breakSuccess: Value(rack.breakSuccess),
        breakScratch: Value(rack.breakScratch),
        breakFoul: Value(rack.breakFoul),
        easyMissCount: Value(rack.easyMissCount),
        hardMissCount: Value(rack.hardMissCount),
        scratchErrorCount: Value(rack.scratchErrorCount),
        positionErrorCount: Value(rack.positionErrorCount),
        safetyErrorCount: Value(rack.safetyErrorCount),
        kickErrorCount: Value(rack.kickErrorCount),
        jumpErrorCount: Value(rack.jumpErrorCount),
        bestStrengths: Value(jsonEncode(rack.bestStrengths)),
        biggestMistakes: Value(jsonEncode(rack.biggestMistakes)),
      ),
    );
    return updatedRows > 0;
  }

  /// RFC-301: verify a Match row exists before a Rack is attached to it.
  Future<bool> matchExists(int matchId) async {
    final result = await (_db.select(_db.matches)..where((m) => m.id.equals(matchId)))
        .getSingleOrNull();
    return result != null;
  }

  Future<int> deleteRack(int id) async {
    return (_db.delete(_db.racks)..where((r) => r.id.equals(id))).go();
  }

  Future<int> getRackCountByMatchId(int matchId) async {
    final count = _db.racks.id.count();
    final query = _db.selectOnly(_db.racks)
      ..addColumns([count])
      ..where(_db.racks.matchId.equals(matchId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> getWinCountByMatchId(int matchId) async {
    final count = _db.racks.id.count();
    final query = _db.selectOnly(_db.racks)
      ..addColumns([count])
      ..where(_db.racks.matchId.equals(matchId) & _db.racks.result.equals(true));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> getNextRackNumber(int matchId) async {
    final count = await getRackCountByMatchId(matchId);
    return count + 1;
  }

  Rack _mapToRack(db.Rack data) {
    // RFC-301: read Match-Mode fields from their real columns (schema v11).
    // The list fields are stored as JSON text; tolerate legacy/empty values.
    List<String> _decodeList(String raw) {
      if (raw.isEmpty) return const [];
      try {
        final decoded = jsonDecode(raw);
        return decoded is List ? List<String>.from(decoded) : const [];
      } catch (_) {
        return const [];
      }
    }

    return Rack(
      id: data.id,
      matchId: data.matchId,
      rackNumber: data.rackNumber,
      result: data.result,
      notes: data.notes,
      createdAt: data.createdAt,
      biggestMistake: data.biggestMistake,
      biggestStrength: data.biggestStrength,
      confidence: data.confidence,
      ballsPotted: data.ballsPotted,
      largestRun: data.largestRun,
      breakSuccess: data.breakSuccess,
      breakScratch: data.breakScratch,
      breakFoul: data.breakFoul,
      easyMissCount: data.easyMissCount,
      hardMissCount: data.hardMissCount,
      scratchErrorCount: data.scratchErrorCount,
      positionErrorCount: data.positionErrorCount,
      safetyErrorCount: data.safetyErrorCount,
      kickErrorCount: data.kickErrorCount,
      jumpErrorCount: data.jumpErrorCount,
      bestStrengths: _decodeList(data.bestStrengths),
      biggestMistakes: _decodeList(data.biggestMistakes),
    );
  }
}
