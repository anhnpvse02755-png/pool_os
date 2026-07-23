# P2.3 Product Domain Entity Skeleton Implementation

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Implement immutable constructor-only Product entity skeletons using accepted
P2.2 domain primitives, without implementing capability behavior.

## Implemented Skeletons

- `ProductMatch`
- `PlayerProfile`
- `TrainingSession`
- `CoachSession`
- `PerformanceSnapshot`
- `UserProfile`
- `SettingsProfile`
- `SimulationRequest`
- `EvidenceReference`
- `KnowledgeReference`

`Entity<TId>` supplies typed identity, version and creation timestamp. Entity
equality uses runtime type plus identity only. External references use complete
value equality across identity, version, digest and owner/provenance.

## Immutability And Validation

All fields are final and use approved P2.2 primitives. Collection inputs are
defensively copied into unmodifiable lists. Primitive constructors validate
shape/range before an entity can be constructed. Lifecycle state is only an
immutable non-empty primitive; no valid-state or transition logic is present.

## Ownership Boundary

Skeletons hold typed foreign identities/digests rather than embedding Platform
aggregates. Evidence and Knowledge references do not mutate or reinterpret their
Platform sources. Score, Training, Coach, Analytics and Simulation fields are
data references only.

## Scope Guard

No business rule, transition, aggregate method, score/training/AI/analytics/
simulation logic, repository, persistence, event source, command, service,
Application layer, API, network, provider, Riverpod, Flutter, UI or navigation
was implemented.

## Definition Of Done

- Ten authorized skeletons compile and remain immutable.
- P2.2 primitives are reused for identity, value, version and time.
- Entity identity and reference value equality are tested.
- Collection inputs are defensively copied and unmodifiable.
- Primitive validation failures prevent invalid construction.
- No capability behavior or infrastructure is present.

## Engineering Evidence

- Focused entity skeleton tests pass 11/11.
- Focused analyzer is clean.
- Full app regression passes 997/997.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Entity source imports only Product Domain Shared and Shared/Core foundations.
- Generated architecture health was restored to its protected baseline.
- Exactly the authorized P2.3 paths change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
