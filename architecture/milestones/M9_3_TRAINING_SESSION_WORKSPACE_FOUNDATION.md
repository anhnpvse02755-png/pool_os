# M9.3 Training Session Workspace Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M9.3 adds a deterministic Product workspace projection over the approved public
M9.2 player profile projection and the M3 `CoachPlanningGraphContract`.
Per the Product Owner decision, `TrainingPlanProjection` is an architectural
alias for `CoachPlanningGraphContract`; no new M3 contract is introduced.

## Deliverables

- `app/lib/contracts/training_session_workspace_contracts.dart`
- `app/test/training_session_workspace_foundation_test.dart`

## Contract

- `TrainingWorkspaceEntry` binds player identity, canonical position, planning
  node identity/digest, optional matching feature identity, profile digest, and
  planning graph digest.
- `TrainingSessionWorkspaceContract` is immutable, versioned,
  content-addressed, canonically ordered, and provenance-bound.
- `TrainingSessionWorkspaceProjector` consumes only
  `PlayerProfileProjectionContract` and `CoachPlanningGraphContract`.

## Invariants

- Workspace projection does not consume `TrainingSessionContract`,
  `OrderedRecommendationView`, Recommendation, Execution, Runtime, or AI.
- No session execution, timers, scoring, tracking, persistence, scheduler, or
  UI is present.
- Every workspace entry is bound to an authoritative planning graph node.
- Foreign players, stale profile/plan provenance, duplicate positions/nodes,
  orphan training items, and invalid feature bindings fail closed.
- Player profile and planning graph inputs remain immutable.
- Frozen M3-M8 contracts and protected/generated artifacts remain unchanged.

## Verification

- Focused M9.3 tests: 8/8.
- Focused analyzer: clean.
- Full app regression: 594/594.
- Knowledge package regression: 75/75.
- Protected M3-M8 freeze suites: 20/20.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.

Product Owner accepted and closed M9.3 on 2026-07-22. M9.4 Coach Context &
Decision View Foundation is Authorized to Start.
