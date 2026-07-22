# M10.1 Application Bootstrap Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M10.1 adds a deterministic application bootstrap projection. It defines what
must be bootstrapped from public Runtime contracts; it does not implement how
the application starts.

## Deliverables

- `app/lib/contracts/application_bootstrap_contracts.dart`
- `app/test/application_bootstrap_foundation_test.dart`

## Authorized Inputs

Only these public contracts are consumed:

- `RuntimeCompositionContract`
- `RuntimeValidationContract`
- `RuntimeDeliveryProjectionContract`

## Contract

- `ApplicationBootstrapContract` v1 and `ApplicationBootstrapEntry` are
  immutable, versioned, deterministic, and canonically ordered.
- Each entry contains only bootstrap identity, runtime node/delivery
  references, and composition/validation/delivery provenance digests.
- `ApplicationBootstrapBuilder` is pure and emits no startup or resource
  behavior.
- Runtime validation binds the canonical `composition` and `delivery` artifact
  references to the corresponding input digests. A failed validation summary is
  rejected.

## Fail-Closed Invariants

- Stale or failed validation, stale delivery, broken provenance, orphan runtime
  node, incomplete projection, duplicate entry, and duplicate position reject.
- Source projections remain unchanged; input entry order cannot change output
  JSON or digest.
- No `main()`, Flutter initialization, DI, GetIt, service locator, Provider,
  Riverpod, Bloc, widget tree, routing, UI, persistence, configuration loading,
  HTTP, Provider invocation, scheduler, lifecycle execution, async
  orchestration, resource creation, plugin initialization, or runtime mutation
  exists.

## Verification

- Focused M10.1 tests: 6/6.
- Focused analyzer: clean.
- Full app regression: 632/632.
- Knowledge package regression: 75/75.
- Protected M3-M9 freeze suites: 25/25.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- M3-M9 frozen contracts and protected artifacts unchanged.

Product Owner accepted and closed M10.1 on 2026-07-22. M10.2 Dependency
Composition Root Foundation is authorized next.
