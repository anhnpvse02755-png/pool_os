# ADR-015: Production Implementation Execution Governance

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Product Owner, Architecture, Platform, Operations, Security
**Supersedes:** None
**Superseded by:** None

## Context

M15 translated accepted M14 production-readiness governance into eight detailed
implementation plans and then froze M15.1-M15.8 with machine-verifiable proof.
The next phase may introduce real mechanisms across release identity, topology,
operations, recovery, security, performance, rollout and final authorization.
A durable rule is required so the term execution cannot bypass capability
authorization, ownership, evidence, compatibility or rollback.

## Decision

Pool OS will execute production-readiness implementation only through eight
separately authorized, dependency-ordered M16 capabilities. Every capability
must conform to its corresponding frozen M15 contract, use public boundaries,
bind exact candidate and environment identity, preserve frozen M3-M15 and
accepted M14 artifacts, fail closed on incomplete evidence, prove rollback or
disablement, and obtain explicit Product Owner acceptance before repository
closure. Infrastructure/provider mechanisms do not own business policy.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 1.5 Normative authority and architecture evidence"
    - "Section 5 Dependency Rules"
    - "Section 20 Enforcement and amendment"
parentAdrs:
  - ADR-013-production-readiness-governance
  - ADR-014-production-readiness-implementation-governance
contracts:
  - id: m15.foundation.freeze
    version: 1
  - id: m15.production-readiness-planning
    version: 1
```

An ADR cannot grant itself authority that conflicts with the Constitution.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m15_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
integrationTests:
  - path: planned/M16-capability-evidence
    status: planned
productionSignals:
  - metric: production_execution_capability_gate
    owner: Operations
    plan: Bind future mechanism outcomes to candidate, environment, evidence, rollback, and PO acceptance.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M15.0-M15.8 and M15 Foundation Freeze were accepted and closed on 2026-07-22.
The retained baseline is app 885/885, Knowledge 75/75, protected M3-M13 freeze
44/44, M15 freeze 4/4, and Architecture Fitness 133 existing / 0 new. No M16
execution mechanism or production evidence exists; this ADR remains Proposed.

## Alternatives Considered

- Treat M15 plans as direct implementation authority: rejected because planning
  acceptance does not authorize mechanism-specific files or side effects.
- Execute all mechanisms in one milestone: rejected because ownership,
  dependency evidence and rollback would be inseparable.
- Select providers before capability scope: rejected because provider products
  would define policy and create premature coupling.
- Permit dependents on engineering-complete predecessors: rejected because only
  accepted, repository-closed evidence is a stable dependency.

## Consequences

Execution is slower and requires explicit scope/evidence at every capability,
but mechanisms remain auditable, replaceable, rollback-bound and compatible
with frozen planning semantics. Coordination and evidence custody are accepted
costs. Gaps discovered by execution return to separately governed planning or
constitutional amendment rather than silent reinterpretation.

## Compatibility and Migration

M16.0 changes no runtime contract, schema, adapter, data or artifact. Each
future capability must state SemVer impact, migration/upcast strategy,
compatibility window, staged enablement, last-known-good identity, rollback or
forward repair, and invalidation triggers before editing.

## Security, Privacy, and Provenance

Future execution evidence binds source, candidate, configuration, environment,
provider, contract, owner and authority identities. Secrets, raw Evidence and
unnecessary player data are prohibited. Access, retention, erasure, audit,
incident and exception policies remain with Security/Privacy and source owners.

## Enforcement

Exact-file authorization, dependency acceptance, frozen M15 compatibility,
public-boundary checks, focused/integration/full verification, protected freeze
suites, Architecture Fitness, failure/denial evidence, rollback/disablement,
generated/protected checks, clean diff and explicit pre-commit PO acceptance
must block violations. No tool can infer production Go.

## Exceptions

None.
