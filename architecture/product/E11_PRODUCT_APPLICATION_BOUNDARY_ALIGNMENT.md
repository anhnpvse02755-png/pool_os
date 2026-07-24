# E11 Product Application Boundary Alignment And Expansion Readiness

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

P3 defines framework-neutral Application contracts, P6 defines Product
capability contracts, P8 provides fail-closed capability bootstrap/preflight,
and P9 executes one accepted command or query handler through the generic
pipeline. Accepted Product features predate and postdate those foundations and
do not all use them uniformly. E11 inventories the actual Product application
boundaries without modifying services or adding facades, orchestrators,
mediators, workflow engines, repositories, runtimes, frameworks, commands,
queries or contracts.

## Application Ownership Map

| Feature | Application responsibility currently present | Effective owner |
| --- | --- | --- |
| Match | record lifecycle/racks through coordinator; calculate completed statistics | Match application plus Session recording data service |
| Training | execute training sessions/exercises; calculate completed statistics | Session application and Training application |
| Coach | deterministic projections/builders, Learning replay, structured conversation, AI-boundary foundations | Coach application with Event/Mastery/Knowledge inputs |
| Knowledge | catalog browse/search query over package loader | Knowledge application; package owns semantics |
| Analytics | merge Match/Training projections and recent activity | Analytics application |
| Product Simulation I10 | replay/compare observed Match/Training summaries | Simulation application, not physics Simulation |
| Home | compose six existing Product services into one view | Home application/Experience |
| Session | general lifecycle in presentation notifier; training execution service; repository gateways | split across presentation, application and data |
| Tournament | reads, commands, bracket/result behavior in providers and repository | presentation controller plus repository |
| Club | reads, commands, rankings/statistics in providers and repository | presentation controller plus repository |
| Player | CRUD/selection/profile behavior in presentation notifiers and repository | presentation plus repository |

Application ownership is therefore behavioral, not reliably inferred from the
`application/` directory. Some historical Product behavior lives in Riverpod
presentation controllers or concrete repositories, while newer MVP services
use P3/P6/P8/P9 foundations.

## Service Inventory

### Match and Training

- `MatchRecordingService`: P9 command execution for create Match, record Rack,
  finish Match and finish Session; delegates writes to `RecordingCoordinator`.
- `MatchStatisticsService`: direct read of Match and Rack repositories; filters,
  sorts and aggregates completed performance without P9 query execution.
- `TrainingSessionExecutionService`: P9 command execution for create Session,
  add/complete exercise and finish Session; direct repository reads for history.
- `TrainingStatisticsService`: aggregates the training execution service's
  completed-session projection; no direct repository of its own.
- `SessionNotifier`: older general Session application behavior located in
  presentation and calling repositories/coordinator directly.

### Coach, Player Model and Learning

- `CoachConversationService`: P6/P8 capability preflight and P9 structured
  command execution for three conversation intents.
- `LearningRuntime`: replays and appends Evidence through Knowledge, Event and
  Mastery collaborators; it is a stateful application service outside P9.
- Player/Experience, eligibility, context, AI session, prompt and orchestration
  builders: synchronous deterministic projections over accepted contracts.
- `CoachAIAdapter`/deterministic stub: accepted AI boundary proof, not provider
  integration or Coach business execution.
- legacy Coach providers also compose repositories directly; E6 documents the
  three-generation compatibility condition and selects none for removal.

### Knowledge, Analytics, Product Simulation and Home

- `KnowledgeMvpService`: P6/P8 preflight plus P9 browse query over a package
  catalog loader.
- `AnalyticsMvpService`: P6/P8 preflight plus P9 query over supplied Match and
  Training loaders.
- `SimulationMvpService`: P6/P8 preflight plus P9 observed-replay query; compare
  calls preview twice sequentially.
- `HomeDashboardService`: eagerly starts six injected loaders and composes one
  view directly; it is not a P9 query or workflow engine.

### Session, Tournament, Club and Player

- `competitionHistoryProvider`: application-named FutureProvider that reads
  Session and Match repositories directly.
- `sessionMatchGateway`: Riverpod aliases exposing concrete Session/Match/Rack
  repositories rather than an application port.
- Tournament FutureProviders/controllers call `TournamentRepository` directly;
  bracket generation, result propagation and completion are in the repository.
- Club FutureProviders/controllers call `ClubRepository` directly; rankings,
  statistics, membership and links span provider and repository calculations.
- Player notifiers call `PlayerRepository` directly and trigger other provider
  refreshes; profile composition also reads Equipment.
- `settings_provider.dart`, despite its application path, imports Flutter,
  Riverpod and the Player repository directly.

Additional application directories contain Event IO factory, Mastery providers,
Performance providers and projection builders. Their presence confirms that
the directory currently mixes application services, UI state wiring and
Infrastructure construction.

## Public Application API Inventory

| Surface | Public operations |
| --- | --- |
| Match recording | `createMatch`, `recordRack`, `finishMatch`, `finishSession` |
| Match statistics | `load` completed Match/Rack projection |
| Training execution | history/detail/exercise loads; create/add/complete/finish commands |
| Training statistics | `load` summary, recent, drills and trend |
| Coach conversation | `ask` structured intent |
| Coach/Learning builders | replay/record Evidence; project/build deterministic contracts |
| Knowledge | `browse` request |
| Analytics | `load` dashboard projection |
| Product Simulation | `preview`, `compare` observed replay |
| Home | `load` composed dashboard |
| Session | notifier lifecycle/selection plus repository gateway aliases |
| Tournament | provider reads and controller mutations |
| Club | provider reads and controller mutations |
| Player | notifier CRUD/selection/profile operations |

Most feature APIs expose concrete records, domain models or Dart record types.
Only the M3 contract chain uses explicit version/digest/provenance-rich public
contracts. This inventory does not promote feature internals to stable public
ports.

## Command And Query Execution Map

```text
P3 handler/context contracts
          |
          v
P9 CommandExecutor
  -> MatchRecordingService -> RecordingCoordinator -> repositories
  -> TrainingSessionExecutionService -> repositories/coordinator
  -> CoachConversationService -> deterministic handler

P9 QueryExecutor
  -> KnowledgeMvpService -> KnowledgeCatalog loader
  -> AnalyticsMvpService -> Match/Training loaders
  -> SimulationMvpService -> Match/Training replay loaders

Direct execution paths
  -> Match/Training statistics -> repositories/services
  -> Home -> six service loaders
  -> Session/Tournament/Club/Player providers -> repositories
  -> Coach/Learning/projectors -> contracts, Evidence and domain collaborators
```

There are seven Product P9 execution points: three service families using
commands and three using queries, with Training providing both command and
direct read paths. Private command/query/handler types avoid creating feature
contract families, but every service creates local request IDs from mutable
sequence counters, uses wall-clock request time and a never-cancelled token.
Failures are commonly converted to `StateError(code)` at the service boundary.

P9 supplies deterministic traversal, cancellation checks and failure wrapping;
it does not own Product behavior. P3 owns handler/context types. P6 owns
capability metadata. P8 validates locally constructed capability registries for
Match recording, Coach conversation, Knowledge, Analytics and I10. Training's
accepted P6/P8 capability exists but the training execution service does not
currently consume it. The broader Coach M3 application chain also does not run
through the Coach capability bootstrap.

## Cross-Feature Dependency Graph

```text
Player presentation -------> Player repository (+ Equipment for profile)

Session presentation ------> Session/Match/Rack repositories
Session training service --> Session/Match/Rack repositories
                           -> RecordingCoordinator
Match recording -----------> RecordingCoordinator
Match statistics ----------> Match + Rack repositories
Training statistics -------> Session training service

Coach Learning ------------> Knowledge package + Event log + Mastery engine
Player/Experience ----------> Coach Learning snapshot types
Coach conversation --------> Coach output

Analytics -----------------> Match statistics + Training statistics
I10 observed replay -------> Match statistics + Training statistics
Home ----------------------> Match + Training + Coach + Knowledge + Analytics + I10

Tournament presentation ---> Tournament repository
Club presentation ---------> Club repository (+ linked Match/Training data internally)
```

The strongest coupling runs from Product composition features to concrete
application services and from historical presentation state directly to
repositories. There is no dependency from P3/P6/P8/P9 back into Product
features, preserving foundation dependency direction.

## Composition Map

- Riverpod is the dominant composition mechanism and creates concrete services,
  repositories, notifiers and controllers.
- Newer MVP providers inject loader functions into Analytics, I10 and Home,
  which narrows mutation authority but does not version the read boundary.
- `RecordingCoordinator` is the accepted write choke point for Session/Match/
  Rack/Shot/Event recording, but it resides under Session `data/` and is
  imported by Match and Training application services.
- Home is the top Product read composition surface and can trigger nested
  Match/Training reads through Analytics and I10.
- Tournament, Club and Player have no distinct application-service layer;
  presentation providers/controllers are their composition and execution edge.

## Coupling Analysis

### Accepted foundation-aligned coupling

- P9 depends on P3/Shared and remains generic.
- P6/P8 preflight is feature metadata validation, not discovery or orchestration.
- Query services accept loader functions and keep source mutation out.
- M3 Coach builders consume accepted immutable contracts.

### Compatibility coupling

- application services import concrete data repositories/coordinators across
  feature folders;
- presentation providers own application sequencing and repository mutation;
- the `application/` namespace includes Flutter/Riverpod and an Event IO factory;
- feature outputs use unversioned records and internal domain models;
- capability preflight and P9 execution adoption is partial;
- wall-clock/sequence request metadata and `StateError` translation are repeated;
- Home, Analytics and I10 can independently reload the same sources;
- Player refresh behavior reaches laterally across providers.

These are current compatibility conditions, not authorization to reorganize
layers or mandate universal framework adoption.

## Evolution Matrix

| Surface | Action | Constraint |
| --- | --- | --- |
| P3 contracts | Freeze/reuse | no duplicate handler/context/result types |
| P6 capability contracts | Freeze/reuse where semantically applicable | no ceremonial capability wrapper |
| P8 bootstrap/runtime | Freeze/reuse for accepted capability preflight | no runtime discovery |
| P9 executors | Freeze/reuse for single-handler execution | no bus, mediator or workflow engine |
| Match/Training command services | Keep | RecordingCoordinator remains accepted write boundary |
| MVP query services | Keep | source ownership remains external |
| M3 Coach builders/runtime | Keep | no forced P9 wrapping in E11 |
| Home composition | Keep thin | no orchestrator/facade promotion |
| Session/Tournament/Club/Player direct provider paths | Preserve compatibility | no relocation or rewrite in E11 |
| concrete repositories and Riverpod wiring | Preserve | future ports require separately authorized evidence and migration policy |

## Genuine Gaps

- explicit Product application-layer policy defining service, provider,
  controller, coordinator and repository responsibilities;
- versioned public read/write ports for cross-feature use, with semantic IDs,
  player scope, provenance, cutoff and compatibility;
- typed error/failure policy that preserves diagnostics instead of collapsing to
  `StateError` or presentation strings;
- request identity/time/correlation and real cancellation ownership at the
  Product composition edge;
- transaction/atomicity semantics for multi-repository Match/Training writes;
- one documented compatibility policy for partial P6/P8/P9 adoption;
- removal of infrastructure construction and Flutter state concerns from the
  conceptual application boundary, only through a separately authorized move;
- side-effect and invalidation maps for Riverpod controllers;
- snapshot/coalescing policy for nested Home/Analytics/I10 source reads;
- public application surfaces for Session, Tournament, Club and Player before
  external consumers are added;
- tests proving cross-feature dependency direction and preventing new direct
  presentation-to-foreign-repository coupling.

These are findings only. E11 implements none of them.

## Compatibility Strategy

1. Keep P3, P6, P8 and P9 frozen as generic accepted foundations.
2. Do not require framework adoption solely for structural uniformity; apply it
   only when a separately authorized behavior needs its guarantees.
3. Preserve all current Product service/provider/repository APIs until a
   versioned port and consumer migration policy are explicitly authorized.
4. Keep RecordingCoordinator as the current recording write choke point.
5. Keep source calculations in Match, Training, Coach, Knowledge, Analytics,
   I10, Tournament, Club and Player owners; composition does not transfer them.
6. Do not turn Home or any adapter into an application orchestrator.
7. Treat directory/layer inconsistencies as compatibility evidence, not an
   automatic refactoring instruction.
8. Add no facade, mediator, bus, workflow engine or duplicate command/query
   contract to close documented gaps.

## Risk Assessment

- High: direct presentation-to-repository mutation makes UI state containers
  effective application services and complicates non-UI reuse/testing.
- High: multi-repository recording behavior lacks an explicit application-level
  transaction contract despite an accepted coordinator choke point.
- High: concrete cross-feature imports couple consumers to internal repository,
  service and domain model changes.
- Medium: partial P6/P8/P9 adoption can be misread as either mandatory or
  irrelevant, leading to duplicate wrappers or bypassed guarantees.
- Medium: unversioned record-shaped read APIs lack provenance, player scope and
  compatibility guarantees for expansion.
- Medium: repeated request metadata, never-cancelled tokens and `StateError`
  conversion weaken end-to-end diagnostics and cancellation.
- Medium: application folders containing Flutter, Riverpod and IO factories
  obscure dependency ownership.
- Medium: nested Product composition can repeat reads and mix source snapshots.
- Low: synchronous deterministic builders do not use P9, but wrapping pure
  functions without a behavioral requirement would add ceremony, not safety.

## Verification

- Inventory covers Match, Training, Coach, Knowledge, Analytics, I10, Home,
  Session, Tournament, Club and Player application behavior plus accepted P3,
  P6, P8 and P9 interaction points.
- Allowlist compliance: only the E11 document and `MEMORY.md` are changed.
- No source implementation under the broader read allowlist was modified.
- Outside documentation outputs: 0.
- `git diff --check`: clean.
- Protected artifacts: unchanged.
- No regression suite was run because E11 is documentation-only and requires
  no implementation verification.

## Repository State

Product Owner accepted and closed E11 on 2026-07-24 without requested changes
and authorized the documentation and memory updates to be committed and pushed.
Acceptance does not authorize changes to application services, dependency
direction or any documented compatibility path.
