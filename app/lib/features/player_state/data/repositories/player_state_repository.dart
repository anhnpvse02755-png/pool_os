import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/player_state/domain/models/player_state_log.dart';

final playerStateRepositoryProvider = Provider<PlayerStateRepository>((ref) {
  return PlayerStateRepository(ref.watch(databaseProvider));
});

/// Player State System persistence. Unlike daily_readiness (an in-memory map),
/// this writes through Drift so player-state history survives restart — the
/// doc (§9) requires the states be stored as history, never overwritten, never
/// fabricated. Every log is an append (no update/upsert).
class PlayerStateRepository {
  final db.AppDatabase _db;

  PlayerStateRepository(this._db);

  /// Appends one state log and returns its real id (persist-first).
  Future<int> addLog(PlayerStateLog log) async {
    return _db.into(_db.playerStateLogs).insert(
          db.PlayerStateLogsCompanion.insert(
            sessionId: log.sessionId,
            matchId: Value(log.matchId),
            kind: log.kind,
            readyToCompete: Value(log.readyToCompete),
            warmedUp: Value(log.warmedUp),
            handFeel: Value(log.handFeel),
            fatigueLevel: Value(log.fatigueLevel),
            notes: Value(log.notes),
            createdAt: log.createdAt,
          ),
        );
  }

  Future<List<PlayerStateLog>> getLogsBySession(int sessionId) async {
    final rows = await (_db.select(_db.playerStateLogs)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_map).toList();
  }

  Future<List<PlayerStateLog>> getLogsByMatch(int matchId) async {
    final rows = await (_db.select(_db.playerStateLogs)
          ..where((t) => t.matchId.equals(matchId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_map).toList();
  }

  /// Recent logs of a given [kind] across all sessions, newest first — used to
  /// learn a player's history (e.g. fatigue trend). Never fabricates: returns
  /// only what was actually recorded.
  Future<List<PlayerStateLog>> getRecentByKind(String kind, {int limit = 20}) async {
    final rows = await (_db.select(_db.playerStateLogs)
          ..where((t) => t.kind.equals(kind))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_map).toList();
  }

  PlayerStateLog _map(db.PlayerStateLog row) {
    return PlayerStateLog(
      id: row.id,
      sessionId: row.sessionId,
      matchId: row.matchId,
      kind: row.kind,
      readyToCompete: row.readyToCompete,
      warmedUp: row.warmedUp,
      handFeel: row.handFeel,
      fatigueLevel: row.fatigueLevel,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }
}
