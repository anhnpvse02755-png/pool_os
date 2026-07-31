// EPIC 01 — Match Engine — Phase 6: Match Manager.
//
// Application-layer orchestrator. Combines the engine, the event log
// and the rule registry into a single object that the application can
// use to issue commands and persist results. The MatchManager owns
// exactly one in-memory MatchEngineCore at a time, but is responsible
// for hydrating / persisting that core against the MatchEventLog.

import 'package:meta/meta.dart';

import '../rule/placeholder_rule.dart';
import 'command.dart';
import 'command_processor.dart';
import 'event.dart';
import 'match_aggregate.dart';
import 'match_event_log.dart';
import 'states.dart';
import 'value_objects.dart';

/// Snapshot of the engine state that the manager can hand back to a
/// caller (UI / recovery). Not for persistence — the event log is.
class MatchManagerState {
  const MatchManagerState({
    required this.match,
    required this.events,
    required this.canUndo,
    required this.canRedo,
  });

  final Match match;
  final List<MatchEvent> events;
  final bool canUndo;
  final bool canRedo;
}

@immutable
class MatchManager {
  const MatchManager._({
    required this.engine,
    required this.eventLog,
    required this.clock,
  });

  final MatchEngineCore engine;
  final MatchEventLog eventLog;
  final MatchClock clock;

  /// Issue a command and persist its events to the event log.
  /// Throws [StateError] if the engine rejects the command.
  Future<MatchManagerState> issue(MatchCommand command) async {
    final result = engine.apply(command);
    await eventLog.append(matchId: command.matchId, events: result.events);
    return _snapshot(result);
  }

  /// Synchronous issue for engine-only paths (no persistence). Useful
  /// for tests and undo / redo preview.
  MatchManagerState issueSync(MatchCommand command) {
    final result = engine.apply(command);
    return _snapshot(result);
  }

  MatchManagerState snapshotSync() => _snapshotFromEngine();

  Future<void> persistSnapshot() async {
    await eventLog.saveSnapshot(
      MatchSnapshot(
        matchId: engine.match.id,
        payload: _serialize(engine.match),
        writtenAt: clock.now(),
      ),
    );
  }

  MatchManagerState _snapshot(CommandResult result) => MatchManagerState(
        match: result.match,
        events: result.events,
        canUndo: engine.canUndo,
        canRedo: engine.canRedo,
      );

  MatchManagerState _snapshotFromEngine() => MatchManagerState(
        match: engine.match,
        events: engine.events,
        canUndo: engine.canUndo,
        canRedo: engine.canRedo,
      );

  static String _serialize(Match match) {
    // Minimal canonical representation sufficient for cold-start
    // snapshot load. Recovery replays the event log to derive the
    // exact state; the snapshot is only a fast-path optimisation.
    return '${match.id.value}|${match.gameType.value}|${match.state.name}|'
        '${match.raceLength}|${match.racks.length}';
  }
}

/// Builder for MatchManager. Hydrates the engine from the event log
/// (preferred) or from a saved snapshot (fast path). Snapshots and
/// event logs are kept consistent via the `persistSnapshot` helper.
class MatchManagerBuilder {
  MatchManagerBuilder({
    required this.eventLog,
    required this.ruleRegistry,
    MatchClock? clock,
  }) : clock = clock ?? const SystemMatchClock();

  final MatchEventLog eventLog;
  final GameRuleRegistry ruleRegistry;
  final MatchClock clock;

  Future<MatchManager> hydrate(Match initialMatch) async {
    final events = await eventLog.read(matchId: initialMatch.id);
    final core = MatchEngineCore(
      match: initialMatch,
      ruleRegistry: ruleRegistry,
      clock: clock,
      initialEvents: events,
    );
    // Force the engine to reflect the hydrated event log: replay
    // forward to rebuild the snapshot from events.
    final rebuilt = _rebuildFromEvents(core, initialMatch, events);
    final hydrated = MatchEngineCore(
      match: rebuilt,
      ruleRegistry: ruleRegistry,
      clock: clock,
      initialEvents: events,
    );
    return MatchManager._(
      engine: hydrated,
      eventLog: eventLog,
      clock: clock,
    );
  }

  MatchManager buildNew(Match initialMatch) {
    final core = MatchEngineCore(
      match: initialMatch,
      ruleRegistry: ruleRegistry,
      clock: clock,
    );
    return MatchManager._(
      engine: core,
      eventLog: eventLog,
      clock: clock,
    );
  }

  Match _rebuildFromEvents(
    MatchEngineCore core,
    Match initial,
    List<MatchEvent> events,
  ) {
    // Reuse the engine's forward reducer (private). We replay against
    // a freshly-constructed empty Match snapshot for the same id /
    // participants / race length.
    final empty = Match(
      id: initial.id,
      gameType: initial.gameType,
      raceLength: initial.raceLength,
      participants: initial.participants,
      state: MatchState.created,
      racks: const [],
      startedAt: initial.startedAt,
    );
    // The engine's reducer is private; for hydrate we mirror the
    // command handlers by replaying the events we already know about.
    var current = empty;
    for (final ev in events) {
      current = _applyEventForward(core, current, ev);
    }
    return current;
  }

  Match _applyEventForward(
    MatchEngineCore core,
    Match snapshot,
    MatchEvent ev,
  ) {
    // Delegate to the engine's existing forward reducer through a
    // single command: this preserves the engine's invariants in a
    // single code path.
    // We round-trip by inspecting the event type and re-issuing the
    // matching command. This is intentionally simple — production
    // may swap to a direct reducer call.
    switch (ev) {
      case MatchStarted _:
        if (snapshot.state == MatchState.created) {
          return core.applySync(StartMatch(
            matchId: snapshot.id,
            issuedAt: ev.occurredAt,
          ));
        }
        return snapshot;
      case RackBegan e:
        return core.applySync(BeginRack(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          rackId: e.rackId,
          breakingParticipantId: e.breakingParticipantId,
        ));
      case TurnBegan e:
        return core.applySync(BeginTurn(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          turnId: e.turnId,
          rackId: e.rackId,
          participantId: e.participantId,
        ));
      case ShotRecorded e:
        return core.applySync(RecordShot(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          shotId: e.shotId,
          turnId: e.turnId,
          rackId: e.rackId,
          participantId: e.participantId,
        ));
      case TurnEnded e:
        return core.applySync(EndTurn(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          turnId: e.turnId,
          rackId: e.rackId,
          resolution: e.resolution,
        ));
      case FoulRecorded e:
        return core.applySync(RecordFoul(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          turnId: e.turnId,
          rackId: e.rackId,
          participantId: e.participantId,
          reason: e.reason,
        ));
      case SafetyRecorded e:
        return core.applySync(RecordSafety(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          turnId: e.turnId,
          rackId: e.rackId,
          participantId: e.participantId,
          reason: e.reason,
        ));
      case RackEnded e:
        return core.applySync(EndRack(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          rackId: e.rackId,
          winnerParticipantId: e.winnerParticipantId,
        ));
      case MatchConceded e:
        return core.applySync(ConcedeMatch(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          concedingParticipantId: e.concedingParticipantId,
        ));
      case MatchCompleted e:
        return core.applySync(CompleteMatch(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          winnerParticipantId: e.winnerParticipantId,
        ));
      case MatchAbandoned e:
        return core.applySync(AbandonMatch(
          matchId: snapshot.id,
          issuedAt: e.occurredAt,
          reason: e.reason,
        ));
      case CommandUndone _:
      case CommandRedone _:
        return snapshot;
    }
  }
}

/// Convenience constructor used by application callers.
extension MatchEngineCoreApplySync on MatchEngineCore {
  Match applySync(MatchCommand command) => apply(command).match;
}
