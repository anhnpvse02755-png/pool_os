# M10.2 Dependency Composition Root Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M10.2 adds an immutable projection describing how accepted bootstrap entries
bind to runtime service composition entries. It is not a dependency injection
implementation and creates no objects or resources.

## Deliverables

- `app/lib/contracts/dependency_composition_root_contracts.dart`
- `app/test/dependency_composition_root_foundation_test.dart`

## Authorized Inputs

- `ApplicationBootstrapContract`
- `RuntimeServiceCompositionContract`

## Contract

- `DependencyCompositionRootContract` v1 and
  `DependencyCompositionEntry` are immutable, versioned, deterministic, and
  canonically ordered.
- `DependencyCompositionRootBuilder` joins bootstrap and service references by
  the public `serviceId`; it does not parse encoded IDs or inspect internals.
- The projection binds composition-root identity, bootstrap digest, runtime
  service-composition digest, service ID, runtime node ID, bootstrap entry ID,
  canonical position, and deterministic digest.

## Fail-Closed Invariants

- Bootstrap and service composition must bind the same runtime composition
  digest and have complete equal coverage.
- Stale inputs, orphan bootstrap/service references, broken provenance,
  duplicate services, duplicate positions, duplicate entries, and incomplete
  projections reject.
- No GetIt, DI container, service locator, Provider/Riverpod/Bloc registration,
  constructor injection, object/singleton creation, lazy loading, resource
  lifetime, startup, Flutter initialization, activation, persistence, HTTP,
  Provider integration, scheduler, configuration loading, or runtime mutation
  exists.

## Verification

- Focused M10.2 tests: 6/6.
- Focused analyzer: clean.
- Full app regression: 638/638.
- Knowledge package regression: 75/75.
- Protected M3-M9 freeze suites: 25/25.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen M3-M9 contracts and protected artifacts unchanged.

Product Owner accepted and closed M10.2 on 2026-07-22. M10.3 Runtime Service
Activation Projection Foundation is authorized next.
