# ADR-003: M4 Intelligence Sequencing After Foundation Freeze

**Status:** Accepted

**Date:** 2026-07-21

**Owners:** Product Owner, Architecture

**Supersedes:** None

**Superseded by:** None

## Context

M1-M3 establish deterministic Knowledge, Learning, Coach, and AI boundary
foundations. M3 is frozen at commit `576b18b` with baseline index
`architecture/milestones/M3_FOUNDATION_BASELINE_MANIFEST.json`. The next work
must add Intelligence capabilities without redesigning those boundaries.

## Decision

Plan M4 as an acyclic sequence: planning, adaptive recommendation, structured
trace, session composition, execution coordination, outcome evaluation,
adaptation, and only then AI runtime activation. Trace is an auditability layer,
so it precedes all session and adaptive reasoning. Each capability consumes public M3
ports, proves its own deterministic DoD, and requires Product Owner acceptance
before the next capability opens.

AI runtime activation is an optional consumer of the deterministic pipeline. It
cannot bypass Planning, Recommendation, or Execution and cannot become a source
of truth.

This ADR is Proposed until the Product Owner accepts the M4 planning package.
It authorizes planning only, not implementation or new contracts.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 4: Domain Ownership"
    - "Section 5: Dependency Rules"
    - "Section 6: Contract Constitution"
    - "Section 14: Decision Trace and Alternatives"
    - "Section 17: Explicit Prohibitions"
    - "Section 20: Governance and Amendments"
parentAdrs: []
contracts:
  - id: m3.foundation.baseline
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: architecture/milestones/m3_freeze/proof_record.json
    status: retained
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests: []
productionSignals:
  - metric: not_available
    owner: Product Owner / Architecture
    plan: Define signals per M4 capability before production rollout.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

As of 2026-07-21, M3 freeze evidence passes: 14 contracts, 0 dependency cycles,
freeze tests 4/4, app tests 325/325, Knowledge tests 75/75, and Architecture
Fitness 133 existing / 0 new. M4 planning has no production evidence yet.

## Alternatives Considered

- Start with LLM integration: rejected because deterministic Coach behavior and
  traceability must remain independently useful.
- Build a monolithic Intelligence service: rejected because it would duplicate
  ownership and obscure capability-level dependencies.
- Change M3 contracts first: rejected because M3 is frozen; gaps require a
  separate governed extension or defect decision.

## Consequences

The sequence makes deterministic feedback and explanation prerequisites for AI,
reduces provider coupling, and keeps rollback at capability boundaries. It adds
planning overhead and requires separate acceptance evidence for each milestone.

## Compatibility and Migration

No migration occurs in M4.0. Future additions must be additive and compatible
with the M3 baseline, with explicit versioning, provenance, and upcasters only
if a Product Owner-approved contract gap exists.

## Security, Privacy, and Provenance

No new data is collected or transmitted by M4.0. Future AI activation must use
AISession only, preserve provenance, and keep Evidence/Event Log outside the AI
boundary.

## Enforcement

- Reject M4 implementation before this ADR and the planning package are
  accepted.
- Run architecture fitness and protected-artifact checks for every capability.
- Require deterministic replay, compatibility, and Decision Trace evidence.

## Exceptions

None.
