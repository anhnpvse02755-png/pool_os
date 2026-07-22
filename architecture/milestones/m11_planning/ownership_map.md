# M11 Ownership Map

| Concern | Authoritative owner | M11 responsibility | Explicit non-owner |
|---|---|---|---|
| Deterministic runtime state | Runtime Core | Expose and consume approved public ports | Composition Root, Product, adapters |
| Construction and resource lifetime | Composition Root | Create, wire, scope, and dispose approved instances | Domain policy and runtime truth |
| Application startup coordination | Application Runtime | Order bootstrap, composition, host, and validation | Deployment infrastructure and Product UI |
| Application use cases | Application Services | Coordinate public commands/projections | Persistence schemas and domain internals |
| Product feature assembly | Product Application | Bind product surfaces to application services | Coach, Learning, and Runtime policy |
| Operational diagnostics | Runtime Operations | Export structured health and diagnostics | Canonical state and alert business policy |
| Startup authorization | Release Governance | Evaluate readiness/delivery gates | Runtime activation and deployment execution |
| Configuration, persistence, transport | Infrastructure adapters | Translate external mechanisms to public ports | Compatibility and business decisions |
| AI | Existing AI boundary owners | Observe only approved sessions/responses | Runtime and application ownership |

No capability may move ownership without a constitutional amendment or an
accepted superseding ADR.
