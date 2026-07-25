# FEATURE_007 Match Lifecycle State Policy

Version: 1.0

Status: Proposed; Pending Engineering Specification Audit

Candidate: E4-G02 (Essential)

## Goal

Define one Match-owned, versioned lifecycle policy over the existing persisted
Match timestamps, then make Match writes use that policy without changing
Session's recording transaction ownership.

## Lifecycle V1

The only states are:

- `recording`: `startTime` may be null or present; `endTime` is null.
- `completed`: `startTime` is present and `endTime` is present at or after start.

There is no `draft`, `cancelled`, `deleted`, repair state or inferred winner
state in V1. `result` and `winner` remain legacy Match metadata and do not
determine lifecycle.

## Ownership

- Match owns lifecycle validation and state transitions.
- Session `RecordingCoordinator` remains the sole cross-recording transaction
  owner. Match must not create a second coordinator or transaction boundary.
- Rack/Shot/Event remain source facts; they do not define lifecycle in V1.
- UI renders lifecycle but does not infer, repair or write it directly.

## Compatibility Source And Policy Version

The persisted `matches` row remains source of truth. FEATURE_006 identity
compatibility remains read-only and unchanged.

`lifecyclePolicyVersion` is literal `1`. Legacy rows are read as:

- valid `recording` or `completed` when they satisfy V1;
- `invalid` assessment when end precedes start, or when end exists without
  start; no read repair or silent default is allowed.

The policy must be deterministic and not use wall-clock time during a read.

## Commands And Transitions

Only the following V1 transitions are legal:

| From | Command | To | Preconditions |
| --- | --- | --- | --- |
| recording | start | recording | null start/end; supplied instant |
| recording | finish | completed | supplied end; persisted or supplied start <= end |
| completed | none | completed | immutable lifecycle fields |

`start` requires a non-null instant. Command instants are converted to UTC then
canonicalized to whole Unix seconds before validation, persistence and every
idempotency comparison. A null start is a valid unstarted `recording` row, not
a valid start command.

`start` is idempotent only when the persisted canonical start equals the
supplied canonical instant. `finish` requires a non-null canonical end. If a
recording row has null start, finish must supply a non-null canonical start;
the repository atomically writes both values and requires start <= end. If it
already has a start, the supplied start must be null and the existing canonical
start is used. `finish` is idempotent only when persisted end equals the
supplied canonical end and all persisted lifecycle values remain valid.

Zero-argument legacy call sites obtain command instants from an application
clock adapter before entering `RecordingCoordinator`; reads never obtain time.
The lifecycle primitive writes only timestamps. It cannot clear/reopen fields,
allocate a Match number, or derive a timestamp from a read.

Legacy recording orchestration may write its supplied `winner` metadata only
after a successful lifecycle primitive within the same existing Session-owned
transaction. A lifecycle failure rolls back both lifecycle and winner writes.
This preserves existing UI behavior without making winner/result lifecycle
state.

## Failure Contract

Literal failure strings are:

- `match-lifecycle-target-not-found`;
- `match-lifecycle-invalid-source-state`;
- `match-lifecycle-invalid-transition`;
- `match-lifecycle-timestamp-missing`;
- `match-lifecycle-timestamp-order-invalid`;
- `match-lifecycle-idempotency-conflict`;
- `match-lifecycle-database-failure`;
- `match-lifecycle-source-read-failure`.

Command precedence is input timestamp validation, database failure, source-read
failure, target-not-found, invalid source state, invalid transition, then
idempotency conflict. A conditional update affecting zero rows is classified by
a transaction-local re-read using this same precedence. A failed command is
atomic: the persisted Match row, including legacy winner metadata, is unchanged.

## Persistence And Concurrency

No schema migration is authorized. The policy may add repository methods that
perform a conditional update in the caller's existing transaction context.
It must not rely on a read-then-write sequence that can overwrite a concurrent
finish. Start predicate includes target ID and null start/end. Finish predicate
includes target ID and null end; it conditionally persists supplied start only
when the existing start is null. Affected-row semantics and re-read occur in
the existing Session transaction.

Generic metadata update must omit `startTime` and `endTime`; lifecycle fields
are mutable only through the lifecycle primitive.

FEATURE_007 does not implement one-open-Match-per-Session, monotonic Match
number allocation, Match deletion/retention, MatchContext integrity, or request
identity/cancellation. Those are separate roadmap work.

## Allowed Implementation Surfaces

- Match lifecycle domain policy and typed failures;
- Match application command/service adapter that delegates cross-recording work
  to existing Session ownership;
- `match_recording_service.dart` and Session-owned `recording_coordinator.dart`
  integration required to preserve existing winner behavior;
- existing Match repository conditional lifecycle methods and protected generic
  metadata update;
- focused lifecycle/repository integration tests and necessary existing Match
  command tests.

## Prohibited Scope

- schema, generated artifacts, cache, UI or frozen contract changes;
- new transaction coordinator/capability/runtime;
- player/team/tournament identity inference;
- rack/shot/event mutation or score-derived completion;
- FEATURE_006 contract changes;
- FEATURE_008 or later roadmap work.

## Acceptance Criteria

- Legacy valid rows classify deterministically without writes.
- Invalid timestamp combinations fail closed and do not repair storage.
- Start/finish transitions preserve atomicity and idempotency semantics.
- A failed target/precondition/concurrency path preserves the row exactly.
- Completion cannot be reopened or altered through lifecycle APIs.
- FEATURE_006 snapshots remain compatible and existing Match recording,
  FEATURE_001-006, full app and architecture gates remain green.

## Required Evidence

- policy unit tests for every state/transition/failure precedence;
- repository tests for conditional update, rollback, idempotency and reopen
  rejection, including SQLite close/reopen;
- existing Match characterization/recording regression;
- FEATURE_001-006, full app, Knowledge, Foundation Freeze, Architecture
  Fitness, analyzer, formatter, diff and scope checks.

## Implementation Authorization

None. Code Pool OS may audit this specification and repository evidence
read-only. Implementation requires separate PO acceptance.
