# ADR-024: Product Domain Capabilities

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Capability Owners, Platform Domain Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.1 defined logical Product runtime modules and dependency boundaries. Product
implementation also needs an explicit business capability map so runtime slices
do not duplicate ownership or become coupled through application or UI code.

## Decision

Organize Product planning around ten logical capabilities: User & Identity,
Settings / Configuration, Match Management, Scoring, Training, Knowledge,
Evidence, Simulation, Performance Analytics and AI Coach. Each capability has
one accountable owner, one authoritative state boundary, planned public
interfaces and an acyclic dependency position.

Knowledge, Evidence, Simulation, Learning and AI boundary semantics remain under
their accepted Platform owners. Product capabilities compose or integrate those
contracts without redefining them. This ADR is planning-only.

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
  - ADR-023-product-runtime-architecture
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.domain.capability.map
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
  - ruleId: product_capability_dependency_acyclic
    status: planned
  - ruleId: product_capability_single_state_owner
    status: planned
integrationTests:
  - path: planned/product-capability-contract-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Organize only by UI features: rejected; presentation flows do not define state
  ownership or cross-capability contracts.
- One Product domain: rejected; it concentrates unrelated semantics and creates
  shared persistence coupling.
- Let Analytics or AI own copied source data: rejected; derived/generated output
  cannot replace authoritative facts.
- Combine Match and Scoring: rejected; their lifecycles and authority differ.

## Consequences

Future implementation can be delivered in ownership-aligned vertical slices and
tested at public boundaries. The explicit graph constrains sequencing and makes
cross-capability changes more deliberate. Product orchestration cannot become a
hidden business owner.

## Compatibility And Migration

No runtime or data contract changes. Future capability contracts must remain
compatible with P1.1 and accepted Platform versions. Breaking evolution requires
new versions, migration, rollback, affected-owner approval and evidence.

## Security Privacy And Provenance

Each capability receives only required data through explicit contracts. Identity,
Evidence, generated AI content and player data preserve purpose, custody and
provenance. Capability boundaries cannot be bypassed for convenience.

## Enforcement

Ownership review, acyclic dependency checks, contract/version tests, protected
freeze tests, Architecture Fitness, exact scope and independent verification
fail closed.

## Exceptions

None.
