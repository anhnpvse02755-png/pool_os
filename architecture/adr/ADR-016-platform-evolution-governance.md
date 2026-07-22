# ADR-016: Platform Evolution Governance

**Status:** Proposed  
**Date:** 2026-07-22  
**Owners:** Product Owner, Architecture, Contract Owners, Platform  
**Supersedes:** None  
**Superseded by:** None

## Context

M16 completed and froze the production-readiness implementation foundation.
The authoritative roadmap keeps Platform/Foundation work active through M22
and defers Product capability planning until afterward. A durable decision is
needed to prevent the remaining platform milestones from weakening frozen
contracts, allowing extensions to absorb domain policy, or treating planning as
implementation authority.

## Decision

Pool OS will evolve the platform from M17 through M22 as a dependency-ordered,
separately authorized program: contract evolution governance, extension
boundaries, migration and portability governance, conformance certification,
foundation stabilization, then final platform validation and freeze. Every
change preserves M16 freeze identity and public ownership boundaries, fails
closed on incompatibility, and carries explicit evidence and rollback.
Product work starts only after M22 is Accepted, Closed and repository-pushed.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 1.4 Constitutional invariants and evolvable mechanisms"
    - "Section 1.5 Normative authority and architecture evidence"
    - "Section 5 Dependency Rules"
    - "Section 20 Enforcement and amendment"
parentAdrs:
  - ADR-015-production-implementation-execution-governance
contracts:
  - id: m16.foundation.freeze
    version: 1
  - id: platform.m17-m22.evolution-plan
    version: 1
```

An ADR cannot grant itself authority that conflicts with the Constitution.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m16_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
integrationTests:
  - path: planned/M17-M22-platform-evolution-evidence
    status: planned
productionSignals:
  - metric: platform_evolution_conformance
    owner: Architecture
    plan: Bind future conformance results to exact freeze, contract, source, owner and authority identities.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M16.1-M16.8 and the M16 Foundation Freeze were accepted, closed and pushed on
2026-07-22. The retained baseline is focused M16 Freeze 4/4, full app 945/945,
Knowledge 75/75, protected M3-M15 freeze 48/48 and Architecture Fitness 133
existing / 0 new. No M17-M22 implementation or Product capability is
authorized; this ADR remains Proposed.

## Alternatives Considered

- Start Product planning at M17: rejected because it conflicts with the
  authoritative Platform M1-M22 delivery order.
- Treat the M16 freeze as the final platform freeze: rejected because the
  Product Owner explicitly reserves M17-M22 for platform completion.
- Permit each extension to define compatibility locally: rejected because it
  fragments contract ownership and makes provider behavior normative.
- Combine M17-M22 into one implementation scope: rejected because dependency,
  ownership, evidence and rollback gates would become inseparable.

## Consequences

Platform completion takes longer and requires separate acceptance at every
milestone. In return, contract evolution, extensions, migrations and final
freeze remain auditable, provider-neutral and compatible with frozen M3-M16.
Product work receives a stable boundary rather than driving architecture by
accident.

## Compatibility and Migration

M17.0 changes no runtime contract, schema, adapter, data or generated artifact.
Future changes prefer additive compatible extension. Deprecation requires an
owned compatibility window. Breaking change requires constitutional amendment,
explicit migration/upcast strategy, staged validation, last-known-good
identity and rollback or forward repair. Mixed or stale identities fail closed.

## Security, Privacy, and Provenance

Evolution evidence binds source, freeze, contract, owner, authority and result
identities. It excludes secrets, raw Evidence and unnecessary player data.
Extensions cannot broaden data access through infrastructure. Retention,
erasure, consent and audit remain with the owning domains and accepted policy.

## Enforcement

Exact-file authorization, predecessor acceptance, public dependency checks,
compatibility and negative tests, deterministic replay/digest proof, protected
freeze regression, Architecture Fitness, generated/protected artifact checks,
clean diff and explicit Product Owner acceptance block violations. Planning and
ADRs never authorize implementation by themselves.

## Exceptions

None.

