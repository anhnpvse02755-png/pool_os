# M6 Capability Inventory

| Capability | Purpose | Primary owner | Depends on | Implementation gate |
|---|---|---|---|---|
| M6.1 Runtime Composition Engine | Compose deterministic projections into application-ready workflows | Application/Runtime | M3-M5 contracts, activation proof | contract and replay tests |
| M6.2 Coach Runtime Pipeline | Run Context -> Decision -> Plan -> Recommendation -> Execution workflow | Intelligence Runtime | M6.1, M3 contracts | ownership and no-mutation tests |
| M6.3 Application Service Layer | Expose use cases through public application ports | Application | M6.1/M6.2 | port and boundary tests |
| M6.4 Persistence Projection Layer | Persist/rebuild approved projections without redefining truth | Infrastructure | contracts, projections | migration/replay tests |
| M6.5 Event & Synchronization Foundation | Append-only event synchronization and idempotent projection rebuild | Evidence/Infrastructure | Evidence contracts, M6.4 | ordering/idempotency tests |
| M6.6 Runtime Configuration | Versioned runtime policy/configuration boundaries | Application/Infrastructure | contracts and ADRs | compatibility tests |
| M6.7 Product API Boundary | Transport-neutral API contracts and adapters | Application/Experience | M6.3, M6.6 | API compatibility tests |
| M6.8 Product Runtime Activation | Operationally activate the composed product runtime | Application/Operations | M6.1-M6.7 | activation/rollback proof |

M6.0 does not authorize implementation of any row. Ordering is a planning
proposal and may be adjusted only by Product Owner review.
