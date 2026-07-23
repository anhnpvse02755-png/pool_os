# ADR-026: Product Application Services

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Application Owner, Capability Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.1-P1.3 define runtime modules, Product capabilities and aggregate/state
ownership. Product use cases need a public orchestration boundary that does not
move business rules or state authority into controllers or presentation code.

## Decision

Define logical Product application services for User/Profile, Configuration,
Match, Scoring, Training, Knowledge Consumption, Evidence Recording, Simulation
Invocation, Performance Analytics and AI Coach. Services separate commands from
queries, coordinate accepted public contracts in deterministic order and expose
canonical request/result/failure envelopes.

Each mutating command targets one authoritative aggregate transaction. Multi-
capability workflows are explicit sequences with typed partial failure and
owner-command compensation. Application services own no domain truth, policy,
authorization semantics or persistence. This ADR is planning-only.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 1.5 Normative authority and architecture evidence"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-023-product-runtime-architecture
  - ADR-024-product-domain-capabilities
  - ADR-025-product-data-model-state-ownership
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.application-service.plan
    version: 1
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m22_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
  - ruleId: application_service_no_domain_ownership
    status: planned
  - ruleId: application_service_public_contract_only
    status: planned
integrationTests:
  - path: planned/product-application-orchestration-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Put orchestration in UI/controllers: rejected; Experience would acquire domain
  coordination and testing would depend on presentation state.
- Put all orchestration in domain services: rejected; cross-capability workflow
  policy would leak into domain ownership.
- Use distributed transactions: rejected; they obscure owner boundaries and no
  runtime mechanism is authorized.
- Treat failures as fallback/retry: rejected; intent or compatibility may change.

## Consequences

Product entry points can depend on stable use-case contracts while domain owners
retain invariants and state. Workflows expose partial progress and compensation,
increasing explicit modeling but preventing hidden cross-owner mutation.

## Compatibility And Migration

P1.4 changes no runtime contract. Future application contracts require explicit
versions, idempotency and compatibility. Breaking changes require successor
versions, migration, rollback and affected-owner evidence/approval.

## Security Privacy And Provenance

Application envelopes carry access-context references, purpose and required
provenance only. Authorization decisions remain security-owner controlled.
Failures and events avoid secrets, raw Evidence and unnecessary player data.

## Enforcement

Command/query separation tests, ownership/import checks, deterministic ordering,
idempotency/failure contract tests, Architecture Fitness, protected freezes,
exact scope and independent verification fail closed.

## Exceptions

None.
