# M8.0 Product Runtime Services & Delivery Architecture Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

M8.0 is planning only. It defines service and delivery architecture over the
frozen M3-M7 public projections without creating runtime behavior or new
production contracts.

## Deliverables

- `m8_planning/capability_inventory.md`
- `m8_planning/capability_graph.json`
- `m8_planning/layer_map.md`
- `m8_planning/ownership_map.md`
- `m8_planning/mutation_boundaries.md`
- `m8_planning/reuse_analysis.md`
- `m8_planning/implementation_sequence.md`
- ADR-007 Product Runtime Services.

## Invariants

- M3-M7 contracts are authoritative inputs and remain frozen.
- Runtime Core remains the deterministic source of truth.
- Services consume public ports/contracts only.
- Registry is not a business owner; delivery cannot mutate runtime state.
- AI observes public projections only.
- Persistence, API, and transport remain adapters.
- Modular monolith remains the deployment baseline.

## Product Review

Product Owner accepted and closed M8.0 on 2026-07-22. M8.1 Runtime Service
Composition Foundation is Ready to Start.
