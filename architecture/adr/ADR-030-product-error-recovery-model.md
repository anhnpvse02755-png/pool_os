# ADR-030: Product Error Recovery Model

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Application Owner, Capability Owners, Experience Owner, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.4-P1.7 define application orchestration, workflows, navigation and
interaction. Product implementation needs consistent source-owned error and
recovery semantics before exceptions, retries or resilience mechanisms can be
authorized.

## Decision

Use a versioned Product error taxonomy that preserves authoritative source owner,
category, outcome certainty, retry eligibility and evidence reference. Application
propagates and correlates; Experience renders declared recovery; neither
reclassifies source semantics. Unknown outcomes reconcile exact request identity,
partial success preserves committed steps and capability degradation is explicit.

Recovery follows a deterministic fail-closed sequence and cannot weaken
validation, change provider/owner or fabricate success. This ADR is planning-only.

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
  - ADR-026-product-application-services
  - ADR-027-product-domain-workflows
  - ADR-029-product-user-interaction-model
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.error-recovery.plan
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
  - ruleId: product_error_source_identity_preserved
    status: planned
  - ruleId: product_recovery_no_semantic_fallback
    status: planned
integrationTests:
  - path: planned/product-error-recovery-contract-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- One generic Product error: rejected; source, retry and user action become
  ambiguous.
- Catch/retry every failure: rejected; may duplicate mutation or bypass rejection.
- Treat missing response as failed: rejected; accepted mutation may already exist.
- Silent degraded fallback: rejected; stale/incompatible data could become truth.

## Consequences

Future implementations receive consistent failure/recovery contracts and can
isolate capabilities without ownership drift. Explicit outcome reconciliation,
partial state and degradation require more modeling but prevent data corruption
and misleading success.

## Compatibility And Migration

P1.8 changes no runtime error contract. Future versions must preserve category
and source identity or provide explicit migration. Product error evolution cannot
change Platform failure semantics or governance.

## Security Privacy And Provenance

Public error envelopes exclude secrets, raw Evidence, stack traces and provider
payloads. Audit retains only purpose-required immutable references with custody,
retention/redaction and access rules.

## Enforcement

Taxonomy/source-preservation, retry/idempotency/outcome reconciliation,
partial/degradation and redaction contract tests, Architecture Fitness, protected
freezes, exact scope and independent verification fail closed.

## Exceptions

None.
