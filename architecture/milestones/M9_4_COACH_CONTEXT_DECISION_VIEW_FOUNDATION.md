# M9.4 Coach Context & Decision View Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M9.4 adds a deterministic Product decision-view projection over the M9.3
training workspace and public M3 CoachContextContract.

## Deliverables

- `app/lib/contracts/coach_decision_view_contracts.dart`
- `app/test/coach_decision_view_foundation_test.dart`

## Contract

- `CoachDecisionViewEntry` binds player, canonical position, planning node,
  workspace digest, and Coach Context digest.
- `CoachDecisionViewContract` is immutable, versioned, content-addressed, and
  canonically ordered.
- `CoachDecisionViewProjector` is pure and only creates references/projection;
  it does not compute coaching logic or create decisions/recommendations.

## Invariants

- Only `TrainingSessionWorkspaceContract` and `CoachContextContract` are
  consumed.
- Stale/foreign workspace or context, duplicate entries/positions, orphan
  workspace references, and broken provenance fail closed.
- No Recommendation, Runtime, Execution, AI, persistence, UI, or mutation is
  present.
- M3-M8 frozen contracts and protected/generated artifacts remain unchanged.

## Verification

- Focused M9.4 tests: 7/7.
- Focused analyzer: clean.
- Full app regression: 601/601.
- Knowledge package regression: 75/75.
- Protected M3-M8 freeze suites: 20/20.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.

Product Owner accepted and closed M9.4 on 2026-07-22. M9.5 Plan &
Recommendation Inbox Foundation is Authorized to Start and may consume only
CoachDecisionViewContract plus public M3 OrderedRecommendationViewContract.
