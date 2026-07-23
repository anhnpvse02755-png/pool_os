# Product Domain Workflows

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Workflow Contract

Product lifecycle transitions are owner-controlled, version-bound, idempotent,
append-only in audit and deterministic. This catalog is logical planning; it does
not create enums, state machines, commands, events or runtime mechanisms.

## Lifecycle Summary

| Workflow | Owner | Initial state | Terminal states |
|---|---|---|---|
| Match | Match Management | draft | completed, cancelled |
| Rack/Game Session | Match Management | pending | completed, voided |
| Training Session | Training | planned | completed, cancelled |
| Coach Session | AI Coach | prepared | completed, failed, cancelled |
| Snapshot generation | Performance Analytics | requested | materialized, failed, cancelled; later superseded/invalidated |
| Configuration | Settings / Configuration | draft | discarded, superseded, retired |
| User/Profile | User & Identity Product owner | invited | closed |
| Simulation request | Product Simulation Invocation | prepared | completed, failed, cancelled, rejected |
| Evidence recording reference | Product Evidence Recording | prepared | recorded, rejected, cancelled; later owner-superseded |

## Universal Invariants

1. One authoritative owner accepts every transition.
2. Identity, owner and creation provenance never change.
3. Expected version and idempotency key bind every mutating command.
4. Invalid/rejected commands do not mutate state or append accepted transitions.
5. Same canonical command against the same version has the same disposition.
6. Terminal state has no outbound transition unless explicitly modeled.
7. Cancellation never erases a completed fact or foreign owner transition.
8. Recovery/compensation is a new authorized command with new evidence.
9. Application orchestration cannot create a cross-owner atomic boundary.
10. Platform entity state is referenced, never transitioned by Product.

## Deterministic Transition Evaluation

```text
canonical command
  -> identity/owner/contract gate
  -> authorization decision reference
  -> idempotency gate
  -> expected aggregate version gate
  -> current-state/transition lookup
  -> precondition and foreign-reference compatibility gates
  -> owner invariant evaluation
  -> state/version advance
  -> immutable transition and owner event references
```

Any gate failure stops evaluation and returns a typed rejection. Wall-clock or
arrival race cannot silently choose a semantic outcome; owner ordering and
expected versions make the accepted order explicit.

## Prohibited Transitions

All unlisted state pairs are prohibited. In particular: terminal states cannot
reopen; pending/draft objects cannot skip required active/accepted gates; Match
cannot complete with non-terminal required Racks; Training cannot start with
stale eligibility; Coach cannot complete with an unbound response; a snapshot
cannot be edited after materialization; Product cannot correct Evidence or
Simulation results; Configuration cannot reactivate a retired version.

## Failure Categories

Stable logical categories are malformed command, unauthorized, not found,
duplicate mismatch, stale version, invalid transition, failed precondition,
incompatible reference, provenance mismatch, invariant rejection, dependency
failure, partial workflow and compensation rejection. Failure carries owner,
stage and request identity without exposing secrets or internals.

## Recovery And Replay

Replay of accepted transition records in owner sequence produces the same state,
version and deterministic digest where the owner contract requires a digest.
Recovery uses committed owner references and explicit new commands. Rebuild does
not edit transition history. Retry/locking/queue/scheduler mechanics are outside
this planning milestone.

## Platform Boundary

Simulation and Evidence workflows in this catalog govern Product request and
reference state only. Player, Knowledge, Learning, Evidence facts, Simulation
scenarios/results and deterministic Coach contracts remain governed exclusively
by accepted Platform contracts.

## Planning Constraint

No state machine, enum, Dart class/code, repository, persistence, event source,
workflow engine, concurrency/lock, queue, retry or scheduler is implemented.
