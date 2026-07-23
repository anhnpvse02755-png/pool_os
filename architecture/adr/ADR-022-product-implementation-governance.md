# ADR-022: Product Implementation Governance

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Platform Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

Platform M1-M22 and Foundation Freezes M3-M22 are closed. Product implementation
requires a durable governance boundary that preserves the terminal Platform
baseline while allowing separately authorized delivery work.

## Decision

Product implementation will proceed through separately authorized programs P1-
P8 rooted in the M22 terminal digest. Product depends on Platform public
contracts. Platform ownership, freezes, evidence and constitutional governance
remain immutable and cannot be superseded by Product decisions.

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
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-021-platform-final-closure-governance
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.implementation.plan
    version: 1
```

This Proposed ADR grants no implementation authority.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m22_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
integrationTests:
  - path: planned/product-implementation-contract-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M22 Freeze was accepted on 2026-07-23. Baseline: focused 4/4, app 969/969,
Knowledge 75/75, prior freezes 72/72 and Architecture 133/0. No Product
implementation evidence exists; ADR-022 remains Proposed.

## Alternatives Considered

- Continue as M23: rejected because Platform planning is terminally closed.
- Let Product modify Platform for convenience: rejected because ownership and
  freeze integrity would be lost.
- Begin features without program governance: rejected because scope, evidence,
  compatibility and rollback would be ambiguous.

## Consequences

Product delivery gains an explicit lifecycle and roadmap but each capability
requires separate authorization, evidence and acceptance. Platform changes are
slower because they require a governed upstream successor rather than local edits.

## Compatibility and Migration

P1.0 changes no runtime contract or data. Future Product work must consume
compatible public versions; breaking changes require separate Platform authority,
migration, rollback and superseding evidence.

## Security, Privacy, and Provenance

Product evidence references Platform provenance without copying authority.
Secrets, raw Evidence and unnecessary player data remain excluded. Product-
specific evidence requires explicit custody, retention and erasure governance.

## Enforcement

Exact scope, protected-freeze integrity, dependency direction, public contract
use, provenance, independent verification, Architecture Fitness, clean diff and
PO acceptance must fail closed.

## Exceptions

None.
