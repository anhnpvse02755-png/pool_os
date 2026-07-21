# M9.0 Product Features & User Experience Architecture Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

M9.0 is planning only. It defines the product layer above the frozen M3-M8
framework without creating production contracts, UI, API, persistence, or
feature behavior.

## Deliverables

- `m9_planning/capability_inventory.md`
- `m9_planning/capability_graph.json`
- `m9_planning/feature_layer_map.md`
- `m9_planning/product_ownership_map.md`
- `m9_planning/mutation_boundaries.md`
- `m9_planning/reuse_analysis.md`
- `m9_planning/implementation_sequence.md`
- ADR-008 Product Feature Architecture.

## Invariants

- M3-M8 contracts remain frozen and authoritative.
- Product Features consume public contracts/ports only.
- Product code does not bypass Runtime Core, Coach Core, or AI activation.
- Persistence, API, and UI remain adapters.
- Product projections do not become sources of truth.
- Modular monolith remains the deployment baseline.
- Feedback changes knowledge, policy, recommendation, or UX before platform
  architecture.

## Explicitly Not Implemented

No production contracts, runtime implementation, UI, API, scheduler,
orchestration, persistence, provider integration, or feature behavior.

## Evidence Plan

- Planning JSON parses and validates with 8 nodes, 15 edges, and 0 cycles.
- ADR cites constitutional authority and M3-M8 architecture evidence.
- Architecture Fitness remains 133 known / 0 new.
- Protected M3-M8 artifacts remain unchanged.
