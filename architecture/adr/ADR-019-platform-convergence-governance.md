# ADR-019: Platform Convergence Governance

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Product Owner, Architecture, Platform, Domain Owners, Contract Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

M19 validated and froze platform planning. M20 must converge accepted platform
declarations and stabilize public architecture before M21 without confusing
document consistency, passing tests or technical completion with semantic and
governance acceptance. The affected ownership spans Architecture, Knowledge,
Evidence, Intelligence, Simulation, Experience, infrastructure boundaries and
their public contracts. No runtime contract changes in M20.0.

## Decision

Pool OS will govern platform convergence through eight separately authorized,
dependency-ordered M20 capabilities. Every candidate binds the exact M19 Freeze,
public contracts/boundaries, domain and contract owners, compatibility rules,
canonical evidence, gaps/exceptions, replay and recovery identity. Convergence
cannot centralize domain meaning, expose internals, alter a freeze or authorize
Product. Independent audit and explicit PO acceptance remain mandatory.

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
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-018-platform-validation-governance
contracts:
  - id: m19.foundation.freeze
    version: 1
  - id: platform.m20.convergence-plan
    version: 1
```

ADR-018 and ADR-019 remain Proposed and grant no implementation authority. An
ADR cannot grant itself authority that conflicts with the Constitution.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m19_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
integrationTests:
  - path: planned/M20-platform-convergence-evidence
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M19.1-M19.8 and M19 Foundation Freeze were accepted and closed on 2026-07-22.
The retained baseline is M19 Freeze 4/4, app 957/957, Knowledge 75/75, prior
protected freezes 60/60 and Architecture Fitness 133 existing / 0 new. No M20
convergence implementation or production evidence exists; this ADR remains
Proposed.

## Alternatives Considered

- Treat M19 validation as sufficient convergence: rejected because validation
  proves claims but does not reconcile convergence ownership and closure gates.
- Centralize cross-domain semantics in Platform: rejected because it violates
  constitutional domain ownership and creates a god module.
- Let each domain stabilize independently: rejected because public compatibility,
  replay, failure and freeze continuity would fragment.
- Begin Product or M21 work immediately: rejected because M20 closure and freeze
  are explicit predecessors on the authoritative roadmap.

## Consequences

Convergence adds staged owner reviews, explicit gap management and independent
audit. In return, public boundaries, compatibility, replay and operational
claims become attributable and stable before M21. Unknown or conflicting claims
remain blocked rather than becoming undocumented convention.

## Compatibility and Migration

M20.0 changes no runtime contract, schema, adapter, data or generated artifact.
Future convergence prefers unchanged/additive compatible evolution. Breaking
change requires separate authority, version/migration window, last-known-good
identity, rollback or forward repair and superseding evidence.

## Security, Privacy, and Provenance

Candidates bind exact source/freeze/contracts/rules, owners, evidence, custody,
exceptions, findings and lineage. They exclude secrets, raw Evidence and
unnecessary player data. Purpose, retention, erasure and audit remain with
source owners. Generated/provider content cannot review or publish itself.

## Enforcement

Exact-file scope, accepted predecessor, public-boundary and ownership checks,
compatibility/constitutional mapping, canonical replay, positive/negative
evidence, gap/exception lifecycle, independent audit, freeze-chain regression,
Architecture Fitness, clean diff and PO acceptance block violations. ADR-019
must remain Proposed until separately accepted.

## Exceptions

None.
