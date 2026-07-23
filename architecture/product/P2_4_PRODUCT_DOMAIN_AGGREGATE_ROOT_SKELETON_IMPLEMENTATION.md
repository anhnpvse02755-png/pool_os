# P2.4 Product Domain Aggregate Root Skeleton Implementation

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Implement immutable aggregate-root structural skeletons only, composing accepted
P2.3 entities and P2.2 references without executable aggregate behavior.

## Implemented Aggregates

- `MatchAggregate` rooted at `ProductMatch`.
- `TrainingAggregate` rooted at `TrainingSession`.
- `CoachAggregate` rooted at `CoachSession`.
- `UserAggregate` rooted at `UserProfile`.
- `ConfigurationAggregate` rooted at `SettingsProfile`.

`AggregateRoot<TId, TRoot>` delegates immutable identity, version and creation
timestamp to its root entity and applies runtime-type plus identity equality.

## Structural Composition

Aggregate child/reference inputs are defensively copied into unmodifiable lists.
Training composition stores immutable Knowledge/Evidence references and
Simulation request IDs. Coach composition stores response/execution IDs. Other
aggregates store only typed structural child/reference IDs.

Documentation comments state future invariant ownership but no constructor or
method executes an invariant, transition, command or workflow.

## Scope Guard

No scoring/training/AI rule, transition, workflow, command, event, repository,
persistence, event sourcing, service, Application logic, API, network, provider,
Riverpod, Flutter, UI or navigation was implemented.

## Definition Of Done

- Five authorized aggregate skeletons compile and remain immutable.
- Existing entity skeletons are reused as aggregate roots.
- Identity/version/time accessors are structural only.
- Child/reference collections are defensive unmodifiable copies.
- Aggregate equality and immutability have focused tests.
- No executable invariant or business behavior exists.

## Engineering Evidence

- Focused aggregate skeleton tests pass 6/6.
- Focused analyzer is clean.
- Full app regression passes 1003/1003.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Aggregate source imports only accepted entity, primitive and Shared/Core layers.
- Generated architecture health was restored to its protected baseline.
- Exactly the authorized P2.4 paths change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
