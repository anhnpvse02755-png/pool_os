# ADR-011: Infrastructure and Adapter Architecture

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Application Runtime, Infrastructure Adapters, and Release Governance
**Supersedes:** None
**Superseded by:** None

## Context

M3-M11 provide frozen deterministic domain, Runtime, Product, AI boundary, and
production-application composition foundations. Pool OS now needs concrete
Flutter, configuration, persistence, transport, AI provider, observability,
packaging, and deployment mechanisms without moving truth or policy into those
mechanisms or exposing framework types to frozen contracts.

## Decision

Organize infrastructure implementation as M12.1-M12.8. Each mechanism is an
outward adapter behind a frozen public contract or port. Configuration is the
first dependency; Flutter and the other mechanism adapters remain independently
owned; integration validation is last and has no production effect. Adapters
translate and perform explicitly authorized external effects only. They never
own Knowledge, Evidence, Learning, Coach, Product, Runtime, or AI semantics.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 2 System Model"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 6 Contract Constitution"
    - "Section 7 Versioning and Provenance"
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-009
  - ADR-010
contracts:
  - id: m3-m11.frozen-public-contracts
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m11_foundation_freeze_test.dart
    status: passing
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: app/test/m12_infrastructure_integration_validation_test.dart
    status: planned
productionSignals:
  - metric: adapter_compatibility_rejections
    owner: runtime-operations
    plan: Add before external adapter activation.
  - metric: external_effect_failures
    owner: infrastructure-operations
    plan: Add before production exposure.
  - metric: deployment_gate_rejections
    owner: release-governance
    plan: Add before deployment execution.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

Planning evidence on 2026-07-22 starts from the accepted M11 freeze: 8 sources,
42 public symbols, 6 dependency edges, 0 cycles, and contract-set digest
`0f62c5453e4b90ad878dbaef0ae478f3105b1abbe66f85164c81a1700b82ca2d`.
M12 implementation and production signals are unavailable until each capability
receives explicit authorization.

## Alternatives Considered

- Let Flutter or provider frameworks drive application architecture: rejected
  because frameworks are replaceable adapters and cannot own domain policy.
- Share storage schemas or SDK models across domains: rejected because this
  bypasses versioned public ports and couples truth to mechanisms.
- Implement all adapters in one infrastructure service: rejected because effect,
  security, ownership, and compatibility boundaries would become implicit.
- Extract adapters into microservices now: rejected because the modular monolith
  remains authoritative without operational evidence for extraction.
- Implement adapters during planning: rejected because executable scopes,
  failure semantics, and effect ownership require separate approval.

## Consequences

External technologies can be replaced behind stable ports, business ownership
remains explicit, and effects can be audited and tested independently. Costs
include mapping code, compatibility gates, secret handling, effect-specific
cleanup/rollback, and cross-adapter integration proofs before production use.

## Compatibility and Migration

M12.0 is additive documentation and changes no frozen contract. Adapter-specific
DTOs and schemas remain private and require explicit upcasters or migrations when
their public contract meaning changes. Breaking public changes require SemVer,
the accepted contract migration process, and Product Owner approval. No data,
provider, deployment, or application migration is authorized by this ADR.

## Security, Privacy, and Provenance

Secrets remain inside owning configuration/provider/deployment adapters and are
excluded from public digests and diagnostics. Persistence and transport enforce
data minimization, authorization, retention, and erasure at their boundaries.
All adapter outputs retain required semantic identity, source versions, digests,
and provenance. Raw Evidence is never sent to AI outside an approved AI boundary.

## Enforcement

- M12 capability graph must contain eight nodes and zero cycles.
- Protected M3-M11 freeze suites must pass unchanged.
- Architecture Fitness must introduce zero new violations.
- No framework, database, protocol, provider, or telemetry type may enter a
  deterministic public contract.
- Infrastructure imports public contracts/ports only, never another domain's
  persistence or internal implementation.
- Flutter may not infer Mastery, decisions, plans, or recommendations.
- AI provider adapters may not own Coach, Planner, Learning, or AI policy.
- External effects require explicit authorization and fail-closed compatibility,
  identity, provenance, and release gates.
- No M12 implementation begins before Product Owner approval of its executable
  scope.

## Exceptions

None.

