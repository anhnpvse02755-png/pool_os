// EPIC 01 — Match Engine — Phase 2: state machine.
//
// Lifecycle states for Match, Rack, and Turn. Transitions are
// constrained by the MatchEngine; direct mutation of these enums on
// persisted entities is forbidden outside the engine's command
// pipeline.

/// Lifecycle of a [Match].
///
///   created → inProgress → (completed | abandoned)
///
/// `created` is the brief window between match creation and the first
/// rack opening. Real providers may persist directly into
/// `inProgress` if the match opens with the first rack.
enum MatchState {
  created,
  inProgress,
  completed,
  abandoned;

  bool get isTerminal =>
      this == MatchState.completed || this == MatchState.abandoned;
}

/// Lifecycle of a [Rack] within a Match.
///
///   pending → inProgress → (closed | abandoned)
enum RackState {
  pending,
  inProgress,
  closed,
  abandoned;

  bool get isTerminal =>
      this == RackState.closed || this == RackState.abandoned;
}

/// Lifecycle of a single [Turn] within a Rack.
///
///   pending → active → ended
enum TurnState {
  pending,
  active,
  ended;

  bool get isTerminal => this == TurnState.ended;
}

/// Status flag indicating why a turn ended (recorded by the engine
/// when a turn closes). EPIC 01 keeps this minimal; richer
/// classifications (push-out, three-foul, deliberate safety vs.
/// incidental miss) come with EPIC Rule System.
enum TurnResolution {
  unknown,
  normal,
  foul,
  safety,
  concession,
}
