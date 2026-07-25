# FEATURE_008 Match Recording Transaction Integrity

Version: 1.0

Status: Proposed; Pending Engineering Specification Audit

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
- A new Match number is greater than every previously allocated number in that
  Session. Deletion never permits reuse.
- A Session has zero or one Match with `endTime == null`.
- The transaction validates the parent Session before allocating or creating.
- If any invariant fails, no Match row or dependent recording fact is written.

## Creation Contract

The coordinator receives a Session ID and requested Match metadata. Inside its
existing transaction it validates the Session, rejects an existing open Match,
allocates `max(match_number) + 1` for that Session and inserts the Match with a
canonical lifecycle start. The caller cannot supply or override `matchNumber`.

The allocation/insertion must use a transaction-safe database strategy proven
by audit; count-plus-one is prohibited. Concurrent attempts must result in one
successful creation and typed failure for the other, never duplicate number or
two open Matches.

## Legacy Data

Existing duplicate numbers or multiple open Matches are invalid source state.
Reads fail closed for new creation; FEATURE_008 performs no repair, deletion,
migration or silent winner selection. Existing completed history remains
readable through prior compatibility paths.

## Failure Contract

Required failure categories are: Session target not found, invalid source state,
open Match exists, allocation conflict, database failure and source-read
failure. Engineering audit must lock literal codes, deterministic precedence,
conditional predicates and zero-row semantics before implementation.

## Persistence And Scope

Schema migration is not authorized unless audit proves the current schema cannot
enforce concurrency safely. Any proposed migration is a blocker requiring a
separate PO decision; do not implement it by inference.

Allowed surfaces are Match/Session coordinator creation path, existing Match
repository allocation/create support, typed failure mapping and focused tests.
Prohibited: UI, generated files, cache, lifecycle policy changes, MatchContext,
deletion/retention, Training, Feature 009 or a new transaction coordinator.

## Acceptance Evidence

- concurrent creation yields one Match and one typed failure;
- deletion then creation never reuses a number;
- existing open Match prevents creation without writes;
- duplicate-number/multiple-open legacy rows fail closed without repair;
- parent missing, rollback and SQLite reopen behavior are deterministic;
- FEATURE_007 lifecycle, existing recording, FEATURE_001-007, full app,
  Knowledge, Freeze, Architecture Fitness, analyzer and scope checks remain green.

## Implementation Authorization

None. Code Pool OS may audit this specification and repository evidence
read-only. Implementation requires separate PO acceptance.
