# P1.4 Product Public Application Services & Use Case Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define the logical Product application service layer and public use-case
boundaries without implementing services or runtime behavior. P1.4 preserves
P1.1-P1.3 and the immutable M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Application Layer Responsibility

Application services coordinate authenticated/authorized use-case intent across
accepted public capability contracts. They define processing order, request
scope, idempotency and failure propagation. They do not own business rules,
aggregates, domain truth, persistence, Platform semantics or presentation state.

An application service may normalize an envelope, invoke policy/validation ports,
send a typed command to one owner, query immutable projections and compose an
output. It cannot mutate foreign state, inspect internal persistence or convert a
failed dependency into synthetic success.

## Public Logical Services

| Service | Command use cases | Query use cases | Authoritative capability |
|---|---|---|---|
| User/Profile Application Service | establish/update Product profile association; request access-state change | get user/profile/access context | User & Identity |
| Configuration Application Service | create/supersede Product preference version | get effective configuration | Settings / Configuration |
| Match Application Service | create/schedule/start/complete/cancel match; start/complete/void rack | get match/match list | Match Management |
| Scoring Application Service | record/correct accepted score transition | get scoreboard/score history | Scoring |
| Training Application Service | plan/start/complete/cancel training session; bind eligible exercise | get training session/progress | Training |
| Knowledge Consumption Service | none against authoring; request accepted reference resolution | query published Knowledge projection/reference | Platform Knowledge through Product integration |
| Evidence Recording Service | submit observed fact/correction request with custody | resolve Evidence reference/status | Platform Evidence |
| Simulation Invocation Service | submit deterministic scenario request | get version-bound result/status | Platform Simulation |
| Performance Analytics Service | request projection rebuild/invalidation | get performance snapshot | Performance Analytics |
| AI Coach Application Service | prepare/execute/cancel Coach boundary session | get Coach session/structured response | AI Coach through AISession/CoachResponse |

Names and operations are planning vocabulary. They do not create classes,
methods, endpoints, routes or concrete contracts.

## Use-Case Boundary

Each use case declares one application-service owner, request identity,
correlation and idempotency identity, actor/access context, expected contract and
aggregate versions, provenance, one primary authoritative command target,
required queries, deterministic invocation order, response contract and typed
failure set.

One command changes at most one authoritative aggregate transaction. A broader
workflow is a sequence of accepted owner operations; it is not an implicit
distributed transaction. Later steps consume committed outputs from earlier
steps and never assume uncommitted foreign state.

## Commands Queries And Application Events

Commands express intent, target one owner and may be rejected. They carry no
precomputed domain decision. Queries are side-effect-free and return immutable,
versioned owner-produced projections. Command/query models are distinct.

Application events report orchestration facts such as request accepted,
dependency step completed, workflow failed or compensation requested. Domain
events remain domain-owned. An application event cannot claim that a domain
transition occurred before the owner commits it or duplicate the domain event as
a new source of truth.

Event publication follows owner commit and records source event/reference,
correlation, causation, sequence, version and provenance. P1.4 does not implement
an event bus, message broker or queue.

## Logical Input And Output Envelopes

Inputs contain request ID, use-case ID/version, actor/access-context reference,
idempotency key, correlation/causation IDs, canonical payload, expected owner
versions and provenance. Outputs contain request/use-case identity, disposition,
owner result/projection references, emitted event references, compatibility
bindings and typed failures.

Payloads are immutable and canonical. Application envelopes do not expose
internal domain objects, persistence models, provider SDK objects, raw Evidence
or Platform internals.

## Validation And Authorization Ownership

- Application boundary owns envelope shape, required fields, canonicalization,
  request duplication and declared compatibility checks.
- Capability/domain owner owns semantic validation and invariant enforcement.
- Identity/security owner owns authorization policy and decision semantics.
- Application service supplies access context and enforces the returned decision;
  it does not invent roles, permissions or authorization rules.
- Platform owner validates Platform contract/provenance compatibility.

Failure at any layer stops downstream invocation. P1.4 defines responsibility
only and implements no validator or authorization engine.

## Logical Transaction Boundaries

A single aggregate owner defines its atomic boundary. Application orchestration
does not expand that boundary across capabilities. Reads used for a command bind
their versions; the owner rejects stale assumptions. Successful mutation and its
owner event are one logical owner operation.

Cross-capability workflows record completed steps. If a later step fails, the
service returns partial-progress evidence and, where an owner has an accepted
reversal command, requests explicit compensation. Compensation is a new audited
command, never history deletion or direct rollback of another owner.

## Deterministic Orchestration Order

1. Canonicalize and validate the application envelope.
2. Resolve use-case/contract versions and reject duplicates or incompatibility.
3. Resolve actor/access context and request an authorization decision.
4. Query required immutable owner projections in declared order.
5. Verify identity, version, provenance and precondition bindings.
6. Submit the primary typed command to its authoritative owner.
7. Record the owner result and committed event references.
8. Execute declared downstream steps in stable dependency order.
9. Produce the canonical application result or typed failure/partial result.
10. Publish application event references after owner commits.

Same canonical inputs and same owner states produce the same deterministic
request plan and non-generated result envelope. External timing and transport
do not alter ordering or semantic disposition.

## Idempotency

Every mutating request carries a stable idempotency key scoped by use-case,
actor, target identity and contract version. Replaying an identical request
returns/references the same accepted result. Reusing a key with different
canonical input fails closed. Queries are naturally repeatable at an explicitly
bound projection version.

Idempotency ownership sits at the application boundary while domain transition
uniqueness remains with the domain owner. No cache or storage mechanism is
selected here.

## Failure And Compensation Semantics

Typed failures include malformed request, unauthenticated/unauthorized intent,
not found, conflict, stale version, duplicate mismatch, incompatible contract,
provenance mismatch, invariant rejection, dependency unavailable, partial
workflow and compensation rejection. Failures preserve source owner and stage.

No fallback weakens validation, changes target owner or substitutes stale data.
Retry is permitted only by a later policy and cannot change canonical intent.
Compensation requires an accepted owner command, current authorization and new
evidence; otherwise the workflow remains explicitly partial/failed.

## Platform Interaction

Knowledge, Evidence, Simulation, Player/Learning/Coach and AI capabilities are
reached only through accepted public ports/contracts. Application services never
import compiler, persistence, runtime or provider internals. AI Coach sends only
AISession and consumes only structured CoachResponse.

## Definition Of Done

- Required logical application services and use cases are defined.
- Command/query/event and logical I/O boundaries are explicit.
- Orchestration is separated from business-rule/state ownership.
- Logical validation, authorization, transaction, idempotency and compensation
  responsibilities are defined.
- Deterministic ordering and fail-closed Platform interaction are documented.
- P1.1-P1.3 and M22 governance remain unchanged.
- ADR-026 remains Proposed; no runtime implementation exists.
- Exactly the four authorized P1.4 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.4 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
