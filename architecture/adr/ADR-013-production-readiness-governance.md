# ADR-013: Production Readiness Governance

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Product Owner, Architecture, Platform, Operations, Security
**Supersedes:** None
**Superseded by:** None

## Context

M13 established and froze deterministic production-runtime boundaries without
selecting or implementing deployment infrastructure. A durable, auditable gate
is required before later milestones introduce operational mechanisms.

## Decision

Pool OS will promote immutable release candidates through evidence-gated stages.
Missing evidence fails closed. Release governance is provider-neutral; topology,
observability, recovery, security, performance, acceptance, rollout, and
rollback requirements are approved before implementation technology is chosen.
Production facts cannot amend contracts or the Constitution by accident.

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
  - ADR-012-production-behavior-implementation
contracts:
  - id: m13.foundation.freeze
    version: 1
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m13_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
integrationTests:
  - path: planned/M14-acceptance-matrix
    status: planned
productionSignals:
  - metric: release_readiness_gate
    owner: Operations
    plan: Record pass/fail and evidence links for every promoted release.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M13 Foundation Freeze was accepted on 2026-07-22 with contract-set digest
`7e11dfd665996a3e976c0c16cd3fa399848066d08ad0e36f49cb3b211a0837e5`,
protected M3-M12 suites passing, and Architecture Fitness at 133 existing / 0
new violations. Operational evidence remains planned; this ADR stays Proposed.

## Alternatives Considered

- Select infrastructure first: rejected because products would dictate policy.
- Release from test pass alone: rejected because recovery, security, capacity,
  and operational ownership would remain unproven.
- One irreversible production launch: rejected in favor of staged promotion.

## Consequences

Releases gain reproducibility, clear ownership, and safer rollback, at the cost
of evidence collection, rehearsal time, and explicit release governance.

## Compatibility and Migration

No contract or runtime migration occurs in M14.0. Later implementations must
preserve frozen M3-M13 inputs and define compatibility/rollback checkpoints.

## Security, Privacy, and Provenance

Release records bind source, artifacts, configuration schema, Knowledge and
runtime contract identities. Telemetry must exclude secrets and unnecessary
Evidence/player data. Retention and erasure remain domain-owned.

## Enforcement

Protected freeze suites, Architecture Fitness, release acceptance matrix,
restore/rollback rehearsal, security gate, and Product Owner approval must fail
promotion when required evidence is missing or incompatible.

## Exceptions

None.
