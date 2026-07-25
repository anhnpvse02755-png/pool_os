# FEATURE_005 Player Profile Compatibility And Provenance

Version: 1.0

Status: Proposed; Pending Engineering Specification Audit

Candidates: E3-G01 and E3-G03 (Essential)

## Goal

Create one deterministic Player-owned compatibility boundary between the
persisted legacy `Player`, the foundation `PlayerProfile` direction, and the
accepted `PlayerProfileContract`. Every downstream consumer can identify which
local Player row produced a profile representation, which adapter policy was
used, and whether the representation is compatible without inventing defaults.

This feature does not replace the legacy aggregate or migrate Player identity.
It adds a canonical derived snapshot and read adapter over the existing Player
source of truth.

## User Value

Profile-based learning, Coach and future Equipment Fit features cannot silently
use a different Player, stale profile fields, unsupported stored codes or an
untraceable profile conversion. Existing local profiles remain readable and
editable through the current UI.

## Ownership

Player owns:

- mapping its existing persisted profile into accepted Player representations;
- profile compatibility policy, diagnostics, version and provenance;
- canonical profile serialization and digest;
- public read access to a derived profile snapshot by Player identity.

Player does not own Player Model, Match, Training, Equipment, Knowledge, Coach,
Club, Tournament, account/device identity, sync or cross-device identity.

The existing `PlayerRepository` remains the sole persistence gateway. The new
adapter is a Player application/domain boundary and must not import another
domain's persistence implementation.

## Source Of Truth

The `players` row remains the only persisted editable profile source. The
foundation entity, cross-domain contract and new canonical snapshot are derived
representations, not independent aggregates and not writable stores.

`isActive` is a local selection lifecycle from FEATURE_004, not profile content.
Changing Active Player cannot change the canonical profile digest of either
Player.

## Identity Compatibility

For every persisted Player with positive integer ID `N`:

- legacy identity is integer `N`;
- foundation identity is `PlayerId(N.toString())`;
- foundation canonical identity is `entity.player:N`;
- `PlayerProfileContract.playerId` is exactly `entity.player:N`;
- source reference is exactly `player:N`.

The mapping is bijective for positive local IDs and versioned by adapter policy.
Parsing accepts only the exact canonical form and rejects zero, negative,
whitespace, signs, leading zeros, alternate namespaces and non-decimal values.

This local compatibility mapping is not a global/cross-device identity and must
not be used as an account, device or sync key.

## Canonical Snapshot V1

Player owns immutable `CanonicalPlayerProfileSnapshot` version 1 with:

- `schemaVersion`;
- `adapterPolicyVersion`;
- `legacyPlayerId`;
- `canonicalPlayerId`;
- `sourceReference`;
- `sourceSchemaVersion`;
- `sourceCreatedAt` and `sourceUpdatedAt` in canonical UTC;
- canonical editable profile fields from the legacy row;
- compatibility status and ordered diagnostics;
- `sourceDigest` over canonical source facts;
- `digest` over the complete snapshot payload excluding `digest`.

Canonical editable fields are name, dominant hand, language, measurement
system, theme, avatar path, age, gender, club region, rank, main game, goal,
play styles, training goals, started-playing date, competition flag and weekly
hours. Nullable fields remain explicitly `null`; absence is never replaced with
display defaults.

`isActive`, achievements, timeline, cues, readiness, mastery, inferred skill,
statistics and wall-clock-derived tenure are excluded.

JSON keys use a fixed order. UTC timestamps use one canonical representation.
Set-like play-style and training-goal codes are trimmed, de-duplicated and
sorted before digesting. Other strings preserve stored semantic text except for
validation that forbids empty required values and null bytes.

The snapshot is derived on read and is not persisted as another profile row or
cache in v1.

## Provenance Contract

Provenance is generated only from the persisted Player row and adapter policy:

- source kind: `legacy-player-row`;
- source reference: `player:<positive-id>`;
- source schema version: current Drift schema version used for the read;
- adapter policy version: `1`;
- source timestamps: persisted `createdAt` and `updatedAt` normalized to UTC;
- source digest: SHA-256 of canonical source facts.

No caller may supply or override provenance, digests, identity mapping, schema
version or source timestamps. Two reads of byte-equivalent source facts produce
byte-identical JSON and digests. Updating a canonical profile field changes the
source digest and snapshot digest. Switching Active Player alone changes
neither.

## Representation Adapter

For a compatible snapshot the adapter exposes:

1. Foundation `PlayerProfile`:
   - `id`: mapped foundation `PlayerId`;
   - `version`: adapter policy version 1;
   - `createdAt`: persisted profile creation timestamp in UTC;
   - `displayName`: exact validated name;
   - `lifecycleState`: stable code `available` while the local row exists.
2. `PlayerProfileContract`:
   - canonical player ID defined above;
   - dominant hand from the profile;
   - locale from language;
   - preferences as ordered namespaced codes `play-style:<code>` and
     `training-goal:<code>`;
   - empty `historyReferences`, because Match/Training history belongs to source
     domains and cannot be inferred by this adapter.

`available` means the local profile row exists. It does not mean Active Player,
account enabled, online, selected, authenticated or undeletable.

The adapter must expose the canonical snapshot/digests alongside these
representations so consumers never receive an unprovenanced conversion.

## Compatibility And Diagnostics

Compatibility evaluation is deterministic and fail-closed. Stable diagnostics
cover at least:

- invalid/missing persisted Player ID;
- empty required name, dominant hand, language, measurement system or theme;
- invalid source timestamp or `updatedAt` earlier than `createdAt`;
- malformed stored list JSON;
- empty, duplicate or unsupported preference codes;
- unsupported dominant-hand, language, measurement-system or theme codes;
- invalid canonical identity/reference;
- digest/provenance mismatch when decoding a serialized snapshot.

An incompatible profile returns typed ordered diagnostics and no foundation or
cross-domain representation. It must not silently drop malformed list data,
substitute defaults, use the Active Player, or partially construct a contract.

Legacy profile UI readability is preserved: this feature does not prevent the
existing repository/UI from displaying or correcting an old row. The strict
boundary applies when requesting a canonical compatibility snapshot.

Supported-code policy v1 is derived from existing persisted UI catalogs and
localization codes. Engineering must inventory actual accepted codes and lock
them in tests; it must not create new user-visible choices.

## Public Read Boundary

Expose read-only operations for:

- canonical snapshot by explicit positive legacy Player ID;
- canonical snapshot for the strict Active Player from FEATURE_004;
- decoding/verifying canonical snapshot JSON;
- adapting a compatible snapshot to the two accepted representations.

Explicit-ID reads never fall back to Active Player. Active reads return `null`
only for valid empty Player storage. Missing target, incompatible profile,
invalid Active Player state and database failure remain distinguishable stable
failures.

No write operation accepts a foundation entity, contract or snapshot as a
profile update command.

## Persistence And Migration

No schema migration is expected. FEATURE_005 adds no profile table, identity
column, digest column or compatibility cache. It reads the existing v29 row and
derives versioned output.

If Engineering evidence proves a schema change is unavoidable, implementation
must stop and return a specification blocker; it may not expand scope.

## Allowed Surfaces

- `app/lib/features/player/` compatibility snapshot, adapter, public read port
  and repository read support;
- existing foundation `PlayerProfile` and `PlayerProfileContract` imports as
  read-only target contracts;
- focused tests and compatibility characterization tests;
- this specification, Handoff and project memory at workflow transitions.

## Prohibitions

Do not add or change:

- Player database identity, profile columns or Active Player lifecycle;
- foundation entity or `PlayerProfileContract` schemas/versions;
- profile edit UI, routes or user-visible field catalog;
- account, authentication, device or global/cross-device identity;
- sync, merge, conflict resolution or cloud storage;
- external-reference deletion/deactivation policy (E3-G05);
- privacy/consent/export classification (E3-G07);
- validated replacement value objects for persisted fields (E3-G08);
- Match/Training history ownership or inferred history references;
- FEATURE_001-004 canonical contracts;
- FEATURE_006 or any later roadmap implementation.

## Acceptance Criteria

- Every valid positive legacy ID maps bijectively to one canonical foundation
  ID, contract ID and source reference.
- Canonical JSON/digests are deterministic across repeated reads, restart and
  input list order.
- Active selection changes do not change either Player's profile digest.
- Canonical profile updates change digest; no-op equivalent source facts do not.
- Nullable fields stay explicitly null and malformed values never become
  defaults.
- Compatible rows adapt to both accepted representations with the exact mapping
  above.
- Incompatible rows produce stable ordered diagnostics and no partial output.
- Explicit-ID reads never substitute Active Player.
- Empty storage has no active snapshot; invalid non-empty Active Player state
  fails closed through FEATURE_004.
- Serialized snapshots verify schema, identity, provenance and both digests on
  decode; tampering is rejected.
- Legacy profile UI, persistence and FEATURE_001-004 regressions remain green.
- No schema/generated output change is present.

## Required Evidence

- identity mapping and strict reverse-parsing tests;
- full-field legacy row to canonical snapshot characterization;
- foundation and contract adapter mapping tests;
- deterministic JSON/source digest/snapshot digest under reversed list input;
- explicit null and timestamp normalization tests;
- unsupported/malformed code and list diagnostics;
- no Active Player fallback on explicit-ID miss;
- Active Player switch digest-invariance test;
- profile update digest-change and no-op stability tests;
- serialized round-trip and tamper rejection for every protected field;
- SQLite close/reopen determinism;
- FEATURE_004 lifecycle regression and FEATURE_001-003 regression;
- full app, Knowledge, Foundation Freeze, Architecture Fitness, analyzer,
  formatter and `git diff --check`.

## Audit Resolution Contract

The following rules refine and override any less-specific wording above.

### Lossless Source Assessment

Player first creates immutable `PlayerProfileSourceAssessment` v1 from a
repository-owned lossless source record. The record retains exact raw scalar
values and exact raw `play_styles`/`training_goals` JSON and must not pass
through lossy `Player.decodeList`.

Assessment always contains `schemaVersion`, `adapterPolicyVersion`,
`sourceKind`, source reference/schema/timestamps, raw facts, ordered diagnostics
and a source digest. Malformed data remains attributable in this assessment.
Only a compatible assessment can create `CanonicalPlayerProfileSnapshot`; an
incompatible assessment creates no canonical/foundation/contract output.

Raw list JSON is compatible only when it is an array of case-sensitive strings.
Each code is trimmed, non-empty and unique after trimming. Non-array,
non-string, empty or duplicate-after-trim input is incompatible. Diagnostics
sort by canonical field order, list index, then diagnostic code.

### Supported Codes And Aliases

Policy v1 accepts every live compatibility code without rewriting persistence:

- dominant hand: `left`, `right`;
- language source: `vi`, `en`, `vietnamese`, `english`;
- canonical locale: `vi|vietnamese -> vi`, `en|english -> en`;
- measurement source: `cm`, `in`, `inch`, `metric`, preserved exactly because
  `PlayerProfileContract` has no measurement field;
- theme: `system`, `light`, `dark`;
- rank: null or `H`, `G`, `F`, `E`, `D`, `C`, `B`, `A`;
- main game: null or `9 Ball`, `10 Ball`, `8 Ball`;
- play styles: `safe`, `attack`, `fast`, `steady`, `control`, `power_break`;
- training goals: `rank_up`, `break_power`, `position`, `jump`, `safety`,
  `tournament`.

Unknown codes remain in raw assessment with an unsupported diagnostic and do
not produce canonical output. No UI option is added. Leading/trailing whitespace
in required name is incompatible because foundation `NonEmptyString` would
otherwise silently trim it; compatible display name is exact.

### Exact Wire And Digest Rules

Canonical snapshot fields include `sourceKind: legacy-player-row`. JSON key
order is the field-list order, then canonical profile fields,
`compatibilityStatus`, `diagnostics`, `sourceDigest`, `digest`. Encoding is
compact UTF-8. Digests are lowercase 64-character SHA-256 hex.

`sourceDigest` hashes the lossless assessment source payload excluding
diagnostics and digests. Snapshot `digest` hashes the complete canonical payload
excluding only `digest`. Missing/extra keys, wrong types, unknown versions,
non-canonical order, cross-field identity mismatch and digest mismatch fail.

`createdAt`/`updatedAt` are instants serialized as UTC ISO-8601 with six
fractional digits and `Z`. `startedPlayingAt` is a calendar date serialized as
`YYYY-MM-DD` without timezone conversion. Nullable fields remain JSON null.

Exact identity parsing belongs to the adapter. It validates positive SQLite
integer bounds before constructing foundation values, rejects overflow and
requires round-trip equality among legacy ID, canonical ID, contract ID and
source reference.

### Result And No-Op Semantics

Stable operation failures distinguish target missing, Active Player invariant,
database failure, raw source decode failure, unsupported snapshot version and
provenance/digest mismatch. Compatibility diagnostics are not exceptions and
are returned only through source assessment.

No-op stability means repeated derivation from identical source facts. This
feature does not change `updatePlayer()` write/timestamp behavior.

Required tests additionally cover raw non-array/non-string JSON,
duplicate-after-trim, every alias, stable diagnostics, name whitespace/null
bytes, UTC+7 calendar boundaries, instant microseconds/reopen, missing/extra/
wrong-type keys, SQLite integer bounds/overflow and cross-field ID mismatch.

## Open Product Decisions

None. First-audit questions were resolved conservatively from live compatibility
evidence: existing aliases remain accepted without persistence rewrite;
calendar-date semantics are preserved; no-op stability is read-only; and
lossless raw assessment is separate from canonical output. Any later discovery
requiring schema, UI, identity or supported-code expansion must be returned as
a blocker instead of inferred.

## Implementation Authorization

None. Engineering may audit this specification and repository evidence only.
Implementation requires a separate Product Owner acceptance and authorization.
