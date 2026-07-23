# P1.7 Product User Interaction & Command Model Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define the logical interaction boundary from user intent through Experience and
Application to an authoritative capability, without implementing UI or command
handling. P1.7 preserves P1.1-P1.6 and the immutable M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Interaction Principles

- The user owns intent; Experience captures and presents it but does not decide
  domain meaning or success.
- Queries and commands are distinct interaction types.
- A command requires explicit intent and targets one P1.4 application use case.
- Owner acceptance, not local presentation state, establishes a domain change.
- Validation, confirmation, submission and result are separate logical stages.
- Same canonical intent and owner state follow the same deterministic sequence.
- Accessibility semantics are part of intent equivalence, not an alternate flow.

## Ownership Boundary

| Concern | Owner |
|---|---|
| Human intent and confirmation choice | User |
| Interaction draft, visible status and navigation context | Experience |
| Envelope validation and orchestration | P1.4 Application service |
| Semantic validation and transition acceptance | P1.2/P1.3 capability owner |
| Authorization policy/decision | Identity/Security owner |
| Platform compatibility/provenance | Platform contract owner |
| Audit fact for accepted domain change | Authoritative capability owner |
| Interaction audit references | Experience/Application within authorized scope |

No owner may infer another owner's decision. Experience cannot turn an enabled
control, confirmation or animation completion into domain acceptance.

## Command Interaction Lifecycle

```text
idle
  -> drafting
  -> boundaryChecking
       -> invalid -> drafting or abandoned
       -> ready
            -> confirmationRequired -> confirmed or abandoned
            -> submitting
                 -> accepted
                 -> rejected
                 -> partial
                 -> outcomeUnknown
```

`confirmationRequired` is skipped only when the use-case contract declares no
confirmation. `abandoned` before submission changes no domain state. `accepted`,
`rejected` and `partial` are terminal for one interaction attempt. `outcomeUnknown`
requires owner result resolution using the same request/idempotency identity;
it does not authorize a new semantic command.

## Query Interaction Lifecycle

```text
idle -> loading -> ready | empty | stale | offline | unauthorized |
                   notFound | incompatible | failed | cancelled
```

Queries are side-effect-free, version-bound and repeatable. A query refresh is a
new read attempt, not a domain command. Previously verified data may remain
visible only with explicit source version and stale/offline status.

## User Intent Model

A logical intent contains interaction ID/version, use-case/route identity,
actor/access-context reference, target owner/entity/version, purpose, canonical
user-supplied values, correlation context and requested operation. Mutating intent
gains an idempotency key at submission. Confirmation binds the exact canonical
intent digest; changing a material value invalidates prior confirmation.

Draft content is Experience-owned transient state and is not a domain fact.
Application/capability contracts determine canonical command data. Provider,
persistence, widget and controller objects cannot enter an intent envelope.

## Validation Boundaries

1. Experience may detect missing/ill-formed interaction input for immediate
   presentation but cannot declare semantic validity.
2. Application validates canonical envelope, duplicate/idempotency and declared
   contract compatibility.
3. Identity/Security returns authorization decision.
4. Capability owner validates semantics, current version, transition and invariant.
5. Platform owner validates Platform identity/version/provenance where applicable.

Experience validation is advisory and repeatable at submit. A locally ready
interaction may still receive an owner rejection. P1.7 implements no validation.

## Confirmation Semantics

Confirmation is required when a command is terminal, destructive, exceptional,
corrective, privacy/security-sensitive, costly or creates external/AI execution.
At minimum this includes Match/Rack cancellation/completion where policy marks it,
Score correction, active Training cancellation, Coach execution/cancellation,
Configuration retirement, Profile closure, Simulation submission/cancellation
and Evidence correction request.

Confirmation presents logical operation, target identity, material consequences,
owner, current version and whether compensation exists. Confirmation has its own
identity/time/access binding and is invalid after intent, target, version,
authorization context or consequence summary changes.

Confirmation itself never submits a second command or mutates state. The exact
confirmed intent proceeds once through the command boundary.

## Cancellation Semantics

- Before submission: abandon local draft/confirmation; no owner command/event.
- While submitting with no known owner acceptance: mark cancellation requested,
  resolve the original outcome first and never assume it was stopped.
- After owner acceptance: cancellation is a separate P1.5 transition command if
  the current state explicitly allows it.
- After terminal state: cancellation is prohibited; correction/compensation is a
  separate authorized command when available.
- Query cancellation stops presentation interest only and does not change owner
  state or invalidate a response already produced.

## Long-Running Interaction Handling

Long-running intent has a stable request identity and logical statuses
`submitted`, `accepted`, `inProgress`, `completed`, `failed`, `partial`,
`cancellationRequested`, `cancelled` or `outcomeUnknown`, as supported by its
owner contract. Experience queries status; it does not advance it by elapsed time.

Leaving a route does not cancel work. Returning resolves the same request. The
user may initiate an owner-supported cancel command. No polling, timeout, retry,
background task, notification or scheduling mechanism is selected here.

## Required Interaction Models

| Flow | Interaction type | Confirmation/cancellation rule |
|---|---|---|
| Match creation | draft -> create command -> Match result | confirm only if policy requires; abandon before submit |
| Match scoring | Score query + record/correct command | correction confirmation; owner expected-version conflict |
| Training workflow | query eligible plan + lifecycle commands | active cancellation confirmation and explicit command |
| AI Coach request | prepare/execute query-command flow | execution binds AISession; cancel through Coach lifecycle |
| Knowledge browse/search | query only | cancel read interest; no Knowledge mutation |
| Settings modification | draft + activate/supersede/retire command | retirement/scope-sensitive change confirmation |
| Profile update | query + version-bound update/close command | close confirmation; Identity owner authorization |
| Simulation request | prepare/submit/status query/cancel command | submit/cancel confirmation per consequence policy |
| Analytics filtering | local query criteria + projection query | no domain command; cancel/replace read attempt |
| Error acknowledgement | local acknowledgement or safe navigation | cannot acknowledge away owner failure/partial progress |
| Confirmation | confirmation decision over intent digest | expires on material binding change |

## Error Interaction Patterns

Errors retain interaction/request ID, stage, accountable source, stable category,
safe structured detail and last valid view. Categories include invalid input,
unauthorized, not found, stale/conflict, duplicate mismatch, incompatible,
provenance failure, invariant rejection, dependency unavailable, partial and
outcome unknown.

User correction returns to `drafting` with a new canonical intent where semantics
change. Owner rejection cannot be relabeled as local validation. Error
acknowledgement changes presentation state only and does not erase the failure,
audit reference or committed partial progress.

## Retry Eligibility And Idempotency

| Outcome | Retry rule |
|---|---|
| Query failed/offline | new query attempt against declared version/context |
| Command not submitted | submit once after readiness/confirmation |
| Transport failed, outcome unknown | resolve/replay exact request with same idempotency key |
| Explicit owner rejection | no identical blind retry; correct intent/version or stop |
| Accepted | return same result for same key; never create a second mutation |
| Partial | resume/compensate only through declared application workflow |
| Terminal failed/cancelled | new attempt identity only if owner lifecycle permits |

Reusing an idempotency key with different canonical intent fails closed.
Experience cannot generate repeated commands from repeated gestures/activation.

## Interaction Concurrency

One interaction attempt has one canonical mutable draft and at most one active
submission. Multiple read interactions may coexist when their identities and
versions are distinct. Commands bind expected aggregate version; owner ordering
decides concurrent attempts and stale/conflicting attempts fail explicitly.

A later local edit cannot mutate an in-flight command; it creates a successor
draft/interaction. Duplicate physical activation maps to the same logical submit
identity. No lock, debounce, queue or concurrency mechanism is specified.

## Deterministic Interaction Order

1. Establish interaction/use-case identity and target.
2. Capture canonical user intent.
3. Run Experience boundary checks.
4. Resolve access and contract/version context.
5. Bind required confirmation to the intent digest.
6. Create one request/idempotency identity.
7. Submit to the P1.4 application boundary.
8. Display explicit submitting/long-running state.
9. Bind authoritative result/failure and owner version.
10. Navigate/update view only from the accepted result or typed failure.

## Accessibility Interaction Considerations

Every logical action has a stable semantic name, role, state and consequence
independent of gesture, pointer, visual position, color or animation. All intents
must be reachable by an equivalent non-pointer path. Focus/reading context returns
to the initiating action or first relevant result/error after completion.

Confirmation and error states expose operation, target, status and safe actions
to assistive technologies. Time alone cannot confirm, cancel or discard input.
These are logical requirements, not widget/layout implementation.

## Interaction Audit Boundary

Audit records semantic interaction facts: intent/request identity and digest,
actor/access decision reference, confirmation decision where required,
application submission, owner result/event reference, failure/partial state,
cancellation/compensation reference and provenance. It does not record every
keystroke, pointer movement, hover, focus change or sensitive raw field value.

Audit cannot establish domain truth beyond referenced owner results and must obey
purpose, minimization, custody, retention and erasure governance.

## Definition Of Done

- Interaction principles and command/query lifecycles are defined.
- Intent, ownership, validation, confirmation and cancellation are explicit.
- Long-running/error/retry/idempotency/concurrency and deterministic ordering are
  documented for all required flows.
- Logical accessibility and audit boundaries preserve privacy and ownership.
- User interaction remains separated from Application/domain execution.
- ADR-029 remains Proposed; no UI/runtime implementation exists.
- Exactly the four authorized P1.7 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.7 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
