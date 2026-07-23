# ADR-031: Product Implementation Readiness

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Platform Owners, Capability Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.0-P1.8 complete Product governance, runtime, capability, data, application,
workflow, Experience, interaction and recovery planning. A final baseline is
needed to determine when a bounded runtime slice may be authorized and how its
implementation evidence traces to planning and Platform authority.

## Decision

Treat P1.0-P1.8 as the Product planning completion baseline rooted at the M22
terminal digest. A slice is implementation-ready only with explicit owner,
contracts/versions, exact files, state/compatibility impact, sequencing,
prohibitions, rollback, evidence and Product Owner authorization.

Planning completion makes slices eligible for authorization; it grants no runtime
authority. Implementation follows contract/capability/application/Experience/
adapter ordering, uses public Platform contracts and closes only after independent
evidence and PO acceptance. This ADR remains Proposed.

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
  - ADR-022-product-implementation-governance
  - ADR-023-product-runtime-architecture
  - ADR-024-product-domain-capabilities
  - ADR-025-product-data-model-state-ownership
  - ADR-026-product-application-services
  - ADR-027-product-domain-workflows
  - ADR-028-product-experience-navigation
  - ADR-029-product-user-interaction-model
  - ADR-030-product-error-recovery-model
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.implementation-readiness.baseline
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
  - ruleId: product_implementation_traceability_complete
    status: planned
  - ruleId: product_implementation_exact_scope
    status: planned
integrationTests:
  - path: planned/product-first-runtime-slice-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Start coding directly from roadmap: rejected; roadmap entries lack exact
  contracts/files/evidence/rollback authority.
- Make one broad Product implementation milestone: rejected; blast radius,
  ownership and verification would be unbounded.
- Let engineering choose/modify Platform contracts: rejected; semantic authority
  would move to consumers.
- Require all adapters before capability core: rejected; infrastructure would
  define business contracts.

## Consequences

Implementation can begin as small traceable vertical slices after explicit PO
authorization. Preparation is more deliberate and each slice carries evidence,
but Platform immutability, ownership and rollback remain auditable.

## Compatibility And Migration

P2.0 changes no runtime contract. Future slices declare compatibility/migration
per affected contract/state. Breaking Platform changes require upstream successor
authority and cannot be absorbed into Product implementation.

## Security Privacy And Provenance

Work packets declare data purpose/classification, access, provenance, retention,
erasure and evidence custody. Implementations minimize exposed data and never put
secrets/raw Evidence/provider internals into public Product contracts.

## Enforcement

Exact work-packet scope, traceability, ownership/dependency, contract/version,
migration/rollback, focused/full/freeze/Architecture evidence, protected diff,
independent verification and PO acceptance all fail closed.

## Exceptions

None.
