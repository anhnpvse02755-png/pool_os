# M10.3 Runtime Service Activation Projection Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M10.3 adds an immutable projection describing activation ordering for
dependency-composed services. It preserves the accepted M8 activation order and
does not activate or construct any service.

## Deliverables

- `app/lib/contracts/runtime_service_activation_projection_contracts.dart`
- `app/test/runtime_service_activation_projection_foundation_test.dart`

## Authorized Inputs

- `DependencyCompositionRootContract`
- `RuntimeActivationCoordinationContract`

## Contract

- `RuntimeServiceActivationProjectionContract` v1 and
  `RuntimeServiceActivationEntry` are immutable, versioned, deterministic, and
  canonically ordered by the M8 activation position.
- `RuntimeServiceActivationProjector` joins public service IDs and binds the
  dependency-root digest, activation-coordination digest, activation ID,
  service ID, runtime node ID, composition entry ID, and projection identity.
- The projection contains references only and creates no runtime state.

## Fail-Closed Invariants

- Exact equal coverage of dependency composition and activation coordination is
  required.
- Stale/foreign inputs, broken provenance, orphan activation/composition
  entries, duplicate activation/service bindings, duplicate positions, and
  incomplete projection reject.
- No service activation, lifecycle execution, DI, object/singleton creation,
  startup sequence, scheduler, async execution, event bus, retry, queue, Flutter
  initialization, persistence, HTTP/API, Provider integration, configuration
  loading, or runtime mutation exists.

## Verification

- Focused M10.3 tests: 6/6.
- Focused analyzer: clean.
- Full app regression: 644/644.
- Knowledge package regression: 75/75.
- Protected M3-M9 freeze suites: 25/25.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen M3-M9 contracts and protected artifacts unchanged.

Product Owner accepted and closed M10.3 on 2026-07-22. M10.4 Runtime Lifecycle
Host Projection Foundation is authorized next.
