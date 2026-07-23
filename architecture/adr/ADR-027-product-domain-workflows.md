# ADR-027: Product Domain Workflows

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Capability Owners, Application Owner, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.3 established logical aggregates/state ownership and P1.4 established
application orchestration. Product implementation needs explicit lifecycle rules
before state machines or workflow code can be authorized.

## Decision

Define deterministic, version-bound and idempotent logical workflows for Match,
Rack/Game Session, Training Session, Coach Session, Performance Snapshot,
Configuration, User/Profile, Simulation request and Evidence recording reference.
One authoritative owner accepts each transition. Invalid transitions leave state
unchanged; accepted transitions produce immutable audit/event references;
terminal state cannot reopen unless a specific owner transition is modeled.

Cross-capability synchronization remains P1.4 orchestration of committed owner
results. Simulation/Evidence Product workflows govern request/reference state
only and do not modify Platform entities. This ADR is planning-only.

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
  - ADR-024-product-domain-capabilities
  - ADR-025-product-data-model-state-ownership
  - ADR-026-product-application-services
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.domain-workflow.plan
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
  - ruleId: product_transition_single_owner
    status: planned
  - ruleId: product_terminal_transition_closed
    status: planned
integrationTests:
  - path: planned/product-workflow-replay-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Let runtime code define transitions implicitly: rejected; valid lifecycle and
  ownership would be implementation-dependent.
- Use a global workflow state machine: rejected; it would own foreign states and
  create a cross-capability transaction boundary.
- Reopen terminal state for retry: rejected; audit/replay would become ambiguous.
- Apply Product transitions to Platform entities: rejected; it violates ownership.

## Consequences

Future implementations receive explicit valid transitions, failure categories
and replay expectations. Exceptional paths require explicit terminal/correction
semantics rather than mutation, increasing modeling while preserving audit and
single-writer authority.

## Compatibility And Migration

P1.5 changes no runtime contract. Later state contracts may narrow planning
vocabulary but cannot widen ownership or bypass Platform semantics. Breaking
changes require successor versions, migration, rollback and evidence.

## Security Privacy And Provenance

Transitions bind actor/access decision, purpose, aggregate version and provenance.
Events/failures expose no secret, raw Evidence or unnecessary player data.
Cancellation/closure retain required custody and correction lineage.

## Enforcement

Transition matrix tests, terminal/replay/idempotency/concurrency contract tests,
ownership/import checks, Architecture Fitness, protected freezes, exact scope
and independent verification fail closed.

## Exceptions

None.
