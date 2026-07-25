# FEATURE_006 Match Identity Compatibility And Provenance

Version: 1.0

Status: Accepted; Implementation Authorized

Candidates: E4-G01 (Essential), prerequisite slice of E4-G08

## Goal

Create one Match-owned, read-only compatibility boundary that maps an existing
persisted Match row to the frozen foundation `ProductMatch`, `MatchAggregate`
and `MatchId` representations without changing persisted Match behavior.

This feature establishes trustworthy Match identity and provenance for later
lifecycle, transaction and public-source work. It does not make lifecycle
decisions or repair legacy rows.

## Product Value

Downstream Coach, Analytics, Equipment and Player projections need to identify
the same recorded Match without importing Drift rows or guessing identity from
session order. FEATURE_006 provides a deterministic, attributable source while
preserving current local data.

## Ownership And Boundaries

- Match owns the compatibility assessment, canonical snapshot and adapters.
- The legacy `Match` row remains the persisted compatibility source.
- `ProductMatch`, `MatchAggregate`, `MatchId`, `SessionId` and shared foundation
  values remain frozen target contracts.
- Session remains owner of recording transactions and parent Session facts.
- Rack, Shot and Event remain owners of child facts.
- Free-text opponent, partner and winner values are preserved as Match metadata;
  they are not Player, Team or Tournament identities.

## Identity Contract

For a positive persisted integer Match ID `N`:

- canonical Match ID: `entity.match:N`;
- foundation `MatchId` value: `N`;
- primary source reference: `match:N`.

For a positive Session ID `S`:

- canonical Session ID: `entity.session:S`;
- foundation `SessionId` value: `S`.

Raw assessment accepts signed SQLite Match IDs and nullable signed Session IDs.
SQLite integers are bounded by `-9223372036854775808..9223372036854775807`;
canonical Match ID, Session ID and Match number require
`1..9223372036854775807`. Strict canonical parsing rejects signs, whitespace,
leading zeroes, decimal/exponent notation and trailing data. Invalid identity
produces diagnostics and no partial canonical output.

Identity is local-device compatibility identity. Account identity, global IDs,
cross-device merge and migration are outside this feature.

## Lossless Raw Assessment

The repository exposes a Match-owned application read source containing exact
storage values for the existing Match row:

- schema version;
- Match ID, Session ID and match number;
- raw game type, race target, opponent, partner and team mode;
- raw winner, result, objective and notes;
- raw start, end and created timestamp storage values.

The raw source must not trim, translate, default, infer or normalize values.
V1 supports schema-conforming SQLite storage classes only. A mismatched storage
class is `match-identity-source-read-failure`; V1 does not invent type-tagged
wire values.

`rawAssessmentDigest` hashes keys 1-19 of this exact ordered wire and excludes
itself and `diagnostics`:

| # | Key | JSON type |
| -: | --- | --- |
| 1 | `schemaVersion` | integer `1` |
| 2 | `sourceKind` | string `legacy-match-row` |
| 3 | `sourceSchemaVersion` | integer |
| 4 | `legacyMatchId` | signed integer |
| 5 | `sourceReference` | string `match:<signed-id>` |
| 6 | `legacySessionId` | signed integer or null |
| 7 | `matchNumber` | signed integer |
| 8 | `gameTypeRaw` | string |
| 9 | `raceToRaw` | signed integer or null |
| 10 | `opponentRaw` | string or null |
| 11 | `partnerRaw` | string or null |
| 12 | `teamModeRaw` | string or null |
| 13 | `winnerRaw` | string or null |
| 14 | `resultRaw` | string or null |
| 15 | `matchObjectiveRaw` | string or null |
| 16 | `notesRaw` | string or null |
| 17 | `startTimeStorageValue` | signed Unix seconds or null |
| 18 | `endTimeStorageValue` | signed Unix seconds or null |
| 19 | `createdAtStorageValue` | signed Unix seconds |
| 20 | `rawAssessmentDigest` | lowercase SHA-256 string |
| 21 | `diagnostics` | ordered array |

## Canonical Snapshot V1

A compatible source produces exactly one immutable snapshot containing:

- `schemaVersion`: `1`;
- `adapterPolicyVersion`: `1`;
- `canonicalMatchId` and `legacyMatchId`;
- `canonicalSessionId` and `legacySessionId`;
- `matchNumber`;
- canonical game type and nullable race target;
- exact nullable opponent, partner, team mode, winner, result, objective and
  notes after validation, without treating them as external identities;
- canonical UTC start, end and created instants where present;
- derived compatibility lifecycle label;
- `sourceReference`, `sourceSchemaVersion`, `sourceDigest` and `digest`;
- empty `diagnostics`.

The compatibility lifecycle label is descriptive only:

- `recording` when end time is absent;
- `completed` when end time is present.

It must not validate winner/result rules or authorize a state transition.
FEATURE_007 owns versioned lifecycle semantics.

The canonical JSON key order is exact: `schemaVersion`,
`adapterPolicyVersion`, `canonicalMatchId`, `legacyMatchId`,
`canonicalSessionId`, `legacySessionId`, `matchNumber`, `gameType`, `raceTo`,
`opponent`, `partner`, `teamMode`, `winner`, `result`, `matchObjective`, `notes`,
`startTime`, `endTime`, `createdAt`, `lifecycleLabel`, `sourceKind`,
`sourceReference`, `sourceSchemaVersion`, `diagnostics`, `sourceDigest`,
`digest`. Nullable values remain explicit JSON nulls and `diagnostics` is empty.

## Canonicalization Rules

- Game type must be exactly one of: `race_to`, `race_to_5`, `race_to_7`,
  `race_to_11`, `ghost_challenge`, `challenge_match`, `league_match`,
  `tournament_match`, `practice_match`, `practice`, `warm_up`, `drill`,
  `9ball`, `match`, `tournament`, `training`.
- V1 defines no aliases: every accepted historic game code remains distinct.
- Nullable team mode must be `solo`, `doubles` or `team` when present.
- Nullable `raceTo` must be positive when present. V1 defines no cross-field
  game-type/race-target rule because historic writers were inconsistent.
- Optional free text preserves content exactly and rejects null bytes.
- Drift timestamps are signed Unix seconds. Range-check before multiplication;
  canonical UTC uses exactly six fractional digits and uppercase `Z`.
- End time before start time is incompatible.
- Created time is provenance, not a lifecycle transition time.
- Lists of participants are not inferred from opponent/partner text.
- A legacy Match maps to one `ProductMatch` with the canonical Match ID, one
  Session ID and an empty participant-ID list.
- `ProductMatch.version = 1`, `createdAt` is persisted `created_at`, lifecycle
  state is the compatibility label, `participantIds = []`, and
  `sessionIds = [SessionId("S")]`.
- `MatchAggregate.root` uses that same semantic ProductMatch and
  `rackSessionIds = []`.

## Digest Semantics

`sourceDigest` hashes canonical keys 2-23, excluding `schemaVersion`,
`diagnostics` and both digest fields. `digest` hashes canonical keys 1-25,
excluding only `digest`. V1 has no code aliases; timestamp seconds canonicalize
to UTC strings.

All digest payloads use UTF-8 JSON, exact documented key order, no whitespace
and SHA-256 lowercase hexadecimal. Decode recomputes identity, provenance,
source digest and snapshot digest; it never trusts serialized digest fields.

Future equivalence rules require a new adapter-policy version and cannot alter
saved v1 snapshots.

## Diagnostics And Failure Contract

Compatibility diagnostics are ordered by this field order: `legacyMatchId`,
`legacySessionId`, `matchNumber`, `gameTypeRaw`, `raceToRaw`, `opponentRaw`,
`partnerRaw`, `teamModeRaw`, `winnerRaw`, `resultRaw`, `matchObjectiveRaw`,
`notesRaw`, `startTimeStorageValue`, `endTimeStorageValue`,
`createdAtStorageValue`, `sourceSchemaVersion`. Within one field, precedence is:

- `invalid-match-id`;
- `invalid-session-id`;
- `invalid-match-number`;
- `required-empty`;
- `null-byte`;
- `code-unsupported`;
- `integer-out-of-range`;
- `timestamp-invalid`;
- `timestamp-order-invalid`.

Public read/decode failures require stable codes for:

- target not found;
- database failure;
- source read failure;
- snapshot JSON invalid;
- snapshot shape invalid;
- snapshot version unsupported;
- snapshot identity invalid;
- snapshot provenance mismatch;
- snapshot digest mismatch.

Their literal strings are: `match-identity-target-not-found`,
`match-identity-database-failure`, `match-identity-source-read-failure`,
`match-identity-snapshot-json-invalid`, `match-identity-snapshot-shape-invalid`,
`match-identity-snapshot-version-unsupported`,
`match-identity-snapshot-identity-invalid`,
`match-identity-snapshot-provenance-mismatch`, and
`match-identity-snapshot-digest-mismatch`.

Read precedence is database failure, source-read failure, target-not-found,
assessment diagnostics, then adaptation. Decode precedence is JSON syntax,
exact-key/type shape, schema version, strict identity, canonical
value/timestamp provenance, source digest, then snapshot digest. Incompatible
assessment is attributable with no snapshot.

## Public Read Boundary

Expose a Match-owned read-only application port for:

- assessment by explicit legacy Match ID;
- canonical snapshot by explicit Match ID when compatible;
- decoding a stored canonical snapshot;
- adapting a compatible snapshot to `ProductMatch` and `MatchAggregate`.

The port must not expose Drift types. Broader queries for Coach, Analytics,
Club, Equipment and Player are deferred to a later public-source slice after
FEATURE_007 lifecycle semantics are accepted.

## Persistence

No schema migration, cache or write path is expected. Repository support may
add a raw read query for the current Match table. Existing CRUD, numbering,
open-Match selection and recording coordination remain unchanged.

## Allowed Implementation Surfaces

- Match domain compatibility assessment/snapshot/adapter;
- Match application read port/service;
- lossless read-only support in the existing Match repository;
- focused unit and repository integration tests.

## Prohibited Scope

- schema, generated files, cache or UI changes;
- Match creation, update, finish, deletion or numbering changes;
- one-open-Match enforcement or transaction changes;
- MatchContext, Rack, Shot or Event integrity changes;
- participant identity inference or Player binding;
- lifecycle state-machine enforcement;
- changes to frozen foundation/domain/capability/runtime contracts;
- FEATURE_007 or later roadmap implementation.

## Acceptance Criteria

- Positive legacy IDs map deterministically to canonical Match and Session IDs.
- Zero/negative IDs remain attributable in raw assessment but cannot adapt.
- Compatible rows reproduce byte-identical canonical JSON and digests across
  repeated reads and SQLite close/reopen.
- Raw digest changes with exact storage; canonical digest follows only declared
  semantic equivalence.
- Malformed code, timestamp, ordering or identity produces ordered diagnostics
  and no partial canonical output.
- Snapshot tampering fails with stable precedence.
- Foundation representations preserve one semantic Match identity and Session
  reference, with no inferred participant or Rack identity.
- Existing Match/Session recording behavior and FEATURE_001-005 remain green.

## Required Evidence

- focused assessment, wire, digest, identity, alias, timestamp and tamper tests;
- repository tests for explicit read, missing target, corrupt raw row and
  SQLite close/reopen determinism;
- adapter tests proving identity equality across snapshot, `ProductMatch` and
  `MatchAggregate`;
- existing Match characterization and recording tests;
- FEATURE_001-005 regression, full app, Knowledge, Foundation Freeze,
  Architecture Fitness, analyzer, formatter and diff/scope checks;
- proof that schema, generated files, UI and frozen contracts are unchanged.

## Open Product Decisions

None currently. Engineering specification audit must report repository facts
that contradict this contract rather than broadening scope.

## Implementation Authorization

Product Owner accepted this specification after two read-only Engineering audit
rounds. `Code Pool OS` is authorized to implement exactly the allowed surfaces
and required evidence. It must return an Engineering Report without staging,
commit, push or FEATURE_007; repository closure requires PO review.
