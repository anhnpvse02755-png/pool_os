// EPIC 01 — Match Engine — Phase 8: integration seams.
//
// Adapters that connect the Match Engine to other modules:
//   - Player module (Active Player → match participant)
//   - Equipment module (Active cue → turn metadata)
//   - Timeline module (Match-completed → CareerTimelineProjection)
//   - Statistics module (Shot history → MatchStatisticsProjection)
//
// Each adapter lives in domain/ and is intentionally minimal: a
// reference to the relevant module's projection / service, plus a
// thin glue function. Module owners may replace these adapters with
// their preferred pattern without modifying the Match Engine.

import '../engine/event.dart';
import '../engine/match_manager.dart';
import '../engine/match_aggregate.dart';
import '../engine/value_objects.dart';

/// Minimal type the Player module must supply so the Match Engine
/// can read the active participant for a turn. Real implementation
/// lives in the Player module and is passed into the pipeline at
/// construction time.
abstract class PlayerModuleBridge {
  String activeParticipantId();
}

/// Minimal type the Equipment module must supply for shot metadata.
abstract class EquipmentModuleBridge {
  String? activeCueId();
}

/// Minimal type the Timeline module must supply so completed matches
/// appear on the career timeline.
abstract class TimelineModuleBridge {
  Future<void> onMatchCompleted({
    required MatchId matchId,
    required String winnerParticipantId,
    required DateTime endedAt,
    required List<String> participants,
  });
}

/// Minimal type the Statistics module must supply so shot history
/// flows into match statistics. Shot count, foul count, safety count
/// are summarised here; richer classifications come from EPIC Rule
/// System.
abstract class StatisticsModuleBridge {
  Future<void> onShotHistoryRecorded({
    required MatchId matchId,
    required String participantId,
    required int shotCount,
    required int foulCount,
    required int safetyCount,
  });
}

/// A no-op implementation used by tests and for migrations where the
/// modules are not yet wired in.
class NullPlayerBridge implements PlayerModuleBridge {
  const NullPlayerBridge();
  @override
  String activeParticipantId() => 'unknown-participant';
}

class NullEquipmentBridge implements EquipmentModuleBridge {
  const NullEquipmentBridge();
  @override
  String? activeCueId() => null;
}

class NullTimelineBridge implements TimelineModuleBridge {
  const NullTimelineBridge();
  @override
  Future<void> onMatchCompleted({
    required MatchId matchId,
    required String winnerParticipantId,
    required DateTime endedAt,
    required List<String> participants,
  }) async {}
}

class NullStatisticsBridge implements StatisticsModuleBridge {
  const NullStatisticsBridge();
  @override
  Future<void> onShotHistoryRecorded({
    required MatchId matchId,
    required String participantId,
    required int shotCount,
    required int foulCount,
    required int safetyCount,
  }) async {}
}

/// Glue that pipes a Match-completed event into the Timeline module.
class TimelineAdapter {
  const TimelineAdapter(this.timeline);
  final TimelineModuleBridge timeline;

  Future<void> handle(MatchManagerState state) async {
    if (state.events.isEmpty) return;
    for (final ev in state.events) {
      if (ev is MatchCompleted) {
        await timeline.onMatchCompleted(
          matchId: ev.matchId,
          winnerParticipantId: ev.winnerParticipantId,
          endedAt: ev.occurredAt,
          participants: state.match.participants,
        );
      }
    }
  }
}

/// Glue that summarises the per-participant shot history and ships
/// it to the Statistics module.
class StatisticsAdapter {
  const StatisticsAdapter(this.statistics);
  final StatisticsModuleBridge statistics;

  Future<void> handle(MatchManagerState state) async {
    if (state.events.isEmpty) return;
    for (final ev in state.events) {
      if (ev is ShotRecorded) {
        final stats = _summariseFor(state.match, ev.participantId);
        await statistics.onShotHistoryRecorded(
          matchId: ev.matchId,
          participantId: ev.participantId,
          shotCount: stats.shots,
          foulCount: stats.fouls,
          safetyCount: stats.safeties,
        );
      }
    }
  }

  _ParticipantStats _summariseFor(Match match, String participant) {
    var shots = 0;
    var fouls = 0;
    var safeties = 0;
    for (final rack in match.racks) {
      for (final turn in rack.turns) {
        if (turn.participantId != participant) continue;
        shots += turn.shots.length;
        if (turn.resolution.toString().endsWith('foul')) fouls++;
        if (turn.resolution.toString().endsWith('safety')) safeties++;
      }
    }
    return _ParticipantStats(shots, fouls, safeties);
  }
}

class _ParticipantStats {
  const _ParticipantStats(this.shots, this.fouls, this.safeties);
  final int shots;
  final int fouls;
  final int safeties;
}
