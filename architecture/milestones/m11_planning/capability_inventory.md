# M11 Capability Inventory

| Capability | Purpose | Owner | Depends on | Frozen contracts consumed |
|---|---|---|---|---|
| M11.1 Application Bootstrap Implementation | Adapt an explicit startup request into M10.1 bootstrap validation and result handling | Application Runtime | M10 Freeze | M10.1 bootstrap, M10.7 readiness |
| M11.2 Dependency Injection Composition | Construct the approved dependency graph and resource lifetimes | Composition Root | M11.1 | M10.2 composition root |
| M11.3 Runtime Host Initialization | Initialize the host through approved Runtime ports after bootstrap and composition validation | Application Runtime | M11.2 | M10.3 activation projection, M10.4 lifecycle host |
| M11.4 Application Service Wiring | Bind application services to public Runtime/domain ports without policy duplication | Application Runtime | M11.2-M11.3 | M3-M10 public contracts and ports |
| M11.5 Product Feature Assembly | Connect Product surfaces to application services and immutable projections | Product Application | M11.4 | M9 Product projections |
| M11.6 Runtime Observability Integration | Attach structured diagnostics and operational signals outside Runtime truth | Runtime Operations | M11.3-M11.4 | M10.5 health diagnostics |
| M11.7 Production Startup Validation | Evaluate fail-closed readiness and delivery gates before exposure | Release Governance | M11.3, M11.6 | M10.7 readiness, M10.8 delivery gate |
| M11.8 End-to-End Application Composition | Assemble the approved application path and prove complete public-port coverage | Application Runtime | M11.5-M11.7 | Complete frozen M3-M10 contract set |

M11.0 authorizes no implementation of these capabilities. Each capability
requires a separately approved executable scope.
