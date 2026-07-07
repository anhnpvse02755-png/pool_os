import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(ref.watch(databaseProvider));
});

class MatchRepository {
  final db.AppDatabase _db;

  MatchRepository(this._db);

  Future<List<Match>> getMatchesBySessionId(int sessionId) async {
    final results = await (_db.select(_db.matches)
          ..where((m) => m.sessionId.equals(sessionId))
          ..orderBy([(m) => OrderingTerm.asc(m.matchNumber)]))
        .get();
    return results.map(_mapToMatch).toList();
  }

  Future<Match?> getMatchById(int id) async {
    final result = await (_db.select(_db.matches)..where((m) => m.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToMatch(result);
  }

  Future<Match?> getActiveMatchBySessionId(int sessionId) async {
    final result = await (_db.select(_db.matches)
          ..where((m) => m.sessionId.equals(sessionId) & m.endTime.isNull()))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToMatch(result);
  }

  Future<int> createMatch(Match match) async {
    return _db.into(_db.matches).insert(
      db.MatchesCompanion.insert(
        sessionId: match.sessionId,
        matchNumber: match.matchNumber,
        gameType: match.gameType,
        raceTo: Value(match.raceTo),
        opponent: Value(match.opponent),
        partner: Value(match.partner),
        teamMode: Value(match.teamMode),
        winner: Value(match.winner),
        result: Value(match.result),
        startTime: Value(match.startTime),
        endTime: Value(match.endTime),
        matchObjective: Value(match.matchObjective),
        notes: Value(match.notes),
        createdAt: Value(match.createdAt),
      ),
    );
  }

  Future<bool> updateMatch(Match match) async {
    final updatedRows = await (_db.update(_db.matches)
          ..where((m) => m.id.equals(match.id!)))
        .write(
      db.MatchesCompanion(
        sessionId: Value(match.sessionId),
        matchNumber: Value(match.matchNumber),
        gameType: Value(match.gameType),
        raceTo: Value(match.raceTo),
        opponent: Value(match.opponent),
        partner: Value(match.partner),
        teamMode: Value(match.teamMode),
        winner: Value(match.winner),
        result: Value(match.result),
        startTime: Value(match.startTime),
        endTime: Value(match.endTime),
        matchObjective: Value(match.matchObjective),
        notes: Value(match.notes),
      ),
    );
    return updatedRows > 0;
  }

  Future<int> finishMatch(int id, [String? winner]) async {
    return (_db.update(_db.matches)..where((m) => m.id.equals(id))).write(
      db.MatchesCompanion(
        endTime: Value(DateTime.now()),
        winner: Value(winner),
      ),
    );
  }

  Future<int> deleteMatch(int id) async {
    return (_db.delete(_db.matches)..where((m) => m.id.equals(id))).go();
  }

  Future<int> getMatchCountBySessionId(int sessionId) async {
    final count = _db.matches.id.count();
    final query = _db.selectOnly(_db.matches)
      ..addColumns([count])
      ..where(_db.matches.sessionId.equals(sessionId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Future<int> getNextMatchNumber(int sessionId) async {
    final count = await getMatchCountBySessionId(sessionId);
    return count + 1;
  }

  Future<List<Match>> getAllMatches() async {
    final results = await (_db.select(_db.matches)
          ..orderBy([(m) => OrderingTerm.desc(m.startTime)]))
        .get();
    return results.map(_mapToMatch).toList();
  }

  Future<List<Match>> getRecentMatches({int limit = 10}) async {
    final results = await (_db.select(_db.matches)
          ..orderBy([(m) => OrderingTerm.desc(m.startTime)])
          ..limit(limit))
        .get();
    return results.map(_mapToMatch).toList();
  }

  Match _mapToMatch(db.Matche data) {
    return Match(
      id: data.id,
      sessionId: data.sessionId,
      matchNumber: data.matchNumber,
      gameType: data.gameType,
      raceTo: data.raceTo,
      opponent: data.opponent,
      partner: data.partner,
      teamMode: data.teamMode,
      winner: data.winner,
      result: data.result,
      startTime: data.startTime,
      endTime: data.endTime,
      matchObjective: data.matchObjective,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }
}
