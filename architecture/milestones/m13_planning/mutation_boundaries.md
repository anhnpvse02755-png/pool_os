# M13 Mutation Boundaries

| Boundary | Permitted mutation/effect | Required guard | Failure and rollback |
|---|---|---|---|
| Configuration source | Read environment/file/secure store; cache only private normalized values | Schema, identity, version, required key, secret redaction | Fail startup; discard private cache; never synthesize defaults outside policy |
| Persistence port | Transactional durable state changes | Contract/provenance, authorization, idempotency, migration version | Roll back transaction; quarantine corruption; preserve append-only history |
| Transport port | Network I/O and private request state | Auth, payload minimization, timeout/cancel, compatibility | Typed failure; bounded retry only when explicitly idempotent |
| AI provider port | Provider network I/O and transient request state | AISession-only input, capability/provider compatibility, redaction | Typed provider failure; no fallback unless separately authorized |
| Composition Root | Object construction, activation handles, disposal state | Complete bindings, canonical order, duplicate rejection | Reverse-order disposal of successfully started components |
| Runtime host | Lifecycle, dispatch queue, cancellation state | Frozen state machine and accepted activation plan | Fail closed, isolate component, emit structured trace, deterministic shutdown |
| Flutter host | Framework lifecycle, route stack, view-local state | Frozen Product/Flutter plans and command/query separation | Recoverable UI state; no domain mutation outside commands |
| Release boundary | Deployment rollout state | Accepted readiness evidence and rollback plan | Halt rollout; execute infrastructure rollback; retain audit evidence |

No mutation may alter immutable contracts, historical transitions, proof
artifacts, semantic IDs, provenance, or frozen digests. All secrets and personal
data follow minimization, retention, erasure, and audit requirements.
