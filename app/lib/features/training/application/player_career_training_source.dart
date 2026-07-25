import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../player/data/database/app_database.dart' as db;
import '../../player/data/providers/database_providers.dart';
import '../../session/domain/models/session.dart';
import '../../match/domain/models/match.dart';

final playerCareerTrainingSourceProvider =
    Provider<PlayerCareerTrainingSource>((ref) {
  return PlayerCareerTrainingSource(ref.watch(databaseProvider));
});

final class CompletedTrainingTimelineFact {
  const CompletedTrainingTimelineFact({
    required this.id,
    required this.goal,
    required this.completedAt,
    required this.drillMatches,
  });

  final int id;
  final String? goal;
  final DateTime completedAt;
  final List<CompletedTrainingDrillTimelineFact> drillMatches;
}

final class CompletedTrainingDrillTimelineFact {
  const CompletedTrainingDrillTimelineFact({
    required this.id,
    required this.matchNumber,
  });

  final int id;
  final int matchNumber;
}

/// Read-only public hook exposing completed Training facts to Player.
final class PlayerCareerTrainingSource {
  const PlayerCareerTrainingSource(this._database);

  final db.AppDatabase _database;

  Future<List<CompletedTrainingTimelineFact>> loadForPlayer(
      int playerId) async {
    final sessions = await _database.select(_database.sessions).get();
    final matches = await _database.select(_database.matches).get();
    return [
      for (final session in sessions)
        if (session.sessionType == SessionTypes.training &&
            session.finishedAt != null &&
            (session.playerId == null || session.playerId == playerId))
          CompletedTrainingTimelineFact(
            id: session.id,
            goal: session.trainingGoal,
            completedAt: session.finishedAt!.toUtc(),
            drillMatches: ([
              for (final match in matches)
                if (match.sessionId == session.id &&
                    match.endTime != null &&
                    match.gameType == GameTypes.drill)
                  CompletedTrainingDrillTimelineFact(
                    id: match.id,
                    matchNumber: match.matchNumber,
                  ),
            ]..sort((left, right) {
                final numberOrder =
                    left.matchNumber.compareTo(right.matchNumber);
                return numberOrder != 0
                    ? numberOrder
                    : left.id.compareTo(right.id);
              })),
          ),
    ];
  }
}
