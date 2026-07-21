# M7.0 Product Runtime & Integration Architecture Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

M7.0 is planning only. It defines how frozen M3-M6 contracts will become a
runtime product without reopening foundation contracts or adding behavior.

## Deliverables

- `m7_planning/capability_inventory.md`
- `m7_planning/capability_graph.json`
- `m7_planning/layer_map.md`
- `m7_planning/ownership_map.md`
- `m7_planning/implementation_sequence.md`
- ADR-006 Runtime Product Integration.

## Invariants

- M3-M6 remain frozen and are consumed through public contracts.
- Runtime Core is deterministic and owns no persistence or transport details.
- Adapters own persistence, API, and infrastructure concerns.
- Only Runtime Coordinator/Dispatcher may mutate runtime through explicit ports.
- AI remains a consumer and cannot bypass deterministic runtime boundaries.
- Planning contains no production code, scheduler, persistence, API, UI,
  provider, queue, or runtime behavior.

## Product Review

Product Owner accepted and closed M7.0 on 2026-07-22. M7.1 Runtime Composition
Coordinator Foundation is Ready to Start.
