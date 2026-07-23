# Product User Interaction Model

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Boundary Model

```text
User intent
  -> Experience draft/visible state
  -> Application request envelope
  -> Authorization and compatibility gates
  -> Authoritative capability command/query
  -> Owner result/event or typed failure
  -> Experience result state/navigation
```

Each arrow is a public logical boundary. Presentation does not execute domain
rules, and owner results cannot be fabricated from interaction state.

## Interaction State Summary

| Interaction | States |
|---|---|
| Command | idle, drafting, boundaryChecking, invalid, ready, confirmationRequired, confirmed, submitting, accepted, rejected, partial, outcomeUnknown, abandoned |
| Query | idle, loading, ready, empty, stale, offline, unauthorized, notFound, incompatible, failed, cancelled |
| Long-running request | submitted, accepted, inProgress, completed, failed, partial, cancellationRequested, cancelled, outcomeUnknown |

These are logical Experience/Application statuses, not domain enums or code.

## Interaction Invariants

1. One user intent maps to one application use-case identity.
2. Confirmation binds exact canonical intent; material edit invalidates it.
3. One interaction attempt has at most one active submission.
4. Duplicate activation reuses one request/idempotency identity.
5. Owner acceptance alone establishes mutation.
6. Pre-submit cancellation changes no domain state.
7. Post-acceptance cancellation is a new allowed owner command.
8. Query/navigation/error acknowledgement never mutates domain state.
9. Outcome unknown is resolved, not guessed or blindly retried.
10. Audit captures semantic facts, not detailed human input behavior.

## Confirmation Classes

| Class | Examples | Required binding |
|---|---|---|
| terminal/destructive | Profile close, Match cancellation, Configuration retirement | intent digest, target/version, consequence, access context |
| corrective | Score correction, Evidence correction request | original owner reference, reason, correction consequence |
| external/generated | Coach execution, Simulation submission | boundary/request identity, external consequence/cost class |
| exceptional cancellation | active Training/Coach/Simulation cancel | current owner state/version, partial-progress consequence |
| ordinary reversible | non-terminal draft changes | no confirmation unless policy declares it |

Confirmation policy is versioned and owner-approved. UI form/dialog design is
outside this plan.

## Command Query Separation

Commands are explicit, version/idempotency-bound and may be rejected. Queries are
side-effect-free and may be cancelled/replaced locally. Search and filters are
query intent; refresh is not a command. Rendering a button or opening a route
cannot submit a command implicitly.

## Audit Matrix

| Fact | Audit owner/reference | Excluded detail |
|---|---|---|
| intent submitted | Application interaction record | transient draft edits |
| confirmation decision | Experience/Application reference | gesture or visual path |
| authorization decision | Identity/Security reference | policy internals/secrets |
| owner acceptance/rejection | capability result/event reference | internal implementation |
| partial/compensation | Application workflow reference | rewritten domain history |
| query viewed | only where purpose/retention explicitly requires | routine focus/hover/scroll |

## Accessibility Equivalence

Semantic actions, state and consequence are input-modality independent. Keyboard,
assistive technology and pointer activation produce the same canonical intent and
idempotency behavior. Focus/reading context, error association and confirmation
semantics must be deterministic in later UI contracts.

## Planning Constraint

No widget, gesture/input handler, controller/view model, dialog, form, validator,
state manager, API, runtime command handler or runtime behavior is implemented.
