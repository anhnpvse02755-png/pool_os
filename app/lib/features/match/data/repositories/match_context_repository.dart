import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/match/domain/models/match_context.dart';

final matchContextRepositoryProvider = Provider<MatchContextRepository>((ref) {
  return MatchContextRepository(ref.watch(databaseProvider));
});

/// Task 06: persistence for pre/post-match context. One row per Match; the pre
/// and post halves are written independently (upsert on matchId). Data-only —
/// nothing here computes or interprets, it just stores.
class MatchContextRepository {
  final db.AppDatabase _db;

  MatchContextRepository(this._db);

  MatchContext _map(db.MatchContext r) {
    return MatchContext(
      id: r.id,
      matchId: r.matchId,
      purpose: r.purpose,
      opponent: r.opponent,
      tableFamiliarity: r.tableFamiliarity,
      roomFamiliarity: r.roomFamiliarity,
      lighting: r.lighting,
      warmupLevel: r.warmupLevel,
      matchGoals: MatchContext.decodeList(r.matchGoals),
      preRecordedAt: r.preRecordedAt,
      fatigueLevel: r.fatigueLevel,
      fatigueAreas: MatchContext.decodeList(r.fatigueAreas),
      mentalState: r.mentalState,
      selfRating: r.selfRating,
      biggestFactor: r.biggestFactor,
      biggestFactorNote: r.biggestFactorNote,
      postRecordedAt: r.postRecordedAt,
    );
  }

  Future<MatchContext?> getByMatchId(int matchId) async {
    final row = await (_db.select(_db.matchContexts)
          ..where((t) => t.matchId.equals(matchId))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _map(row);
  }

  /// Save the PRE-match half. Creates the row if missing, otherwise updates only
  /// the pre-match columns (leaves any post-match data intact).
  Future<void> savePreMatch(MatchContext ctx) async {
    final existing = await getByMatchId(ctx.matchId);
    final companion = db.MatchContextsCompanion(
      matchId: Value(ctx.matchId),
      purpose: Value(ctx.purpose),
      opponent: Value(ctx.opponent),
      tableFamiliarity: Value(ctx.tableFamiliarity),
      roomFamiliarity: Value(ctx.roomFamiliarity),
      lighting: Value(ctx.lighting),
      warmupLevel: Value(ctx.warmupLevel),
      matchGoals: Value(MatchContext.encodeList(ctx.matchGoals)),
      preRecordedAt: Value(ctx.preRecordedAt ?? DateTime.now()),
    );
    if (existing == null) {
      await _db.into(_db.matchContexts).insert(companion);
    } else {
      await (_db.update(_db.matchContexts)
            ..where((t) => t.matchId.equals(ctx.matchId)))
          .write(companion);
    }
  }

  /// Save the POST-match half. Creates the row if missing (pre-match may have
  /// been skipped), otherwise updates only the post-match columns.
  Future<void> savePostMatch(MatchContext ctx) async {
    final existing = await getByMatchId(ctx.matchId);
    final companion = db.MatchContextsCompanion(
      matchId: Value(ctx.matchId),
      fatigueLevel: Value(ctx.fatigueLevel),
      fatigueAreas: Value(MatchContext.encodeList(ctx.fatigueAreas)),
      mentalState: Value(ctx.mentalState),
      selfRating: Value(ctx.selfRating),
      biggestFactor: Value(ctx.biggestFactor),
      biggestFactorNote: Value(ctx.biggestFactorNote),
      postRecordedAt: Value(ctx.postRecordedAt ?? DateTime.now()),
    );
    if (existing == null) {
      await _db.into(_db.matchContexts).insert(companion);
    } else {
      await (_db.update(_db.matchContexts)
            ..where((t) => t.matchId.equals(ctx.matchId)))
          .write(companion);
    }
  }

  /// All contexts (for Task 07+ to read). Read-only consumers.
  Future<List<MatchContext>> getAll() async {
    final rows = await _db.select(_db.matchContexts).get();
    return rows.map(_map).toList();
  }
}
