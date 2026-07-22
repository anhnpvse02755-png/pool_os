# M12 Mutation Boundaries

M12.0 performs no mutation. The table constrains future implementations.

| Capability | Reads | Future authorized effect | Must not mutate |
|---|---|---|---|
| M12.1 Flutter | Product/Application projections and explicit UI/platform input | Send commands through public application ports and render local UI state | Domain, Runtime, Coach, AI, projection, or persistence state directly |
| M12.2 Configuration | Platform environment and secret/configuration sources | Emit normalized immutable configuration input | Process environment, frozen contracts, business state, or public diagnostics with secrets |
| M12.3 Persistence | Explicit public repository operations | Write owned storage through implemented repository ports | Domain objects in place, historical Evidence, another owner's tables, or frozen artifacts |
| M12.4 Transport | Public application requests/results | Perform protocol I/O and translate transport failures | Domain/runtime internals, persistence, or business outcomes |
| M12.5 AI Provider | Frozen AI provider request and selected provider configuration | Invoke provider and return provider result through AIProvider | AISession, Coach state, capability policy, prompts, Knowledge, Evidence, or provider-independent contracts |
| M12.6 Observability | Structured diagnostics and operational events | Append/export logs, metrics, traces, and diagnostics | Source projections, runtime truth, business decisions, or secrets |
| M12.7 Packaging & Deployment | Accepted gate, package identity, deployment configuration | Build/sign/publish/deploy only after explicit authorization | Readiness proof, source contracts, Knowledge artifacts, or runtime state |
| M12.8 Validation | Adapter outputs, frozen plans, compatibility evidence | Emit immutable validation/readiness evidence | Any adapter, external target, runtime state, or release artifact |

Every effect must be explicit, owned, and reached through a public port. A
failed compatibility, identity, provenance, or authorization check must stop
before the external effect.

