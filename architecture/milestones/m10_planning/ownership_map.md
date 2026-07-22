# M10 Ownership Map

| Concern | Authoritative owner | M10 responsibility | Explicit non-owner |
|---|---|---|---|
| Runtime deterministic state | Runtime Core | Invoke public ports and project lifecycle | Composition Root, Product, adapters |
| Dependency wiring and lifetime | Composition Root | Construct approved graph and dispose owned resources | Coach, Learning, Product policy |
| Application host lifecycle | Application Runtime | Coordinate bootstrap/start/ready/stop/failure | Domain state and recommendations |
| Service activation intent | Runtime Operations | Coordinate accepted activation contracts | Service business behavior |
| Health and diagnostics | Runtime Operations | Project structured health references | Canonical runtime state |
| Configuration source | Infrastructure adapter | Read platform environment and emit normalized input | Contract compatibility policy |
| Configuration compatibility | Application Runtime | Validate versioned normalized configuration | Raw environment provider |
| Production readiness | Release Governance | Create fail-closed readiness proof | Runtime state mutation |
| Delivery authorization | Release Governance | Accept or reject delivery from proof | Deployment infrastructure execution |
| Player, Coach, Recommendation, AI | Existing M3-M9 owners | Expose frozen public projections/ports | M10 host and composition code |

The modular monolith owns one in-process Composition Root. Future extraction
requires a separate accepted ADR and operational evidence.
