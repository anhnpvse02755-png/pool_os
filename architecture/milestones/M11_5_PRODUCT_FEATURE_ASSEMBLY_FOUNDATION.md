# M11.5 Product Feature Assembly Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M11.5 implements deterministic product feature assembly planning. It binds each
frozen Product Shell feature to the complete application wiring-plan provenance;
it does not infer or assign an individual service to any feature.

## Approved Scope Adjustment

The original Product Analytics input did not own feature inventory or a
feature-to-service mapping. The Product Owner removed it and authorized only:

- `ApplicationServiceWiringPlan`
- `ProductShellContract`

The normative v1 binding means "this feature is assembled under this complete
application wiring plan." No per-feature `serviceId` or `runtimeNodeId` appears.

## Deliverables

- `app/lib/application/product_feature_assembly_planner.dart`
- `app/test/product_feature_assembly_planner_foundation_test.dart`

## Implementation

- `ProductFeatureAssemblyPlanner` is stateless and deterministic.
- `ProductFeatureAssemblyEntry` is immutable and binds feature/shell identity,
  category, visibility, parent topology, canonical position, shell digest, and
  complete wiring-plan digest.
- `ProductFeatureAssemblyPlan` canonicalizes entries by Product Shell position
  and produces a replay-safe digest.
- The fixed structural log order is `validateInputs`, `orderFeatures`,
  `bindWiringProvenance`, `completed`.

## Fail-Closed Invariants

- Stale shell/wiring provenance, incomplete shell coverage, orphan or duplicate
  feature identity, duplicate position, invalid topology binding, and malformed
  logs reject.
- Inputs are not mutated and the planner retains no mutable state.
- No feature instantiation, service selection/assignment, widget/UI/navigation,
  Provider/Riverpod/Bloc, runtime activation, dependency injection, business or
  Coach logic, AI execution, persistence, networking, or runtime mutation is
  present.

## Verification

- Focused M11.5 tests: 8/8.
- Focused analyzer: clean.
- Full app regression: 714/714.
- Knowledge package regression: 75/75.
- Protected M3-M10 freeze suites: 30/30.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen contracts, protected artifacts, Golden Fixtures, production Knowledge,
  and generated plugin artifacts unchanged.

Product Owner accepted and closed M11.5 on 2026-07-22. M11.6 Runtime
Observability Integration Foundation is authorized next.
