# M12 Ownership Map

| Concern | Authoritative owner | Adapter responsibility | Adapter is explicitly not owner of |
|---|---|---|---|
| Knowledge truth and dependencies | Knowledge | Preserve published identity at boundaries | Knowledge authoring, prerequisite, unlock, or dependency semantics |
| Evidence facts and history | Evidence | Persist/transport only through public ports | Evidence interpretation or destructive history changes |
| Player and Learning projections | Learning Runtime | Render or store approved projections | Mastery/readiness inference |
| Coach decisions, plans, recommendations, execution | Coach | Carry immutable contracts unchanged | Coach policy, lifecycle decisions, ranking, or completion |
| AI session, capability, provider, orchestration, response | AI contracts and accepted AI owners | Implement provider mechanism behind AIProvider | AI reasoning, capability policy, Coach behavior, or direct deterministic access |
| Runtime deterministic state | Runtime Core | Invoke public ports and expose structured adapter results | Runtime state, activation truth, or lifecycle history |
| Product composition and presentation semantics | Product Application | Adapt Flutter lifecycle/events and render projections | Runtime, Coach, Learning, or AI internals |
| Construction and lifetime | Composition Root | Construct approved adapter instances after authorization | Business policy or hidden service discovery |
| Configuration source | Configuration adapter | Read and normalize external values | Compatibility acceptance or domain defaults |
| Storage and protocol mechanisms | Persistence/Transport adapters | Translate public port calls | Use-case and domain behavior |
| Operational export | Observability adapter | Export structured diagnostics | Canonical health/runtime state |
| Release authorization | Release Governance | Consume evidence and approve/reject delivery | Packaging/deployment execution |
| Packaging/deployment execution | Release Infrastructure | Execute an accepted delivery plan | Readiness policy or gate creation |

The modular monolith remains authoritative. Extraction requires a separate
accepted ADR and operational evidence.

