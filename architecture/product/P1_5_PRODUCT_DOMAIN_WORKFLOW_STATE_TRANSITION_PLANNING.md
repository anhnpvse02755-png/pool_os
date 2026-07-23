# P1.5 Product Domain Workflow & State Transition Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define logical lifecycle and transition semantics for Product-owned aggregates
and Product request/reference workflows without implementing state machines.
P1.5 preserves P1.1-P1.4 and the immutable M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Transition Contract

Every planned transition declares aggregate identity, owner, command identity and
version, current state/version, target state, actor/access-context reference,
idempotency/correlation/causation identity, preconditions, owner result/event
reference, timestamp/ordering metadata and provenance. A transition is accepted
only by the authoritative aggregate owner.

Invalid, stale, unauthorized, duplicate-mismatched or incompatible commands are
rejected and leave state/history unchanged. Accepted transitions append an
immutable transition record; P1.5 does not prescribe event sourcing or storage.

## Match Lifecycle

Owner: Match Management. Terminal states: `completed`, `cancelled`.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | create match | draft | unique ID; valid participant references | match created |
| draft | schedule match | scheduled | schedule and participants valid | match scheduled |
| draft | cancel match | cancelled | authorized cancellation reason | match cancelled |
| scheduled | start match | active | schedule eligible; participants resolved | match started |
| scheduled | cancel match | cancelled | no active Rack; reason present | match cancelled |
| active | complete match | completed | all required Racks terminal; score projection compatible | match completed |
| active | cancel match | cancelled | explicit exceptional reason and policy authority | match cancelled |

Match cannot own or mutate score state. Completion binds an immutable compatible
Scoring projection reference; it does not copy the score ledger.

## Rack / Game Session Lifecycle

Owner: Match Management within one Match aggregate. Terminal states: `completed`,
`voided`.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | add rack | pending | parent Match is draft/scheduled/active; unique Rack ID | rack added |
| pending | start rack | active | parent Match active; no conflicting active Rack | rack started |
| pending | void rack | voided | reason present; no accepted scoring activity | rack voided |
| active | complete rack | completed | compatible terminal score reference | rack completed |
| active | void rack | voided | exceptional policy authority and reason | rack voided |

Rack transition ordering is scoped by parent Match. Completing/cancelling Match
cannot silently terminalize a non-terminal Rack; explicit Rack transitions occur
first in deterministic order.

## Training Session Lifecycle

Owner: Training. Terminal states: `completed`, `cancelled`.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | plan training | planned | Player and eligible target references compatible | training planned |
| planned | start training | active | plan current; eligibility/Knowledge references valid | training started |
| planned | cancel training | cancelled | cancellation reason present | training cancelled |
| active | complete training | completed | required session outputs/references present | training completed |
| active | cancel training | cancelled | cancellation reason and partial result references recorded | training cancelled |

Training never recomputes prerequisite/unlock/availability. Stale eligibility
rejects start and requires a newly planned session or explicit plan supersession.

## Coach Session Lifecycle

Owner: AI Coach Product boundary. Terminal states: `completed`, `failed`,
`cancelled`.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | prepare Coach session | prepared | unique ID; compatible AISession digest | Coach session prepared |
| prepared | execute Coach session | active | AISession unchanged; capability/provider compatible | Coach execution started |
| prepared | cancel Coach session | cancelled | reason present | Coach session cancelled |
| active | accept structured response | completed | response binds AISession/request and passes contract gate | Coach session completed |
| active | record execution failure | failed | typed provider/adapter failure reference | Coach session failed |
| active | cancel Coach session | cancelled | cancellation authority; no accepted response | Coach session cancelled |

Retry creates a new execution attempt/request identity under an explicit later
policy; it does not reopen terminal state or mutate generated response content.

## Performance Snapshot Generation Lifecycle

Owner: Performance Analytics. Terminal request states: `materialized`, `failed`,
`cancelled`; materialized snapshot may later be `superseded` or `invalidated` by
a new owner transition.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | request snapshot | requested | canonical source references/version set | snapshot requested |
| requested | begin build | building | sources resolved and compatible | snapshot build started |
| requested | cancel request | cancelled | no build committed | snapshot request cancelled |
| building | materialize snapshot | materialized | deterministic projection/digest complete | snapshot materialized |
| building | record build failure | failed | typed source/build failure | snapshot build failed |
| materialized | supersede snapshot | superseded | newer accepted snapshot covers same scope | snapshot superseded |
| materialized | invalidate snapshot | invalidated | source correction/incompatibility evidence | snapshot invalidated |

Rebuild creates a new request and snapshot identity. Existing materialized data
is never rewritten.

## Configuration Lifecycle

Owner: Settings / Configuration. Terminal states: `discarded`, `superseded`,
`retired`.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | create configuration draft | draft | unique ID/version and valid scope | configuration drafted |
| draft | activate configuration | active | values valid; no conflicting active version | configuration activated |
| draft | discard configuration | discarded | never active | configuration discarded |
| active | supersede configuration | superseded | compatible successor activated atomically by owner | configuration superseded |
| active | retire configuration | retired | explicit retirement authority and fallback policy | configuration retired |

Configuration activation cannot redefine domain, security or infrastructure
policy. Historical versions and provenance remain immutable.

## User / Profile Lifecycle

Owner: User & Identity Product capability for Product profile/access references.
Terminal state: `closed`.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | invite/create Product profile | invited | unique User ID; accepted identity reference | profile invited |
| invited | activate profile | active | identity/access decision accepted | profile activated |
| invited | close profile | closed | closure authority and retention disposition | profile closed |
| active | suspend profile | suspended | security/owner decision reference | profile suspended |
| active | close profile | closed | closure authority and retention disposition | profile closed |
| suspended | reactivate profile | active | new accepted access decision | profile reactivated |
| suspended | close profile | closed | closure authority and retention disposition | profile closed |

Product lifecycle does not alter Platform Player identity/model or credential
provider state.

## Simulation Request Lifecycle

Owner: Product Simulation Invocation for request tracking; Platform Simulation
owns scenario/result semantics. Terminal request states: `completed`, `failed`,
`cancelled`, `rejected`.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | prepare simulation request | prepared | compatible scenario/version reference | request prepared |
| prepared | submit request | submitted | authorization and canonical request valid | request submitted |
| prepared | cancel request | cancelled | not submitted | request cancelled |
| submitted | accept Platform receipt | accepted | receipt binds request/version | request accepted |
| submitted | record Platform rejection | rejected | typed rejection reference | request rejected |
| accepted | bind simulation result | completed | result binds request/scenario/digest | request completed |
| accepted | record simulation failure | failed | typed Platform failure reference | request failed |
| accepted | cancel request | cancelled | Platform cancellation acceptance reference | request cancelled |

Product never edits a Platform Simulation Scenario or result. Timeout/retry
mechanisms are not defined here.

## Evidence Recording Reference Lifecycle

Owner: Product Evidence Recording for request/reference tracking; Platform
Evidence owns facts, custody and correction lineage. Terminal request states:
`recorded`, `rejected`, `cancelled`; recorded references may become `superseded`
only through owner-issued correction/supersession evidence.

| From | Command | To | Preconditions | Resulting logical event |
|---|---|---|---|---|
| none | prepare observation request | prepared | canonical observation/custody provenance | observation prepared |
| prepared | submit to Evidence owner | submitted | authorization, purpose and provenance valid | observation submitted |
| prepared | cancel request | cancelled | not submitted | observation cancelled |
| submitted | bind Evidence record | recorded | owner receipt/record identity matches request | Evidence reference recorded |
| submitted | record rejection | rejected | typed owner rejection reference | Evidence request rejected |
| recorded | bind owner correction | superseded | owner-issued correction lineage/reference | Evidence reference superseded |

Product cannot edit, delete, validate or infer from an Evidence fact through this
lifecycle. A correction request is a new owner command, not mutation of history.

## Concurrency Version And Idempotency Assumptions

Every command binds expected aggregate version and idempotency key. The owner
serializes logical transitions for one aggregate and rejects stale expected
versions. No lock, transaction mechanism or concurrency implementation is
selected. Concurrent commands have a deterministic owner-defined order; losers
receive typed conflict/stale failures.

Replaying the same key with identical canonical command and starting version
returns/references the same disposition. Reusing it with changed semantics fails.
Commands against terminal state are rejected unless an explicit transition above
exists (snapshot supersession/invalidation and Evidence reference supersession).

## Cross-Capability Synchronization

P1.4 Application orchestration sequences owner transitions by declared
dependency. It waits for immutable accepted owner result/event references before
invoking the next command. It never changes two owners in one implicit
transaction. Later failure produces partial workflow state and optional explicit
compensation commands; history is not erased.

## Failure Recovery And Cancellation

Failure before owner acceptance changes no aggregate state. Failure after one or
more owner commits records partial progress. Recovery resumes from committed
references with a new authorized command or starts a new aggregate/request;
terminal states are not reopened. Cancellation is allowed only in listed states,
records a reason and does not undo completed external facts.

## Definition Of Done

- Required aggregate/request/reference lifecycles are defined.
- Valid/prohibited transitions, owners, commands, pre/postconditions and logical
  events are explicit.
- Immutable/terminal, cancellation, failure, recovery, replay, idempotency and
  logical concurrency rules are documented.
- Cross-capability synchronization remains deterministic orchestration only.
- Platform-owned entity lifecycles remain untouched.
- ADR-027 remains Proposed; no runtime implementation exists.
- Exactly the four authorized P1.5 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.5 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
