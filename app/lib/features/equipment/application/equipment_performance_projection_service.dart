import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match/data/repositories/match_repository.dart';
import '../../match/domain/models/match.dart';
import '../../player/data/repositories/player_repository.dart';
import '../../rack/data/repositories/rack_repository.dart';
import '../../session/data/repositories/session_repository.dart';
import '../../session/domain/models/session.dart';
import '../data/repositories/equipment_repository.dart';
import '../data/repositories/match_equipment_snapshot_repository.dart';
import '../domain/equipment_performance_projection.dart';
import 'equipment_performance_calculator.dart';

final equipmentPerformanceProjectionServiceProvider =
    Provider<EquipmentPerformanceProjectionService>((ref) {
  return EquipmentPerformanceProjectionService(
    players: ref.watch(playerRepositoryProvider),
    equipment: ref.watch(equipmentRepositoryProvider),
    sessions: ref.watch(sessionRepositoryProvider),
    matches: ref.watch(matchRepositoryProvider),
    racks: ref.watch(rackRepositoryProvider),
    snapshots: ref.watch(matchEquipmentSnapshotRepositoryProvider),
  );
});

final class EquipmentPerformanceProjectionService {
  const EquipmentPerformanceProjectionService({
    required PlayerRepository players,
    required EquipmentRepository equipment,
    required SessionRepository sessions,
    required MatchRepository matches,
    required RackRepository racks,
    required MatchEquipmentSnapshotRepository snapshots,
    EquipmentPerformanceCalculator calculator =
        const EquipmentPerformanceCalculator(),
  })  : _players = players,
        _equipment = equipment,
        _sessions = sessions,
        _matches = matches,
        _racks = racks,
        _snapshots = snapshots,
        _calculator = calculator;

  final PlayerRepository _players;
  final EquipmentRepository _equipment;
  final SessionRepository _sessions;
  final MatchRepository _matches;
  final RackRepository _racks;
  final MatchEquipmentSnapshotRepository _snapshots;
  final EquipmentPerformanceCalculator _calculator;

  Future<int?> loadActivePlayerId() async =>
      (await _players.getActivePlayer())?.id;

  Future<List<EquipmentPerformanceProjection>>
      loadOrRefreshActivePlayer() async {
    final player = await _players.getActivePlayer();
    final playerId = player?.id;
    if (playerId == null) return const [];
    final cues = await _equipment.getAllCues(playerId: playerId);
    final cueIds = cues.map((cue) => cue.id).whereType<int>().toSet();
    final stored = await _equipment.getPerformanceProjections(playerId);
    if (stored.map((item) => item.equipmentId).toSet().containsAll(cueIds) &&
        stored.length == cueIds.length) {
      return stored;
    }
    return refreshActivePlayer();
  }

  Future<List<EquipmentPerformanceProjection>> refreshActivePlayer() async {
    final player = await _players.getActivePlayer();
    final playerId = player?.id;
    if (playerId == null) return const [];
    final cues = await _equipment.getAllCues(playerId: playerId);
    final cueIds = cues.map((cue) => cue.id).whereType<int>().toSet();
    final activities = <int, List<EquipmentPerformanceActivity>>{
      for (final cueId in cueIds) cueId: [],
    };
    final sessions = await _sessions.getAllSessions();
    final sessionById = <int, Session>{
      for (final session in sessions)
        if (session.id != null) session.id!: session,
    };
    final matches = (await _matches.getAllMatches())
        .where((match) => match.id != null && match.endTime != null)
        .toList();

    for (final match in matches) {
      final snapshot = await _snapshots.getByMatchId(match.id!);
      if (snapshot == null) continue;
      final usedCueIds = <int>{
        if (snapshot.playingCueId != null) snapshot.playingCueId!,
        if (snapshot.breakCueId != null) snapshot.breakCueId!,
        if (snapshot.jumpCueId != null) snapshot.jumpCueId!,
      }.where(cueIds.contains).toSet();
      if (usedCueIds.isEmpty) continue;
      final session = sessionById[match.sessionId];
      if (session == null) continue;
      final training = session.sessionType == SessionTypes.training ||
          match.gameType == GameTypes.drill;
      if (training && session.finishedAt == null) continue;
      final racks = await _racks.getRacksByMatchId(match.id!);
      final successes = racks.fold(0, (sum, rack) => sum + rack.ballsPotted);
      final misses = racks.fold(
        0,
        (sum, rack) => sum + rack.easyMissCount + rack.hardMissCount,
      );
      final activity = EquipmentPerformanceActivity(
        kind: training
            ? EquipmentActivityKind.training
            : EquipmentActivityKind.match,
        sourceId: training
            ? 'training:${session.id}:${match.id}'
            : 'match:${match.id}',
        sessionId: session.id!,
        endedAt: training ? session.finishedAt! : match.endTime!,
        durationSeconds: _durationSeconds(
          training ? session.startedAt : match.startTime,
          training ? session.finishedAt : match.endTime,
        ),
        won: (match.winner ?? '').toLowerCase() == 'player' ||
            (match.winner ?? '').toLowerCase() == 'me',
        attempts: successes + misses,
        successes: successes,
      );
      for (final cueId in usedCueIds) {
        activities[cueId]!.add(activity);
      }
    }

    final projections = cueIds
        .map((cueId) => _calculator.calculate(
              playerId: playerId,
              equipmentId: cueId,
              activities: activities[cueId]!,
            ))
        .toList()
      ..sort((left, right) => left.equipmentId.compareTo(right.equipmentId));
    await _equipment.replacePerformanceProjections(playerId, projections);
    return List.unmodifiable(projections);
  }
}

int _durationSeconds(DateTime? start, DateTime? end) {
  if (start == null || end == null || end.isBefore(start)) return 0;
  return end.toUtc().difference(start.toUtc()).inSeconds;
}
