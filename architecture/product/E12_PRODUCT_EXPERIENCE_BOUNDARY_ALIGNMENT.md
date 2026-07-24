# E12 Product Experience Boundary Alignment And Expansion Readiness

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

P5 defines framework-neutral Experience contracts but deliberately implements
no UI, navigation, state management or rendering. M3.2 defines a deterministic
Experience projection owned by Intelligence and explicitly does not integrate
Flutter. The accepted Product MVP uses Flutter, Riverpod, GoRouter and local
Navigator flows built before and after those foundations. E12 inventories the
actual presentation boundary without changing UI, providers, routing,
navigation, rendering ownership or adding navigation services, presentation
frameworks, coordinators, MVVM, MVI or mediator abstractions.

## Experience Ownership Map

| Feature | Experience ownership | Non-ownership |
| --- | --- | --- |
| Home | six destination cards, recent activity rendering, refresh, local pushes | source calculations and feature lifecycle |
| Match | history/detail/context forms, rack/result interactions, statistics panels | canonical recording and aggregate meaning |
| Training | active exercise interaction, history/detail and statistics panels | Session/Match/Rack persistence semantics |
| Coach | renders structured Coach V2 output and conversation actions | analysis, decision, recommendation and Learning semantics |
| Knowledge | browse/search/category/detail rendering and Training launch | authored Knowledge and unlock/prerequisite policy |
| Analytics | metrics, charts, timeline and refresh | Match/Training aggregation ownership |
| Product Simulation I10 | scenario selectors, comparison chart and local history | physics Simulation and source facts |
| Tournament | list/create/detail tabs, bracket and result interactions | tournament persistence and bracket rules |
| Club | list/create/detail tabs, membership/ranking/statistics interactions | Club persistence and aggregate calculations |
| Player | profile rendering/edit sheet and player selection state | Player persistence and cross-domain facts |
| Session | active lifecycle UI, dialogs/sheets, summary/history navigation | recording invariants and repository semantics |

Experience legitimately owns display selection, formatting, user-event capture,
loading/error/empty states and navigation affordances. It must not infer
Mastery, Coach recommendations, Knowledge availability or physical outcomes.

## Screen Inventory

| Feature | Principal screens/views |
| --- | --- |
| Home | `HomeDashboardScreen` and local Match/Training history wrapper |
| Match | `MatchHistoryView`, `MatchDetailScreen`, pre/post Match context screens |
| Training | `TrainingSessionView`, `TrainingHistoryView`, Training detail and statistics panel |
| Coach | `CoachScreen` plus Coach action navigation helper |
| Knowledge | library and detail screens; related-entry and Training launch flows |
| Analytics | `AnalyticsDashboardScreen` with metric/chart/timeline sections |
| Product Simulation I10 | `SimulationMvpScreen` with comparison controls/chart/history |
| Tournament | list, create, detail, participant/standings/bracket/statistics widgets |
| Club | list, create, detail, members/ranking/leaderboard/statistics/history widgets |
| Player | profile screen, profile sections and edit sheet |
| Session | active `SessionScreen` and `SessionSummaryScreen` |

The inventory includes 22 principal screen/view files plus feature widgets.
Several large screen files also define StateNotifier/provider or application
logic locally, notably Match detail and Session summary.

## Navigation Inventory

### Application router ownership

I12 GoRouter owns `/home` as initial location, the four-branch shell and named
routes for Session, Coach, legacy Dashboard/Statistics, Match detail, Knowledge,
Player profile and other established features. Tournament and Club have
top-level `/tournaments` and `/clubs` entries. I12 preserved `/dashboard` as a
compatibility route.

### Local Navigator ownership

- Home locally pushes all six destination screens.
- Match history pushes detail; Match detail pushes context and related screens.
- Training history pushes detail; Session and Knowledge can launch Training
  interaction screens locally.
- Knowledge library/detail push detail, related content and Training completion.
- Tournament and Club lists push create/detail; create replaces itself with
  detail; dialogs and tabs pop local results.
- Player profile locally pushes Equipment and opens edit interactions.
- Session uses local pushes for histories, detail/context and summary flows.

### GoRouter feature actions

Coach action navigation uses `context.go`/`context.push` for accepted Product
destinations, including Training Center query parameters. This is the primary
feature-local consumer of named routing in the inventoried set.

GoRouter and Navigator coexist as accepted navigation mechanisms. E12 does not
select either for replacement and does not authorize route convergence.

## Provider Inventory

| Provider family | Responsibility |
| --- | --- |
| Home | constructs six-source service and exposes refreshable Future view |
| Match context | StateNotifier loads/saves pre/post context through repository |
| Match detail | screen-local provider/notifier loads repositories and executes recording/mutations |
| Training | views call execution/statistics services directly; no dedicated feature provider |
| Coach conversation | append-only-in-state conversation turns, submitting/error state |
| legacy Coach | large StateNotifier analyzing multiple repositories |
| Coach V2 | multi-provider composition of repositories, Mastery, readiness, equipment and endurance |
| Stop-shot Learning | async pack/log/runtime/replay providers |
| Knowledge | repository/catalog/service, browse result and entry selection providers |
| Analytics | source-service composition plus dashboard FutureProvider |
| Product Simulation I10 | service provider and StateNotifier with selectors/local history |
| Tournament | family FutureProviders plus mutation controller and invalidation |
| Club | family FutureProviders plus mutation controller and broad invalidation |
| Player | CRUD/selection StateNotifier and profile composition StateNotifier |
| Session | lifecycle StateNotifier over repositories, coordinator and execution services |

Riverpod therefore serves dependency wiring, async loading, UI state,
application sequencing, mutation execution and cache invalidation. Provider
presence alone does not define a thin Experience boundary.

## Rendering Responsibility Map

| Rendering concern | Current behavior | Ownership decision |
| --- | --- | --- |
| loading/error/empty | AsyncValue/StateNotifier branches in screens | Experience |
| textual formatting | screens, panels and Home/provider adapters | Experience when display-only |
| charts | Analytics and I10 use `fl_chart` over supplied projections | Experience |
| forms/dialogs/sheets | Match, Training, Session, Tournament, Club, Player | Experience captures commands |
| domain calculations | some providers/notifiers/repositories calculate results | owning application/domain, not rendering |
| recommendations | Coach output supplied by Coach | Experience renders only |
| Knowledge availability | Knowledge/Learning output | Experience does not resolve graph |
| navigation | app router plus local screen affordances | Application shell and Experience respectively |

Some rendering files perform more than rendering. Match detail directly deletes
a Rack, reads the recording coordinator and appends Player-state logs. Session
screen reads repository gateway/coordinator/equipment snapshot providers and
appends Player-state logs. Training views invoke execution services directly.
These are active interaction boundaries, not evidence that Experience owns the
underlying behavior.

## Experience And Application Boundary Analysis

### Thin presentation examples

- Analytics renders one existing immutable dashboard projection.
- I10 renders supplied preview/comparison and keeps only session-local selector
  and history state.
- Home renders the composed view and delegates source semantics.
- Coach screen renders Coach output keys and delegates structured conversation
  requests to a notifier/service.

### Mixed presentation/application examples

- Session notifier performs lifecycle sequencing and direct repository writes.
- Tournament/Club controllers mutate repositories and coordinate invalidation.
- Player notifier performs CRUD, active selection and cascading provider refresh.
- Match detail combines rendering, notifier definition, mutation and direct
  repository/coordinator access in one file.
- Knowledge detail coordinates related navigation and Training completion.
- Coach providers contain both legacy analysis and newer cross-source context
  composition.

The mixed boundary is a compatibility condition documented by E11 and E12. It
does not authorize moving code or adding a presentation architecture framework.

## Experience Foundation And M3.2 Alignment

P5 contracts describe generic Experience identity, metadata, state, event,
lifecycle, capability, execution and provenance. The Flutter features do not
currently implement those contracts as their Widget/provider base types. P5 is
a frozen semantic foundation, not a mandate for a parallel widget hierarchy.

M3.2 `ExperienceSnapshot` is an Intelligence read model derived from Learning
and Player Model outputs. Coach-facing consumers receive it; the inventoried
Flutter experiences do not treat it as raw Evidence or a universal UI store.
Its name does not transfer UI ownership into Intelligence, and UI rendering does
not gain permission to infer its contents.

## Cross-Feature Interaction Map

```text
GoRouter shell -> Home / Session / Training Center / Coach
Home -> Match, Training, Coach, Knowledge, Analytics, I10 screens

Match UI -> Match notifier/service + Rack repository + Player-state log
Training UI -> Training execution/statistics services
Session UI -> Session notifier + Match/Training services + coordinator

Coach UI -> Coach V2/context/conversation providers -> many source projections
Knowledge UI -> Knowledge providers -> local detail / Training launch
Analytics UI -> Analytics provider -> Match + Training statistics
I10 UI -> Simulation provider -> Match + Training statistics

Tournament UI -> controller/repository + Player participants
Club UI -> controller/repository + Player members + linked records
Player UI -> Player repository + Equipment profile composition
```

Cross-feature interaction is primarily mediated by Riverpod provider imports,
concrete service imports and navigation to concrete screens. There is no common
Experience runtime or navigation service.

## Evolution Matrix

| Surface | Action | Constraint |
| --- | --- | --- |
| P5 Experience contracts | Freeze/preserve | no forced Widget/provider implementation |
| M3.2 Experience projection | Freeze/preserve | Intelligence read model, not UI store |
| I11 Home | Keep composition-only | no dashboard engine/orchestrator |
| I12 GoRouter shell/routes | Keep | no route change in E12 |
| local Navigator flows | Preserve compatibility | convergence requires separate authorization |
| thin FutureProvider projections | Keep | source behavior remains in application/domain |
| StateNotifier/controller interactions | Preserve compatibility | no MVVM/MVI rewrite |
| screen-local providers/mutations | Preserve and document | no relocation in E12 |
| legacy/new Coach presentations | Preserve E6 compatibility | no generation selected for removal |
| direct repository/provider interactions | Preserve | public-port migration requires separate packet |

## Genuine Gaps

- explicit Experience responsibility policy for Widget, provider, notifier,
  controller, application service and repository boundaries;
- route/deep-link/restoration policy covering GoRouter and local Navigator;
- versioned presentation-facing projections with typed loading/failure semantics;
- consistent command dispatch boundary so screens do not mutate foreign
  repositories or coordinators directly;
- documented Riverpod invalidation and cascading-refresh ownership;
- player/account scope and source snapshot identity for composite screens;
- localization/date/number formatting ownership and removal of hard-coded
  display strings through a separately authorized UI milestone;
- accessibility semantics, keyboard/focus behavior and responsive coverage;
- consistent cancellation, stale-result and duplicate-submit behavior;
- screen decomposition evidence for very large mixed-responsibility files;
- automated dependency fitness preventing new presentation-to-foreign-data
  imports without changing accepted legacy paths;
- explicit policy for whether/where P5 contracts add value in Product UI before
  any implementation adoption.

These are findings only. E12 implements none of them.

## Compatibility Strategy

1. Preserve P5 and M3.2 as distinct accepted foundations with their stated
   non-claims.
2. Preserve I11/I12 Home, shell and navigation behavior.
3. Keep GoRouter and local Navigator coexistence until a separately authorized
   navigation policy includes migration and deep-link compatibility.
4. Keep every business calculation and lifecycle in its current owning feature;
   UI interaction does not transfer semantic ownership.
5. Preserve Riverpod providers/controllers and direct calls as existing Product
   compatibility surfaces; do not add wrappers solely for uniformity.
6. Keep all three Coach presentations under the E6 compatibility condition.
7. Do not introduce MVVM, MVI, mediator, coordinator or another presentation
   framework to close documentation gaps.
8. Require separate Product authorization for any UI, provider, router or
   rendering-ownership change.

## Risk Assessment

- High: screens/providers with direct foreign repository/coordinator mutation
  blur Experience/Application ownership and increase change blast radius.
- High: GoRouter/local Navigator coexistence gives uneven deep-link, restoration
  and browser-history semantics.
- High: large Match/Session/Coach presentation units combine rendering, state,
  execution and cross-feature composition.
- Medium: broad Riverpod invalidation graphs are implicit and can trigger stale,
  redundant or surprising reloads.
- Medium: direct concrete screen/service/provider imports make feature UI
  composition sensitive to internal changes.
- Medium: asynchronous screens lack one consistent cancellation, stale-result,
  retry and typed-error policy.
- Medium: P5 could be misused to create a duplicate Flutter abstraction layer if
  adoption is pursued without behavioral evidence.
- Low: display strings, dates and compact card text have inconsistent
  localization/responsiveness treatment.

## Verification

- Inventory covers the required 11 Product feature experiences, principal
  screens/views, provider families, navigation calls, P5 Experience Foundation,
  M3.2 projection, I11 Home and I12 routing.
- Allowlist compliance: only the E12 document and `MEMORY.md` are changed.
- No UI, provider, routing, navigation or source implementation was modified.
- Outside documentation outputs: 0.
- `git diff --check`: clean.
- Protected artifacts: unchanged.
- No regression suite was run because E12 is documentation-only and requires
  no implementation verification.

## Repository State

Product Owner accepted and closed E12 on 2026-07-24 without requested changes
and authorized the documentation and memory updates to be committed and pushed.
Acceptance does not authorize UI/provider/navigation changes or implementation
of any documented gap.
