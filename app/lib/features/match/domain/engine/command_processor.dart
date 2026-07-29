// EPIC 01 — Match Engine — Phase 4: command processor.
//
// Pure Dart, no Flutter / Drift dependency. The processor folds a
// stream of commands into a Match aggregate and emits a stream of
// events. Undo / redo are modelled as event-sourced: every accepted
// command has a corresponding "applied" event id stored on an undo
// stack; undo pops and emits a CommandUndone event that the reducer
// treats as a rewind.
//
// This file deliberately has zero Flutter / Drift imports. It lives
// inside `domain/engine/`.

import 'package:meta/meta.dart';

import '../rule/placeholder_rule.dart';
import 'command.dart';
import 'event.dart';
import 'match_aggregate.dart';
import 'states.dart';
import 'value_objects.dart';

/// Reason emitted by the engine when a command is rejected.
class CommandRejection {
  const CommandRejection(this.command, this.reason);
  final MatchCommand command;
  final String reason;

  @override
  String toString() => 'CommandRejection(${command.runtimeType}: $reason)';
}

/// Successful outcome from `apply`. Carries the new aggregate and the
/// events that the command produced.
class CommandResult {
  const CommandResult({required this.match, required this.events});
  final Match match;
  final List<MatchEvent> events;
}

@immutable
class _PendingUndo {
  const _PendingUndo({
    required this.undoneCommand,
    required this.appliedEvents,
  });
  final MatchCommand undoneCommand;
  final List<MatchEvent> appliedEvents;
}

/// The Match Engine core. Holds the current Match aggregate, the
/// rule registry, and undo/redo bookkeeping. All mutations route
/// through this processor.
///
/// Construction is deliberately minimal: the engine is independent of
/// persistence and UI; the persistence layer drives reconstruction on
/// hydration.
class MatchEngineCore {
  MatchEngineCore({
    required Match match,
    required GameRuleRegistry ruleRegistry,
    MatchClock? clock,
    List<MatchEvent>? initialEvents,
    List<_PendingUndo>? initialUndoStack,
    List<_PendingUndo>? initialRedoStack,
  })  : _clock = clock ?? const SystemMatchClock(),
        _ruleRegistry = ruleRegistry,
        _match = match,
        _events = List.of(initialEvents ?? const <MatchEvent>[]),
        _undoStack = List.of(initialUndoStack ?? const <_PendingUndo>[]),
        _redoStack = List.of(initialRedoStack ?? const <_PendingUndo>[]) {
    _nextEventOrdinal = _events.length;
  }

  final MatchClock _clock;
  // The rule registry is consulted by command handlers; in the
  // placeholder engine the handlers do not invoke it directly. It is
  // kept on the constructor so that real rule engines can be plugged
  // in without changing the engine's public surface.
  // ignore: unused_field
  final GameRuleRegistry _ruleRegistry;
  final List<MatchEvent> _events;
  final List<_PendingUndo> _undoStack;
  final List<_PendingUndo> _redoStack;
  Match _match;
  int _nextEventOrdinal = 0;
  bool _inRedo = false;

  Match get match => _match;
  List<MatchEvent> get events => List.unmodifiable(_events);
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  EventId _nextEventId() {
    final v = _nextEventOrdinal++;
    return EventId('evt-${_match.id.value}-$v');
  }

  // ---- public command surface ----------------------------------------

  CommandResult apply(MatchCommand command) {
    switch (command) {
      case StartMatch _:
        return _applyStart(command);
      case BeginRack _:
        return _applyBeginRack(command);
      case BeginTurn _:
        return _applyBeginTurn(command);
      case RecordShot _:
        return _applyRecordShot(command);
      case EndTurn _:
        return _applyEndTurn(command);
      case RecordFoul _:
        return _applyRecordFoul(command);
      case RecordSafety _:
        return _applyRecordSafety(command);
      case EndRack _:
        return _applyEndRack(command);
      case ConcedeMatch _:
        return _applyConcede(command);
      case CompleteMatch _:
        return _applyComplete(command);
      case AbandonMatch _:
        return _applyAbandon(command);
      case UndoCommand _:
        return _applyUndo(command);
      case RedoCommand _:
        return _applyRedo(command);
    }
  }

  // ---- command handlers ----------------------------------------------

  CommandResult _applyStart(StartMatch c) {
    if (_match.state != MatchState.created) {
      throw StateError('Match ${_match.id} already started');
    }
    final event = MatchStarted(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
    );
    final next = _match.copyWith(state: MatchState.inProgress);
    return _commit(c, next, [event]);
  }

  CommandResult _applyBeginRack(BeginRack c) {
    if (_match.state != MatchState.inProgress) {
      throw StateError('Match ${_match.id} not in progress');
    }
    if (_match.activeRack != null) {
      throw StateError('A rack is already in progress');
    }
    if (!_match.participants.contains(c.breakingParticipantId)) {
      throw ArgumentError(
        'Breaking participant ${c.breakingParticipantId} is not a participant',
      );
    }
    final rackNumber = _match.racks.length + 1;
    final rack = Rack(
      id: c.rackId,
      matchId: _match.id,
      rackNumber: rackNumber,
      state: RackState.inProgress,
      breakingParticipantId: c.breakingParticipantId,
      turns: const [],
      startedAt: c.issuedAt,
    );
    final event = RackBegan(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      rackId: c.rackId,
      rackNumber: rackNumber,
      breakingParticipantId: c.breakingParticipantId,
    );
    final next = _match.copyWith(racks: [..._match.racks, rack]);
    return _commit(c, next, [event]);
  }

  CommandResult _applyBeginTurn(BeginTurn c) {
    final rack = _rack(c.rackId);
    if (rack.activeTurn != null) {
      throw StateError('A turn is already in progress for rack ${rack.id}');
    }
    final turn = Turn(
      id: c.turnId,
      rackId: c.rackId,
      participantId: c.participantId,
      state: TurnState.active,
      resolution: TurnResolution.unknown,
      shots: const [],
      startedAt: c.issuedAt,
    );
    final nextRack = rack.copyWith(turns: [...rack.turns, turn]);
    final nextRacks = List.of(_match.racks);
    nextRacks[nextRacks.length - 1] = nextRack;
    final event = TurnBegan(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      turnId: c.turnId,
      rackId: c.rackId,
      participantId: c.participantId,
    );
    final next = _match.copyWith(racks: nextRacks);
    return _commit(c, next, [event]);
  }

  CommandResult _applyRecordShot(RecordShot c) {
    final rack = _rack(c.rackId);
    final turns = List.of(rack.turns);
    if (turns.isEmpty) {
      throw StateError('No turn in progress for shot');
    }
    final turn = turns.removeLast();
    if (turn.state != TurnState.active) {
      throw StateError('Cannot record shot in a closed turn');
    }
    if (turn.participantId != c.participantId) {
      throw ArgumentError(
        'Shot participant ${c.participantId} does not match active turn ${turn.participantId}',
      );
    }
    final shot = Shot(
      id: c.shotId,
      turnId: c.turnId,
      shootingParticipantId: c.participantId,
      shotIndex: turn.shots.length + 1,
      recordedAt: c.issuedAt,
    );
    final updated = turn.copyWith(shots: [...turn.shots, shot]);
    turns.add(updated);
    final nextRack = rack.copyWith(turns: turns);
    final nextRacks = List.of(_match.racks);
    nextRacks[nextRacks.length - 1] = nextRack;
    final event = ShotRecorded(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      shotId: c.shotId,
      turnId: c.turnId,
      rackId: c.rackId,
      participantId: c.participantId,
      shotIndex: shot.shotIndex,
    );
    final next = _match.copyWith(racks: nextRacks);
    return _commit(c, next, [event]);
  }

  CommandResult _applyEndTurn(EndTurn c) {
    final rack = _rack(c.rackId);
    final turns = List.of(rack.turns);
    if (turns.isEmpty) {
      throw StateError('No turn in progress');
    }
    final turn = turns.removeLast();
    if (turn.state != TurnState.active) {
      throw StateError('Cannot end a non-active turn');
    }
    final resolution = _parseTurnResolution(c.resolution);
    final updated = turn.copyWith(
      state: TurnState.ended,
      resolution: resolution,
      endedAt: c.issuedAt,
    );
    turns.add(updated);
    final nextRack = rack.copyWith(turns: turns);
    final nextRacks = List.of(_match.racks);
    nextRacks[nextRacks.length - 1] = nextRack;
    final event = TurnEnded(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      turnId: c.turnId,
      rackId: c.rackId,
      resolution: c.resolution,
    );
    final next = _match.copyWith(racks: nextRacks);
    return _commit(c, next, [event]);
  }

  CommandResult _applyRecordFoul(RecordFoul c) {
    final event = FoulRecorded(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      turnId: c.turnId,
      rackId: c.rackId,
      participantId: c.participantId,
      reason: c.reason,
    );
    return _commit(c, _match, [event]);
  }

  CommandResult _applyRecordSafety(RecordSafety c) {
    final event = SafetyRecorded(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      turnId: c.turnId,
      rackId: c.rackId,
      participantId: c.participantId,
      reason: c.reason,
    );
    return _commit(c, _match, [event]);
  }

  CommandResult _applyEndRack(EndRack c) {
    final rack = _rack(c.rackId);
    if (rack.state != RackState.inProgress) {
      throw StateError('Rack ${rack.id} is not in progress');
    }
    final updated = rack.copyWith(
      state: RackState.closed,
      endedAt: c.issuedAt,
      winnerParticipantId: c.winnerParticipantId,
    );
    final nextRacks = List.of(_match.racks);
    nextRacks[nextRacks.length - 1] = updated;
    final event = RackEnded(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      rackId: c.rackId,
      rackNumber: rack.rackNumber,
      winnerParticipantId: c.winnerParticipantId,
    );
    final next = _match.copyWith(racks: nextRacks);
    return _commit(c, next, [event]);
  }

  CommandResult _applyConcede(ConcedeMatch c) {
    if (_match.state.isTerminal) {
      throw StateError('Match already terminal');
    }
    final opponent = _match.participants.firstWhere(
      (p) => p != c.concedingParticipantId,
      orElse: () => c.concedingParticipantId,
    );
    final event1 = MatchConceded(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      concedingParticipantId: c.concedingParticipantId,
    );
    final event2 = MatchCompleted(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      winnerParticipantId: opponent,
    );
    final next = _match.copyWith(
      state: MatchState.completed,
      winnerParticipantId: opponent,
      endedAt: c.issuedAt,
    );
    return _commit(c, next, [event1, event2]);
  }

  CommandResult _applyComplete(CompleteMatch c) {
    if (_match.state.isTerminal) {
      throw StateError('Match already terminal');
    }
    final event = MatchCompleted(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      winnerParticipantId: c.winnerParticipantId,
    );
    final next = _match.copyWith(
      state: MatchState.completed,
      winnerParticipantId: c.winnerParticipantId,
      endedAt: c.issuedAt,
    );
    return _commit(c, next, [event]);
  }

  CommandResult _applyAbandon(AbandonMatch c) {
    if (_match.state.isTerminal) {
      throw StateError('Match already terminal');
    }
    final event = MatchAbandoned(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      reason: c.reason,
    );
    final next = _match.copyWith(
      state: MatchState.abandoned,
      endedAt: c.issuedAt,
    );
    return _commit(c, next, [event]);
  }

  CommandResult _applyUndo(UndoCommand c) {
    if (_undoStack.isEmpty) {
      throw StateError('Nothing to undo');
    }
    final last = _undoStack.removeLast();
    final undoEvent = CommandUndone(
      eventId: _nextEventId(),
      matchId: _match.id,
      occurredAt: c.issuedAt,
      undoneCommandEventId: last.appliedEvents.first.eventId,
    );
    final next = _rewind(last.appliedEvents);
    _match = next;
    _redoStack.add(last);
    return CommandResult(match: next, events: [undoEvent]);
  }

  CommandResult _applyRedo(RedoCommand c) {
    if (_redoStack.isEmpty) {
      throw StateError('Nothing to redo');
    }
    final entry = _redoStack.removeLast();
    final redone = entry.undoneCommand;
    // Mark that we are inside a redo so that `_commit` does not clear
    // the redo stack when the redone command is re-applied.
    _inRedo = true;
    try {
      final result = apply(redone);
      // Re-push the entry on the undo stack so the user can undo again.
      _undoStack.add(entry);
      final redoEvent = CommandRedone(
        eventId: _nextEventId(),
        matchId: _match.id,
        occurredAt: c.issuedAt,
        redoneCommandEventId: result.events.first.eventId,
      );
      return CommandResult(
        match: result.match,
        events: [...result.events, redoEvent],
      );
    } finally {
      _inRedo = false;
    }
  }

  // ---- helpers -------------------------------------------------------

  Rack _rack(RackId rackId) {
    for (final r in _match.racks.reversed) {
      if (r.id == rackId) return r;
    }
    throw StateError('Unknown rack $rackId');
  }

  TurnResolution _parseTurnResolution(String s) {
    switch (s) {
      case 'normal':
        return TurnResolution.normal;
      case 'foul':
        return TurnResolution.foul;
      case 'safety':
        return TurnResolution.safety;
      case 'concession':
        return TurnResolution.concession;
      default:
        return TurnResolution.unknown;
    }
  }

  CommandResult _commit(
    MatchCommand command,
    Match nextMatch,
    List<MatchEvent> events,
  ) {
    _match = nextMatch;
    _events.addAll(events);
    _undoStack.add(_PendingUndo(
      undoneCommand: command,
      appliedEvents: events,
    ));
    // Only clear the redo stack when applying a forward command; redo
    // operations preserve the redo stack so that subsequent redo
    // commands can continue to fire.
    if (!_inRedo) {
      _redoStack.clear();
    }
    return CommandResult(match: nextMatch, events: events);
  }

  Match _rewind(List<MatchEvent> applied) {
    // Snapshot the post-state size of `_events` AFTER the events were
    // already appended in `_commit`, so we know the events we need to
    // trim are at the tail. We capture `_events.length - applied.length`
    // BEFORE we trim, since `_applyNegativeEvent` reads from `_events`.
    final keptCount = _events.length - applied.length;
    // Drop the appended events.
    for (var i = 0; i < applied.length; i++) {
      _events.removeLast();
    }
    final next = _applyNegativeEvent(_match, applied.first, keptCount);
    return next;
  }

  Match _applyNegativeEvent(Match snapshot, MatchEvent ev, int keptCount) {
    // Drop the events beyond `keptCount` from `_events` and rebuild the
    // snapshot by replaying forward. `keptCount` is the size of the
    // event log after the undone command's events have been removed.
    final keptEvents = _events.sublist(0, keptCount);
    return _replayToSnapshot(snapshot, keptEvents);
  }

  /// Replay the given event list and produce the resulting snapshot.
  /// Used by undo and by recovery.
  Match _replayToSnapshot(Match initial, List<MatchEvent> events) {
    var current = initial;
    // Strip all appended events from current's aggregate history, then
    // replay fresh. This is intentionally simple — a production
    // engine may swap this for an efficient incremental rebuilder
    // while keeping the same public shape.
    current = Match(
      id: current.id,
      gameType: current.gameType,
      raceLength: current.raceLength,
      participants: current.participants,
      state: MatchState.created,
      racks: const [],
      startedAt: current.startedAt,
    );
    for (final ev in events) {
      current = _applyEventForward(current, ev);
    }
    return current;
  }

  /// Pure reducer over an event. Mirrors the command handlers above
  /// for forward replay.
  Match _applyEventForward(Match snapshot, MatchEvent ev) {
    switch (ev) {
      case MatchStarted _:
        return snapshot.copyWith(state: MatchState.inProgress);
      case RackBegan e:
        final rack = Rack(
          id: e.rackId,
          matchId: snapshot.id,
          rackNumber: e.rackNumber,
          state: RackState.inProgress,
          breakingParticipantId: e.breakingParticipantId,
          turns: const [],
          startedAt: e.occurredAt,
        );
        return snapshot.copyWith(racks: [...snapshot.racks, rack]);
      case TurnBegan e:
        final racks = List.of(snapshot.racks);
        if (racks.isEmpty) return snapshot;
        final last = racks.removeLast();
        final turn = Turn(
          id: e.turnId,
          rackId: e.rackId,
          participantId: e.participantId,
          state: TurnState.active,
          resolution: TurnResolution.unknown,
          shots: const [],
          startedAt: e.occurredAt,
        );
        racks.add(last.copyWith(turns: [...last.turns, turn]));
        return snapshot.copyWith(racks: racks);
      case ShotRecorded e:
        final racks = List.of(snapshot.racks);
        if (racks.isEmpty) return snapshot;
        final last = racks.removeLast();
        if (last.turns.isEmpty) {
          racks.add(last);
          return snapshot.copyWith(racks: racks);
        }
        final turns = List.of(last.turns);
        final turn = turns.removeLast();
        final shot = Shot(
          id: e.shotId,
          turnId: e.turnId,
          shootingParticipantId: e.participantId,
          shotIndex: e.shotIndex,
          recordedAt: e.occurredAt,
        );
        turns.add(turn.copyWith(shots: [...turn.shots, shot]));
        racks.add(last.copyWith(turns: turns));
        return snapshot.copyWith(racks: racks);
      case TurnEnded e:
        final racks = List.of(snapshot.racks);
        if (racks.isEmpty) return snapshot;
        final last = racks.removeLast();
        if (last.turns.isEmpty) {
          racks.add(last);
          return snapshot.copyWith(racks: racks);
        }
        final turns = List.of(last.turns);
        final turn = turns.removeLast();
        final updated = turn.copyWith(
          state: TurnState.ended,
          resolution: _parseTurnResolution(e.resolution),
          endedAt: e.occurredAt,
        );
        turns.add(updated);
        racks.add(last.copyWith(turns: turns));
        return snapshot.copyWith(racks: racks);
      case FoulRecorded _:
      case SafetyRecorded _:
        // Stateless side-channel events; they do not alter the snapshot
        // for the placeholder engine. Real recording sinks observe
        // them as a separate stream.
        return snapshot;
      case RackEnded e:
        final racks = List.of(snapshot.racks);
        if (racks.isEmpty) return snapshot;
        final last = racks.removeLast();
        final updated = last.copyWith(
          state: RackState.closed,
          endedAt: e.occurredAt,
          winnerParticipantId: e.winnerParticipantId,
        );
        racks.add(updated);
        return snapshot.copyWith(racks: racks);
      case MatchConceded _:
        return snapshot;
      case MatchCompleted e:
        return snapshot.copyWith(
          state: MatchState.completed,
          winnerParticipantId: e.winnerParticipantId,
          endedAt: e.occurredAt,
        );
      case MatchAbandoned e:
        return snapshot.copyWith(
          state: MatchState.abandoned,
          endedAt: e.occurredAt,
        );
      case CommandUndone _:
      case CommandRedone _:
        return snapshot;
    }
  }
}
