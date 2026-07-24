# E8 Analytics Domain Alignment And Expansion Readiness

Status: Accepted; Closed

Date: 2026-07-24

## Decision Context

Analytics I9 is a read-only Product composition over accepted Match and
Training statistics. It creates a small immutable dashboard projection and
renders it in Home. The repository also contains a larger historical
`statistics` bounded context and domain-specific statistics services. E8 maps
these surfaces without adding analytics, KPIs, reports, warehouses, OLAP,
event sourcing, projections, repositories, caches, schemas, migrations, AI,
prediction, trends, frameworks or runtime behavior.

## Ownership Map

| Concern | Owner | Current evidence | Boundary |
| --- | --- | --- | --- |
| Recorded Match/Rack facts | Match/Rack | repositories and recording pipeline | Analytics reads completed records only |
| Match aggregate statistics | Match | `MatchStatisticsService` | Match owns match/rack calculation semantics |
| Recorded Training sessions/exercises | Session/Training | execution service and recording pipeline | Analytics does not persist or mutate execution |
| Training aggregate statistics | Training | `TrainingStatisticsService` | Training owns exercise/success aggregation |
| Cross-domain dashboard projection | Analytics | `AnalyticsMvpService` | Combines accepted source projections only |
| Detailed historical player statistics | legacy Statistics bounded context | `StatisticsRepository`, `StatisticsEngine` | Preserved compatibility surface, not I9 ownership |
| Dashboard composition/navigation | Home/Experience | Home service and screen | Renders Analytics; no metric invention in UI |
| Coaching policy | Coach/Intelligence | CoachBrain and legacy consumers | Analytics never recommends or decides |
| Knowledge semantics | Knowledge | package/catalog | Analytics has no Knowledge ownership |
| Player identity/state | Player | Player bounded context | Analytics currently has no player-scoped input |

## Public API Inventory

### Analytics I9

- `MatchAnalyticsSource` and `MatchAnalyticsActivity` adapt Match summaries.
- `TrainingAnalyticsSource` and `TrainingAnalyticsActivity` adapt Training
  summaries.
- `AnalyticsActivity` is the normalized cross-domain timeline item, keyed by
  source kind plus source-local integer ID.
- `AnalyticsDashboardView` exposes immutable source projections, recent
  activity, Match win rate and Training success rate.
- `AnalyticsMvpService.load()` executes the dashboard query and merges source
  activity deterministically.
- `analyticsMvpServiceProvider` wires Match and Training services;
  `analyticsDashboardProvider` publishes the view.
- `AnalyticsDashboardScreen` renders the I9 projection.

The dashboard screen has no top-level route. Home pushes it with an in-memory
`MaterialPageRoute` when the Analytics destination is selected.

### Source-domain statistics APIs

- `MatchStatisticsService.load()` returns completed match count, rack count,
  wins/losses, total duration and per-match performance.
- `TrainingStatisticsService.load()` returns completed session/exercise counts,
  attempts/successes, duration, recent sessions, drill totals and a five-point
  training trend.

These are application read services owned by their source domains. Analytics
adapts their results rather than querying persistence directly.

### Capability/runtime API

Analytics I9 registers one private capability identity/version implementing
lifecycle, statistics collection and reporting. The accepted Analytics
capability runtime checks registration, version compatibility, dependencies
and exposure. It does not calculate metrics or invoke a generic analytics
engine.

## Projection Inventory

| Projection | Input | Output/use |
| --- | --- | --- |
| Match statistics | completed Match + Rack records | Match panel, Home, Analytics, Simulation |
| Training statistics | completed Training sessions/exercises | Training panel, Home, Analytics, Simulation |
| Match analytics adapter | Match statistics record | I9 Match source/activity |
| Training analytics adapter | Training statistics record | I9 Training source/activity |
| Analytics dashboard | both source projections | overview, rates, duration, recent activity |
| Home dashboard | Analytics plus other Product summaries | Home cards and six recent activities |
| legacy Statistics projections | Session/Match/Rack/Shot/Event data | detailed Statistics/Player/legacy Coach surfaces |

I9 owns only the normalized dashboard projection. It does not become the owner
of Match, Training or legacy detailed-statistics semantics.

## Aggregation Inventory

### Match

Match statistics selects completed matches, sorts newest first, loads racks per
match, calculates per-match and total rack wins/losses, counts matches/racks and
sums recorded duration.

### Training

Training statistics loads completed sessions, aggregates exercise count,
attempts, successes and duration, builds per-session recent activity, groups
drill totals by code and derives the last five training rates.

### Analytics

Analytics calculates only:

- Match win rate from aggregate wins and losses;
- Training success rate from aggregate attempts and successes;
- one normalized timeline, ordered by occurrence descending, then source kind,
  then source-local ID, limited to eight items.

No trend inference, prediction, ranking, KPI target, cohort, attribution or
recommendation is performed by I9.

### Home

Home loads Match, Training and Analytics independently, even though Analytics
loads Match and Training again. Home then derives summary strings and takes six
items from the Analytics timeline. This is composition duplication and can
observe different repository moments; it is not a second Analytics owner.

## Repository Ownership

Analytics I9 has no repository, table, cache, schema or persistence. Its source
loaders are injected functions.

`MatchStatisticsService` reads Match and Rack repositories owned by those
domains. `TrainingStatisticsService` reads through the accepted Training
session execution service. Analytics wiring imports those application services
but no persistence implementation.

The historical `StatisticsRepository` directly reads the database plus Match,
Rack, Shot and Event repositories and produces detailed Session, career, skill,
event, shot, error, break and player statistics. That repository remains owned
by the legacy Statistics bounded context and is not an Analytics I9 repository.

## Runtime Interaction

```text
Match/Rack persistence -> MatchStatisticsService -----+
                                                     |
Training execution -> TrainingStatisticsService -----+-> AnalyticsMvpService
                                                          |
                                                          v
                                                AnalyticsDashboardView
                                                          |
                                          +---------------+---------------+
                                          v                               v
                                  Analytics screen                  Home dashboard
```

`AnalyticsMvpService` uses the accepted query executor and an always-active
cancellation token. It invokes Match first and Training second inside the
handler. The request ID and request timestamp are process-local execution
metadata and do not enter the returned value object.

## Existing Charts And Dashboard Composition

I9 renders six overview metrics, one two-bar rate chart, one two-bar recorded
duration chart and a recent activity list. Charts render accepted projection
values and contain no calculation beyond display formatting.

Home renders an Analytics summary card and recent Match/Training activity, then
opens `AnalyticsDashboardScreen` without a named route. The older Dashboard and
`/statistics` surfaces remain separate Product experiences. The legacy
Statistics screen includes detailed widgets and a skill bar chart; it is not
fed by the I9 dashboard projection.

## Cross-Domain Dependency Map

| Direction | Dependency | Alignment decision |
| --- | --- | --- |
| Analytics -> Match | `MatchStatisticsService` projection | Match keeps calculation ownership |
| Analytics -> Training | `TrainingStatisticsService` projection | Training keeps calculation ownership |
| Home -> Analytics | dashboard projection and timeline | Home renders/composes only |
| Simulation -> Match/Training | same source services | Simulation does not consume Analytics I9 |
| Coach -> Statistics | legacy repository/current findings | Coach does not consume Analytics dashboard |
| Player -> Statistics | legacy Statistics provider | Player does not become Analytics owner |
| Analytics -> Knowledge | none | no content or catalog dependency |
| Analytics -> persistence | none | no Analytics repository authorized |

## Match, Training, Coach, Knowledge And Player Interaction

Match and Training expose source-owned aggregations. Analytics normalizes only
the subset needed by I9 and cannot change the source facts or definitions.

Coach currently obtains facts from its own Finding producers and, in a legacy
path, the historical Statistics repository. It does not call
`AnalyticsMvpService`; Analytics therefore has no coaching policy ownership.

Knowledge has no direct I9 dependency. Any future Knowledge-based grouping must
come through a public versioned projection rather than importing catalog or
authored graph internals.

Player consumes detailed legacy Statistics through an existing presentation
provider. I9 carries no player ID, cohort or profile binding, so its current
dashboard is implicitly single-local-profile scope rather than an explicit
player-scoped contract.

## Concept Alignment And Overlap

| Concept | Current owner | Compatibility overlap |
| --- | --- | --- |
| Match summary | Match | legacy Statistics recalculates related Match/Rack metrics |
| Training summary | Training | legacy Statistics includes training categories/models |
| Cross-domain overview | Analytics I9 | Home also loads source summaries directly |
| Detailed statistics | legacy Statistics | I9 displays a smaller overlapping overview |
| Timeline | Analytics I9 normalized view | Home copies a six-item projection |
| Trend | Training source and legacy Statistics | I9 declares capability kind but performs no trend analysis |
| Reporting | I9 dashboard projection | legacy Statistics screens/repository are richer reports |

Analytics I9 and the historical Statistics bounded context solve different
Product scopes. Their coexistence is treated as a compatibility condition, not
authorization to merge, rename, replace or delete either implementation.

## Evolution Matrix

| Artifact | Action | Constraint |
| --- | --- | --- |
| Match statistics service | Keep/reuse | Match owns Match/Rack aggregation |
| Training statistics service | Keep/reuse | Training owns execution aggregation |
| Analytics source adapters/view/service | Keep as I9 boundary | Cross-domain projection only |
| Analytics capability bootstrap | Keep/freeze | Compatibility gate, not metric engine |
| Analytics provider/screen | Keep | Read-only Experience surface |
| Home Analytics composition | Keep pending snapshot policy | No duplicate semantic owner |
| legacy Statistics repository/engine/models/UI | Preserve/deprecate-later | Separate compatibility surface |
| Simulation source reuse | Keep | Simulation owns comparison, not statistics |
| Coach/Player Statistics consumers | Preserve pending public-port policy | No migration under E8 |

## Genuine Gaps

- explicit product policy distinguishing Analytics I9 overview from legacy
  detailed Statistics ownership and future convergence criteria;
- one consistent snapshot/provenance boundary across Match and Training source
  projections;
- stable projection version, source IDs/digests and generated-at semantics;
- explicit player/profile scope for Analytics requests and results;
- public source-domain read contracts instead of wiring concrete application
  services in presentation providers;
- request cancellation/error diagnostics rather than permanent cancellation
  disablement and generic error collapse;
- validation for invalid counts/rates, duplicate semantic activity IDs and
  source timestamp assumptions;
- localization and accessibility ownership for Analytics UI labels/charts;
- removal of redundant Home source loads only under an authorized composition
  milestone;
- scale/query evidence before any cache, warehouse, index or new projection is
  considered.

These are findings only. E8 implements none of them.

## Compatibility Strategy

1. Keep Match and Training as the owners of their aggregation semantics.
2. Keep Analytics I9 a pure read-only cross-domain projection with no
   repository, persistence or business command.
3. Preserve legacy Statistics and I9 until a separately authorized adapter and
   deprecation policy defines convergence, if any.
4. Reuse public projections; do not let Analytics query source persistence or
   duplicate detailed calculation engines.
5. Keep Coach decisions, Knowledge semantics, Player state and Simulation
   policy outside Analytics.
6. Add future metrics only with explicit ownership, provenance, denominator,
   time-window and compatibility contracts.
7. Do not infer predictive, trend, KPI or recommendation capability from enum
   declarations that I9 does not execute.

## Risk Assessment

- High: overlapping I9 and legacy Statistics terminology can lead to a third
  metric/report implementation or inconsistent definitions.
- High: Match and Training are loaded separately without one snapshot identity,
  so a dashboard can combine different repository moments.
- Medium: Home reloads Match/Training directly and through Analytics, increasing
  query cost and temporal inconsistency.
- Medium: I9 projections lack player identity, version, provenance and digest.
- Medium: source application services are imported by presentation wiring
  rather than exposed through explicit cross-domain read ports.
- Medium: counts/rates and semantic activity IDs are trusted without validation.
- Low: UI strings are English-only and charts have limited semantic labeling.

## Verification

- Inventory covers Analytics I9, services, presentation, Match/Training
  statistics, capability/runtime, models, projections, aggregations, charts,
  Home composition and legacy Statistics overlap.
- Allowlist compliance: only the E8 document and `MEMORY.md` are changed.
- Outside allowlist changes: 0.
- `git diff --check`: clean.
- Protected artifacts: unchanged.
- No regression suite was run because E8 is documentation-only and the packet
  requires no implementation verification.

## Repository State

Product Owner accepted and closed E8 on 2026-07-24 without requested changes.
The authorization permits the documentation and memory updates to be committed
and pushed. No Analytics/Statistics convergence or implementation work is
authorized by this acceptance.
