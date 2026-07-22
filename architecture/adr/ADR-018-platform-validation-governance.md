# ADR-018: Platform Validation Governance

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Product Owner, Architecture, Contract Owners, Platform, Quality
**Supersedes:** None
**Superseded by:** None

## Context

M18 integrated and froze platform planning. M19 must validate that frozen
platform claims remain compatible, constitutionally compliant, deterministic
and continuous across delivery surfaces without confusing document maturity or
technical success with validation. A durable governance decision is required
before later conformance, stabilization and final M22 freeze work.

## Decision

Pool OS will validate the platform through eight separately authorized,
dependency-ordered M19 capabilities. Every claim binds the exact M18 Freeze,
surface/boundary/contracts, constitutional rules, evidence and owners; uses
deterministic replay and fail-closed compatibility/compliance gates; preserves
the M3-M18 freeze chain; and requires independent audit plus explicit PO
acceptance. Validation reports cannot amend authority or implement Product.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 1.4 Constitutional invariants and evolvable mechanisms"
    - "Section 1.5 Normative authority and architecture evidence"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 20 Enforcement and amendment"
parentAdrs:
  - ADR-017-platform-integration-governance
contracts:
  - id: m18.foundation.freeze
    version: 1
  - id: platform.m19.validation-plan
    version: 1
```

An ADR cannot grant itself authority that conflicts with the Constitution.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m18_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
integrationTests:
  - path: planned/M19-platform-validation-evidence
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M18.1-M18.8 and M18 Foundation Freeze were accepted and closed on 2026-07-22.
The retained baseline is M18 Freeze 4/4, app 953/953, Knowledge 75/75, prior
protected freezes 56/56 and Architecture Fitness 133 existing / 0 new. No M19
validation implementation or production evidence exists; this ADR remains
Proposed.

## Alternatives Considered

- Treat M18 Freeze as sufficient validation: rejected because a freeze proves
  artifact identity, not cross-surface compatibility or constitutional fitness.
- Let each surface validate locally: rejected because equivalence, provenance
  and compatibility policy would fragment.
- Infer compliance from passing tests: rejected because evidence cannot replace
  normative authority or complete claim ownership.
- Begin M20 certification immediately: rejected because M19 validation and its
  freeze are explicit predecessors.

## Consequences

Validation adds staged reviews and independent evidence work. In return,
cross-surface claims, constitutional compliance, replay and freeze continuity
become attributable and reproducible before certification or stabilization.
Unknown and conflicting claims remain blocked instead of becoming convention.

## Compatibility and Migration

M19.0 changes no runtime contract, schema, adapter, data or generated artifact.
Future validation prefers unchanged/additive compatible contracts. Breaking
change requires separate authority, migration/compatibility window,
last-known-good identity, rollback or forward repair and superseding evidence.

## Security, Privacy, and Provenance

Validation evidence binds exact source/freeze/candidate, surface, contracts,
rules, owner/authority, tool/result and lineage identities. It excludes secrets,
raw Evidence and unnecessary player data. Data purpose, retention, erasure and
audit remain with source owners; a report cannot expand access.

## Enforcement

Exact-file scope, predecessor acceptance, public-boundary and dependency checks,
compatibility/constitutional mapping, canonical replay, positive/negative
evidence, independent audit, freeze-chain regression, Architecture Fitness,
generated integrity, clean diff and PO acceptance block violations. ADR-018
remains Proposed until separately accepted.

## Exceptions

None.
