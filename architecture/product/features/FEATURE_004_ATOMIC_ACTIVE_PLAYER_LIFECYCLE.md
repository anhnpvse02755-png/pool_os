# FEATURE_004 Atomic Active Player Lifecycle

Version: 1.0

Status: Accepted; Closed

Candidate: E3-G04 (Essential)

## Goal

Make local Active Player selection a deterministic Player-owned lifecycle with
an atomic persistence invariant. Every Player-bound consumer must observe one
consistent active identity or the valid empty state.

This feature protects the identity already consumed by FEATURE_001 Player
Model, FEATURE_002 Equipment Performance, and FEATURE_003 Career Timeline. It
does not change any of those projection contracts.

## User Value

Creating, switching, editing, or deleting local Player profiles cannot leave
the application with multiple active profiles, no active profile while Players
remain, or a screen that combines projections from different Players.

## Ownership

Player owns:

- the local Active Player invariant;
- Player creation, selection, profile update, and deletion lifecycle;
- deterministic repair of legacy Active Player data;
- the active-identity handoff exposed to Player-bound consumers.

Player does not own Account, authentication, device identity, cloud sync, Match,
Training, Equipment, Knowledge, Coach, Analytics, or the projections owned by
FEATURE_001-003.

The existing `PlayerRepository` remains the only Player persistence repository.
No new repository, event bus, runtime, API, or background worker is introduced.

## Canonical Invariant

The database and repository must satisfy exactly these states:

- zero Player rows means zero Active Players;
- one or more Player rows means exactly one Active Player.

The database enforces at most one active row. Repository lifecycle transactions
enforce existence of one active row whenever any Player remains.

`getActivePlayer()` is a strict query. It returns `null` only when there are no
Players. If Players exist but the invariant is violated, it fails closed with a
stable invariant error. It must not select the first Player as an implicit
fallback and must not repair data during a read.

## Lifecycle Contract

### Create Player

- Creation runs in a transaction.
- The first Player created becomes active.
- Every later Player is created inactive, regardless of an `isActive` value in
  a caller-supplied profile object.
- Creating another Player never changes the current Active Player.
- Concurrent creation cannot produce two active rows.

### Switch Active Player

- The target Player must be read and validated before the current selection is
  changed.
- A missing target fails closed and leaves the current Active Player unchanged.
- Selecting the already active target is idempotent and performs no semantic
  state change.
- A valid switch deactivates the previous row and activates the target within
  one database transaction.
- Success is observable only after the transaction commits.

### Update Player Profile

- Ordinary profile updates never write `isActive`.
- Active selection changes only through the dedicated lifecycle operation.
- Updating either an active or inactive profile preserves the selected Player.

### Delete Player

- Deletion runs in a transaction.
- Deleting an inactive Player does not affect the Active Player.
- Deleting the Active Player selects the remaining Player with the smallest
  numeric ID.
- Deleting the final Player produces the valid empty state.
- Selection handoff and deletion commit atomically.
- Retention policy for external Player references is outside FEATURE_004; this
  feature does not invent cascading or archival semantics for other domains.

## Persistence And Migration

Implementation uses the existing Drift database and increments its schema
version once. Migration repairs legacy rows deterministically before installing
the database constraint:

1. If no Players exist, leave the table empty.
2. If one or more active rows exist, retain the active row with the smallest ID
   and deactivate every other row.
3. If Players exist with no active row, activate the Player with the smallest
   ID.
4. Create a SQLite partial unique index over the active state so at most one row
   can have `is_active = 1`.

Repair and index creation occur in the same migration transaction. Migration is
idempotent with respect to the resulting Player state. It does not rewrite
Player identity, profile fields, timestamps, or FEATURE_001-003 projection data.

The existing `isActive` column remains a compatibility field on Player reads,
but caller-provided values are not accepted as lifecycle commands.

## Consumer Handoff

After a successful Active Player switch or active-Player deletion handoff, the
Player UI and all Player-bound consumers must transition to the same committed
identity:

- Player Profile and Player state;
- FEATURE_001 Player Model projection;
- FEATURE_002 Equipment Performance projection;
- FEATURE_003 Career Timeline projection;
- existing Dashboard and Statistics consumers that are refreshed by Player
  selection today.

During handoff, presentation may show a loading state but must not render a new
Player profile with projections cached for the previous Player. A failed
lifecycle command invalidates nothing and preserves the current rendered
identity. This feature changes orchestration and invalidation only; it does not
change projection schemas, builders, digests, or source ownership.

## Allowed Surfaces For Implementation

- `app/lib/features/player/`;
- existing Drift schema and generated output;
- existing Player selection UI/provider orchestration;
- FEATURE_001-003 public provider invalidation or reload hooks only;
- existing Dashboard/Statistics refresh wiring only where required for a
  consistent identity handoff;
- related tests;
- this specification and `MEMORY.md`.

Any implementation change outside these surfaces requires a new PO decision.

## Prohibitions

Do not add or change:

- Account, authentication, authorization, device identity, or user identity;
- cloud or multi-device synchronization;
- a new Player aggregate, repository, database namespace, runtime, event bus,
  HTTP/API, background worker, or global service locator;
- external Player-reference retention, archival, or cascade policy;
- Match, Training, Equipment, Knowledge, Coach, Analytics, Ranking, League, or
  Tournament ownership;
- FEATURE_001, FEATURE_002, or FEATURE_003 contracts;
- FEATURE_005.

## Failure Contract

Lifecycle failures must be explicit and stable enough for tests and UI mapping:

- target Player not found;
- persisted Active Player invariant violated;
- database transaction or constraint failure.

No failure path may silently choose a Player, partially change selection, or
leave Player-bound consumers on a mixed identity.

## Acceptance Criteria

- Empty database returns no Active Player.
- First creation makes that Player active.
- Later creation remains inactive and preserves the prior selection.
- Exactly one active row exists after every successful lifecycle operation when
  Players remain.
- Switch is atomic and idempotent.
- Missing switch target fails closed without changing the prior selection.
- Ordinary profile update cannot change Active Player state.
- Deleting inactive Player preserves selection.
- Deleting active Player selects the smallest remaining Player ID.
- Deleting the last Player produces the valid empty state.
- Legacy zero-active and multi-active data migrate deterministically.
- Database constraint rejects a second active row.
- `getActivePlayer()` never falls back or repairs invalid non-empty data.
- Player UI and FEATURE_001-003 consumers switch to one identity without stale
  cross-Player projection display.
- SQLite restart preserves the invariant and selected identity.
- Existing FEATURE_001-003 and full regression remain green.

## Required Tests

- repository unit/integration tests for every create, switch, update, and delete
  transition, including idempotency and missing targets;
- transaction rollback evidence proving the prior selection survives failure;
- concurrent creation/switch coverage sufficient to prove the unique-active
  constraint and transaction semantics;
- migration tests for empty, one-valid-active, zero-active, and multi-active
  legacy datasets;
- direct database constraint test for a second active row;
- strict `getActivePlayer()` invariant-violation test;
- SQLite close/reopen persistence test;
- widget/provider integration test proving Player Profile and FEATURE_001-003
  surfaces never render mixed Player identities during handoff;
- regression for FEATURE_001, FEATURE_002, FEATURE_003, full app, Knowledge,
  Foundation Freeze, analyzer, formatter, and Architecture Fitness.

## Implementation Authorization

Product Owner accepted this specification without changes on 2026-07-25 and
authorized Engineering to implement FEATURE_004 on
`product/guided-learning-pilot` within the exact allowed surfaces above.
Engineering must run the required focused and regression evidence, then send an
Engineering Report for Product Owner review. Do not commit, push or start
FEATURE_005 before explicit Product Owner closure authorization.
