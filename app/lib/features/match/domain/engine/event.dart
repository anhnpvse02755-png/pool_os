// EPIC 01 — Match Engine — Phase 3: event stream.
//
// Every command that the engine accepts produces zero or more events.
// Events are an append-only log. The Match snapshot is derived by
// folding the event log; persistence stores both the snapshot (for
// fast load) and the event log (for replay / undo / redo).

import 'package:meta/meta.dart';

import 'value_objects.dart';

@immutable
sealed class MatchEvent {
  const MatchEvent({
    required this.eventId,
    required this.matchId,
    required this.occurredAt,
  });

  final EventId eventId;
  final MatchId matchId;
  final DateTime occurredAt;
}

class MatchStarted extends MatchEvent {
  const MatchStarted({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
  });
}

class RackBegan extends MatchEvent {
  const RackBegan({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.rackId,
    required this.rackNumber,
    required this.breakingParticipantId,
  });

  final RackId rackId;
  final int rackNumber;
  final String breakingParticipantId;
}

class TurnBegan extends MatchEvent {
  const TurnBegan({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.turnId,
    required this.rackId,
    required this.participantId,
  });

  final TurnId turnId;
  final RackId rackId;
  final String participantId;
}

class ShotRecorded extends MatchEvent {
  const ShotRecorded({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.shotId,
    required this.turnId,
    required this.rackId,
    required this.participantId,
    required this.shotIndex,
  });

  final ShotId shotId;
  final TurnId turnId;
  final RackId rackId;
  final String participantId;
  final int shotIndex;
}

class TurnEnded extends MatchEvent {
  const TurnEnded({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.turnId,
    required this.rackId,
    required this.resolution,
  });

  final TurnId turnId;
  final RackId rackId;
  final String resolution;
}

class FoulRecorded extends MatchEvent {
  const FoulRecorded({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.turnId,
    required this.rackId,
    required this.participantId,
    required this.reason,
  });

  final TurnId turnId;
  final RackId rackId;
  final String participantId;
  final String reason;
}

class SafetyRecorded extends MatchEvent {
  const SafetyRecorded({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.turnId,
    required this.rackId,
    required this.participantId,
    required this.reason,
  });

  final TurnId turnId;
  final RackId rackId;
  final String participantId;
  final String reason;
}

class RackEnded extends MatchEvent {
  const RackEnded({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.rackId,
    required this.rackNumber,
    required this.winnerParticipantId,
  });

  final RackId rackId;
  final int rackNumber;
  final String winnerParticipantId;
}

class MatchConceded extends MatchEvent {
  const MatchConceded({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.concedingParticipantId,
  });

  final String concedingParticipantId;
}

class MatchCompleted extends MatchEvent {
  const MatchCompleted({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.winnerParticipantId,
  });

  final String winnerParticipantId;
}

class MatchAbandoned extends MatchEvent {
  const MatchAbandoned({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.reason,
  });

  final String reason;
}

class CommandUndone extends MatchEvent {
  const CommandUndone({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.undoneCommandEventId,
  });

  final EventId undoneCommandEventId;
}

class CommandRedone extends MatchEvent {
  const CommandRedone({
    required super.eventId,
    required super.matchId,
    required super.occurredAt,
    required this.redoneCommandEventId,
  });

  final EventId redoneCommandEventId;
}
