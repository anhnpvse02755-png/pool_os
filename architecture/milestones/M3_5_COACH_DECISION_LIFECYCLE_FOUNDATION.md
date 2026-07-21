# M3.5 Coach Decision Lifecycle Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

**Implementation:** Uncommitted worktree; commit pending explicit authorization

## Ownership And Contracts

- Intelligence owns Coach Decision lifecycle behavior and history projection.
- `CoachDecisionTransitionContract` v1 is the public immutable transition
  record for issued, completed, and superseded states.
- `CoachDecisionLifecycleProjection` v1 and
  `CoachDecisionHistoryProjection` v1 are deterministic, rebuildable read
  models over Coach Decisions and transition records.
- The lifecycle projector imports only public Coach Decision contracts. It does
  not access Evidence, Knowledge persistence, Simulation, Experience internals,
  Flutter state, or another domain's implementation.

## Executable Scope

- Issuing creates the first active lifecycle transition at the immutable Coach
  Decision effective time.
- Completing or superseding creates a new transition record and never mutates
  the original Coach Decision.
- Replay canonicalizes transition input by sequence and rejects gaps, foreign
  bindings, invalid state flow, and non-chronological transitions.
- Supersede requires a distinct, newer Coach Decision and preserves the
  replacement Decision ID and digest.
- History projection validates replacement links, orders Decisions
  chronologically with Decision ID as a stable tie-break, and identifies active
  Decisions deterministically.
- Lifecycle and history identities bind their complete structured payloads with
  deterministic SHA-256 digests.

## Terminal Lifecycle Validation

The public `CoachDecisionLifecycleProjection.create` factory now rejects a
terminal `completed` or `superseded` projection that has no initial `issued`
transition. This closes a contract-level construction path that the projector's
replay validation already rejected. Regression coverage proves both terminal
states fail loudly when presented as sequence 1 without issuance.

## Verification

- Focused Coach Decision Lifecycle tests: 13/13.
- Focused analyzer across lifecycle contract, projector, and tests: no issues.
- App regression: 262/262.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Architecture health projection refreshed to cover 291 Dart files and 1195
  directives.
- Constitution, Reference Behavior, Golden Fixtures, production Knowledge,
  publication/current, M2.4 and M2 Final proof records, and frozen M2 identities
  are unchanged.
- Three pre-existing generated plugin changes remain present and untouched.

## Explicit Non-Claims

M3.5 does not implement Planner target selection, recommendation scoring, AI,
LLM prompts or prose, persistence, event-store integration, UI rendering,
Vision, Simulation, production activation, or mutation of an existing Coach
Decision.

## Product Review

The Product Owner accepted and closed M3.5 on 2026-07-21 after reviewing the
immutable Decision boundary, append-only transition history, terminal-state
validation, deterministic replay, regression evidence, architecture fitness,
and protected-artifact checks. No blocker or follow-up correction remains.
