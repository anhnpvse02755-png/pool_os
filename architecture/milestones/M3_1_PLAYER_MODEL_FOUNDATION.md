# M3.1 Player Model Foundation

**Status:** Engineering Complete; Product Review Pending

**Date:** 2026-07-21

**Implementation commit:** `261988a`

## Executable Scope

M3.1 establishes the first versioned Intelligence contracts and deterministic
projection for a player model:

1. `PlayerProfileContract` carries player identity, handedness, locale,
   preferences, and history references without Flutter or persistence types.
2. `PlayerModelState` contains projected Technique mastery and Mistake state.
3. `PlayerProgressSnapshot` binds the projected state to one Knowledge version
   and content digest, records its source Decision references, and has a
   deterministic SHA-256 digest.
4. `CoachInputContract` exposes only the profile and progress snapshot. It does
   not expose raw Evidence records.
5. `PlayerModelProjector` consumes `LearningSnapshot` outputs from the Learning
   Runtime and does not read the Evidence log directly.

The executable flow is:

```text
Evidence
  -> Learning Runtime replay
  -> LearningSnapshot
  -> PlayerModelProjector
  -> PlayerProgressSnapshot
  -> CoachInputContract
```

## Determinism And Failure Semantics

- Reordering equivalent Learning snapshots produces the same canonical JSON
  and snapshot digest.
- A new completed measurement changes the next snapshot without mutating an
  earlier snapshot.
- Empty input, duplicate Knowledge snapshots, mixed Knowledge package
  identities, and mismatched Coach/profile player IDs fail loudly.
- Mastery and Mistake state remain outputs of the accepted M2 Learning Runtime;
  M3.1 does not reinterpret raw Evidence or change M2 decisions.

## Architecture Enforcement

`app/lib/features/player_model/` is classified as Intelligence by Architecture
Fitness. The projector is an application service rather than a domain model
because it orchestrates Learning Runtime projections. Fitness remains at 133
known violations with zero new violations.

## Verification

- Player Model focused tests: 7/7.
- App regression: 229/229.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3.1 focused analyzer: no issues.
- Full analyzer baseline unchanged: app 62 info; Knowledge package 4 info and
  1 warning, with no M3.1 findings.
- Constitution, Reference Behavior, Golden Fixtures, production Knowledge,
  publication artifacts, and M2 digests are unchanged.

## Explicit Non-Claims

M3.1 does not implement:

- Player Model persistence or snapshot storage;
- probabilistic mastery or uncertainty aggregation;
- attempt-level Evidence processing;
- Learning Planner or new Recommendation behavior;
- LLM, Vision, or Simulation input;
- Experience integration;
- production activation or Knowledge publication changes.

Product Owner review must decide `Accepted`, `Needs Changes`, or `Rejected`.
Engineering completion does not self-ratify the Player Model contract.
