# FEATURE_003 Player Career Timeline

Version: 1.0

Status: Accepted; Closed

## Goal

Allow the active Player to inspect a chronological career timeline rebuilt only
from facts already recorded by Pool OS. The timeline is a read-only historical
projection. It does not create or alter Player, Match, Training, Player Model,
Equipment snapshots, or Knowledge Mastery facts.

## User Value

The Player Profile shows when the Player record was created and the timestamps
of completed Match, completed Training, current Player Model snapshot,
the immutable cue roles captured for each completed activity, and timestamped
Mastery evidence. Events are displayed from newest to oldest and retain visible
primary and child source references.

## Ownership

Player owns `CareerTimelineProjection`, `CareerTimelineEvent`, the deterministic
builder, cache lifecycle, and Player Profile presentation. Match and Training
provide read-only public source hooks. Equipment exposes immutable per-Match
snapshots through an application-level read-only contract. Player Model and
Knowledge Mastery retain ownership of their projections and facts.

No new repository, runtime, event bus, API, background worker, or source-fact
write path is introduced. The existing `PlayerRepository` persists the optional
cache.

## Inputs And Outputs

Inputs are the active Player, completed Match facts, completed Training facts,
the current Player Model projection, immutable Match Equipment snapshots, and
Knowledge Mastery entries with a real `lastEvidenceAt`.

Output is immutable `CareerTimelineProjection` v1 with:

- Player ID;
- projection version;
- source digest;
- projection digest;
- canonically ordered `CareerTimelineEvent` values;
- deterministic event ID, event type, UTC timestamp, title, summary, and source
  reference for every event;
- canonical `CareerEquipmentUsageRef` values containing Match ID, Match number,
  snapshot reference, role, and cue ID. Cue names are excluded because they are
  mutable.

## Fail-Closed Event Contract

Only these direct event types are allowed:

- `playerCreated` from `Player.createdAt`;
- `completedMatch` from `Match.endTime`;
- `completedTraining` from `Session.finishedAt`;
- `playerModelSnapshot` from the current projection and `lastUpdated`;
- `masteryEvidenceUpdated` from a Mastery entry with `lastEvidenceAt`.

Equipment usage enriches a completed Match or Training event and never creates
a separate event. A Match uses only its own `equipment-snapshot:match:<id>`.
A Training event aggregates all completed Drill Match snapshots in canonical
`matchNumber`, Match ID, then Playing/Break/Jump order while retaining each
Drill Match's provenance. Missing snapshots or roles remain empty; Active Cue
is never used as fallback. The primary references remain `match:<id>` and
`training:<sessionId>`.

The projection does not label a Player Model as increased, Equipment as
changed, a Match or Training as important, an improvement as major, or any fact
as a newly achieved milestone. Mastery sources without a historical evidence
timestamp contribute no event.

## Determinism And Ordering

Source collections are canonicalized by stable source identity before hashing.
Equipment usage within an event is canonicalized by Match number, Match ID, and
role. Event IDs hash event type, canonical UTC timestamp, source reference, and
canonical equipment usage. The projection orders events by timestamp
descending, then event-type ordinal, then source reference. The source digest
covers the canonical source payload; the projection digest covers version,
Player binding, source digest, and ordered event content.

The domain builder fails closed when a Match usage reference does not match the
Match fact identity, when Training usage does not belong to that Session's
completed Drill Match identities, or when a non-activity event contains
equipment usage. Canonically ordered Drill Match identities are included in the
Training source payload and source digest even when their snapshots are absent.

Deleting schema-v28 `CareerTimelineProjections` data changes no source fact.
Rebuilding identical inputs reproduces identical serialized projection JSON,
event IDs, source digest, and projection digest.

## Persistence And Refresh

Drift schema v28 adds only `CareerTimelineProjections`, keyed by Player ID. The
existing `PlayerRepository` validates stored projection version, event IDs, and
projection digest when loading. Match completion refreshes Player Model,
Equipment Performance, then Career Timeline; FEATURE_003 itself has no
dependency on Equipment Performance. Opening or pull-refreshing Player Profile
rebuilds the timeline, so completed Training facts are reflected without adding
a Training-owned write or runtime.

Legacy Session rows with no Player ID remain readable under the application's
existing single-profile compatibility behavior. A Session explicitly owned by
another Player is excluded.

## Prohibitions

No AI, Coach logic, Recommendation, Prediction, Analytics Engine, Ranking,
League, Tournament, cloud sync, HTTP/API, new repository, event bus, runtime, or
source-fact mutation. FEATURE_001 and FEATURE_002 projections and contracts are
unchanged.

## Acceptance Evidence

Engineering verification on 2026-07-25:

- FEATURE_003 tests pass 16/16 for deterministic replay, stable order, stable
  digests, immutable historical events, source references, Player filtering,
  immutable Match cue attribution after Active Cue changes, multi-Drill
  Training aggregation, repeated cue roles, foreign-provenance rejection,
  missing-snapshot fail-closed behavior, SQLite restart, service-level cache
  delete/rebuild, and newest-first UI;
- full app regression passes 1218/1218, including FEATURE_001 and FEATURE_002;
- Knowledge package passes 75/75;
- Foundation Freeze passes 76/76;
- Architecture Fitness passes with 133 known violations and 0 new;
- full analyzer has no error or warning and retains 62 existing info lints;
  focused FEATURE_003 analysis is clean;
- formatter and `git diff --check` are clean.

Product Owner accepted and closed FEATURE_003 on 2026-07-25 after independent
re-verification of all 16 focused tests. No commit or push was made, as required
by the implementation STOP instruction.
