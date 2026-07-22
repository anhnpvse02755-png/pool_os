# ADR-017: Platform Integration Governance

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Product Owner, Architecture, Contract Owners, Platform, Quality
**Supersedes:** None
**Superseded by:** None

## Context

M17 established and froze platform-evolution governance. M18 must plan how
already accepted platform components integrate without turning integration into
permission for private dependencies, semantic duplication, fallback behavior or
Product implementation. A durable rule is required for identity, compatibility,
evidence, failure, security, rollback and acceptance across boundaries.

## Decision

Pool OS will govern platform integration through eight separately authorized,
dependency-ordered M18 capabilities. Every integration binds the exact M17
freeze and participating public contracts, preserves domain ownership and
deterministic replay/provenance, fails closed on incompatibility, retains
positive/negative/failure evidence, defines rollback or forward repair and
requires explicit Product Owner acceptance before repository closure.
Infrastructure and providers cannot own integration semantics.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 1.5 Normative authority and architecture evidence"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 20 Enforcement and amendment"
parentAdrs:
  - ADR-016-platform-evolution-governance
contracts:
  - id: m17.foundation.freeze
    version: 1
  - id: platform.m18.integration-plan
    version: 1
```

An ADR cannot grant itself authority that conflicts with the Constitution.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m17_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
integrationTests:
  - path: planned/M18-platform-integration-evidence
    status: planned
productionSignals:
  - metric: platform_integration_conformance
    owner: Architecture/Quality
    plan: Bind future integration outcomes to exact freeze, contracts, boundary, evidence, owner and rollback identities.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M17.0-M17.9 and M17 Foundation Freeze were accepted and closed on 2026-07-22.
The retained baseline is M17 Freeze 4/4, app 949/949, Knowledge 75/75, prior
protected freezes 52/52 and Architecture Fitness 133 existing / 0 new. No M18
integration implementation or runtime evidence exists; this ADR remains
Proposed.

## Alternatives Considered

- Integrate directly through existing implementations: rejected because public
  contracts, ownership and independent compatibility evidence would be bypassed.
- Let adapters infer compatibility/fallback: rejected because provider behavior
  would become policy and hide mixed-version failure.
- Plan all M18 concerns in one undifferentiated gate: rejected because identity,
  evidence, failure, security, conformance and acceptance need separate owners.
- Begin Product integration after M17: rejected because Platform remains active
  through M22.

## Consequences

Integration proceeds more slowly and requires separate evidence/acceptance per
capability. The cost buys auditable composition, failure isolation, replaceable
infrastructure and stable frozen-domain semantics. Gaps return to governance or
amendment rather than silent coupling.

## Compatibility and Migration

M18.0 changes no runtime contract, schema, adapter, data or artifact. Future
integration prefers unchanged/additive compatible contracts; explicit adapters
or upcasters require owner authority and cannot invent semantics. Breaking
change requires amendment, migration window, staged validation, last-known-good
identity and rollback/forward repair.

## Security, Privacy, and Provenance

Future evidence binds source/freeze/contracts/candidate, producer/consumer,
owner/authority, data classification, access purpose, tool/rule/provider,
inputs/results and rollback. Secrets, raw Evidence and unnecessary player data
are excluded. Consent, retention, erasure and audit remain with source owners.

## Enforcement

Exact-file scope, predecessor acceptance, public dependency checks,
compatibility/replay evidence, positive/negative/failure tests, rollback,
security/privacy review, protected freezes, Architecture Fitness, generated
integrity, clean diff and PO acceptance block violations. Tooling cannot infer
integration or Product approval.

## Exceptions

None.

