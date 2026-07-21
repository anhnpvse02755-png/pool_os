# M9.1 Product Shell & Navigation Foundation

**Status:** Accepted; Closed  
**Date:** 2026-07-22

M9.1 adds the deterministic product-shell projection above the frozen M3-M8
runtime framework. It consumes only the public M8 exposure and delivery
projections plus the approved `ProductNavigationPolicy` input policy.

## Deliverables

- `app/lib/contracts/product_shell_contracts.dart`
- `app/test/product_shell_foundation_test.dart`

## Contract

- `ProductNavigationPolicy` is immutable, versioned, content-addressed, and
  canonicalizes feature position, category, visibility, and parent topology.
- `ProductShellContract` is immutable, replayable, and bound to the exposure,
  delivery, and policy digests.
- `ProductShellBuilder` is a pure function. It does not mutate runtime
  projections, infer navigation categories, add features, or provide fallback.

## Invariants

- Navigation categories are fixed to Home, Training, Coach, AI, Analytics, and
  Settings.
- Feature IDs and positions are unique and contiguous.
- Parent topology is validated and acyclic through canonical parent ordering.
- Every navigation edge is explicit, canonical, and provenance-bound.
- Stale or mixed exposure/delivery/policy inputs fail closed.
- Frozen M3-M8 contracts and protected/generated artifacts remain unchanged.

## Verification

- Focused M9.1 tests: 8/8.
- Full app regression: 578/578.
- Knowledge package regression: 75/75.
- Protected M3-M8 freeze suites: 20/20.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.

Product Owner accepted and closed M9.1 on 2026-07-22. M9.2 Player Profile &
Progress Foundation is Authorized to Start.
