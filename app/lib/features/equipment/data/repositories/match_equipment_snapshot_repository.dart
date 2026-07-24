import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';

final matchEquipmentSnapshotRepositoryProvider =
    Provider<MatchEquipmentSnapshotRepository>((ref) {
  return MatchEquipmentSnapshotRepository(
    ref.watch(databaseProvider),
    ref.watch(equipmentRepositoryProvider),
    ref.watch(playerRepositoryProvider),
  );
});

/// Task 04: an immutable equipment snapshot per match (doc §4).
///
/// Records which cue filled each role (Playing / Break / Jump) at the moment a
/// match starts. Written once, read-side only (never inside the LOCKED RFC-301
/// recording pipeline). Later changes to the player's default active cues do
/// NOT touch existing snapshots, so historical matches always show the cues
/// actually used.
class MatchEquipmentSnapshotRepository {
  final db.AppDatabase _db;
  final EquipmentRepository _equipmentRepo;
  final PlayerRepository? _players;

  MatchEquipmentSnapshotRepository(
    this._db,
    this._equipmentRepo, [
    this._players,
  ]);

  /// Capture the active-cue-per-role snapshot for [matchId]. Idempotent: if a
  /// snapshot already exists for this match it is left untouched — critical
  /// because the practice path reuses an open match (ensurePracticeMatch), so
  /// this can fire repeatedly for the same matchId and must not overwrite the
  /// original (which would rewrite history if the active cues changed midway).
  Future<void> captureForMatch(int matchId) async {
    // A 'break_jump' cue resolves as BOTH the break and jump cue here — that is
    // intentional (one physical cue owning two roles), not a data error.
    final playerId = (await _players?.getActivePlayer())?.id;
    final playing =
        await _equipmentRepo.getActiveCueByType('playing', playerId: playerId);
    final breakCue =
        await _equipmentRepo.getActiveCueByType('break', playerId: playerId);
    final jumpCue =
        await _equipmentRepo.getActiveCueByType('jump', playerId: playerId);

    // The check-and-insert runs in a transaction so a rapid double-invocation
    // (the practice path reuses an open match and can fire captureForMatch twice
    // before the first insert commits) cannot both observe "no row" and both
    // insert. On the single DB connection the transaction serializes the
    // existence check with the insert, keeping the snapshot written-once.
    await _db.transaction(() async {
      final existing = await getByMatchId(matchId);
      if (existing != null) return;
      await _db.into(_db.matchEquipmentSnapshots).insert(
            db.MatchEquipmentSnapshotsCompanion.insert(
              matchId: matchId,
              playingCueId: Value(playing?.id),
              breakCueId: Value(breakCue?.id),
              jumpCueId: Value(jumpCue?.id),
              createdAt: DateTime.now(),
            ),
          );
    });
  }

  Future<db.MatchEquipmentSnapshot?> getByMatchId(int matchId) async {
    return (_db.select(_db.matchEquipmentSnapshots)
          ..where((s) => s.matchId.equals(matchId))
          ..limit(1))
        .getSingleOrNull();
  }
}
