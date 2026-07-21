# M6 Implementation Sequence

1. M6.1 Runtime Composition Engine: define composition ports and replay proof.
2. M6.2 Coach Runtime Pipeline: wire existing public deterministic contracts.
3. M6.3 Application Service Layer: expose use cases without domain leakage.
4. M6.4 Persistence Projection Layer: add rebuildable storage adapters.
5. M6.5 Event & Synchronization Foundation: add idempotent append/sync proof.
6. M6.6 Runtime Configuration: version operational policy/configuration.
7. M6.7 Product API Boundary: add transport adapters over application ports.
8. M6.8 Product Runtime Activation: add operational activation and rollback.

Every implementation milestone requires focused tests, full regression,
Architecture Fitness, protected-artifact validation, and Product Owner review
before commit/push. M6.0 itself contains no implementation authorization.
