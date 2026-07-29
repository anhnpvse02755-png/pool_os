// EPIC 01 — Match Engine — Phase 2: aggregate roots.
//
// Pure-Dart aggregates. The Match aggregate is the root; Rack and
// Turn are value-typed sub-structures that live inside the Match
// snapshot. All mutation goes through the command pipeline.

import 'package:meta/meta.dart';

import '../rule/game_type.dart';
import 'states.dart';
import 'value_objects.dart';

/// Snapshot of a single shot, in rule-agnostic form. Rule-specific
/// shot metadata (called pocket, ball contact) is deferred to EPIC
/// Rule System.
@immutable
class Shot {
  const Shot({
    required this.id,
    required this.turnId,
    required this.shootingParticipantId,
    required this.shotIndex,
    required this.recordedAt,
  });

  final ShotId id;
  final TurnId turnId;
  final String shootingParticipantId;
  final int shotIndex;
  final DateTime recordedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Shot &&
          other.id == id &&
          other.turnId == turnId &&
          other.shootingParticipantId == shootingParticipantId &&
          other.shotIndex == shotIndex &&
          other.recordedAt == recordedAt;

  @override
  int get hashCode =>
      Object.hash(id, turnId, shootingParticipantId, shotIndex, recordedAt);
}

/// Snapshot of a turn, with its shot log and resolution.
@immutable
class Turn {
  const Turn({
    required this.id,
    required this.rackId,
    required this.participantId,
    required this.state,
    required this.resolution,
    required this.shots,
    required this.startedAt,
    this.endedAt,
  });

  final TurnId id;
  final RackId rackId;
  final String participantId;
  final TurnState state;
  final TurnResolution resolution;
  final List<Shot> shots;
  final DateTime startedAt;
  final DateTime? endedAt;

  bool get hasShots => shots.isNotEmpty;

  Turn copyWith({
    TurnState? state,
    TurnResolution? resolution,
    List<Shot>? shots,
    DateTime? endedAt,
  }) {
    return Turn(
      id: id,
      rackId: rackId,
      participantId: participantId,
      state: state ?? this.state,
      resolution: resolution ?? this.resolution,
      shots: shots ?? this.shots,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}

/// Snapshot of a rack, with the turn log and winner (if closed).
@immutable
class Rack {
  const Rack({
    required this.id,
    required this.matchId,
    required this.rackNumber,
    required this.state,
    required this.breakingParticipantId,
    required this.turns,
    required this.startedAt,
    this.endedAt,
    this.winnerParticipantId,
  });

  final RackId id;
  final MatchId matchId;
  final int rackNumber;
  final RackState state;
  final String breakingParticipantId;
  final List<Turn> turns;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? winnerParticipantId;

  Turn? get activeTurn => turns.isEmpty
      ? null
      : turns.last.state == TurnState.active
          ? turns.last
          : null;

  String? get lastShootingParticipantId {
    for (final turn in turns.reversed) {
      if (turn.shots.isNotEmpty) return turn.participantId;
    }
    return null;
  }

  Rack copyWith({
    RackState? state,
    List<Turn>? turns,
    DateTime? endedAt,
    String? winnerParticipantId,
  }) {
    return Rack(
      id: id,
      matchId: matchId,
      rackNumber: rackNumber,
      state: state ?? this.state,
      breakingParticipantId: breakingParticipantId,
      turns: turns ?? this.turns,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      winnerParticipantId: winnerParticipantId ?? this.winnerParticipantId,
    );
  }
}

/// Match aggregate root. Immutable; mutations go through the
/// command pipeline which produces a new Match snapshot.
@immutable
class Match {
  const Match({
    required this.id,
    required this.gameType,
    required this.raceLength,
    required this.participants,
    required this.state,
    required this.racks,
    required this.startedAt,
    this.endedAt,
    this.winnerParticipantId,
  });

  final MatchId id;
  final GameType gameType;
  final int raceLength;
  final List<String> participants;
  final MatchState state;
  final List<Rack> racks;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? winnerParticipantId;

  Rack? get activeRack => racks.isEmpty
      ? null
      : racks.last.state == RackState.inProgress
          ? racks.last
          : null;

  int rackWinsFor(String participantId) {
    var wins = 0;
    for (final r in racks) {
      if (r.state == RackState.closed &&
          r.winnerParticipantId == participantId) {
        wins++;
      }
    }
    return wins;
  }

  Map<String, int> get rackWinsByParticipant {
    final out = <String, int>{};
    for (final p in participants) {
      out[p] = rackWinsFor(p);
    }
    return out;
  }

  Match copyWith({
    MatchState? state,
    List<Rack>? racks,
    DateTime? endedAt,
    String? winnerParticipantId,
  }) {
    return Match(
      id: id,
      gameType: gameType,
      raceLength: raceLength,
      participants: participants,
      state: state ?? this.state,
      racks: racks ?? this.racks,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      winnerParticipantId: winnerParticipantId ?? this.winnerParticipantId,
    );
  }
}
