# ADR-023: Product Runtime Architecture

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Platform Domain Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.0 established Product implementation governance after Platform M1-M22 was
terminally frozen. Product delivery needs explicit logical module boundaries
before any runtime code can be authorized.

## Decision

Use a modular-monolith runtime organized by Experience, Application, domain
capabilities, infrastructure adapters and domain-neutral Shared/Core primitives.
Logical modules are Application, Experience, Domain, Knowledge, Intelligence,
Evidence, Simulation and Shared/Core. Cross-module dependencies use accepted
public contracts or ports, preserve ownership and fail closed on incompatible
or ambiguous composition.

This ADR defines planning constraints only. It neither creates source modules
nor authorizes implementation.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 1.5 Normative authority and architecture evidence"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-022-product-implementation-governance
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.runtime.architecture
    version: 1
```

ADR-023 cannot supersede any Platform ADR or change a Platform dependency edge.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m22_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
  - ruleId: product_module_dependency_direction
    status: planned
integrationTests:
  - path: planned/product-runtime-composition-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Microservices now: rejected; no operational evidence justifies extraction.
- Layer-only architecture without domain ownership: rejected; it permits semantic
  leakage and shared persistence.
- Direct module implementation imports: rejected; they create reverse coupling
  and bypass compatibility contracts.
- Put reusable business logic in Shared/Core: rejected; it erodes ownership.

## Consequences

Runtime implementation can proceed incrementally through stable public
boundaries. Composition and adapters remain replaceable. Additional contracts
and version gates add deliberate work, while preventing hidden coupling and
ownership drift.

## Compatibility And Migration

The plan changes no runtime or data contract. Future implementation must bind
accepted public versions. Any Platform contract change needs separate upstream
authority, compatibility analysis, migration, rollback and successor evidence.

## Security Privacy And Provenance

Interfaces expose only required immutable data and provenance. Raw Evidence,
secrets, persistence internals and unnecessary player data remain owner-bound.
Infrastructure credentials cannot enter domain or Shared/Core contracts.

## Enforcement

Architecture Fitness, contract tests, dependency-cycle checks, protected-freeze
tests, exact scope, ownership review and independent verification fail closed.

## Exceptions

None.
