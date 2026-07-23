# P1.3 Product Data Model & State Ownership Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define the logical Product data architecture, aggregate boundaries and state
ownership without creating runtime types or persistence. P1.3 is subordinate to
P1.1, P1.2 and the immutable M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Modeling Rules

- Every entity has one stable semantic identity and one authoritative owner.
- Every mutable state transition has exactly one writer.
- Cross-aggregate links are immutable typed identity/version references, never
  shared object graphs or foreign persistence access.
- Owner-produced projections are read-only and rebuildable by consumers.
- Platform entities remain Platform-owned; Product may retain compatible
  references or projections but cannot copy authority.
- This document specifies logical models, not Dart classes, tables or schemas.

## Canonical Entity And Aggregate Map

| Logical entity | Aggregate boundary | Authoritative owner | Product state authority |
|---|---|---|---|
| User | User | User & Identity | Product account/access lifecycle reference |
| Player | Player reference/projection | Platform Player domain | Reference and Product display projection only |
| Configuration | Configuration | Settings / Configuration | Versioned Product preferences/configuration |
| Match | Match | Match Management | Match lifecycle and participant references |
| Rack / Game Session | Child entity of Match | Match Management | Rack lifecycle; score data remains Scoring-owned |
| Training Session | Training Session | Training | Training workflow and accepted target references |
| Exercise | Knowledge definition plus Training assignment reference | Platform Knowledge / Training respectively | Assignment/reference only; definition remains Knowledge-owned |
| Knowledge Reference | Immutable value reference | Platform Knowledge | No Product-authored Knowledge state |
| Evidence Record | Evidence aggregate/reference | Platform Evidence | Product capture request/reference; facts/custody remain Evidence-owned |
| Simulation Scenario | Simulation Scenario | Platform Simulation | Scenario/request/result under Simulation contract |
| Performance Snapshot | Performance projection | Performance Analytics | Rebuildable derived projection only |
| Coach Session | Coach Session | AI Coach Product owner | Boundary request/response lifecycle; no generated truth authority |

## Identity Rules

Identities are opaque, stable and never derived from display names, ordering,
timestamps or mutable attributes. Every cross-boundary reference binds entity ID,
contract/schema version and required provenance/digest. Compound identities are
canonical tuples declared by the owner; consumers cannot invent aliases.

User ID and Player ID are distinct. Association is explicit, versioned and does
not transfer Player Model ownership. Match ID and Rack ID remain stable across
projection rebuild. Knowledge/Evidence/Simulation references include their
owner-issued identity and version/digest where required.

## Aggregate Boundaries

### User

Protects Product account/access reference lifecycle. Identity provider secrets,
credentials and Platform security semantics are outside the aggregate.

### Configuration

Protects one versioned Product configuration scope. Domain rules and deployment
configuration cannot be stored as user settings.

### Match

Protects match lifecycle, participants and ordered Rack identities. A Rack/Game
Session is a Match-owned child whose mutations occur through Match commands.
Scoring owns score ledger/state and exposes immutable score projections to Match.

### Training Session

Protects training lifecycle and immutable references to Player, exercises,
eligibility and Simulation results. It never recomputes Learning prerequisites,
unlock or availability.

### Coach Session

Protects Product boundary lifecycle binding one AISession/request envelope to
structured response records. It cannot mutate AISession, Coach deterministic
contracts or generated content after capture.

### External Owner Aggregates

Player, Knowledge definition/publication, Evidence Record and Simulation Scenario
remain governed by their Platform aggregates. Product stores typed references or
owner-produced projections, not local replicas with write authority.

### Performance Snapshot

Is a versioned immutable read model built from accepted owner projections. A new
snapshot supersedes rather than mutates an older snapshot. Source correction
causes rebuild/invalidation under source provenance; Analytics never rewrites it.

## Attribute Mutability

Immutable after creation: entity identity, owner, creation provenance, semantic
type and origin contract. Version-bound references are replaced by new reference
versions, not edited in place.

Owner-mutable through typed commands: Product lifecycle state, allowed display
metadata and owner-specific associations explicitly listed by a future contract.
Every mutation validates current version/state and emits owner evidence.

Append-only: Evidence facts/corrections, score history, lifecycle transition
history, Coach execution/session records and provenance lineage, subject to their
accepted owning contracts. P1.3 does not introduce event sourcing.

## Lifecycle Planning

| Entity | Logical lifecycle |
|---|---|
| User | invited -> active -> suspended or closed |
| Player reference | referenced -> active -> inactive or archived |
| Configuration | draft -> active -> superseded -> retired |
| Match | draft -> scheduled -> active -> completed or cancelled |
| Rack / Game Session | pending -> active -> completed or voided |
| Training Session | planned -> active -> completed or cancelled |
| Exercise/Knowledge reference | resolved -> stale -> superseded or unavailable |
| Coach Session | prepared -> active -> completed, failed or cancelled |
| Performance Snapshot | materialized -> superseded or invalidated |
| Evidence Record reference | referenced -> superseded/corrected by owner lineage |
| Simulation Scenario | defined -> validated -> executed -> superseded or invalidated |

These states are planning vocabulary only. Later contracts must validate exact
transitions against accepted Platform semantics and may narrow, but not silently
widen, authority.

## Mutation And Consumer Rules

| State | Sole writer | Read-only consumers |
|---|---|---|
| User access/reference | User & Identity | Application and authorized capabilities |
| Product configuration | Settings / Configuration | Product capability composition |
| Match/Rack lifecycle | Match Management | Scoring, Analytics, Experience |
| Score ledger/state | Scoring | Match projection, Analytics, Experience |
| Training lifecycle | Training | Analytics, Experience, AI-session composition |
| Published Knowledge | Platform Knowledge | Knowledge integration and authorized projections |
| Evidence fact/custody | Platform Evidence | Training/Analytics owner-produced projections |
| Simulation scenario/result | Platform Simulation | Training and Experience through public contracts |
| Performance snapshot | Performance Analytics | Experience and AI-session composition |
| Coach boundary record | AI Coach | Experience and audit consumers |

No consumer writes through a projection or uses a foreign repository. A desired
change is a command to the owner; acceptance is not assumed.

## Read Models And Projections

Read models declare source contract IDs/versions/digests, projection version,
builder owner, canonical inputs and rebuild policy. They are immutable at a
version and never accepted as authoritative writes. Match view, scoreboard,
training progress, effective configuration, Performance Snapshot and Coach view
are projected by their accountable owners or Application composition.

Projection failure, mixed provenance or missing source state fails closed. Cache
presence, age or transport success cannot establish validity.

## Cross-Capability References

References carry only required identity/version/provenance and never embed a
foreign aggregate. Deletion/retention follows the source owner's policy;
consumers react through tombstone, unavailable or supersession semantics defined
by future contracts. No cascade across owners is implicit.

Reference resolution occurs through public query ports. Product cannot resolve
Knowledge compiler internals, Evidence storage or Player persistence directly.

## Versioning And Logical Persistence Responsibility

Entity schema versions and contract versions are explicit and independently
tracked. Compatible readers may accept declared ranges; writers emit one exact
current version. Breaking changes require migration, rollback and evidence.

Logical persistence belongs to the authoritative owner. Repository technology,
database topology, tables, serialization, caching, synchronization, retention
mechanisms and event sourcing are deliberately unspecified and require later
authorization.

## Implementation Sequencing

1. Authorize identity/reference primitives and version rules.
2. Authorize aggregate contracts in P1.2 dependency order.
3. Implement single-writer command paths before consumer projections.
4. Implement rebuildable read models only after source contracts stabilize.
5. Add logical persistence ports before selecting persistence technology.
6. Validate cross-reference compatibility and owner correction/rebuild flows.

## Fail-Closed Governance

Reject missing/duplicate identity, multiple writers, embedded foreign aggregates,
projection writes, stale/mixed provenance, unversioned references, implicit
cascade, Platform ownership duplication and persistence-driven domain models.

## Definition Of Done

- Required logical entities and aggregate boundaries are defined.
- Identity, lifecycle, mutable/immutable and single-writer rules are explicit.
- Read-model/projection and cross-capability reference governance is explicit.
- Logical persistence and versioning responsibility are assigned without design
  or implementation of persistence.
- P1.1, P1.2 and M22 compatibility are preserved.
- ADR-025 remains Proposed and no runtime implementation exists.
- Exactly the four authorized P1.3 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.3 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
