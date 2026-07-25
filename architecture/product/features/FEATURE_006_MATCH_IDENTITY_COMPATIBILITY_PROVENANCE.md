# FEATURE_006 Match Identity Compatibility And Provenance

Version: 1.0

Status: Proposed; Pending Engineering Specification Audit

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

Raw assessment accepts signed SQLite integer IDs so corrupt rows remain
attributable. Canonicalization requires positive Match ID, Session ID and
Match number. Invalid identity produces diagnostics and no partial canonical
snapshot or foundation representation.

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
Malformed nullable values and signed IDs must remain attributable whenever the
database driver can return them.

`rawAssessmentDigest` hashes a canonical wire object containing the exact raw
values. It changes when raw storage changes, including semantically equivalent
text or timestamps represented differently.

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

## Canonicalization Rules

- Required string codes must be exact accepted stored codes; no silent fallback.
- Existing supported game type aliases may normalize only through an explicit,
  versioned alias table proven from persisted compatibility evidence.
- Optional free text preserves content exactly and rejects null bytes.
- Timestamp values must be representable as Dart UTC instants before any unit
  multiplication; overflow fails closed.
- End time before start time is incompatible.
- Created time is provenance, not a lifecycle transition time.
- Lists of participants are not inferred from opponent/partner text.
- A legacy Match maps to one `ProductMatch` with the canonical Match ID, one
  Session ID and an empty participant-ID list.
- `MatchAggregate.root` is that same `ProductMatch`; `rackSessionIds` remains
  empty because Rack identities are not part of this source row.

## Digest Semantics

`sourceDigest` hashes canonical parsed Match meaning. It is stable across only
those raw representations declared equivalent by the versioned compatibility
rules. `digest` hashes the complete canonical snapshot excluding `digest`.

All digest payloads use UTF-8 JSON, exact documented key order, no whitespace
and SHA-256 lowercase hexadecimal. Decode recomputes identity, provenance,
source digest and snapshot digest; it never trusts serialized digest fields.

Engineering audit must lock the exact raw and canonical wire-key tables before
implementation. If existing timestamp/code behavior makes semantic equivalence
ambiguous, return a precise blocker rather than inventing a rule.

## Diagnostics And Failure Contract

Compatibility diagnostics are deterministic and ordered by canonical field
order, optional list index, then diagnostic-code precedence. Required codes:

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

Precedence is database/source failure, target-not-found, assessment diagnostics,
then adaptation. Incompatible assessment is a successful attributable result
with no snapshot; infrastructure and serialized-snapshot failures are typed
failures.

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

None. Engineering may perform a read-only specification/repository audit only.
Implementation requires separate Product Owner acceptance and authorization.
