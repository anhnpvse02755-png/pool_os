# M3.8 Coach Execution Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Ownership And Contracts

- Intelligence owns Coach Execution lifecycle behavior.
- `CoachExecutionTransitionContract` v1 is an immutable append-only transition
  bound to one immutable `CoachRecommendationContract` ID and digest.
- `CoachExecutionRecordContract` v1 is an immutable replayable projection with
  Recommendation provenance, execution policy version, ordered transitions,
  and deterministic SHA-256 digest.
- `CoachExecutionProjector` is a pure application service over public
  Recommendation and Execution contracts. It has no Evidence, Decision,
  Decision History, Planner, persistence, AI, or LLM dependency.

## Executable Scope

- An Execution may initially be marked `accepted`, `rejected`, `deferred`, or
  `expired`.
- Only an accepted Execution may append one `completed` transition.
- Terminal outcomes cannot be appended, replaced, or removed.
- Replay validates Recommendation binding, sequence continuity, transition
  shape, chronological order, and final state.
- Equivalent Recommendation and transition inputs produce identical Record
  JSON, ID, and digest.
- Execution never mutates the Recommendation or any prior transition.

## Verification

- Focused M3.8 tests: 7/7.
- Combined Coach foundation tests: 47/47.
- Focused analyzer across Execution contracts, projector, and tests: no issues.
- App regression: 284/284.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Architecture health projection refreshed; protected Reference Behavior,
  Golden Fixtures, production Knowledge/publication artifacts, and M2 proof
  records are unchanged.

## Product Review

The Product Owner accepted and closed M3.8 on 2026-07-21 after reviewing
Recommendation immutability, append-only transitions, deterministic replay,
the initial and completed state machine, ownership separation, regression
evidence, and architecture fitness.

## Explicit Non-Claims

M3.8 does not mutate Recommendations, create Decisions, append or change
Decision History, read Evidence, invoke Planner, persist state, rank actions,
use AI/LLM/ML, generate prose, chat, Vision, Simulation, or UI output.
