import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/data/database/app_database.dart' as db;
import '../../player/data/providers/database_providers.dart';
import '../../session/domain/models/session.dart';
import '../domain/models/match.dart';

final playerCareerMatchSourceProvider =
    Provider<PlayerCareerMatchSource>((ref) {
  return PlayerCareerMatchSource(ref.watch(databaseProvider));
});

final class CompletedMatchTimelineFact {
  const CompletedMatchTimelineFact({
    required this.id,
    required this.matchNumber,
    required this.gameType,
    required this.opponent,
    required this.winner,
    required this.result,
    required this.completedAt,
  });

  final int id;
  final int matchNumber;
  final String gameType;
  final String? opponent;
  final String? winner;
  final String? result;
  final DateTime completedAt;
}

/// Read-only public hook exposing completed Match facts for Player projections.
final class PlayerCareerMatchSource {
  const PlayerCareerMatchSource(this._database);

  final db.AppDatabase _database;

  Future<List<CompletedMatchTimelineFact>> loadForPlayer(int playerId) async {
    final sessions = await _database.select(_database.sessions).get();
    final sessionById = {
      for (final session in sessions) session.id: session,
    };
    final matches = await _database.select(_database.matches).get();
    return [
      for (final match in matches)
        if (_isIncluded(match, sessionById[match.sessionId], playerId))
          CompletedMatchTimelineFact(
            id: match.id,
            matchNumber: match.matchNumber,
            gameType: match.gameType,
            opponent: match.opponent,
            winner: match.winner,
            result: match.result,
            completedAt: match.endTime!.toUtc(),
          ),
    ];
  }
}

bool _isIncluded(db.Matche match, db.Session? session, int playerId) {
  if (match.endTime == null || session == null) return false;
  if (session.playerId != null && session.playerId != playerId) return false;
  return session.sessionType != SessionTypes.training &&
      match.gameType != GameTypes.drill;
}
