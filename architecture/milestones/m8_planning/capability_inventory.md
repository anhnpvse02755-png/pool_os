# M8 Capability Inventory

| Capability | Purpose | Owner | Depends on | Gate |
|---|---|---|---|---|
| M8.1 Runtime Service Composition | Compose service descriptors | Application | M7 freeze | contract/replay |
| M8.2 Runtime Service Registry | Register compatible services | Application | M8.1 | identity/compatibility |
| M8.3 Runtime Dependency Resolution | Resolve service dependencies | Application | M8.2 | graph/no cycles |
| M8.4 Runtime Activation Coordinator | Coordinate activation intent | Runtime Core | M8.3 | deterministic policy |
| M8.5 Runtime Health Projection | Project service health | Operations | M8.2 | replay/ownership |
| M8.6 Runtime Diagnostics Projection | Project structured diagnostics | Operations | M8.3/M8.5 | provenance |
| M8.7 Runtime Delivery Projection | Describe delivery readiness | Operations | M8.4/M8.6 | no mutation |
| M8.8 Product Runtime Release Gate | Validate release evidence | Operations | M8.1-M8.7 | freeze/rollback |

M8.0 authorizes no implementation of these rows.
