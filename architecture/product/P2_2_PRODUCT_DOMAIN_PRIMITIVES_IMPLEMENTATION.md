# P2.2 Product Domain Primitive Types Implementation

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Implement reusable immutable validated Product domain primitive value types only,
reusing the accepted P2.1 Shared/Core foundation.

## Implemented Primitives

- Entity identity base with `GenericEntityId`, `MatchId`, `PlayerId` and
  `SessionId`, composed from `RuntimeIdentifier`.
- `NonEmptyString`, `PositiveInteger`, `VersionNumber`, `Percentage` and
  non-negative `ScoreValue`.
- UTC-only `UtcTimestamp` and `NonNegativeDuration`.
- finite two-dimensional `CoordinateValue`.
- typed generic `EnumValue<T extends Enum>`.

All primitives extend Shared/Core `ValueObject`, expose final state, validate at
construction and use deterministic value equality/hash semantics. Validation is
limited to primitive shape/range; no game, capability or workflow rule exists.

## Ownership And Boundaries

Product Domain Shared owns these reusable primitive types. Entity IDs label
future aggregate identities but do not create entities. Score and coordinate
values are scalar containers and do not implement Scoring or Simulation behavior.

## Scope Guard

No Match, Player, Training, Knowledge, Coach, Analytics or Simulation entity/
capability, aggregate, repository, service, workflow, state machine, provider,
persistence, database, API, network, authentication, UI, navigation, Riverpod or
Flutter widget was implemented.

## Definition Of Done

- Primitive value types validate construction and remain immutable.
- Equality, hash and comparison semantics are deterministic.
- Shared/Core `ValueObject` and `RuntimeIdentifier` are reused.
- Unit tests cover valid, invalid, equality, canonicalization and boundary cases.
- No Product capability or business behavior is implemented.

## Engineering Evidence

- Focused primitive tests pass 10/10.
- Focused analyzer is clean.
- Full app regression passes 986/986.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Domain Shared imports only the accepted Shared/Core foundation.
- Generated architecture health was restored to its protected baseline.
- Exactly the authorized P2.2 paths change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
