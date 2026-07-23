# P1.2 Product Domain Capability Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define the logical business capability architecture for Product implementation
without implementing behavior. P1.2 is governed by P1.1 and rooted in the M22
Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Authorized Scope

This milestone defines capability map, ownership, boundaries, responsibilities,
planned public interfaces, interactions, lifecycle, dependency and evolution
rules, and future sequencing. Capability/interface names are planning identities,
not implemented types, packages, services, APIs or persistence schemas.

## Capability Map

| Capability | Product responsibility | Accountable owner | Authoritative state/source |
|---|---|---|---|
| User & Identity | Product user identity references, access context and player binding | Identity Product owner | Accepted Identity contracts; Product identity reference state |
| Settings / Configuration | User preferences and Product-scoped configuration | Configuration Product owner | Versioned Product configuration |
| Match Management | Match identity, participants and match lifecycle coordination | Match Product owner | Match aggregate lifecycle |
| Scoring | Rules-bound score commands, score state and score projections | Scoring Product owner | Score ledger/state derived from accepted commands |
| Training | Training intent, session and progression workflow | Training Product owner | Training lifecycle; Learning truth remains Platform-owned |
| Knowledge | Product access to accepted published Knowledge | Knowledge integration owner | Platform Knowledge authoring/publication; Product stores references only |
| Evidence | Product capture/ingestion boundary for observed facts and provenance | Evidence domain owner | Evidence records and custody lineage |
| Simulation | Product requests and results for deterministic physics | Simulation domain owner | Simulation scenario/result contracts |
| Performance Analytics | Deterministic derived performance projections | Analytics Product owner | Rebuildable projections; source facts remain source-owned |
| AI Coach | AI-session orchestration and structured Coach response consumption | AI Coach Product owner | AISession/request/response records; generated output is not domain truth |

## Boundaries And Responsibilities

Each capability accepts only versioned inputs, validates provenance and produces
immutable public outputs. It may change only state that it owns. A capability
cannot reinterpret another owner's fact, projection, lifecycle or digest.

Knowledge is an integration capability, not a new authoring/compiler owner.
Evidence owns observed facts, not inference. Analytics owns rebuildable derived
views, not source facts. AI Coach consumes only the accepted AISession boundary
and emits only structured CoachResponse contracts; it cannot directly read
Evidence, Player, Knowledge internals or other deterministic internals.

## Planned Public Interfaces

| Capability | Planned input boundary | Planned output boundary |
|---|---|---|
| User & Identity | identity/access commands | immutable identity/access context |
| Settings / Configuration | version-bound setting commands | effective configuration projection |
| Match Management | match lifecycle commands | match state/events/projection |
| Scoring | score commands plus accepted match/rule identity | score events and scoreboard projection |
| Training | training lifecycle commands and eligible targets | training session/progress projection |
| Knowledge | accepted publication identity/query | immutable Knowledge projection/reference |
| Evidence | observation command with provenance/custody | append-only Evidence fact/reference |
| Simulation | deterministic scenario request | version-bound simulation result |
| Performance Analytics | accepted owner-produced projections | deterministic analytics projection |
| AI Coach | AISession contract | structured CoachResponse contract |

Actual contract IDs, versions and fields require later explicit authorization.
No table entry grants permission to create a contract or runtime interface.

## Capability Interactions

Capabilities communicate through P1.1 public contracts using typed commands,
queries, append-only events and immutable projections. Application orchestration
connects capabilities but owns no business state. Direct persistence access,
shared mutable models, internal imports, provider-specific payloads and
unversioned generic maps are prohibited.

Cross-capability messages preserve semantic IDs, versions, provenance,
compatibility and deterministic failure. Consumers retain references to owner
outputs and never copy them into a competing source of truth.

## Dependency Graph

The planned capability graph is acyclic and ordered in levels:

1. **Foundation/reference:** User & Identity, Settings / Configuration,
   Knowledge, Evidence and Simulation.
2. **Operational:** Match Management consumes Identity, Configuration and
   Knowledge; Scoring consumes Match and Knowledge; Training consumes Identity,
   Configuration, Knowledge, Evidence and Simulation.
3. **Derived:** Performance Analytics consumes owner-produced Match, Scoring,
   Training and Evidence projections.
4. **AI boundary:** AI Coach consumes an AISession composed from accepted
   deterministic projections and produces a CoachResponse.

No dependency points from an earlier level to a later level. Data returned to a
source capability is a new command or fact, not a reverse import. Platform rules
remain authoritative over every planned edge.

## Capability Lifecycle

Capability delivery follows `planned`, `contractAuthorized`, `implemented`,
`verified`, `productAccepted`, `activated`, `deprecated`, `retired` or
`rolledBack`. Transitions are append-only and evidence-bound. Planning status
cannot be inferred as implementation or activation.

Business lifecycles inside each capability require separate contracts; this
generic delivery lifecycle does not invent match, score or training semantics.

## Evolution Constraints

Compatible evolution is additive, owner-approved and preserves semantic IDs,
canonicalization and existing behavior. Breaking evolution requires a new
contract version, migration, rollback, evidence and affected-owner approval.
Product cannot change a Platform contract through a Product capability plan.

No capability may absorb another capability for convenience, move source-of-
truth state into Analytics, hide policy in Shared/Core, let AI-generated output
self-verify, or use caches/projections as authoritative facts.

## Implementation Sequencing

1. Authorize and freeze Product capability contract identities and ownership.
2. Establish domain-neutral Product runtime primitives under P1.1 constraints.
3. Implement foundation/reference capability adapters behind Platform ports.
4. Implement Match, then Scoring, then Training as separately verified slices.
5. Implement Analytics only after its source projections are stable.
6. Implement AI Coach only through accepted AISession/CoachResponse boundaries.
7. Add Experience flows after capability commands/queries are stable.

Each step requires a separate milestone with exact files and evidence. Parallel
work is permitted only where the dependency graph and ownership remain disjoint.

## Fail-Closed Governance

Reject missing owners, duplicated authoritative state, cycles, direct internal
imports, mixed contract versions, stale provenance, ambiguous writes, AI
boundary bypass, Knowledge authoring duplication or unsupported Platform edges.
Repair occurs at the accountable source; consumers do not manufacture fallback.

## Definition Of Done

- Ten Product capability categories are defined.
- Ownership, source of truth, inputs, outputs and boundaries are explicit.
- Capability interactions and dependency levels are acyclic and documented.
- Lifecycle, evolution rules and implementation sequencing are explicit.
- P1.1 and M22 compatibility are preserved.
- ADR-024 remains Proposed and no runtime implementation exists.
- Exactly the four authorized P1.2 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.2 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
