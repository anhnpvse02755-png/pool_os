# E3 Player Domain Alignment And Gap Analysis

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

Player is an existing Product bounded context. E3 inventories its current
identity/profile aggregate, compatibility surfaces and cross-domain reads before
Product Expansion. This is documentation-only: no code, schema, repository,
persistence, provider, UI, API, runtime, framework, capability or migration is
introduced.

## Bounded Context Ownership

| Concern | Current owner | Evidence | Boundary |
| --- | --- | --- | --- |
| Player identity and editable profile | Player domain | legacy `Player`, foundation `PlayerProfile` | Does not own match, training, club or tournament lifecycle |
| Local active-player selection | Player repository | `isActive`, `getActivePlayer`, `setActivePlayer` | Local application preference, not account identity |
| Profile preferences | Player domain | dominant hand, locale, units, play styles, training goals | Self-declared metadata, not Evidence or inferred mastery |
| Career profile view | Player presentation | `PlayerProfileService`, `PlayerProfileState` | Composite read model over external owners |
| Readiness, fatigue and form | Player State domain | `features/player_state/` | Separate bounded context |
| Deterministic progress/mastery | Player Model contracts | `PlayerProgressSnapshot`, `PlayerModelState` | Separate projection; Player profile is only an input |
| Match/session/training history | Match, Session and Training domains | external repositories | Player may reference or display it, never own it |
| Club membership | Club domain | `ClubMember` | `Player.clubRegion` is profile metadata only |
| Tournament participation | Tournament domain | participants and Tournament records | Player does not own fixtures, brackets or standings |

The foundation `domain/entities/PlayerProfile` is the typed, versioned entity
direction. The persisted `features/player/domain/models/Player` remains the
legacy Product aggregate and compatibility surface. The two are not independent
sources of truth; future work needs an explicit adapter before changing either.

## Public API Inventory

### Domain Models And Contracts

| API | Current semantic role |
| --- | --- |
| `Player` | Persisted legacy identity, settings and career-profile aggregate |
| `PlayStyles` | String-code catalog for self-declared style preferences |
| `TrainingGoals` | String-code catalog for self-declared goals |
| `SkillLevel` | Unpersisted display taxonomy; not computed Player Model mastery |
| `PlayerProfile` | Foundation entity with typed `PlayerId`, version and lifecycle state |
| `PlayerProfileContract` | Immutable Coach/Player Model input boundary |
| `PlayerProfileProjectionContract` | Product-shell projection bound to progress and shell digests |
| `ProfileAchievements` | Read-only profile projection from Match/Rack history |
| `TimelineEntry` / `TimelineKind` | Read-only career timeline projection |

The legacy `Player` has final fields and replacement `copyWith`, but lacks value
equality, schema/contract version, provenance, canonical serialization and typed
identity. Its constructor and `monthsPlaying` use wall-clock time. Nullable
`copyWith` properties cannot be explicitly cleared. List fields are exposed
without defensive copying.

Two Knowledge services also declare local classes named `PlayerProfile`. Those
are recommendation-input shapes, not the Player aggregate or its canonical
cross-domain contract. New integrations must use accepted public contracts and
must not introduce another Player profile source of truth.

## Repository Inventory

`PlayerRepository` is the sole Player persistence gateway and exposes:

- list all Players and load a Player by id;
- legacy `getPlayer` single-row lookup;
- create, update and delete Player rows;
- resolve and change the locally active Player.

`createPlayer` always persists `isActive = true`, regardless of the supplied
value. `setActivePlayer` deactivates all rows and then activates the requested
row through two statements without an explicit transaction. `getActivePlayer`
returns the first active row, or falls back to the first row when none is active.
The schema has no uniqueness constraint for the active Player invariant.

`PlayerProfileService` is a read-only composition service. It directly reads
Session, Match and Rack repositories to calculate achievements and timeline.
Those records remain owned by their source domains; the service owns only the
profile-facing projection.

## Persistence Inventory

The `players` Drift table stores:

- integer identity, display name and active flag;
- dominant hand, language, measurement system and theme;
- optional avatar path, age, gender, region, rank, main game and free-text goal;
- JSON-encoded play-style and training-goal lists;
- playing start date, competition flag and weekly hours;
- creation and update timestamps.

Profile fields were added at schema version 15; the application database is now
schema version 25. Existing tests prove profile round-trip and restart durability.
There are no database constraints for one active Player, age/rank codes or list
vocabulary. Malformed list JSON is silently converted to an empty list.

`AppDatabase` and `databaseProvider` are physically located under the Player
feature but contain and expose tables for most Product domains. Match, Rack,
Session, Training, Tournament, Club, Equipment, Career, Event, Goals,
Statistics, Mastery and other repositories consequently import Player data
paths. This is legacy shared-infrastructure placement, not Player ownership of
those domains. E3 does not relocate it or change persistence boundaries.

## Provider Inventory

| Provider/state | Current responsibility |
| --- | --- |
| `playerRepositoryProvider` | Creates the Player repository from shared database provider |
| `playerNotifierProvider` / `PlayerNotifier` | Multi-player CRUD, local active selection and dashboard/statistics refresh |
| `playerProfileProvider` / `PlayerProfileNotifier` | Loads/saves active profile and composes achievements, timeline and cues |
| `playerProfileServiceProvider` | Composes Session/Match/Rack read repositories |
| `databaseProvider` | Provides the application-wide Drift database despite its Player namespace |

`PlayerNotifier` and `PlayerProfileNotifier` both load and update the active
Player through separate state trees. Their refresh/invalidation behavior is not
unified. `PlayerNotifier` also directly triggers Dashboard and Statistics
presentation providers, creating existing outward coupling.

## UI Inventory

- `PlayerProfileScreen` renders the active career profile.
- `PlayerProfileEditSheet` edits identity, preferences and career metadata.
- `player_profile_sections.dart` renders equipment, achievements and timeline
  projections owned by their source data domains.
- `/profile` is the existing route, reached from Settings.
- Club member and Tournament participant experiences consume the existing
  Player provider for selection/display.

E3 changes none of these surfaces.

## Cross-Domain Dependency Map

| Direction | Current dependency | Alignment decision |
| --- | --- | --- |
| Player presentation -> Equipment | Active cues for profile display | Keep as a read projection; Equipment retains ownership |
| Player profile service -> Session/Match/Rack | Achievements and timeline | Existing technical debt; migrate to public read ports only when required |
| Player notifier -> Dashboard/Statistics | Imperative refresh | Existing presentation coupling; do not copy into new Player APIs |
| Club/Tournament -> Player provider | Member/participant selection | Preserve existing compatibility surface |
| Settings -> Player repository | Locale/theme persistence | Preserve until a dedicated settings/account owner is approved |
| Coach/Player Model -> `PlayerProfileContract` | Deterministic input | Preserve accepted contract and Player identity binding |
| Product repositories -> Player database paths | Shared Drift infrastructure | Namespace debt, not reverse domain ownership |

## Concept Alignment

| Future concept | Existing equivalent | Alignment decision |
| --- | --- | --- |
| Player | legacy `Player` plus foundation `PlayerProfile` | One semantic aggregate; bridge with an adapter, never duplicate |
| Player identity | integer `Player.id`, typed `PlayerId`, contract string id | Preserve all compatibility forms until an explicit identity migration |
| Player preferences | dominant hand, locale, styles and goals | Keep self-declared; never infer or overwrite from Intelligence |
| Skill level | legacy `SkillLevel` / rank metadata | Descriptive only; Player Model owns computed progression |
| Active Player | `isActive` repository convention | Keep local selection behavior; not authentication/account identity |
| Career achievements | `ProfileAchievements` | Projection only; source domains remain authoritative |
| Career timeline | `TimelineEntry` | Projection only; not Event Log ownership |
| Player state | `features/player_state/` | Independent bounded context; never fold into profile |
| Player model | accepted Player Model contracts | Independent deterministic projection; never persist inside Player profile |
| Club membership | `ClubMember` | Club-owned; region metadata is not membership |
| Tournament participation | Tournament participants | Tournament-owned soft association |

## Ownership And Compatibility Risks

- The shared application database lives under Player paths, making unrelated
  domains appear to depend on Player internals and obscuring true ownership.
- Three identity representations exist: integer database id, typed `PlayerId`
  and string contract id. No documented mapping currently binds them.
- The legacy and foundation Player profile models can drift without an adapter
  and compatibility tests.
- Multiple active rows are possible; active-player changes are not atomic and
  creation ignores the supplied active flag.
- `getPlayer` assumes zero or one row and is ambiguous beside multi-player APIs.
- Player deletion has no documented policy for external soft references.
- Profile achievements/timeline use direct cross-domain repositories and an
  embedded threshold, rather than versioned public projection ports/policy.
- `monthsPlaying`, update timestamps and some projections depend on wall-clock
  time, so replay is not deterministic.
- JSON list decoding and unknown string codes fail open or silently degrade.
- Two Player state notifiers can become stale relative to one another.
- Player presentation triggers Dashboard/Statistics refresh directly.
- Settings, career metadata and gameplay preferences are co-located in the
  legacy row without explicit sub-contract versions.
- Age is stored rather than derived from a dated fact and has no validation.
- Local avatar paths and profile fields have no privacy/consent classification.

## Genuine Missing Concepts

The following are absent and may justify later value-specific milestones:

- authoritative adapter between legacy `Player`, foundation `PlayerProfile`
  and `PlayerProfileContract`;
- stable identity mapping/version and cross-device identity semantics;
- explicit profile contract version, provenance and canonical digest;
- atomic active-player invariant and multi-profile lifecycle policy;
- deletion/deactivation policy for externally referenced Players;
- public read ports for career achievements and timeline composition;
- privacy/consent and data-export classification for profile attributes;
- validated value objects for dominant hand, locale, rank/game and preferences;
- account/device identity separated from the local Player aggregate;
- deterministic clock policy for derived tenure and timeline views;
- synchronization/merge semantics when a concrete multi-device requirement
  exists.

These are findings only. E3 implements none of them.

## Evolution Matrix

| Artifact | Action | Rationale / constraint |
| --- | --- | --- |
| legacy `Player` | Keep as compatibility aggregate | Existing schema, repository, settings and UI depend on it |
| foundation `PlayerProfile` | Keep as canonical entity direction | Typed identity/version/lifecycle; requires an adapter before Product use |
| `PlayerProfileContract` | Keep | Accepted deterministic cross-domain boundary |
| `PlayerProfileProjectionContract` | Keep as projection | Never replace the identity/profile aggregate |
| `PlayStyles` / `TrainingGoals` | Keep as legacy code catalogs | Future typed values must preserve stored codes |
| `SkillLevel` | Keep descriptive or deprecate only via explicit packet | Must not compete with Player Model mastery |
| `PlayerRepository` | Keep | Sole current Player persistence owner |
| `PlayerProfileService` | Keep as compatibility projection service | Future reads should migrate behind public ports |
| Player providers | Keep | Characterize synchronization before consolidation |
| `players` table | Keep | Additive migration only under a separately authorized packet |
| shared `AppDatabase` location | Record as debt | Relocation is cross-domain infrastructure migration, outside E3 |
| Player profile UI and `/profile` | Keep | Existing Product compatibility surface |

No rename, merge, deprecation or implementation occurs in E3.

## Compatibility Strategy

1. Preserve current table/column names, stored string codes, repository/provider
   APIs and `/profile` route.
2. Treat legacy `Player` and foundation `PlayerProfile` as two representations
   of one semantic aggregate; introduce a tested adapter before either evolves.
3. Preserve accepted Player Model and projection contracts; do not move
   mastery, mistakes, readiness or inferred state into Player profile.
4. Preserve Match, Training, Session, Club, Tournament and Equipment ownership.
5. Add public read adapters before replacing direct cross-domain profile reads;
   never create a second history or achievement source of truth.
6. Resolve identity mapping and deletion behavior before adding remote sync,
   account linkage or cross-device features.
7. Make active selection atomic and versioned only under a schema/repository
   packet with migration and characterization tests.
8. Keep the shared database placement unchanged until a dedicated
   infrastructure migration proves compatibility across every consumer.
9. Fail closed for new unsupported codes through versioned adapters while
   retaining readability of existing rows.
10. Add characterization tests before changing Player persistence, active
    selection, profile projection, provider synchronization or identity.

## Verification

- Inventory covers domain models/contracts, repository, persistence, providers,
  UI, routing and existing profile tests.
- Existing concepts are separated from genuine gaps and external ownership.
- Evolution and compatibility decisions are additive and ownership-preserving.
- Existing Player characterization tests: 4/4.
- Full app regression: 1184/1184.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Analyzer: no errors; unchanged repository baseline of 62 lint infos.
- `git diff --check`: clean.
- No Product code, schema, tests, UI, runtime or framework was changed.
- Protected generated artifacts are unchanged.
- Diff is limited to the exact E3 documentation allowlist.

## Repository State

Product Owner accepted E3 on 2026-07-24 and authorized repository commit and
push without implementation changes.

## Accepted Product Policies

- Player remains intentionally small and must not absorb Match, Training,
  Statistics, Mastery or Coach ownership.
- There is exactly one semantic Player profile. Adapters between accepted
  representations are allowed; new duplicate Player profile models are not.
- Identity evolution proceeds through compatibility adapters, never wholesale
  replacement of integer identities.
- The database namespace placement is accepted technical debt and must not be
  relocated during Product Expansion.
- `PlayerProfileService` owns profile projections only and never becomes the
  owner of Match or Training information.
