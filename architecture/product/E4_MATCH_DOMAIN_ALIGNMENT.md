# E4 Match Domain Alignment And Gap Analysis

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

Match is an existing Product bounded context with legacy recording behavior,
foundation domain structures and accepted capability/runtime integration. E4
characterizes those surfaces before Product Expansion. This is documentation-
only: no code, schema, repository, runtime, framework, UI, persistence,
migration or capability change is introduced.

## Bounded Context Ownership

| Concern | Current owner | Evidence | Boundary |
| --- | --- | --- | --- |
| Match identity, metadata and lifecycle | Match | legacy `Match`, foundation `ProductMatch`/`MatchAggregate` | Does not own parent Session or child records |
| Match context observations | Match | `MatchContext` | Match-scoped observations, not durable Player State |
| Match persistence | Match | `MatchRepository`, `MatchContextRepository` | Plain CRUD; transaction orchestration remains external |
| Match command boundary | Match application | `MatchRecordingService` | Uses accepted command/capability/runtime foundations |
| Recording transaction integrity | Session | `RecordingCoordinator` | Choke-point for Session -> Match -> Rack -> Shot -> Event |
| Rack order and outcomes | Rack | `Rack`, `RackRepository` | Match projects score from Rack results |
| Shot and Event facts | Shot and Event | their repositories/models | Match never becomes Evidence owner |
| Player identity/profile | Player | Player domain/contracts | Match stores legacy opponent/partner text, not Player profiles |
| Tournament fixture/bracket | Tournament | `TournamentMatch` and Tournament aggregate | Recorded Match is not a Tournament fixture |
| Training intent/plan | Training | Training domain | Practice/drill may reuse recording pipeline only |
| Coach decisions | Coach | Coach contracts/runtime | Coach consumes Match facts/projections |
| Analytics projections | Analytics/Statistics | external projections/services | Match statistics panel is a local read projection |
| Simulation physics | Simulation | Simulation domain | Simulation never mutates recorded Match truth |

The legacy `features/match/domain/models/Match` is the persisted Product
compatibility aggregate. The foundation `ProductMatch`/`MatchAggregate` is the
typed, versioned structural direction. They are two representations of one
semantic Match and require an adapter before convergence.

## Public API Inventory

### Domain Models And Catalogs

| API | Current semantic role |
| --- | --- |
| `Match` | Legacy persisted match identity, session binding, format, participants, result and timing |
| `GameTypes` | Stored string-code catalog, including legacy fixed race codes and practice/drill reuse |
| `TeamModes` | Stored solo/doubles/team code catalog |
| `MatchContext` | Optional pre/post Match observation record |
| Match context option classes | Stored code catalogs and localized labels |
| `ProductMatch` | Foundation typed entity with version, lifecycle and Player/Session references |
| `MatchAggregate` | Foundation structural aggregate around `ProductMatch` |
| Match capability contracts | Accepted lifecycle/rack/scoring/analytics/integration capability metadata |

Legacy models use final fields but lack shared value equality, schema/contract
version, provenance, canonical serialization and typed identity. Constructors
use wall-clock defaults; lists are not defensively copied; nullable `copyWith`
fields cannot be explicitly cleared. String catalogs accept unknown values.

## Repository Inventory

`MatchRepository` exposes:

- list/load Match records by Session, id, recent order and all-history order;
- resolve the latest open Match for a Session;
- create/update/delete/finish Match rows;
- count Matches and allocate the next per-Session Match number.

`MatchContextRepository` exposes:

- load one context by Match id;
- independently upsert pre-Match and post-Match halves;
- list all contexts for projection consumers.

Repositories are plain Drift gateways. `finishMatch` supplies wall-clock time;
`getNextMatchNumber` uses count + 1; open-Match selection tolerates duplicates
and returns the highest match number. Match context upsert is query-then-write
without a database uniqueness constraint.

## Persistence Inventory

| Table | Purpose | Ownership relationship |
| --- | --- | --- |
| `matches` | Match metadata, lifecycle timestamps and Session foreign key | Match-owned row under Session |
| `match_contexts` | Optional pre/post observations and JSON list codes | Match-owned projection input; soft `match_id` |

`matches.session_id` references `sessions.id`. Racks reference Match and Shots
reference Racks, but those tables remain owned by their respective domains.
`match_contexts.match_id` has neither a foreign key nor uniqueness constraint.
Match context was introduced at schema version 16; the shared database is now
version 25. E4 changes none of it.

## Service And Provider Inventory

| Surface | Current responsibility |
| --- | --- |
| `MatchRecordingService` | Command-execution facade for create Match, record Rack, finish Match/Session |
| private recording capability/commands/handlers | Adapts Product calls to accepted framework/capability contracts |
| `MatchStatisticsService` | Completed-Match/Rack performance projection |
| `matchRepositoryProvider` | Match repository construction |
| `matchContextRepositoryProvider` | Match context repository construction |
| `matchContextProvider` | Family state for loading/saving pre/post context |
| `matchDetailProvider` / `MatchDetailNotifier` | Match detail, score projection and recording interactions |

`MatchDetailNotifier` combines Match and Rack reads, derives score and may finish
a Match while loading when a race target is reached. It also exposes edit,
delete, finish and Rack-recording operations. This is existing presentation
orchestration and must not be treated as domain ownership.

## UI Inventory

- `MatchHistoryView`: completed Match history and Session linkage.
- `MatchDetailScreen`: Match metadata, score, Rack history, recording actions,
  Player State/Form panels and Session-summary navigation.
- `PreMatchContextScreen` and `PostMatchContextScreen`: Match-scoped observations.
- `MatchStatisticsPanel`: completed Match/Rack performance projection.

The detail screen directly composes Rack, Shot, Session and Player State
experiences. Those integrations do not transfer ownership to Match.

## Route Inventory

| Route/entry | Purpose |
| --- | --- |
| `/session/match` | Session-owned entry into recording flow |
| `/match/:id` | Direct Match detail/deep link |
| `/session/history` | Competition history containing Match records |
| `/session/history/:sessionId` | Session summary with Match composition |
| Home Match history view | Completed Match review surface |

Pre/post context screens are pushed locally from Match detail and are not
independent top-level routes.

## Execution Ownership Map

```text
Match UI / Session UI
        |
        v
MatchRecordingService
        |
        +-- Match capability compatibility bootstrap
        +-- CommandExecutor + ApplicationExecutionContext
        |
        v
Session-owned RecordingCoordinator
        |
        +-- transaction boundary
        +-- parent existence and owner-assigned ordering
        |
        v
Session / Match / Rack / Shot / Event repositories
```

The service uses an in-memory request sequence, wall-clock request time and a
never-cancelled token. These are current adapter choices, not new framework
contracts. `RecordingCoordinator` remains the only cross-recording write
orchestrator; E4 does not create another executor or coordinator.

## Cross-Domain Dependency Graph

| Direction | Current dependency | Alignment decision |
| --- | --- | --- |
| Match -> Session | required parent id and recording coordinator | Session retains recording transaction ownership |
| Match -> Rack | score/history and record-Rack command | Rack remains child owner and source of rack outcome |
| Match detail -> Shot | shot recording experience | Shot retains fact ownership |
| Match detail -> Player State | fatigue/readiness/form interactions | Player State remains separate |
| Training -> Match | practice/drill reuse of recording pipeline | Reuse transport/persistence shape, not Match ownership of Training |
| Tournament -> recorded Match | possible future linkage | Tournament fixture remains distinct until explicit adapter exists |
| Coach/Performance/Statistics/Endurance -> Match repositories/models | read inputs | Consumers own derived projections/inferences only |
| Club/Equipment/Player profile -> Match | historical projections | Preserve source Match truth and introduce ports only when needed |
| Match -> accepted Foundation/Capability/Runtime | execution compatibility | Preserve frozen contracts; no duplicate abstractions |

## Concept Alignment

| Future concept | Existing equivalent | Alignment decision |
| --- | --- | --- |
| Match | legacy `Match`, foundation `ProductMatch`/`MatchAggregate` | One semantic aggregate; adapt, never duplicate |
| Match identity | integer id and typed `MatchId` | Preserve until explicit identity adapter/migration |
| Match lifecycle | nullable start/end plus winner/result | Keep legacy semantics; later state machine must be additive/versioned |
| Match score | projection from ordered Rack results | Rack facts remain authoritative; do not persist a competing score by default |
| Match format | `gameType`, `raceTo`, `teamMode` | Preserve stored codes; introduce validated values through adapters |
| Match opponent | free-text Match metadata | Not Player identity or Tournament participant binding |
| Match context opponent | categorical perceived-strength observation | Distinct from opponent display name |
| Match context fatigue/mental state | post-Match observation | Not long-lived Player State ownership |
| Tournament Match | `TournamentMatch` | Fixture/schedule aggregate, not recorded Match |
| Practice/drill Match | reused recording envelope | Training owns intent and curriculum |
| Match statistics | `MatchStatisticsService` result | Read projection, not aggregate |

## Ownership And Compatibility Risks

- Legacy and foundation Match representations lack an explicit identity and
  lifecycle adapter.
- Match lifecycle is inferred from nullable timestamps while winner and result
  strings can diverge.
- More than one open Match per Session is tolerated; no uniqueness invariant is
  enforced.
- Match numbering uses count + 1 and may collide after deletion or concurrent
  creation.
- `MatchDetailNotifier.loadMatch` can cause a finish write during a read/refresh.
- Wall-clock timestamps and in-memory request sequence prevent deterministic
  replay of execution envelopes.
- The execution facade always uses a never-cancelled token and converts
  structured failures to `StateError(code)`.
- Direct `updateMatch`/`deleteMatch` repository methods can bypass the recording
  coordinator's cross-table integrity policy.
- Deleting a Match with child Racks/contexts has no documented aggregate
  deletion policy.
- `match_contexts` does not enforce one row per Match or referential integrity;
  concurrent upserts can duplicate semantic context.
- Malformed JSON lists silently become empty; option codes and rating ranges are
  not validated at persistence boundaries.
- Match-scoped fatigue/mental observations overlap terminology with Player
  State and require explicit adapters to prevent ownership drift.
- Recorded opponent/partner/winner values are free text, so Player, Club and
  Tournament identity cannot be assumed.
- Match detail is a large presentation orchestrator spanning several domains.
- Many consumers import Match repositories directly instead of public read
  ports; this is existing coupling and must not be expanded casually.

## Genuine Missing Concepts

- authoritative adapter among legacy `Match`, `ProductMatch`, `MatchAggregate`
  and typed `MatchId`;
- explicit, versioned Match lifecycle/state transition policy;
- atomic one-open-Match-per-Session and monotonic Match-number allocation;
- Match deletion/retention policy across Rack, Shot, Event and context records;
- one-to-one MatchContext identity/referential constraint and audit semantics;
- typed participant/opponent/team references that preserve current free text;
- explicit adapter linking Tournament fixture to recorded Match when required;
- public read ports for Coach, Analytics, Club, Equipment and Player projections;
- deterministic clock/request identity/cancellation policy at Product adapter;
- validated format/context value objects with legacy code compatibility;
- structured execution failure mapping for Product UI;
- lifecycle/history provenance and canonical digest when replay is required.

These are findings only. E4 implements none of them.

## Evolution Matrix

| Artifact | Action | Rationale / constraint |
| --- | --- | --- |
| legacy `Match` | Keep as compatibility aggregate | Existing schema, repositories and UI depend on it |
| `ProductMatch` / `MatchAggregate` | Keep as foundation direction | Bridge through explicit adapter only |
| `MatchContext` | Keep as Match-scoped observation | Must not absorb Player State |
| `GameTypes` / `TeamModes` | Keep stored codes | Future values must read existing rows |
| `MatchRepository` | Keep | Sole current Match-row persistence gateway |
| `MatchContextRepository` | Keep | Sole current context persistence gateway |
| `MatchRecordingService` | Keep as Product execution facade | Do not add a parallel execution abstraction |
| `RecordingCoordinator` | Keep Session-owned choke-point | Only owner of cross-recording transactions |
| `MatchStatisticsService` | Keep as projection | Never make statistics authoritative Match state |
| Match providers/UI/routes | Keep | Existing Product compatibility surfaces |
| Match capability/runtime contracts | Frozen/reuse | No new registry/runtime/contract in E4 |
| `TournamentMatch` | Keep separate | Fixture semantics remain Tournament-owned |

No rename, merge, deprecation or implementation occurs in E4.

## Compatibility Strategy

1. Preserve current tables/columns, stored string codes, repository/provider
   APIs and routes.
2. Treat legacy and foundation Match structures as representations of one
   semantic aggregate; add a tested adapter before convergence.
3. Keep Session's `RecordingCoordinator` as the only cross-recording write
   boundary and reuse accepted command/capability execution contracts.
4. Keep Rack/Shot/Event facts authoritative and derive Match score/history from
   them; do not duplicate child ownership inside Match.
5. Preserve Tournament fixture, Training intent, Player State, Coach,
   Analytics and Simulation ownership through typed adapters/read ports.
6. Characterize current lifecycle, deletion, numbering and context behavior
   before any schema or repository packet changes them.
7. Introduce typed participant/fixture links additively while retaining legacy
   free-text fields.
8. Inject deterministic clocks/identifiers only under an execution-specific
   packet; do not change frozen framework contracts.
9. Fail closed for new unsupported codes through versioned adapters while
   retaining readability of current rows.
10. Do not add another Match execution service, coordinator, capability,
    registry or runtime without a proven distinct requirement.

## Verification

- Inventory covers ownership, APIs, repositories, persistence, services,
  providers, UI/routes, execution and cross-domain dependencies.
- Existing concepts are separated from genuine gaps and external ownership.
- Evolution and compatibility decisions are additive and ownership-preserving.
- Existing Match Product characterization tests: 9/9.
- Full app regression: 1184/1184.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Analyzer: no errors; unchanged repository baseline of 62 lint infos.
- `git diff --check`: clean.
- No Product code, schema, tests, UI, runtime or framework was changed.
- Protected generated artifacts are unchanged.
- Diff is limited to the exact E4 documentation allowlist.

## Repository State

Product Owner accepted E4 on 2026-07-24 and authorized repository commit and
push without implementation changes.

## Accepted Product Policies

- `RecordingCoordinator` remains permanently the only cross-recording write
  owner; future services delegate to it.
- There is exactly one semantic Match aggregate. Compatibility adapters are
  allowed; duplicate Match models are prohibited.
- `MatchContext` remains observational and never evolves into Player State
  ownership.
- Tournament may reference a played Match; Match never owns Tournament.
- Analytics may project Match facts but never owns Match.
- Multiple-open-Match, count-based numbering, read-triggered completion,
  repository bypass and context integrity remain documented technical debt and
  are not changed without an explicit future packet.
