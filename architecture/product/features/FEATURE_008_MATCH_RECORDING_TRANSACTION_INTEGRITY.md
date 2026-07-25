# FEATURE_008 Match Recording Transaction Integrity

Version: 1.0

Status: Proposed; Pending Engineering Specification Re-audit

Candidate: E4-G03 (Essential)

## Goal

Make Match creation and active-recording selection safe under one Session-owned
transaction: each new Match receives a collision-free, monotonic per-Session
number and each Session has at most one open Match.

## Ownership

Session `RecordingCoordinator` remains the only cross-recording transaction
owner. Match owns its row and lifecycle policy; FEATURE_007 remains unchanged.
Rack, Shot, Event, MatchContext, Training and UI remain outside this feature.

## Invariants

- A Session with Match rows has unique positive `matchNumber` values.
- Beginning with the FEATURE_008 migration, a new Match number is greater than
  every number allocated for that Session after migration. Deletion never
  permits reuse. Allocations deleted before migration are not reconstructable
  and are outside this prospective guarantee.
- A Session has zero or one Match with `endTime == null`.
- The transaction validates the parent Session before allocating or creating.
- If any invariant fails, no Match row or dependent recording fact is written.

## Creation Contract

The coordinator receives a Session ID and requested Match metadata. Inside its
existing transaction its first SQL statement must acquire a write lock on the
target parent Session before any source read. It then validates the Session,
rejects an existing open Match, advances the durable per-Session high-water
mark by one and inserts the Match with a canonical lifecycle start. The caller
cannot supply or override `matchNumber`, start/created timestamps or `endTime`;
the new Match starts open and all instants use FEATURE_007 canonicalization.

The high-water advance and insertion must use conditional database operations
inside that transaction; count-plus-one and max-plus-one at runtime are
prohibited. Concurrent attempts must result in one successful creation and a
typed `open-match-exists` or `allocation-conflict` failure for the other, never
a duplicate number or two open Matches. `ensurePracticeMatch` retains its
existing find-or-create idempotency and returns the already-open practice Match.

## Legacy Data

Existing duplicate/non-positive numbers, multiple open Matches, or a high-water
mark below the current maximum are invalid source state. Reads fail closed for
new creation; FEATURE_008 performs no Match-row repair, deletion or silent
winner selection. Existing completed history remains readable through prior
compatibility paths.

Migration v30 creates `match_number_allocations` with `session_id` as its
primary key and parent foreign key plus non-negative `last_allocated`. It seeds one
row per Session from the current valid `MAX(match_number)`, or zero when none
exists. This starts the prospective no-reuse guarantee. Legacy invalid Match
rows remain unchanged and cause creation to fail closed.

## Failure Contract

The exact failure literals are:

- `match-recording-session-target-not-found`;
- `match-recording-invalid-source-state`;
- `match-recording-open-match-exists`;
- `match-recording-allocation-conflict`;
- `match-recording-database-failure`;
- `match-recording-source-read-failure`.

Precedence is lifecycle/input validation, unexpected database failure,
source-read failure, missing Session, invalid source state, exactly one open
Match, then allocation conflict. `MatchRecordingService` must preserve these
literals in `FailureResult`, not collapse them to `command-handler-threw`.

A zero-row parent lock, high-water compare-and-swap or conditional Match insert
must re-read inside the same transaction and classify by that precedence. One
affected row succeeds; more than one is database failure. A clean number
collision or exhausted signed SQLite integer is allocation conflict.

## Persistence And Scope

Schema v30 is required and authorized only after final specification acceptance.
It adds the allocation sidecar plus insert/update triggers that reject
non-positive or duplicate `(session_id, match_number)` values and reject a
second open Match. Triggers enforce all repository write paths, including
reparenting or renumbering. They do not repair or hide legacy rows.

The v30 schema version changes FEATURE_006 `sourceSchemaVersion` and therefore
its provenance digests as designed. Wire format, identity semantics, adapters
and all source facts remain unchanged; tests must accept only this deterministic
version-derived digest change.

Allowed surfaces are `app_database.dart`, `recording_errors.dart`,
`match_recording_service.dart`, `match_repository.dart`,
`recording_coordinator.dart`, new focused transaction-integrity/migration tests,
`match_identity_compatibility_repository_test.dart` and
`active_player_migration_test.dart`. Prohibited: UI, generated files, cache,
lifecycle policy changes, MatchContext, deletion/retention behavior, Training,
FEATURE_009 or a new transaction coordinator.

## Acceptance Evidence

- concurrent creation through two independent connections to one SQLite file
  yields one Match and one typed failure;
- deletion then creation never reuses a number;
- existing open Match prevents creation without writes;
- duplicate-number/multiple-open legacy rows fail closed without repair;
- direct trigger enforcement covers insert, reparent, renumber and second-open
  writes outside the coordinator;
- migration seed/rollback/reopen, parent missing, service failure propagation,
  drill rollback and practice find-or-create behavior are deterministic;
- FEATURE_007 lifecycle, existing recording, FEATURE_001-007, full app,
  Knowledge, Freeze, Architecture Fitness, analyzer and scope checks remain green.

## Implementation Authorization

None. Code Pool OS may audit this specification and repository evidence
read-only. Implementation requires separate PO acceptance.
