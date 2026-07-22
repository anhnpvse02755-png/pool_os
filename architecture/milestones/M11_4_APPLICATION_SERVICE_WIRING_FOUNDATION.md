# M11.4 Application Service Wiring Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M11.4 implements deterministic application service wiring planning over the
initialized-host plan and frozen service composition authorized by the Product
Owner. It produces metadata only; it does not wire or construct services.

## Deliverables

- `app/lib/application/application_service_wiring_planner.dart`
- `app/test/application_service_wiring_planner_foundation_test.dart`

## Authorized Inputs

- `RuntimeHostInitializationPlan`
- `RuntimeServiceCompositionContract`

No other Pool OS model or contract is imported by the implementation.

## Implementation

- `ApplicationServiceWiringPlanner` is stateless and deterministic.
- `ApplicationServiceWiringEntry` is immutable and binds initialization entry,
  service, runtime node, service key/type, position, and source digests.
- `ApplicationServiceWiringPlan` canonicalizes entries by position and produces
  a replay-safe digest.
- `ApplicationServiceWiringLogEntry` records only structural phases,
  provenance, event codes, and deterministic digests.
- The fixed structural log order is `validateInputs`, `orderWiring`,
  `bindServices`, `completed`.

## Fail-Closed Invariants

- Stale/foreign initialization or composition inputs, incomplete coverage,
  orphan services/nodes, duplicate wiring identity or position, inconsistent
  service/runtime bindings, broken provenance, and malformed logs reject.
- Inputs are not mutated and the planner retains no mutable state.
- No service construction, dependency injection, object creation, runtime
  activation, lifecycle execution, Flutter startup, scheduler,
  Provider/Riverpod/Bloc, persistence, networking, Product/Coach/AI logic, or
  runtime mutation is present.

## Verification

- Focused M11.4 tests: 7/7.
- Focused analyzer: clean.
- Full app regression: 706/706.
- Knowledge package regression: 75/75.
- Protected M3-M10 freeze suites: 30/30.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen contracts, protected artifacts, Golden Fixtures, production Knowledge,
  and generated plugin artifacts unchanged.

Product Owner accepted and closed M11.4 on 2026-07-22. M11.5 Product Feature
Assembly Foundation is authorized next.
