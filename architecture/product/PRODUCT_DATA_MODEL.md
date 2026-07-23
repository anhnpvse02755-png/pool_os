# Product Data Model

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Purpose And Authority

This catalog describes logical Product entities and state ownership. It is not a
database design, serialization format or implementation model. Platform owners
remain authoritative for Platform entities and contracts.

## Aggregate Relationship Model

```text
User --typed association--> Player reference (Platform-owned)
  |
  +--> Configuration

Match aggregate
  +--> Rack / Game Session child identities
  +--> participant Player references
  +--> read-only Score projection (Scoring-owned)

Training Session aggregate
  +--> Player reference
  +--> Exercise / Knowledge references (Platform-owned definitions)
  +--> Evidence references (Platform-owned facts)
  +--> Simulation result references (Simulation-owned)

Performance Snapshot (immutable rebuildable projection)
  +--> Match / Score / Training / Evidence source references

Coach Session aggregate
  +--> AISession identity/digest
  +--> structured CoachResponse records
```

Lines represent typed references, never containment across owner boundaries.

## Entity Definitions

| Entity | Identity | Immutable core | Owner-controlled mutable state |
|---|---|---|---|
| User | opaque Product user ID | ID, origin, creation provenance | account/access lifecycle reference |
| Player | Platform Player ID | ID, Platform provenance/version | Product projection refreshed from owner |
| Configuration | configuration ID + version | ID, scope, owner | values allowed by Product configuration contract |
| Match | match ID | ID, owner, creation provenance | lifecycle, participant/rack references |
| Rack / Game Session | rack ID scoped to Match | ID, parent match ID | lifecycle and ordering under Match |
| Training Session | training session ID | ID, owner, Player binding | lifecycle and accepted target/result references |
| Exercise | Knowledge ID/version plus assignment ID where used | definition reference/provenance | Training assignment state only |
| Knowledge Reference | Knowledge semantic ID/version/digest | complete reference tuple | none; supersede with a new reference |
| Evidence Record | Evidence owner ID/version/provenance | owner-issued reference | none in Product; owner correction lineage only |
| Simulation Scenario | Simulation owner scenario ID/version | owner-issued identity/provenance | Platform Simulation-owned lifecycle/result |
| Performance Snapshot | snapshot ID + projection version | ID, sources, digest, provenance | none; rebuild creates a new snapshot |
| Coach Session | Coach session ID | ID, AISession binding | Product boundary lifecycle and append-only response records |

## Invariants

1. User and Player identities are never conflated.
2. Rack is a Match child; Score is not Match-owned state.
3. Exercise assignment does not transfer Knowledge definition ownership.
4. Product Evidence references cannot mutate Evidence facts or custody.
5. Performance Snapshot is derived, immutable and rebuildable.
6. Coach Session cannot bypass AISession or treat generated output as truth.
7. References bind semantic identity, version and required provenance/digest.
8. Exactly one authoritative writer exists for every mutable state class.
9. A projection cannot become a command or persistence write model.
10. Cross-owner deletion, correction and supersession are explicit, never cascade.

## Lifecycle And Mutation

Lifecycle commands target the owning aggregate, carry expected identity/version
and fail on invalid transitions or stale state. History required by accepted
contracts is append-only. Immutable attributes are never patched; replacement or
supersession creates a new version/reference.

The planning lifecycle vocabulary is defined in the P1.3 milestone. Future
contracts own exact transition matrices. No lifecycle here authorizes code.

## Projection Catalog

| Projection | Builder/owner | Canonical sources | Rebuild trigger |
|---|---|---|---|
| Effective Configuration | Settings / Configuration | configuration versions | accepted configuration supersession |
| Match View | Match Management | Match/Rack state plus owner projections | accepted Match/Rack transition |
| Scoreboard | Scoring | score ledger/state | accepted score transition/correction |
| Training Progress | Training | training lifecycle and owner references | accepted training transition/source supersession |
| Performance Snapshot | Performance Analytics | Match, Score, Training and Evidence projections | source version/correction change |
| Coach View | AI Coach/Application | AISession and structured responses | accepted Coach boundary record |

Every projection records source identities/versions/digests and its own version.
Rebuild does not modify the source or retrospectively edit prior snapshots.

## Persistence Boundary

Each authoritative owner is logically responsible for persistence of its own
state and for exposing public persistence-neutral ports where later authorized.
Consumers store only their own state and typed foreign references. Shared
databases, foreign table reads and cross-owner transactions are not implied.

No database, SQL, Supabase, ORM, repository, cache, synchronization, event store,
retention implementation or migration is selected by this document.

## Compatibility

Identity semantics and immutable provenance survive schema evolution. Compatible
changes are additive. Breaking changes require a new version, migration and
rollback plan, affected-owner approval and evidence. Platform entity changes
require Platform authority and cannot be introduced through Product planning.

## Planning Constraint

These entities are not Dart classes, JSON schemas, database tables or API
resources. Implementation remains prohibited until an exact later milestone.
