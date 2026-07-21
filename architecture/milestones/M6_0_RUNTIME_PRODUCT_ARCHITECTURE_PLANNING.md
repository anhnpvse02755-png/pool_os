# M6.0 Runtime & Product Architecture Planning

**Status:** Accepted; Closed

**Date:** 2026-07-22

## Planning Boundary

M6.0 is planning only. It adds no production code, contract, persistence,
API, UI, Provider, network, or runtime implementation. M3-M5 remain the frozen
deterministic baseline.

## Deliverables

- Capability inventory: `m6_planning/capability_inventory.md`.
- Capability dependency graph: `m6_planning/capability_graph.json`.
- Architecture layer map: `m6_planning/layer_map.md`.
- Runtime ownership map: `m6_planning/runtime_ownership_map.md`.
- Implementation sequencing: `m6_planning/implementation_sequence.md`.
- ADR-005 Runtime Product Architecture.

## Governing Invariants

- Learning Runtime remains the Knowledge/runtime source of truth.
- Coach Runtime consumes public contracts only.
- AI consumes the deterministic activation boundary and never writes state.
- Provider remains infrastructure with no Coach/Learning business logic.
- Vision remains an Evidence producer.
- M3-M5 frozen contracts are not reopened by planning.

## Product Review

Product Owner accepted and closed M6.0 on 2026-07-22. M6.1 Runtime Composition
Engine Foundation is Ready to Start.
