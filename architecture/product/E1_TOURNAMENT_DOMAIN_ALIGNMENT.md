# E1 Tournament Domain Alignment And Gap Analysis

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

The original E1 Tournament Foundation packet was rejected after repository
inspection proved that Tournament is already a mature Product bounded context.
This milestone documents the existing implementation, identifies semantic
overlap and records an additive compatibility strategy. It creates no code,
schema, migration, capability, runtime, repository or UI.

## Bounded Context Ownership

| Concern | Current owner | Evidence | Boundary |
| --- | --- | --- | --- |
| Tournament lifecycle and format | Tournament domain | `Tournament`, `TournamentType`, `TournamentStatus` | Does not own recorded Match lifecycle |
| Entrants and seeding | Tournament domain | `TournamentParticipant` | `playerId` is a soft reference; Player remains external owner |
| Competition fixture slots | Tournament domain | `TournamentMatch` | `matchId` is a soft reference; Match remains external owner |
| Bracket layout | Tournament domain | `BracketGenerator`, `BracketLayout` | Generates Tournament slots, not Pool OS Match records |
| Standings projection | Tournament domain | `StandingCalculator`, `StandingRow` | Derived in memory; not persisted |
| Tournament persistence | Tournament repository | `TournamentRepository` | Maps three Drift tables; no ownership of Match rows |
| Product orchestration | Tournament presentation providers | `TournamentController`, Riverpod providers | Invalidates feature reads after repository mutations |
| Product experience | Tournament presentation | list/create/detail screens and four detail tabs | Existing user-facing MVP; unchanged by E1 |

Tournament is already a bounded context. Its cross-domain contracts are soft
integer references to Player and Match. Session and Training are not imported
or duplicated by the Tournament domain.

## Public API Map

### Domain Models

| API | Current semantic role |
| --- | --- |
| `TournamentType` | Single elimination, double elimination, round robin or league format code |
| `TournamentStatus` | Upcoming, active or completed lifecycle code |
| `TournamentCompetitionMode` | Individual or team mode flag |
| `Tournament` | Persisted competition aggregate data |
| `TournamentParticipant` | Persisted entrant/seed with optional Player soft reference |
| `TournamentMatch` | Persisted fixture/bracket slot with optional recorded Match soft reference |
| `StandingRow` | Derived participant standing row and fixed three-points-per-win projection |
| `TournamentHistoryEntry` | Derived tournament history presentation record |
| `BracketLayout` | Deterministic collection of generated `TournamentMatch` slots |

All model fields are final, but the models do not implement the shared
`ValueObject` equality contract. Their public `copyWith` methods are used as
replacement construction, not mutation. Nullable properties cannot currently
be explicitly cleared through `copyWith` because null means "retain existing".

### Domain Algorithms

| API | Current behavior |
| --- | --- |
| `BracketGenerator.orderBySeed` | Stable seed-first entrant ordering |
| `BracketGenerator.seedOrder` | Power-of-two elimination seed placement |
| `BracketGenerator.nextPowerOfTwo` | Elimination bracket sizing |
| `BracketGenerator.generate` | Elimination or all-pairs fixture layout |
| `BracketGenerator.parentSlot` | Winner advancement target |
| `StandingCalculator.standings` | Points/wins/rack-difference/name ordering |
| `StandingCalculator.championId` | Resolved elimination-final winner |
| `StandingCalculator.placementsFromStandings` | Placement map from an already sorted table |

### Repository

`TournamentRepository` owns these public operations:

- list, load, create, update, status change and delete Tournament records;
- list, add, remove and reseed participants;
- list fixtures, generate a bracket and record a fixture result;
- propagate elimination winners and close a completed tournament internally.

The repository directly owns orchestration that combines persistence and domain
algorithms. E1 does not move or duplicate that behavior.

### Providers And Controller

Public read providers expose Tournament list/detail, participants, matches,
standings and history. `TournamentController` exposes create/update/status/
delete, participant changes, bracket generation and result recording, then
invalidates the relevant read providers.

### UI And Routing

- `TournamentListScreen`: list, delete and create entry.
- `TournamentCreateScreen`: format/mode/options/dates form.
- `TournamentDetailScreen`: lifecycle actions and four tabs.
- `ParticipantsTab`: entrants and seeding.
- `BracketView`: fixture/bracket interaction.
- `StandingsTab`: derived table.
- `TournamentStatsTab`: existing feature statistics.
- Existing route: `/tournaments`.

No UI or route is changed by E1.

## Persistence Map

Schema version 19 introduced three additive Drift tables:

| Table | Purpose | Cross-domain references |
| --- | --- | --- |
| `tournaments` | Competition identity, format, mode, lifecycle, dates and metadata | None |
| `tournament_participants` | Entrant name/seed | Nullable `player_id` soft reference |
| `tournament_matches` | Fixture slot, sides, winner, scores and bracket group | Nullable `match_id` soft reference |

There are intentionally no foreign keys or cascades into Player or Match. The
repository manually deletes Tournament-owned participant and fixture rows while
leaving recorded Matches untouched. E1 preserves this compatibility contract.

## Concept Alignment

| Proposed concept | Existing equivalent | Alignment decision |
| --- | --- | --- |
| Tournament | `Tournament` | Keep; never recreate |
| Fixture | `TournamentMatch` | Same persisted semantic role; do not add `Fixture` |
| Fixture identity | `TournamentMatch.id` | Existing DB identity; a future typed identity must adapt, not replace |
| Standing entry | `StandingRow` | Same derived role; do not add `StandingEntry` |
| Standing | `List<StandingRow>` from `StandingCalculator` | Existing projection; no wrapper needed without a concrete consumer |
| Bracket | `BracketLayout` plus persisted `TournamentMatch` rows | Existing structure; do not add `Bracket` |
| Bracket node | `TournamentMatch` round/slot/group coordinates | Existing node role; no parallel node model |
| League | `TournamentType.league` | Only a format flag today, not a League aggregate |
| Schedule | round/slot ordering only | No scheduling domain currently exists |

## Genuine Gaps

The following concepts are absent and may justify later product milestones:

- `Season`: no time-bounded league/tournament grouping.
- `Division`: no competitive tier or grouping within a season.
- `League` aggregate: `TournamentType.league` only selects all-pairs fixtures
  and points presentation; it has no identity, membership or season ownership.
- Schedule: no planned date/time, venue assignment, round calendar or conflict
  model. Round-robin fixtures currently all use `roundIndex == 0`.
- Promotion/relegation: absent.
- Federation/organizer authority: absent.
- Ranking period and rating policy: absent.
- Team aggregate: `TournamentCompetitionMode.team` is a flag, while entrants
  remain name/player records with no Team identity or roster.
- Versioned identity/provenance/compatibility: domain IDs are nullable database
  integers and enum decoders silently fall back for unknown codes.

These are findings only. E1 does not implement them.

## Behavioral Gaps And Risks

- Double-elimination shares the opening elimination layout, but no complete
  losers-bracket generation/advancement model is present.
- Round-robin/league generation produces every unordered pair but does not
  construct playable rounds or a calendar.
- `StandingRow.points` hard-codes three points per win; no tournament policy
  owns alternative scoring or tie-break rules.
- Domain documentation says Tournament type is fixed after creation, while
  `copyWith` and repository update currently permit changing it.
- Enum `fromCode` methods fail open to defaults, which can mask unsupported
  persisted values.
- `TournamentHistoryEntry` and its provider do not bind history to a specific
  Player identity; champion/placement semantics are field-wide.
- Domain objects are structurally immutable but lack value equality,
  canonical serialization, version and provenance.

These risks require separate authorized changes because correcting them may
affect persistence, UI behavior and backward compatibility.

## Evolution Matrix

| Artifact | Action | Rationale / constraint |
| --- | --- | --- |
| `Tournament` | Extend later | Preserve name, table mapping and route consumers; add semantics only additively |
| `TournamentParticipant` | Extend later | Preserve entrant persistence; Team/roster support needs a separate decision |
| `TournamentMatch` | Keep | Canonical existing Fixture; no rename without adapter and migration plan |
| `StandingRow` | Keep | Canonical current StandingEntry projection |
| `TournamentHistoryEntry` | Extend or deprecate later | Needs explicit Player binding before expansion |
| `TournamentType.league` | Keep as legacy format | Must not be mistaken for a future League aggregate |
| `BracketLayout` | Keep | Existing deterministic bracket result |
| `BracketGenerator` | Extend/correct later | Preserve current consumers; double-elimination/schedule work needs explicit packet |
| `StandingCalculator` | Extend behind policy later | Preserve current 3-point behavior until a versioned policy exists |
| `TournamentRepository` | Keep | Existing persistence owner; no second repository |
| Tournament providers/controller | Keep | Existing Product orchestration surface |
| Tournament UI and `/tournaments` | Keep | Existing MVP compatibility surface |
| Season, Division, League aggregate | Add only in later authorized milestone | Genuine missing concepts with distinct ownership |

No rename, merge or deprecation is executed in E1.

## Compatibility Strategy

1. Preserve existing class names, enum string codes, Drift tables, provider
   names and `/tournaments` route.
2. Treat `TournamentMatch` as the canonical persisted Fixture and
   `StandingRow` as the canonical current StandingEntry.
3. Use additive adapters before any future typed identity or value-object
   hardening; do not change stored integer IDs in place.
4. Add Season/Division/League ownership outside existing Tournament rows only
   after a schema and migration packet is explicitly authorized.
5. Preserve Match and Player as external owners through soft references; never
   import their persistence internals into Tournament domain logic.
6. Version scoring, scheduling and format compatibility before changing current
   calculation behavior. Existing data must remain readable.
7. Do not create P6 capability or P8 runtime registration until a real
   cross-capability execution requirement is demonstrated.
8. Add characterization tests before any implementation milestone changes the
   existing bracket, standings, repository or history semantics.

## Accepted Product Policies

- The current Tournament is a legacy aggregate and permanent compatibility
  surface. Future work may extend it but must not rewrite it.
- League is an independent future aggregate. `TournamentType.league` remains a
  legacy format code and must not evolve into the League aggregate.
- Future ownership is `League -> Seasons -> Divisions -> Tournament references`;
  Tournament remains independently valid.
- Team support is optional; individual and team tournaments must coexist.
- `StandingRow` remains an immutable projection and must never become an
  aggregate. Future ranking ownership belongs elsewhere.
- `BracketLayout` remains a presentation/layout structure. Future bracket
  semantics must be introduced behind compatibility adapters.

## Verification

- Repository inventory covers domain, algorithms, repository, persistence,
  providers, UI, routing and existing Task 13 tests.
- Duplicate concept mapping is explicit.
- Genuine missing concepts are separated from existing equivalents.
- Existing Tournament characterization tests: 20/20.
- Full app regression: 1184/1184.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- `git diff --check`: clean.
- No Product code, schema, tests, UI, runtime or framework was changed.
- Architecture Fitness remains the required cross-domain verification gate.
- Diff is limited to the revised E1 documentation allowlist.

## Repository State

Product Owner accepted E1 on 2026-07-24 and authorized repository commit and
push without implementation changes.
