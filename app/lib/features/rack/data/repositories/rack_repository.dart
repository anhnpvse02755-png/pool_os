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
    // FIX-003: Store additional data as JSON in the notes field for now
    // This is a workaround since the generated Rack class doesn't have new fields
    String? combinedNotes = rack.notes;
    
    if (rack.bestStrengths.isNotEmpty || rack.biggestMistakes.isNotEmpty) {
      final extraData = {
        'bestStrengths': rack.bestStrengths,
        'biggestMistakes': rack.biggestMistakes,
        'ballsPotted': rack.ballsPotted,
        'largestRun': rack.largestRun,
        'breakSuccess': rack.breakSuccess,
        'breakScratch': rack.breakScratch,
        'breakFoul': rack.breakFoul,
        'easyMissCount': rack.easyMissCount,
        'hardMissCount': rack.hardMissCount,
        'scratchErrorCount': rack.scratchErrorCount,
        'positionErrorCount': rack.positionErrorCount,
        'safetyErrorCount': rack.safetyErrorCount,
        'kickErrorCount': rack.kickErrorCount,
        'jumpErrorCount': rack.jumpErrorCount,
      };
      combinedNotes = combinedNotes != null 
          ? '$combinedNotes\n__RACK_DATA__${jsonEncode(extraData)}'
          : '__RACK_DATA__${jsonEncode(extraData)}';
    }
    
    return _db.into(_db.racks).insert(
      db.RacksCompanion.insert(
        matchId: rack.matchId,
        rackNumber: rack.rackNumber,
        result: rack.result,
        notes: Value(combinedNotes),
        createdAt: Value(rack.createdAt),
        biggestMistake: Value(rack.biggestMistake),
        biggestStrength: Value(rack.biggestStrength),
        confidence: Value(rack.confidence),
      ),
    );
  }

  Future<bool> updateRack(Rack rack) async {
    String? combinedNotes = rack.notes;
    
    if (rack.bestStrengths.isNotEmpty || rack.biggestMistakes.isNotEmpty) {
      final extraData = {
        'bestStrengths': rack.bestStrengths,
        'biggestMistakes': rack.biggestMistakes,
        'ballsPotted': rack.ballsPotted,
        'largestRun': rack.largestRun,
        'breakSuccess': rack.breakSuccess,
        'breakScratch': rack.breakScratch,
        'breakFoul': rack.breakFoul,
        'easyMissCount': rack.easyMissCount,
        'hardMissCount': rack.hardMissCount,
        'scratchErrorCount': rack.scratchErrorCount,
        'positionErrorCount': rack.positionErrorCount,
        'safetyErrorCount': rack.safetyErrorCount,
        'kickErrorCount': rack.kickErrorCount,
        'jumpErrorCount': rack.jumpErrorCount,
      };
      combinedNotes = combinedNotes != null 
          ? '$combinedNotes\n__RACK_DATA__${jsonEncode(extraData)}'
          : '__RACK_DATA__${jsonEncode(extraData)}';
    }
    
    final updatedRows = await (_db.update(_db.racks)
          ..where((r) => r.id.equals(rack.id!)))
        .write(
      db.RacksCompanion(
        matchId: Value(rack.matchId),
        rackNumber: Value(rack.rackNumber),
        result: Value(rack.result),
        notes: Value(combinedNotes),
        biggestMistake: Value(rack.biggestMistake),
        biggestStrength: Value(rack.biggestStrength),
        confidence: Value(rack.confidence),
      ),
    );
    return updatedRows > 0;
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
    List<String> bestStrengths = [];
    List<String> biggestMistakes = [];
    int ballsPotted = 0;
    int largestRun = 0;
    bool breakSuccess = false;
    bool breakScratch = false;
    bool breakFoul = false;
    int easyMissCount = 0;
    int hardMissCount = 0;
    int scratchErrorCount = 0;
    int positionErrorCount = 0;
    int safetyErrorCount = 0;
    int kickErrorCount = 0;
    int jumpErrorCount = 0;
    
    // Parse extra data from notes field
    if (data.notes != null && data.notes!.contains('__RACK_DATA__')) {
      try {
        final parts = data.notes!.split('__RACK_DATA__');
        if (parts.length > 1) {
          final extraData = jsonDecode(parts[1]) as Map<String, dynamic>;
          bestStrengths = List<String>.from(extraData['bestStrengths'] ?? []);
          biggestMistakes = List<String>.from(extraData['biggestMistakes'] ?? []);
          ballsPotted = extraData['ballsPotted'] ?? 0;
          largestRun = extraData['largestRun'] ?? 0;
          breakSuccess = extraData['breakSuccess'] ?? false;
          breakScratch = extraData['breakScratch'] ?? false;
          breakFoul = extraData['breakFoul'] ?? false;
          easyMissCount = extraData['easyMissCount'] ?? 0;
          hardMissCount = extraData['hardMissCount'] ?? 0;
          scratchErrorCount = extraData['scratchErrorCount'] ?? 0;
          positionErrorCount = extraData['positionErrorCount'] ?? 0;
          safetyErrorCount = extraData['safetyErrorCount'] ?? 0;
          kickErrorCount = extraData['kickErrorCount'] ?? 0;
          jumpErrorCount = extraData['jumpErrorCount'] ?? 0;
        }
      } catch (_) {}
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
      // FIX-003: New fields
      ballsPotted: ballsPotted,
      largestRun: largestRun,
      breakSuccess: breakSuccess,
      breakScratch: breakScratch,
      breakFoul: breakFoul,
      easyMissCount: easyMissCount,
      hardMissCount: hardMissCount,
      scratchErrorCount: scratchErrorCount,
      positionErrorCount: positionErrorCount,
      safetyErrorCount: safetyErrorCount,
      kickErrorCount: kickErrorCount,
      jumpErrorCount: jumpErrorCount,
      bestStrengths: bestStrengths,
      biggestMistakes: biggestMistakes,
    );
  }
}
