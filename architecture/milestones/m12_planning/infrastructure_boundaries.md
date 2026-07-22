# M12 Infrastructure Boundaries

| Adapter | External mechanism owned | Ingress/egress boundary | Explicit prohibition |
|---|---|---|---|
| Flutter Application | Flutter engine, platform lifecycle, UI events | Product/Application commands and immutable projections | No domain inference, policy, direct Runtime access, or persistence |
| Configuration | Process environment, build-time values, secure configuration source | Normalized configuration identity and compatibility metadata | No compatibility policy, business defaults, or secret leakage into digests/diagnostics |
| Persistence | Database, filesystem, cache, migration mechanism | Public repository ports and serialized contract values | No domain policy, cross-domain table access, or storage schema exposure |
| Transport | HTTP, REST, WebSocket, external API clients | Public application commands/results and transport errors | No use-case policy, direct database access, or internal model serialization |
| AI Provider | Provider SDK, model endpoint, provider credentials | AIProvider request/result contracts | No Coach, Planner, Learning, prompt-policy, or reasoning ownership |
| Observability | Logger, metric sink, telemetry exporter, diagnostic backend | Structured public diagnostics and operational events | No canonical state, decision policy, secret/raw Evidence export, or input mutation |
| Packaging & Deployment | Build artifacts, signing, release channel, deployment target | Validated package identity and accepted delivery authorization | No readiness decisions, contract rewriting, or bypass of release gates |
| Integration Validation | Test harness and retained evidence | Compatibility/readiness report | No startup, deployment, network, persistence, provider call, or mutation |

All future implementations depend inward on contracts. No deterministic domain
may import a framework SDK, storage client, transport client, provider SDK, or
telemetry implementation.

