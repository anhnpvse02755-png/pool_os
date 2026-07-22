# M10 Capability Inventory

| Capability | Purpose | Owner | Depends on | Frozen inputs reused |
|---|---|---|---|---|
| M10.1 Application Bootstrap Foundation | Define deterministic application identity, startup request, and bootstrap result boundaries | Application Runtime | M9 Freeze | M8 delivery projection, M9 shell projection |
| M10.2 Dependency Composition Root | Define wiring declarations and dependency lifetime without business behavior | Application Runtime | M10.1 | M6 composition, M8 registry/dependency resolution |
| M10.3 Runtime Service Activation | Coordinate activation through public Runtime ports and accepted activation contracts | Runtime Operations | M10.2 | M7 activation projection, M8 activation coordination |
| M10.4 Runtime Lifecycle Host | Define start, ready, stop, and failed host lifecycle around Runtime Core | Application Runtime | M10.1-M10.3 | M6 transition/state, M7 lifecycle projection |
| M10.5 Runtime Health & Diagnostics | Project structured readiness and diagnostic references without becoming runtime truth | Runtime Operations | M10.3-M10.4 | M6 validation/state, M8 exposure/delivery |
| M10.6 Runtime Configuration & Environment | Normalize adapter-supplied configuration identity and compatibility metadata | Infrastructure Adapters | M10.1-M10.2 | public version/provenance contracts only |
| M10.7 Production Readiness Validation | Join configuration, activation, lifecycle, health, and protected-freeze evidence into a fail-closed readiness proof | Release Governance | M10.3-M10.6 | M8 delivery, M9 freeze proof |
| M10.8 Runtime Activation & Delivery Gate | Authorize or reject delivery from the readiness proof without owning runtime state | Release Governance | M10.4-M10.7 | M8 delivery projection, M10 readiness proof |

M10.0 authorizes no implementation of these capabilities.
