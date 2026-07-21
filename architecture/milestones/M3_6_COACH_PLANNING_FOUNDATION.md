# M3.6 Coach Planning Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

**Implementation commit:** `b8786ce`

## Ownership And Contracts

- Intelligence owns Coach planning behavior.
- `CoachPlanContract` v1 is an immutable, structured projection over an
  accepted `CoachContextContract` and `CoachDecisionHistoryProjection`.
- Plan provenance binds Context contract/digest, Decision History projection
  version/digest, Knowledge version/digest, and deterministic Planner policy.
- `CoachPlanner` imports only public Coach Context, Decision Lifecycle, and
  Coach Plan contracts. It has no Evidence, Knowledge runtime, persistence,
  Flutter, Recommendation, AI, Vision, or Simulation dependency.

## Executable Scope

- Exactly one active Decision produces `continueActiveDecision`, bound to that
  existing Decision ID and digest.
- A fully terminal history produces `requestNextDecision` with no Decision or
  Knowledge target. Planner requests the next Decision boundary evaluation; it
  does not create that Decision.
- Multiple active Decisions fail loudly. Planner does not rank or choose among
  them.
- The public Coach Plan factory independently rejects a request that would
  bypass an active Decision.
- Equivalent Context and Decision History inputs produce identical Coach Plan
  JSON, ID, and SHA-256 digest.
- Planning leaves Context, Decision History, Decisions, and Transitions
  unchanged.

## Dependency And Unlock Boundary

Planner does not import the executable Knowledge graph, duplicate dependency
rules, or infer unlock eligibility. It respects dependency/unlock ownership by
never inventing a next Knowledge target. Once lifecycle state is terminal, the
only generated step is a structured request for the Decision boundary to
evaluate the next valid action from its accepted inputs.

## Verification

- Focused Coach Planning tests: 7/7.
- Focused analyzer across Coach Plan contract, Planner, and tests: no issues.
- App regression: 269/269.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Architecture health projection refreshed to cover 293 Dart files and 1202
  directives.
- Constitution, Reference Behavior, Golden Fixtures, production Knowledge,
  publication/current, M2.4 and M2 Final proof records, and frozen M2 identities
  are unchanged.

## Explicit Non-Claims

M3.6 does not implement Recommendation, candidate ranking, Knowledge target
selection, Decision creation, Decision lifecycle mutation, persistence, AI,
LLM prompts or prose, chat, Vision, Simulation, UI integration, or production
activation.

## Product Review

The Product Owner accepted and closed M3.6 on 2026-07-21 after reviewing Planner
purity, Decision and Transition immutability, Knowledge selection boundaries,
Learning Runtime ownership, deterministic plan identity, lifecycle behavior,
regression evidence, and architecture fitness. No blocker or follow-up
correction remains.
