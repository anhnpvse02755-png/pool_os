# M9.7 AI Coach Interaction Surface Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M9.7 adds a deterministic Product interaction-surface projection over M9.6
execution outcomes and public M5 AIConversationMemoryContract.

## Deliverables

- `app/lib/contracts/ai_coach_interaction_surface_contracts.dart`
- `app/test/ai_coach_interaction_surface_foundation_test.dart`

## Contract

- `AICoachInteractionEntry` binds player, execution-outcome and conversation-
  memory digests, capability, canonical position, and processing reference.
- `AICoachInteractionSurfaceContract` is immutable, versioned,
  content-addressed, and canonically ordered.
- `AICoachInteractionSurfaceProjector` is pure and only creates references.

## Authoritative Join And Limitation

- Canonical position is the Product Owner-approved join key between the two
  projections. Coverage must be equal, contiguous, duplicate-free, and gapless.
- `AIConversationMemoryContract` v1 is player-neutral and contains no semantic
  binding to execution or recommendation ownership. Foreign-player and semantic
  ownership validation are structurally unavailable in M9.7 and are not
  inferred. Player identity is sourced only from M9.6.
- M5 remains frozen and unchanged; no additional contract is consumed.

## Invariants

- Stale digests, malformed capability/provenance, count/position mismatch,
  duplicate positions, and broken bindings fail closed.
- No prompt generation, AI invocation, memory retrieval, summarization,
  ranking, reasoning, mutation, persistence, analytics, or UI is present.
- M3-M8 frozen contracts and protected/generated artifacts remain unchanged.

## Verification

- Focused M9.7 tests: 5/5.
- Focused analyzer: clean.
- Full app regression: 616/616.
- Knowledge package regression: 75/75.
- Protected M3-M8 freeze suites: 20/20.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.

Product Owner accepted and closed M9.7 on 2026-07-22. M9.8 Product Analytics
& Feedback Loop Foundation is Authorized to Start with the four approved
public Product projection inputs and reference-only aggregate identity.
