# E10 Home Domain Alignment And Expansion Readiness

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

I11 Home is the accepted Product composition surface for Match, Training,
Coach, Knowledge, Analytics and the I10 observed-data replay experience. I12
made `/home` the application entry while preserving the existing shell and
legacy `/dashboard` route. E10 characterizes ownership, composition and
navigation without adding a dashboard engine, orchestration, workflow logic,
repositories, schemas, persistence, caches, runtimes, frameworks, business
rules, AI, recommendation logic or routing changes.

## Ownership Map

| Concern | Owner | Home responsibility |
| --- | --- | --- |
| Match records and aggregates | Match | adapt the public statistics result into display text |
| Training records and aggregates | Training | adapt the public statistics result into display text |
| Coach output and next action | Coach | request and display an existing structured next-action result |
| Knowledge catalog/search/category semantics | Knowledge | display browse counts and open the existing library |
| Cross-source metrics and recent activity | Analytics | display the existing Analytics projection |
| Observed-data replay/comparison | Product Simulation I10 | request a small combined preview and open the existing screen |
| Home summaries, card ordering and refresh | Home/Experience | compose immutable display models |
| Application route graph and shell | Application/I12 | register `/home`, shell branches and compatibility routes |
| Destination feature behavior | Each destination domain | Home neither duplicates nor changes it |

Home owns no source fact, calculation policy, recommendation, lifecycle or
durable state. Its legitimate behavior is Product presentation composition.

## Public API Inventory

- `HomeDestination`: stable Match, Training, Coach, Knowledge, Analytics and
  Simulation card order.
- `HomeSummary`: two display strings supplied to a destination card.
- `HomeRecentActivity`: display copy of Analytics activity kind, source-local
  ID, occurrence time and rate.
- `HomeDashboardView`: unmodifiable destination-summary map and recent list.
- loader typedefs for four summaries, Analytics and Simulation.
- `HomeDashboardService.load()`: eagerly starts all six loaders and creates one
  immutable Home view.
- `homeDashboardServiceProvider` and `homeDashboardProvider`: Riverpod wiring
  and refreshable asynchronous state.
- `HomeDashboardScreen`: six cards, recent activity, refresh and destination
  navigation.

These are feature-local Product APIs. They are not cross-domain source
contracts and do not authorize other domains to depend on Home.

## Composition Inventory

| Source | Product call | Home adaptation |
| --- | --- | --- |
| `MatchStatisticsService` | `load()` | match count and locally formatted win rate |
| `TrainingStatisticsService` | `load()` | session count and locally formatted success rate |
| `CoachConversationService` | `ask(nextAction, CoachOutput)` | response/detail/metric keys |
| `KnowledgeMvpService` | `browse(all)` | article and category counts |
| `AnalyticsMvpService` | `load()` | recent count, two rates and activity list |
| `SimulationMvpService` | combined replay preview, limit 3 | observed sample count and mean rate |

All six calls are started before the first await. Results are then awaited in
fixed destination order. Any exception prevents construction of the complete
view; Home has no partial-success or fallback policy.

The Analytics and Simulation services load Match and Training themselves while
Home also loads them directly. One Home refresh can therefore query each source
up to three times. This is accepted I11 composition behavior, not evidence of
new Home ownership, but the results do not share a cutoff or snapshot identity.

## Navigation Responsibility Map

| Navigation concern | Current owner and behavior |
| --- | --- |
| Initial application location | I12 GoRouter: `/home` |
| Main shell | I12 `StatefulShellRoute` with four preserved branches |
| Home entry screen | application router builds `HomeDashboardScreen` |
| Match and Training from Home | local `MaterialPageRoute` wrappers around existing history views |
| Coach, Knowledge, Analytics and I10 from Home | local `MaterialPageRoute` to existing screens |
| Back from a Home destination | local Navigator pop returns to Home |
| Legacy dashboard | top-level `/dashboard` compatibility route |
| Existing named feature routes | application router; unchanged by Home |

Home owns destination affordances and local presentation transitions. The
application layer owns the route graph, entry point and shell. I11 intentionally
used local pushes because router files were outside its allowlist; I12 retained
that behavior and integrated only Home itself. E10 does not select local or
named navigation for replacement.

## Cross-Domain Dependency Map

```text
Match statistics -----------+
Training statistics --------+
Coach output/conversation --+
Knowledge browse -----------+--> HomeDashboardService --> HomeDashboardView
Analytics dashboard --------+                               |
I10 observed preview -------+                               v
                                                    HomeDashboardScreen
                                                             |
                                             local destination navigation
```

Home depends inward on accepted public application/presentation surfaces. No
source domain depends on Home. Home imports no repository, database, schema,
persistence implementation, platform runtime or constitutional Simulation
engine.

## Runtime Interaction

Riverpod constructs one Home service from six existing service providers. The
screen watches a `FutureProvider`; pull-to-refresh invalidates that composed
future and repeats all source calls.

The Coach loader first awaits the existing Coach V2 output, then calls
`CoachConversationService.ask(nextAction)`. The call executes the accepted
structured Coach command and increments that service instance's request
sequence. It does not call `CoachConversationNotifier.ask`, so the generated
turn is not appended to the conversation state shown by the Coach screen. Home
does not decide, rank or recommend, but its read composition is not entirely
stateless at the service-object level.

Match and Training formatting performs zero-denominator guards locally.
Analytics and I10 summaries reuse their supplied rates. Recent activity is
copied from Analytics and truncated to six only during rendering.

## Match, Training, Coach, Knowledge, Analytics And Simulation Interaction

- Match and Training own all records and aggregate meanings. Home only formats
  their existing totals.
- Coach owns the structured action. Home requests `nextAction` and exposes its
  localization keys; it does not inspect Evidence or create a recommendation.
- Knowledge owns catalog semantics and search. Home only counts the accepted
  browse result and opens the library.
- Analytics owns the merged recent timeline and dashboard rates. Home copies
  that projection rather than rebuilding the timeline.
- I10 owns observed replay semantics. Home requests a preview; it does not own
  physics Simulation or comparison logic.
- The application router owns global navigation. Home does not register routes.

## Concept Alignment And Overlap

| Concept | Current meaning | Alignment decision |
| --- | --- | --- |
| Home dashboard | Product composition and navigation surface | not a metrics engine or domain |
| legacy Dashboard | preserved `/dashboard` experience | compatibility surface, not replaced by E10 |
| Home Analytics summary | formatting of I9 output | Analytics remains owner |
| Home recent activity | copy of Analytics timeline | no second timeline policy |
| Home Simulation summary | I10 observed-data preview | not physics Simulation |
| Home Coach summary | structured Coach service result | not Home recommendation logic |
| route ownership | GoRouter graph plus local Home pushes | coexistence is accepted I11/I12 behavior |

Home and legacy Dashboard coexist. E10 neither declares one canonical for all
Product dashboard semantics nor authorizes convergence, deprecation or removal.

## Evolution Matrix

| Artifact | Action | Constraint |
| --- | --- | --- |
| Home destination enum and view models | Keep | presentation composition only |
| `HomeDashboardService` | Keep | no source-domain rules or workflow engine |
| six provider loaders | Keep/reuse | source services remain owners |
| Coach next-action loader | Preserve compatibility | no conversation-history or recommendation ownership claim |
| Analytics recent activity | Keep as source projection | no duplicate timeline calculation |
| I10 combined preview | Keep as observed summary | no physics meaning |
| local destination pushes | Preserve | navigation convergence requires separate authorization |
| `/home` and shell integration | Freeze accepted I12 behavior | application router remains owner |
| legacy `/dashboard` | Preserve compatibility | no removal in E10 |

## Genuine Gaps

- one versioned Home composition contract with source versions, provenance,
  generated-at and shared snapshot/cutoff identity;
- public source read ports that avoid importing concrete feature services and
  presentation providers across feature boundaries;
- one-load-per-source composition so Match and Training are not independently
  re-read through Home, Analytics and I10;
- typed failure diagnostics plus an explicitly authorized all-or-nothing or
  partial-dashboard policy;
- cancellation and refresh-coalescing semantics;
- a side-effect-free Coach summary projection that does not increment command
  request sequence merely to render Home;
- stable localization keys/value models instead of composing English display
  strings in providers and services;
- explicit player/account scope for every source projection;
- accessibility, responsive layout and destination-state coverage;
- a separately authorized navigation compatibility policy for local pushes,
  deep links, named routes and state restoration;
- an explicit compatibility/deprecation decision for Home versus legacy
  Dashboard after evidence shows which surface should remain.

These are findings only. E10 implements none of them.

## Compatibility Strategy

1. Preserve I11 Home as a thin Experience composition surface.
2. Preserve I12 `/home`, shell behavior and `/dashboard` compatibility route.
3. Keep every source calculation and lifecycle in its owning domain.
4. Do not introduce a Home repository, aggregate, workflow, runtime or engine.
5. Treat direct feature-service/provider imports as current Product wiring;
   replace them only through an explicitly authorized public-port milestone.
6. Treat local pushes and named routes as compatible navigation mechanisms
   until a separate navigation policy authorizes convergence.
7. Do not make Home a retry, fallback, recommendation or orchestration owner.
8. Do not infer physics Simulation semantics from the I10 Home card.

## Risk Assessment

- High: repeated Match/Training reads can mix source moments within one Home
  view and perform redundant repository work.
- High: direct cross-feature concrete imports make Home sensitive to internal
  service and presentation changes.
- Medium: one failing source rejects the entire dashboard with an untyped
  generic error and no cancellation of other work.
- Medium: rendering Home advances the Coach service request sequence even
  though it does not append visible conversation history.
- Medium: navigation ownership is split between GoRouter and local Navigator,
  limiting deep-linking and restoration consistency.
- Medium: Home and legacy Dashboard coexist without a long-term compatibility
  or deprecation decision.
- Low: display strings and date formatting are English/local implementation
  details and card text is constrained to one line.
- Low: recent activity is only visually limited, while the composed immutable
  view retains the full Analytics list.

## Verification

- Inventory covers I11 service/provider/screen/tests, all six Product source
  services, Coach conversation state behavior, I12 router integration and
  navigation acceptance evidence.
- Allowlist compliance: only the E10 document and `MEMORY.md` are changed.
- Outside allowlist changes: 0.
- `git diff --check`: clean.
- Protected artifacts: unchanged.
- No regression suite was run because E10 is documentation-only and requires
  no implementation verification.

## Repository State

Product Owner accepted and closed E10 on 2026-07-24 without requested changes
and authorized the documentation and memory updates to be committed and pushed.
Acceptance does not authorize a dashboard engine, orchestration, routing
change, cross-domain contract or implementation for any documented gap.
