# M9.2 Player Profile & Progress Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M9.2 adds a deterministic Product projection over the public M3 player progress
snapshot and the M9.1 product shell. It does not calculate, copy, or mutate
Player or Learning business state.

## Deliverables

- `app/lib/contracts/player_profile_projection_contracts.dart`
- `app/test/player_profile_projection_foundation_test.dart`

## Contract

- `PlayerProfileEntry` binds a player, product feature, canonical position,
  progress digest, and shell digest.
- `PlayerProfileProjectionContract` is immutable, versioned, content-addressed,
  canonically ordered, and provenance-bound.
- `PlayerProfileProjector` is a pure function consuming only the public M3
  `PlayerProgressSnapshot` progress contract and M9.1 `ProductShellContract`.

## Invariants

- The projection contains references only and does not copy mastery, mistake,
  preference, history, or Knowledge business state.
- Every shell feature has exactly one canonical profile entry.
- Player, progress, shell, feature, and position bindings are explicit.
- Foreign players, stale provenance, duplicate features/positions, orphan
  features, and incomplete projections fail closed.
- No progress update, mastery/statistics calculation, achievement generation,
  persistence, runtime call, AI call, or UI implementation is present.
- Frozen M3-M8 contracts and protected/generated artifacts remain unchanged.

## Verification

- Focused M9.2 tests: 8/8.
- Focused analyzer: clean.
- Full app regression: 586/586.
- Knowledge package regression: 75/75.
- Protected M3-M8 freeze suites: 20/20.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.

Product Owner accepted and closed M9.2 on 2026-07-22. M9.3 Training Session
Workspace Foundation is Authorized to Start.
