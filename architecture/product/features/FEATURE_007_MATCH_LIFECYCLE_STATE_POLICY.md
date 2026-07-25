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
| recording | start | recording | no existing start; supplied UTC instant |
| recording | finish | completed | existing/supplied start; supplied end >= start |
| completed | none | completed | immutable lifecycle fields |

`start` is idempotent only when the persisted start equals the supplied instant;
otherwise it fails. `finish` is idempotent only when persisted end equals the
supplied end and existing lifecycle fields remain valid; otherwise it fails.
No command may clear start/end, reopen a completed Match, mutate winner/result,
allocate a Match number, or derive a timestamp from a read.

## Failure Contract

V1 uses stable Match lifecycle failure codes for target-not-found, invalid
source state, invalid transition, timestamp missing, timestamp order invalid,
idempotency conflict, database failure and source-read failure. Engineering
audit must lock literal strings and precedence against existing errors before
implementation. A failed command is atomic: the persisted Match row is unchanged.

## Persistence And Concurrency

No schema migration is authorized. The policy may add repository methods that
perform a conditional update in the caller's existing transaction context.
It must not rely on a read-then-write sequence that can overwrite a concurrent
finish. Exact conditional predicates and affected-row semantics must be locked
by audit.

FEATURE_007 does not implement one-open-Match-per-Session, monotonic Match
number allocation, Match deletion/retention, MatchContext integrity, or request
identity/cancellation. Those are separate roadmap work.

## Allowed Implementation Surfaces

- Match lifecycle domain policy and typed failures;
- Match application command/service adapter that delegates cross-recording work
  to existing Session ownership;
- existing Match repository conditional lifecycle methods;
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
