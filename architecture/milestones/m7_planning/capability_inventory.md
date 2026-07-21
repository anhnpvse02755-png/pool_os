# M7 Capability Inventory

| Capability | Purpose | Owner | Depends on | Gate |
|---|---|---|---|---|
| M7.1 Runtime Core | Runtime lifecycle state and commands | Runtime Core | M6 freeze | contract/replay |
| M7.2 Runtime Coordinator | Coordinate validated runtime operations | Application | M7.1 | ownership/no bypass |
| M7.3 Runtime Dispatcher | Dispatch explicit commands to ports | Application | M7.2 | routing/compatibility |
| M7.4 Runtime Lifecycle | Start, pause, resume, stop lifecycle semantics | Runtime Core | M7.1 | state machine proof |
| M7.5 Runtime Recovery | Deterministic recovery and failure classification | Runtime Core | M7.4 | recovery/replay |
| M7.6 Persistence Boundary | Rebuildable projection adapter | Infrastructure | M7.1 | migration/replay |
| M7.7 API Boundary | Transport-neutral product adapter | Application | M7.2/M7.3 | compatibility |
| M7.8 Product Activation | Operational activation and rollback | Operations | M7.5-M7.7 | activation proof |

M7.0 authorizes no implementation of these rows.
