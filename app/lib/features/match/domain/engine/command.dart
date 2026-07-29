// EPIC 01 — Match Engine — Phase 3: command architecture.
//
// All state mutations flow through Commands. Each Command produces
// zero or more MatchEvents. The engine is the only component that
// accepts Commands and produces Events; rule interfaces are read-only
// advisors.

import 'package:meta/meta.dart';

import 'value_objects.dart';

/// Sealed command hierarchy. The engine dispatches each subtype to a
/// dedicated handler. Subtypes are exhaustive; the engine treats any
/// unrecognised command as a programming error.
@immutable
sealed class MatchCommand {
  const MatchCommand({required this.matchId, required this.issuedAt});

  final MatchId matchId;
  final DateTime issuedAt;
}

class StartMatch extends MatchCommand {
  const StartMatch({
    required super.matchId,
    required super.issuedAt,
  });
}

class BeginRack extends MatchCommand {
  const BeginRack({
    required super.matchId,
    required super.issuedAt,
    required this.rackId,
    required this.breakingParticipantId,
  });

  final RackId rackId;
  final String breakingParticipantId;
}

class BeginTurn extends MatchCommand {
  const BeginTurn({
    required super.matchId,
    required super.issuedAt,
    required this.turnId,
    required this.rackId,
    required this.participantId,
  });

  final TurnId turnId;
  final RackId rackId;
  final String participantId;
}

class RecordShot extends MatchCommand {
  const RecordShot({
    required super.matchId,
    required super.issuedAt,
    required this.shotId,
    required this.turnId,
    required this.rackId,
    required this.participantId,
  });

  final ShotId shotId;
  final TurnId turnId;
  final RackId rackId;
  final String participantId;
}

class EndTurn extends MatchCommand {
  const EndTurn({
    required super.matchId,
    required super.issuedAt,
    required this.turnId,
    required this.rackId,
    required this.resolution,
  });

  final TurnId turnId;
  final RackId rackId;
  final String resolution;
}

class RecordFoul extends MatchCommand {
  const RecordFoul({
    required super.matchId,
    required super.issuedAt,
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

class RecordSafety extends MatchCommand {
  const RecordSafety({
    required super.matchId,
    required super.issuedAt,
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

class EndRack extends MatchCommand {
  const EndRack({
    required super.matchId,
    required super.issuedAt,
    required this.rackId,
    required this.winnerParticipantId,
  });

  final RackId rackId;
  final String winnerParticipantId;
}

class ConcedeMatch extends MatchCommand {
  const ConcedeMatch({
    required super.matchId,
    required super.issuedAt,
    required this.concedingParticipantId,
  });

  final String concedingParticipantId;
}

class CompleteMatch extends MatchCommand {
  const CompleteMatch({
    required super.matchId,
    required super.issuedAt,
    required this.winnerParticipantId,
  });

  final String winnerParticipantId;
}

class AbandonMatch extends MatchCommand {
  const AbandonMatch({
    required super.matchId,
    required super.issuedAt,
    required this.reason,
  });

  final String reason;
}

class UndoCommand extends MatchCommand {
  const UndoCommand({
    required super.matchId,
    required super.issuedAt,
  });
}

class RedoCommand extends MatchCommand {
  const RedoCommand({
    required super.matchId,
    required super.issuedAt,
  });
}
