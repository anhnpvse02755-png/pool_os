# M11.3 Runtime Host Initialization Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M11.3 implements deterministic runtime host initialization planning over the
two frozen public projections authorized by the Product Owner. It produces
metadata only; it does not create or initialize a runtime host.

## Deliverables

- `app/lib/application/runtime_host_initializer.dart`
- `app/test/runtime_host_initializer_foundation_test.dart`

## Authorized Inputs

- `RuntimeServiceActivationProjectionContract`
- `RuntimeLifecycleHostProjectionContract`

No other Pool OS contract is imported by the implementation.

## Implementation

- `RuntimeHostInitializer` is stateless and deterministic.
- `RuntimeHostInitializationEntry` is immutable and binds activation,
  lifecycle-entry, service, runtime-node, phase, position, and source digests.
- `RuntimeHostInitializationPlan` canonicalizes entries by activation position
  and produces a replay-safe digest.
- `RuntimeHostInitializationLogEntry` records only structural phases,
  provenance, event codes, and deterministic digests.
- The fixed structural log order is `validateProjections`,
  `orderInitialization`, `bindLifecycleHost`, `completed`.

## Fail-Closed Invariants

- Stale/foreign projections, incomplete coverage, orphan nodes, duplicate
  initialization identity, duplicate positions, inconsistent service/node or
  lifecycle bindings, broken provenance, and malformed logs reject.
- Inputs are not mutated and the initializer retains no mutable state.
- No runtime host creation, service activation, lifecycle execution, scheduler,
  timers, event bus, async execution, dependency injection, Flutter startup,
  configuration loading, persistence, networking, Provider/Riverpod/Bloc,
  Product/Coach/AI logic, or runtime mutation is present.

## Verification

- Focused M11.3 tests: 7/7.
- Focused analyzer: clean.
- Full app regression: 699/699.
- Knowledge package regression: 75/75.
- Protected M3-M10 freeze suites: 30/30.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen contracts, protected artifacts, Golden Fixtures, production Knowledge,
  and generated plugin artifacts unchanged.

Product Owner accepted and closed M11.3 on 2026-07-22. M11.4 Application
Service Wiring Foundation is authorized next.
