# P2.8 Product Domain Factory & Builder Contract Implementation

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Implement immutable Product Domain aggregate creation specifications and factory
interfaces only. No executable construction behavior is authorized.

## Implemented Contracts

- Generic `AggregateFactory<TSpecification, TAggregate>` returning Shared/Core
  `Result<TAggregate>`.
- Immutable `MatchCreationSpecification`, `TrainingCreationSpecification`,
  `CoachCreationSpecification`, `UserCreationSpecification` and
  `ConfigurationCreationSpecification` contracts.
- Interface-only `MatchFactory`, `TrainingFactory`, `CoachFactory`, `UserFactory`
  and `ConfigurationFactory` ports with exact specification/aggregate bindings.

Specifications accept already typed root entities and defensive unmodifiable
copies of the same child/reference collections defined by the P2.4 aggregates.
This avoids duplicating entity validation or introducing construction policy.

Optional Match/Training builder interfaces were not added because no structural
need currently justifies a second creation abstraction.

## Dependency Boundary

Factory contracts import only accepted Product Domain aggregates/entities/
primitives and Shared/Core `Result`/immutability helpers. They do not import
repositories, services, Application, Infrastructure, persistence, serialization,
networking, Flutter, provider/state management, UI or dependency injection.

## Scope Guard

No factory implementation, executable builder/construction/validation/business
logic, aggregate mutation, persistence, repository, Application service, DI,
Infrastructure, network, Flutter, Provider/Riverpod or UI was implemented.

## Definition Of Done

- Generic and five named factory interfaces compile.
- Creation specifications are typed and defensively immutable.
- No implementation class or executable construction behavior exists.
- Full regression and protected architecture evidence remain clean.

## Engineering Evidence

- Focused factory contract tests pass 2/2.
- Focused analyzer is clean; formatter reports no changes.
- Full app regression passes 1014/1014.
- Knowledge package regression passes 75/75.
- Protected M3-M22 foundation freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Dependency scan finds no repository, service, event, infrastructure,
  persistence, framework, Application, UI or network dependency in factory
  source.
- Generated architecture health was restored to its protected baseline after the
  architecture run; protected artifacts and Golden Fixtures are unchanged.
- Git scope and `git diff --check` confirm changes remain within the four
  Product Owner-authorized paths.

## Product Owner Decision

Accepted and closed on 2026-07-23. Repository closure by commit and push is
authorized. The next authorized work packet is P3.0 Application Layer
Implementation Baseline under its exact path allowlist.
