# M10.4 Runtime Lifecycle Host Projection Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M10.4 adds an immutable projection describing lifecycle hosting relationships
for activation-plan entries. It neither hosts services nor executes lifecycle
transitions.

## Deliverables

- `app/lib/contracts/runtime_lifecycle_host_projection_contracts.dart`
- `app/test/runtime_lifecycle_host_projection_foundation_test.dart`

## Authorized Inputs

- `RuntimeServiceActivationProjectionContract`
- `RuntimeLifecycleProjectionContract`

## Contract

- `RuntimeLifecycleHostProjectionContract` v1 and
  `RuntimeLifecycleHostEntry` are immutable, versioned, deterministic, and
  canonically ordered by activation position.
- `RuntimeLifecycleHostProjector` binds activation and lifecycle source
  digests, activation ID, lifecycle-entry reference, service ID, runtime node
  ID, lifecycle phase, and host-projection identity.
- Output contains references only and creates no host or runtime state.

## Authoritative Join Limitation

- M7 `RuntimeLifecycleEntry` has no independent lifecycle entry ID and belongs
  to the M7 activation chain, while M10.3 consumes M8 activation coordination.
- `runtimeNodeId` is therefore the only shared public join key. Exact equal,
  unique coverage is required; no cross-chain digest relation is inferred.
- M10.4 creates its own deterministic lifecycle-entry reference from the M7
  lifecycle projection ID and its public `activationEntryId`.

## Fail-Closed Invariants

- Stale/foreign projections, broken source digests, orphan activation/lifecycle
  entries, inconsistent runtime nodes, duplicate host bindings, duplicate
  positions, and incomplete coverage reject.
- No lifecycle execution/transition, activation logic, runtime hosting, service
  instantiation, scheduler, async/queue/retry/timer/event-bus work, DI, Flutter
  startup, persistence, HTTP/API, Provider integration, configuration loading,
  or runtime mutation exists.

## Verification

- Focused M10.4 tests: 6/6.
- Focused analyzer: clean.
- Full app regression: 650/650.
- Knowledge package regression: 75/75.
- Protected M3-M9 freeze suites: 25/25.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen M3-M9 contracts and protected artifacts unchanged.

Product Owner accepted and closed M10.4 on 2026-07-22. M10.5 Runtime Health &
Diagnostics Projection Foundation is authorized next, subject to resolving the
public validation-artifact join semantics without hidden inference.
