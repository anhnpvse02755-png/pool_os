# M13 Capability Inventory

| Capability | Behavior owner | Frozen input boundary | Authorized effect class | Completion evidence |
|---|---|---|---|---|
| M13.1 Configuration Loading | Configuration Infrastructure | Configuration Adapter plan and approved configuration port | Read external configuration, normalize privately, publish validated configuration result | Compatibility, secret-redaction, missing/invalid value, replay-envelope tests |
| M13.2 Persistence Implementation | Persistence Infrastructure | Persistence Adapter plan and approved repositories/ports | Durable read/write and migrations behind ports | Idempotency, transaction, migration, erasure, corruption, rollback tests |
| M13.3 Transport Implementation | Transport Infrastructure | Transport Adapter plan and approved transport ports | Network request/response through private protocol DTOs | Auth, timeout, retry policy, cancellation, serialization, redaction tests |
| M13.4 AI Provider Implementation | AI Infrastructure | AI Provider Adapter plan, AISession/request/provider ports | Provider request and structured result only | Capability/provider compatibility, timeout, payload minimization, malformed result tests |
| M13.5 Dependency Activation | Composition Root | Accepted adapter implementations and frozen wiring/activation plans | Construct, bind, start, and dispose approved runtime dependencies | Ordering, duplicate/missing binding, disposal, partial-start rollback tests |
| M13.6 Runtime Execution Orchestration | Runtime Application | Frozen runtime plans and activated dependency handles | Execute lifecycle and dispatch through public ports | State-machine, cancellation, concurrency, failure isolation, deterministic trace tests |
| M13.7 Flutter Application Startup | Product Application | Frozen Flutter plan and running application host | Bind Flutter lifecycle, routing, commands, and projections | Startup, route, lifecycle, accessibility, command/query boundary tests |
| M13.8 End-to-End Production Runtime | Application Host and Release Governance | Accepted M13.1-M13.7 results | Start/stop the modular monolith and expose readiness | End-to-end startup, shutdown, recovery, degradation, protected-contract tests |

All concrete SDK, framework, protocol, storage, and provider types remain private
to the owning behavior adapter.
