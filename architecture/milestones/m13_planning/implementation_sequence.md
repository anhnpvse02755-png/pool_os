# M13 Implementation Sequence

Capability order is mandatory unless the Product Owner explicitly revises the
roadmap.

1. **M13.1 Configuration Loading**: implement private sources, validation,
   redaction, and typed failure behind the frozen configuration boundary.
2. **M13.2 Persistence Implementation**: implement storage, migrations,
   transactions, retention/erasure, idempotency, and recovery behind ports.
3. **M13.3 Transport Implementation**: implement protocol translation, auth,
   timeout, cancellation, and explicitly authorized retry semantics.
4. **M13.4 AI Provider Implementation**: implement one provider behind the
   frozen AISession/provider/result boundary; no prompt or Coach policy.
5. **M13.5 Dependency Activation**: construct accepted implementations,
   enforce canonical activation order, and dispose partial starts in reverse.
6. **M13.6 Runtime Execution Orchestration**: execute frozen lifecycle and
   dispatch state machines with isolation, cancellation, and structured traces.
7. **M13.7 Flutter Application Startup**: bind the running host to Flutter
   lifecycle, routing, projections, and commands.
8. **M13.8 End-to-End Production Runtime**: prove complete startup, readiness,
   degraded failure, shutdown, recovery, and release rollback.

## Capability Gate

Every capability requires:

- an explicit Product Owner executable scope and exact frozen input ports;
- effect owner, security/privacy treatment, idempotency, timeout/cancellation,
  cleanup, rollback, and observability semantics;
- focused happy-path, fail-closed, compatibility, provenance, concurrency, and
  recovery tests proportional to the effect;
- full app, Knowledge, protected M3-M12 freeze, and Architecture Fitness gates;
- no frozen artifact change except through constitutional evolution;
- Product Owner acceptance before commit and push.

M13.8 cannot start until M13.1-M13.7 are individually accepted and repository
closed.
