# ADR-029: Product User Interaction Model

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Experience Owner, Application Owner, Capability Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.6 defines logical journeys/navigation and P1.4/P1.5 define application and
domain workflows. A stable interaction model is required before UI controls,
forms or handlers can be authorized.

## Decision

Separate user intent, Experience draft/presentation, Application submission and
authoritative owner execution. Commands and queries have distinct lifecycles.
Confirmation binds an exact canonical intent; pre-submit cancellation is local;
post-acceptance cancellation is a new owner command. Idempotency prevents repeated
activation from creating repeated mutation, and outcome-unknown requests are
resolved with their original identity.

Logical accessibility provides input-modality-equivalent intent. Audit captures
semantic submission/confirmation/results, not detailed human interaction. This
ADR is planning-only.

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
  - ADR-028-product-experience-navigation
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.user-interaction.plan
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
  - ruleId: experience_interaction_no_domain_execution
    status: planned
  - ruleId: interaction_idempotency_identity
    status: planned
integrationTests:
  - path: planned/product-interaction-contract-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Let UI state equal command state: rejected; pending presentation would be
  confused with domain acceptance.
- Confirmation after submission: rejected; user intent would not bind the actual
  command.
- Retry every failure automatically: rejected; outcome or semantics may differ.
- Audit all raw interactions: rejected; unnecessary surveillance and privacy risk.

## Consequences

Future UI implementations receive predictable intent, confirmation, retry and
result semantics across input modalities. More explicit identities/states are
required, but duplicate mutation and ambiguous cancellation are prevented.

## Compatibility And Migration

P1.7 changes no runtime interaction contract. Later contracts require semantic
IDs/versions and migration for breaking changes. They cannot widen domain or
Platform ownership.

## Security Privacy And Provenance

Intent contains purpose-required values only. Sensitive drafts are excluded from
audit; authorization decisions remain source-owned. Confirmation/results retain
identity/version/provenance without exposing secrets or raw Evidence.

## Enforcement

Interaction lifecycle, command/query separation, confirmation binding,
idempotency/concurrency, accessibility-equivalence and audit-minimization tests,
Architecture Fitness, protected freezes, exact scope and independent verification
fail closed.

## Exceptions

None.
