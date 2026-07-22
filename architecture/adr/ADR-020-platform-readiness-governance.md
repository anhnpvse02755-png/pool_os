# ADR-020: Platform Readiness Governance

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Architecture, Platform, Domain Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

M20 converged and froze platform planning. M21 must prove platform readiness and
prepare a Product transition boundary without starting Product before M22.

## Decision

Pool OS will govern M21 through eight separately authorized, dependency-ordered
planning capabilities rooted in M20 Freeze. Readiness is conjunctive,
source-owned, independently audited and fail-closed. Product development remains
prohibited until M22 Foundation Freeze is accepted, closed and repository-closed.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-019-platform-convergence-governance
contracts:
  - id: m20.foundation.freeze
    version: 1
  - id: platform.m21.readiness-plan
    version: 1
```

Proposed ADRs grant no implementation authority.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m20_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
integrationTests:
  - path: planned/M21-platform-readiness-evidence
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M20 and its freeze were accepted on 2026-07-23. Baseline: focused 4/4, app
961/961, Knowledge 75/75, protected 64/64, Architecture 133/0. M21 evidence is
not available; this ADR remains Proposed.

## Alternatives Considered

- Start Product after M20: rejected because M22 final validation/freeze remains.
- Let domains self-declare readiness: rejected because cross-domain/audit gates fragment.
- Treat green tests as readiness: rejected because evidence cannot replace authority.

## Consequences

M21 adds staged evidence and audit work but makes final platform readiness and
the future Product boundary explicit and attributable.

## Compatibility and Migration

M21.0 changes no runtime contract or data. Breaking evolution requires separate
authority, migration, last-known-good recovery and superseding evidence.

## Security, Privacy, and Provenance

Candidates bind exact sources, owners, evidence and lineage; secrets, raw
Evidence and unnecessary player data remain excluded.

## Enforcement

Exact scope, predecessor, ownership, compatibility, replay, operational,
freeze-chain, independent audit, Architecture Fitness, clean diff and PO gates.

## Exceptions

None.
