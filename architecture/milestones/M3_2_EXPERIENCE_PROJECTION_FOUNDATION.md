# M3.2 Experience Projection Foundation

**Status:** Engineering Complete; Product Review Pending

**Date:** 2026-07-21

**Implementation commit:** `2722e0d`

## Executable Scope

M3.2 adds deterministic, rebuildable projection contracts over accepted
Learning Runtime and Player Model outputs:

1. `ExperienceEventContract` represents a derived timeline record tied to one
   Learning Decision. It is not a canonical Evidence event or source of truth.
2. `ExperienceTimelineProjection` canonicalizes records by UTC occurrence time
   and stable event ID and computes a deterministic digest.
3. `SessionSummaryProjection` groups timeline records by explicit `sessionId`
   and reports counts and references without scoring or inference.
4. `ExperienceSnapshot` binds timeline and session summaries to one player,
   Player Progress digest, Knowledge version, and Knowledge digest.
5. `ExperienceProjector` consumes `LearningSnapshot` plus
   `PlayerProgressSnapshot`. It does not access an Evidence log or persistence.

The executable flow is:

```text
Evidence
  -> Learning Runtime replay
  -> LearningSnapshot
  -> PlayerProgressSnapshot
  -> ExperienceProjector
  -> ExperienceSnapshot
```

Coach-facing consumers receive `ExperienceSnapshot`; they do not receive raw
Evidence records or an Event Log.

## Ownership Clarification

Experience projection is an Intelligence read model. It is implemented under
the Player Model Intelligence application module because it derives state from
Learning Runtime decisions. This does not move inference into the Experience
Domain: Flutter and other delivery clients remain projection renderers only.

## Determinism And Failure Semantics

- Reordering equivalent projection inputs produces the same timeline,
  canonical JSON, and Experience digest.
- A new replay produces a new snapshot without mutating the previous snapshot.
- Timeline records use stable Decision references and UTC timestamps.
- Empty input, duplicate event IDs, mixed Knowledge identities, incomplete
  session summaries, and cross-player timeline data fail loudly.
- Session summaries must cover every timeline record for their session exactly.

## Verification

- Experience Projection focused tests: 7/7.
- App regression: 236/236.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3.2 focused analyzer: no issues.
- Constitution, Reference Behavior, Golden Fixtures, production Knowledge,
  publication artifacts, and all frozen M2 digests are unchanged.

## Explicit Non-Claims

M3.2 does not implement:

- persistence or a new Event Store;
- raw Evidence or attempt-level ingestion;
- recommendation, ranking, scoring, planning, or Coach policy;
- LLM, Vision, or Simulation integration;
- Experience UI integration;
- production activation or Knowledge publication changes.

Product Owner review must decide `Accepted`, `Needs Changes`, or `Rejected`.
Engineering completion does not self-ratify the Experience contracts.
