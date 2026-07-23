# ADR-025: Product Data Model And State Ownership

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Capability Owners, Platform Domain Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.1 defined runtime boundaries and P1.2 defined business capabilities. Product
implementation needs logical aggregate and state ownership rules before runtime
types or persistence can be safely authorized.

## Decision

Define User, Player reference, Configuration, Match, Rack/Game Session, Training
Session, Exercise/reference, Knowledge Reference, Evidence Record/reference,
Simulation Scenario, Performance Snapshot and Coach Session as logical models.
Every mutable state has one authoritative writer; cross-owner relationships are
typed versioned references; read models are immutable and rebuildable.

Player, Knowledge, Evidence and Simulation remain Platform-owned. Product owns
only explicitly authorized references, projections and Product lifecycles. This
ADR selects no persistence mechanism and grants no implementation authority.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 1.5 Normative authority and architecture evidence"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-022-product-implementation-governance
  - ADR-023-product-runtime-architecture
  - ADR-024-product-domain-capabilities
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.logical.data-model
    version: 1
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m22_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
  - ruleId: product_entity_single_writer
    status: planned
  - ruleId: product_projection_read_only
    status: planned
integrationTests:
  - path: planned/product-data-ownership-contract-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Database-first entities: rejected; storage technology would dictate ownership
  and domain boundaries before contracts exist.
- Shared mutable canonical model: rejected; it creates multiple writers and
  transitive coupling.
- Copy Platform entities into Product: rejected; it creates competing sources of
  truth and loses correction/provenance lineage.
- Make every entity an aggregate: rejected; transactional and lifecycle
  boundaries would be artificial.

## Consequences

Future persistence and runtime work receives explicit aggregate and writer
boundaries. Consumers must resolve typed references and rebuild projections,
which adds deliberate coordination but prevents hidden cross-domain mutation.

## Compatibility And Migration

P1.3 changes no contract or stored data. Future schemas must preserve identity,
version and provenance rules. Breaking evolution needs a new version, migration,
rollback, owner approval and evidence. Platform changes require upstream authority.

## Security Privacy And Provenance

Entities expose only purpose-required references. Identity, Evidence and player
data retain source custody, access classification, retention/erasure lineage and
provenance. Derived views cannot broaden access to their sources.

## Enforcement

Single-writer review, aggregate/reference tests, projection rebuild tests,
version/provenance gates, Architecture Fitness, protected freezes, exact scope
and independent verification fail closed.

## Exceptions

None.
