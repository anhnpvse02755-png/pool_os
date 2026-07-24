import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mastery/domain/models/mastery_models.dart';
import '../../match/data/repositories/match_repository.dart';
import '../../match/domain/models/match.dart';
import '../../player/data/repositories/player_repository.dart';
import '../../rack/data/repositories/rack_repository.dart';
import '../../rack/domain/models/rack.dart';
import '../../session/data/repositories/session_repository.dart';
import '../../session/domain/models/session.dart';
import '../../../infrastructure/wiring/mastery_providers.dart';
import '../domain/player_progress_projection.dart';
import 'player_progress_calculator.dart';

typedef PlayerMasteryLoader = Future<MasterySnapshot> Function();

final playerProgressServiceProvider = Provider<PlayerProgressService>((ref) {
  return PlayerProgressService(
    players: ref.watch(playerRepositoryProvider),
    matches: ref.watch(matchRepositoryProvider),
    racks: ref.watch(rackRepositoryProvider),
    sessions: ref.watch(sessionRepositoryProvider),
    loadMastery: () => ref.read(masterySnapshotProvider.future),
  );
});

final class PlayerProgressService {
  const PlayerProgressService({
    required PlayerRepository players,
    required MatchRepository matches,
    required RackRepository racks,
    required SessionRepository sessions,
    required PlayerMasteryLoader loadMastery,
    PlayerProgressCalculator calculator = const PlayerProgressCalculator(),
  })  : _players = players,
        _matches = matches,
        _racks = racks,
        _sessions = sessions,
        _loadMastery = loadMastery,
        _calculator = calculator;

  final PlayerRepository _players;
  final MatchRepository _matches;
  final RackRepository _racks;
  final SessionRepository _sessions;
  final PlayerMasteryLoader _loadMastery;
  final PlayerProgressCalculator _calculator;

  Future<PlayerProgressProjection?> loadActivePlayer() async {
    final player = await _players.getActivePlayer();
    final playerId = player?.id;
    return playerId == null ? null : _players.getProgressProjection(playerId);
  }

  Future<PlayerProgressProjection?> loadOrRefreshActivePlayer() async {
    final stored = await loadActivePlayer();
    return stored ?? refreshActivePlayer();
  }

  Future<PlayerProgressProjection?> refreshActivePlayer() async {
    final player = await _players.getActivePlayer();
    final playerId = player?.id;
    if (player == null || playerId == null) return null;

    final sessions = await _sessions.getAllSessions();
    final sessionById = <int, Session>{
      for (final session in sessions)
        if (session.id != null) session.id!: session,
    };
    final completedMatches = (await _matches.getAllMatches())
        .where((match) => match.id != null && match.endTime != null)
        .toList();
    final racksByMatch = <int, List<Rack>>{};
    for (final match in completedMatches) {
      racksByMatch[match.id!] = await _racks.getRacksByMatchId(match.id!);
    }

    final activities = <PlayerProgressActivity>[];
    final trainingMatches = <int, List<Match>>{};
    for (final match in completedMatches) {
      final session = sessionById[match.sessionId];
      final isTraining = session?.sessionType == SessionTypes.training ||
          match.gameType == GameTypes.drill;
      if (isTraining) {
        trainingMatches.putIfAbsent(match.sessionId, () => []).add(match);
      } else {
        activities.add(_matchActivity(match, racksByMatch[match.id!]!));
      }
    }
    for (final entry in trainingMatches.entries) {
      final session = sessionById[entry.key];
      if (session == null || session.finishedAt == null) continue;
      activities.add(_trainingActivity(
        session,
        entry.value,
        racksByMatch,
      ));
    }

    final mastery = await _loadMastery();
    final masteryMetrics = mastery.entries.values
        .map((entry) => PlayerMasteryMetric(
              knowledgeId: entry.entryId,
              score: entry.score,
              confidence: entry.confidence,
              lastEvidenceAt: entry.lastEvidenceAt,
            ))
        .toList();
    final projection = _calculator.calculate(
      playerId: playerId,
      activities: activities,
      mastery: masteryMetrics,
      fallbackUpdatedAt: player.updatedAt,
    );
    await _players.saveProgressProjection(projection);
    return projection;
  }

  PlayerProgressActivity _matchActivity(Match match, List<Rack> racks) =>
      _activity(
        kind: PlayerProgressActivityKind.match,
        sourceId: 'match:${match.id}',
        occurredAt: match.endTime!,
        racks: racks,
      );

  PlayerProgressActivity _trainingActivity(
    Session session,
    List<Match> matches,
    Map<int, List<Rack>> racksByMatch,
  ) =>
      _activity(
        kind: PlayerProgressActivityKind.training,
        sourceId: 'training:${session.id}',
        occurredAt: session.finishedAt!,
        racks: [
          for (final match in matches) ...racksByMatch[match.id!] ?? const [],
        ],
      );

  PlayerProgressActivity _activity({
    required PlayerProgressActivityKind kind,
    required String sourceId,
    required DateTime occurredAt,
    required List<Rack> racks,
  }) {
    final ballsPotted = _rackSum(racks, (rack) => rack.ballsPotted);
    final misses = _rackSum(
      racks,
      (rack) => rack.easyMissCount + rack.hardMissCount,
    );
    return PlayerProgressActivity(
      kind: kind,
      sourceId: sourceId,
      occurredAt: occurredAt,
      rackCount: racks.length,
      wins: racks.where((rack) => rack.result).length,
      attempts: ballsPotted + misses,
      successes: ballsPotted,
      breakAttempts:
          kind == PlayerProgressActivityKind.match ? racks.length : 0,
      breakSuccesses: kind == PlayerProgressActivityKind.match
          ? racks.where((rack) => rack.breakSuccess).length
          : 0,
      scratches: _rackSum(
        racks,
        (rack) =>
            rack.scratchErrorCount +
            (rack.breakScratch ? 1 : 0) +
            (rack.breakFoul ? 1 : 0),
      ),
      positionErrors: _rackSum(racks, (rack) => rack.positionErrorCount),
      safetyErrors: _rackSum(racks, (rack) => rack.safetyErrorCount),
      kickErrors: _rackSum(racks, (rack) => rack.kickErrorCount),
      jumpErrors: _rackSum(racks, (rack) => rack.jumpErrorCount),
      confidenceValues:
          racks.map((rack) => rack.confidence).whereType<int>().toList(),
    );
  }
}

int _rackSum(List<Rack> racks, int Function(Rack) select) =>
    racks.fold(0, (sum, rack) => sum + select(rack));
