# M13 Reuse Analysis

| Required behavior | Reuse unchanged | New implementation is limited to |
|---|---|---|
| Configuration | M12.2 ConfigurationAdapterPlan; M10 configuration projection | Private source readers and configuration port adapter |
| Persistence | M12.3 PersistenceAdapterPlan; Evidence append-only and erasure contracts | Repository/storage adapter, migrations, transactions |
| Transport | M12.4 TransportAdapterPlan; public request/result ports | Private protocol DTOs, client, auth, timeout/cancel |
| AI provider | M12.5 AIProviderAdapterPlan; M3 AI session/response/provider boundaries | Provider SDK adapter and structured result translation |
| Observability | M12.6 ObservabilityAdapterPlan; M10 health projection | Export sink only when separately authorized; no new truth |
| Packaging/deployment | M12.7 plan and M10 gate/readiness projections | Release mechanism only in separately authorized scope |
| Composition/activation | M11 bootstrap, composition, wiring, startup plans | Concrete construction, lifetime, disposal, partial-start rollback |
| Runtime orchestration | M10 lifecycle/dispatch contracts; M11 host plans | Effectful executor around frozen state machines |
| Flutter startup | M12.1 FlutterApplicationAdapterPlan; Product projections | Framework entrypoint, lifecycle binding, routing adapter |
| End-to-end host | M11 composition/startup and M12 integration validation | Process-level start/stop and evidence aggregation |

Rejected duplication:

- No second lifecycle, readiness, dependency, recommendation, or AI policy
  engine.
- No storage schema, protocol DTO, SDK object, or Flutter type enters a frozen
  public contract.
- No behavior adapter reconstructs graph ownership from aggregate provenance.
- No temporary bypass of ports, freeze proofs, or release governance.
