// EPIC 01 — Match Engine — Phase 7: Match Recorder.
//
// Application-layer service that owns the recording pipeline. It
// wraps the MatchManager and produces a stream of MatchRecordingEvent
// observers: shot log subscribers, foul log subscribers, safety log
// subscribers, and a completed-match event emitter for downstream
// consumers (Statistics, Timeline).

import 'package:meta/meta.dart';

import '../engine/command.dart';
import '../engine/event.dart';
import '../engine/match_manager.dart';
import '../engine/value_objects.dart';
import '../rule/game_type.dart';
import '../rule/placeholder_rule.dart';

/// Sink for shot history events. Hooks: Statistics, Timeline.
abstract class ShotHistorySink {
  Future<void> onShotRecorded(ShotRecorded event);
}

/// Sink for foul events.
abstract class FoulSink {
  Future<void> onFoulRecorded(FoulRecorded event);
}

/// Sink for safety events.
abstract class SafetySink {
  Future<void> onSafetyRecorded(SafetyRecorded event);
}

/// Sink for match-completed events.
abstract class MatchCompletedSink {
  Future<void> onMatchCompleted(MatchCompleted event);
}

/// A no-op implementation, useful for tests.
class NullRecordingSinks
    implements ShotHistorySink, FoulSink, SafetySink, MatchCompletedSink {
  const NullRecordingSinks();
  @override
  Future<void> onShotRecorded(ShotRecorded event) async {}
  @override
  Future<void> onFoulRecorded(FoulRecorded event) async {}
  @override
  Future<void> onSafetyRecorded(SafetyRecorded event) async {}
  @override
  Future<void> onMatchCompleted(MatchCompleted event) async {}
}

@immutable
class MatchRecordingPipeline {
  MatchRecordingPipeline({
    required this.manager,
    required this.ruleRegistry,
    required ShotHistorySink shotHistorySink,
    required FoulSink foulSink,
    required SafetySink safetySink,
    required MatchCompletedSink completedSink,
    MatchClock? clock,
  })  : clock = clock ?? const SystemMatchClock(),
        shotHistorySink = shotHistorySink,
        foulSink = foulSink,
        safetySink = safetySink,
        completedSink = completedSink;

  final MatchManager manager;
  final GameRuleRegistry ruleRegistry;
  final ShotHistorySink shotHistorySink;
  final FoulSink foulSink;
  final SafetySink safetySink;
  final MatchCompletedSink completedSink;
  final MatchClock clock;

  // ---- command surface (UI / shell -> engine) -----------------------

  Future<MatchManagerState> startMatch() {
    return manager.issue(StartMatch(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
    ));
  }

  Future<MatchManagerState> beginRack(RackId rackId, String breaking) {
    return manager.issue(BeginRack(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      rackId: rackId,
      breakingParticipantId: breaking,
    ));
  }

  Future<MatchManagerState> beginTurn(
      TurnId turnId, RackId rackId, String participant) {
    return manager.issue(BeginTurn(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      turnId: turnId,
      rackId: rackId,
      participantId: participant,
    ));
  }

  Future<MatchManagerState> recordShot({
    required ShotId shotId,
    required TurnId turnId,
    required RackId rackId,
    required String participant,
  }) async {
    final result = await manager.issue(RecordShot(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      shotId: shotId,
      turnId: turnId,
      rackId: rackId,
      participantId: participant,
    ));
    for (final ev in result.events) {
      if (ev is ShotRecorded) {
        await shotHistorySink.onShotRecorded(ev);
      }
    }
    return result;
  }

  Future<MatchManagerState> endTurn({
    required TurnId turnId,
    required RackId rackId,
    required String resolution,
  }) {
    return manager.issue(EndTurn(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      turnId: turnId,
      rackId: rackId,
      resolution: resolution,
    ));
  }

  Future<MatchManagerState> recordFoul({
    required TurnId turnId,
    required RackId rackId,
    required String participant,
    required String reason,
  }) async {
    final result = await manager.issue(RecordFoul(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      turnId: turnId,
      rackId: rackId,
      participantId: participant,
      reason: reason,
    ));
    for (final ev in result.events) {
      if (ev is FoulRecorded) {
        await foulSink.onFoulRecorded(ev);
      }
    }
    return result;
  }

  Future<MatchManagerState> recordSafety({
    required TurnId turnId,
    required RackId rackId,
    required String participant,
    required String reason,
  }) async {
    final result = await manager.issue(RecordSafety(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      turnId: turnId,
      rackId: rackId,
      participantId: participant,
      reason: reason,
    ));
    for (final ev in result.events) {
      if (ev is SafetyRecorded) {
        await safetySink.onSafetyRecorded(ev);
      }
    }
    return result;
  }

  Future<MatchManagerState> endRack(RackId rackId, String winner) {
    return manager.issue(EndRack(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      rackId: rackId,
      winnerParticipantId: winner,
    ));
  }

  Future<MatchManagerState> concedeMatch(String concedingParticipantId) async {
    final result = await manager.issue(ConcedeMatch(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      concedingParticipantId: concedingParticipantId,
    ));
    for (final ev in result.events) {
      if (ev is MatchCompleted) {
        await completedSink.onMatchCompleted(ev);
      }
    }
    return result;
  }

  Future<MatchManagerState> completeMatch(String winner) async {
    final result = await manager.issue(CompleteMatch(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      winnerParticipantId: winner,
    ));
    for (final ev in result.events) {
      if (ev is MatchCompleted) {
        await completedSink.onMatchCompleted(ev);
      }
    }
    return result;
  }

  Future<MatchManagerState> abandonMatch(String reason) {
    return manager.issue(AbandonMatch(
      matchId: manager.engine.match.id,
      issuedAt: clock.now(),
      reason: reason,
    ));
  }

  Future<MatchManagerState> undo() => manager.issue(UndoCommand(
        matchId: manager.engine.match.id,
        issuedAt: clock.now(),
      ));

  Future<MatchManagerState> redo() => manager.issue(RedoCommand(
        matchId: manager.engine.match.id,
        issuedAt: clock.now(),
      ));

  /// Helper used by UI: starting a new match. The pipeline hands a
  /// caller the command surface; the actual Match aggregate is built
  /// by the application layer.
  static MatchRecorderStarter starter({
    required MatchId matchId,
    required GameType gameType,
    required int raceLength,
    required List<String> participants,
    required DateTime startedAt,
  }) {
    return MatchRecorderStarter(
      matchId: matchId,
      gameType: gameType,
      raceLength: raceLength,
      participants: participants,
      startedAt: startedAt,
    );
  }
}

/// Builder data for a new match. Lives in the recording layer to
/// avoid coupling UI to the domain aggregate construction.
class MatchRecorderStarter {
  const MatchRecorderStarter({
    required this.matchId,
    required this.gameType,
    required this.raceLength,
    required this.participants,
    required this.startedAt,
  });

  final MatchId matchId;
  final GameType gameType;
  final int raceLength;
  final List<String> participants;
  final DateTime startedAt;
}
