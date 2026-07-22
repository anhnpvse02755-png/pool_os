# M13 Ownership Map

| Concern | Authoritative owner | Behavior implementation responsibility | Explicitly not owned |
|---|---|---|---|
| Knowledge truth and publication | Knowledge | Load accepted package through existing runtime port | Authoring, verification, or publication bypass |
| Evidence facts and append-only history | Evidence | Persist accepted facts and enforce erasure policy | Inference, recommendation, destructive history edits |
| Learning and Player projections | Learning Runtime | Execute existing projectors from accepted inputs | Evidence capture or UI policy |
| Coach decisions and lifecycle | Coach | Execute frozen decision/plan/recommendation policies | AI/provider/UI ownership |
| AI session and structured response | AI contracts/ports | Send only approved AISession envelope and validate result | Direct Evidence/Runtime/Player access or Coach policy |
| Runtime lifecycle and dispatch | Runtime Core | Execute frozen lifecycle/dispatch plans | Domain truth or implicit service discovery |
| Product commands and projections | Product Application | Bind UI lifecycle and route commands/results | Runtime or domain inference |
| Configuration effects | Configuration Infrastructure | Read, validate, redact, and expose private values through port | Domain defaults or compatibility policy |
| Persistence effects | Persistence Infrastructure | Transactions, migrations, retention, erasure, recovery | Domain semantics |
| Transport effects | Transport Infrastructure | Protocol, auth, timeout, retry/cancel, serialization | Use-case policy |
| AI provider effects | AI Infrastructure | Provider SDK/network call and structured provider result | Prompt policy, planning, recommendation, memory policy |
| Construction/lifetime | Composition Root | Explicit creation, activation order, disposal/rollback | Business policy or global service locator |
| Release | Release Governance | Evidence-based rollout, rollback, and incident authority | Runtime truth or contract amendment |

Extraction from the modular monolith requires operational evidence and a
separate accepted ADR.
