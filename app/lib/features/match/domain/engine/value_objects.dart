// EPIC 01 — Match Engine — Phase 1: value objects.
//
// Identifier types for the Match Engine. Pure Dart, no Drift, no
// Flutter dependency. Reusable across rule, recording, persistence,
// and presentation layers.

import 'package:meta/meta.dart';

/// Stable identifier for a [Match] within the lifetime of a session.
@immutable
class MatchId {
  const MatchId(this.value);
  final String value;

  @override
  String toString() => 'MatchId($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MatchId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Stable identifier for a [Rack] within a [Match].
@immutable
class RackId {
  const RackId(this.value);
  final String value;

  @override
  String toString() => 'RackId($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RackId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Stable identifier for a [Turn] within a [Rack].
@immutable
class TurnId {
  const TurnId(this.value);
  final String value;

  @override
  String toString() => 'TurnId($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TurnId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Stable identifier for a [Shot] within a [Turn].
@immutable
class ShotId {
  const ShotId(this.value);
  final String value;

  @override
  String toString() => 'ShotId($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShotId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Stable identifier for a [MatchEvent] in the event-sourced log.
@immutable
class EventId {
  const EventId(this.value);
  final String value;

  @override
  String toString() => 'EventId($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EventId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Identifier for a player participating in a match. Free-form String
/// to allow the active player + ghost / opponent pattern without
/// coupling to the Player module's own identifier type.
@immutable
class ParticipantId {
  const ParticipantId(this.value);
  final String value;

  @override
  String toString() => 'ParticipantId($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ParticipantId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Deterministic clock for the engine. Allows tests to inject a
/// controlled clock and real code to use a system clock. All event
/// timestamps flow through this clock so that recovery and replay
/// produce identical sequences.
abstract class MatchClock {
  DateTime now();
}

class SystemMatchClock implements MatchClock {
  const SystemMatchClock();
  @override
  DateTime now() => DateTime.now().toUtc();
}
