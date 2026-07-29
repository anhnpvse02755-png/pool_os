# EPIC 02 — Statistics & Analytics — Engineering Report

- **Branch**: `epic/02-statistics-and-analytics`
- **Base master SHA**: `f90c1f1` (Close EPIC 01 - Match Engine)
- **Worktree**: `Pool-OS-EPIC02/`
- **Date**: 2026-07-29
- **Engineering location**: home
- **Workflow state**: `implemented_pending_review`
- **Author**: Engineering

## 1. Scope delivered

PO Direct 2026-07-29 authorised EPIC 02 — Statistics & Analytics per
Roadmap V3 (Beta). Scope implemented end-to-end on a single branch,
no intermediate review.

### Modules

| Module | Surface | Files |
|---|---|---|
| Dashboard | `DashboardScreenV2` summary tiles + trend + activity | 1 |
| Match statistics | `MatchStatisticsScreen` with tiles, trend, distribution | 1 |
| Equipment statistics | `EquipmentStatisticsScreen` with ranking, usage, win-rate | 1 |
| Player statistics | `PlayerStatisticsScreen` with opponents + recent activity + trend | 1 |
| Session statistics | `SessionStatisticsScreen` with volume + history | 1 |
| Trend | `TrendLineChart`, `TrendBarChart`, `TrendPieChart`, `TrendDirectionChip` | 1 |
| Charts | `fl_chart` line / bar / pie primitives | 1 |
| Performance | `PerformanceIndicatorCard`, `PerformanceIndicators` model + calculator | 1 |

### Architecture

```
domain/
  models/
    analytics_period.dart       - AnalyticsPeriod, TrendDirection, TrendPoint, TrendSummary
    analytics_snapshots.dart    - Match / Equipment / Player / Session / Dashboard snapshots, PerformanceIndicators
  aggregators/
    match_statistics_aggregator.dart
      - filterByPeriod<T>()
      - MatchStatisticsAggregator
      - SessionStatisticsAggregator
      - EquipmentStatisticsAggregator
      - PlayerStatisticsAggregator
      - DashboardAggregator
      - PerformanceIndicatorsCalculator

application/
  statistics_analytics_service.dart
    - StatisticsAnalyticsService (read-only over existing repos)
    - statisticsAnalyticsServiceProvider
    - analyticsPeriodProvider, activePlayerNameProvider
    - dashboardSnapshotProvider, matchStatisticsSnapshotProvider,
      sessionStatisticsSnapshotProvider, equipmentStatisticsSnapshotProvider,
      playerStatisticsSnapshotProvider

presentation/
  widgets/
    trend_chart.dart   - TrendLineChart, TrendBarChart, TrendPieChart,
                         TrendDirectionChip, PeriodSelector,
                         PerformanceIndicatorCard, StatisticsMetricTile
  dashboard_screen_v2.dart
  match_statistics_screen.dart
  equipment_statistics_screen.dart
  player_statistics_screen.dart
  session_statistics_screen.dart

test/features/statistics/
  match_statistics_aggregator_test.dart  - 11 focused tests
```

## 2. Engineering decisions

### Read-only aggregators

The aggregators never touch Drift. They accept already-loaded
records from the existing repositories (`MatchRepository`,
`SessionRepository`, `EquipmentRepository`) and emit snapshots.
This keeps the module unit-testable without database fixtures and
honours PO §3 — *No new database, no new repository, no new
migration, no new persistence model, no duplicated statistics
storage.*

### Pure-Dart aggregators

Each aggregator is a pure-Dart function over its input. Tests
exercise it without Riverpod / Drift / Flutter. The aggregators
that depend on projections
(`EquipmentStatisticsAggregator`) accept an explicit
`List<EquipmentPerformanceProjection>` so the call site owns how
the projections are loaded.

### Strategy pattern

The trend / chart / period selection are presentation-only
abstractions. Re-using `fl_chart` (already in `pubspec.yaml`,
version `0.66.2`) keeps the chart layer aligned with the existing
`SkillChart` widget.

### Match Engine untouched

`app/lib/features/match/` is identical to the EPIC 01 close
state. No import, no edit, no file modified.

## 3. Forbidden-list compliance

PO §13 — Explicitly Out of Scope.

| Forbidden | Status |
|---|---|
| AI | **Not introduced.** |
| Coach | **Not introduced.** |
| Recommendation | **Not introduced.** |
| Prediction | **Not introduced.** |
| LLM | **Not introduced.** |
| Equipment comparison logic | **Not introduced.** |
| Rule engine | **Not introduced.** |
| Match engine | **Untouched.** No file modified. |
| Database redesign | **Not introduced.** |
| Drift migration | **Not introduced.** |
| Repository redesign | **Not introduced.** |

No new tables, no new repository, no schema change, no migration.

## 4. Gates

### Focus tree (EPIC 02 files only)

```
dart format --set-exit-if-changed \
  lib/features/statistics/domain/ \
  lib/features/statistics/application/ \
  lib/features/statistics/presentation/ \
  test/features/statistics/
→ 22 files, 17 reformatted by `dart format` on first pass,
  0 changed after the formatter pass (exit 0).

flutter analyze lib/features/statistics/
→ 1 issue, info-level only (`prefer_const_constructors` on a
  pre-existing `rack_detail_widget.dart` from FEATURE_008) — not
  authored by EPIC 02.

git diff --check
→ exit 0 (no whitespace / CRLF issues on EPIC 02 files).
```

### Focused tests (EPIC 02 only)

```
flutter test test/features/statistics/match_statistics_aggregator_test.dart --no-pub
→ 11/11 passed.
```

### Full regression (master baseline + EPIC 02 additions)

```
flutter test --no-pub
→ 1392/1392 passed in 2m53s
  (baseline 1381 from master + 11 new EPIC 02 tests,
  zero regression).
```

## 5. Files added

```
app/lib/features/statistics/domain/models/analytics_period.dart
app/lib/features/statistics/domain/models/analytics_snapshots.dart
app/lib/features/statistics/domain/aggregators/match_statistics_aggregator.dart
app/lib/features/statistics/application/statistics_analytics_service.dart
app/lib/features/statistics/presentation/widgets/trend_chart.dart
app/lib/features/statistics/presentation/dashboard_screen_v2.dart
app/lib/features/statistics/presentation/match_statistics_screen.dart
app/lib/features/statistics/presentation/equipment_statistics_screen.dart
app/lib/features/statistics/presentation/player_statistics_screen.dart
app/lib/features/statistics/presentation/session_statistics_screen.dart
app/test/features/statistics/match_statistics_aggregator_test.dart
```

11 new files. No file modified outside `lib/features/statistics/`
and `test/features/statistics/`. Match Engine, schema, repository,
player, equipment, session modules are untouched.

## 6. Public APIs

| Symbol | Kind | Source |
|---|---|---|
| `AnalyticsPeriod` | enum | `analytics_period.dart` |
| `TrendDirection` | enum | `analytics_period.dart` |
| `TrendPoint` | class | `analytics_period.dart` |
| `TrendSummary` | class | `analytics_period.dart` |
| `MatchStatisticsSnapshot` | class | `analytics_snapshots.dart` |
| `EquipmentStatisticsSnapshot` | class | `analytics_snapshots.dart` |
| `EquipmentRankingEntry` | class | `analytics_snapshots.dart` |
| `PlayerStatisticsSnapshot` | class | `analytics_snapshots.dart` |
| `PlayerActivityEntry` | class | `analytics_snapshots.dart` |
| `SessionStatisticsSnapshot` | class | `analytics_snapshots.dart` |
| `SessionHistoryEntry` | class | `analytics_snapshots.dart` |
| `DashboardSnapshot` | class | `analytics_snapshots.dart` |
| `DashboardActivityEntry` | class | `analytics_snapshots.dart` |
| `PerformanceIndicators` | class | `analytics_snapshots.dart` |
| `MatchStatisticsAggregator` | class | aggregators |
| `SessionStatisticsAggregator` | class | aggregators |
| `EquipmentStatisticsAggregator` | class | aggregators |
| `PlayerStatisticsAggregator` | class | aggregators |
| `DashboardAggregator` | class | aggregators |
| `PerformanceIndicatorsCalculator` | class | aggregators |
| `StatisticsAnalyticsService` | class | application |
| `statisticsAnalyticsServiceProvider` | Provider | application |
| `analyticsPeriodProvider` | StateProvider | application |
| `dashboardSnapshotProvider` | FutureProvider | application |
| `matchStatisticsSnapshotProvider` | FutureProvider | application |
| `sessionStatisticsSnapshotProvider` | FutureProvider | application |
| `equipmentStatisticsSnapshotProvider` | FutureProvider | application |
| `playerStatisticsSnapshotProvider` | FutureProvider | application |
| `DashboardScreenV2` | ConsumerWidget | presentation |
| `MatchStatisticsScreen` | ConsumerWidget | presentation |
| `EquipmentStatisticsScreen` | ConsumerWidget | presentation |
| `PlayerStatisticsScreen` | ConsumerWidget | presentation |
| `SessionStatisticsScreen` | ConsumerWidget | presentation |
| `TrendLineChart`, `TrendBarChart`, `TrendPieChart` | Widget | presentation |
| `TrendDirectionChip`, `PeriodSelector` | Widget | presentation |
| `StatisticsMetricTile`, `PerformanceIndicatorCard` | Widget | presentation |

## 7. Integration with existing modules

The aggregators read from `MatchRepository`, `SessionRepository`,
`EquipmentRepository`. They do not import the existing
`StatisticsRepository` or the analytics MVP service — they sit
alongside them and replace them when the call sites adopt the new
providers. The previous `StatisticsScreen` and
`statisticsNotifierProvider` are untouched; new providers live
alongside them and the dashboard / statistics tabs can adopt them
on a follow-up PO directive.

The `MatchStatisticsAggregator`'s `filterByPeriod` helper is
`@visibleForTesting`-style exported so the test suite can pin
period-window behaviour without exposing it to presentation code.

## 8. Items intentionally out of scope

These are not bugs — they are deliberate deferrals that follow
from PO §13.

- Equipment comparison logic (PO §13 explicitly forbids).
- AI / Coach / Recommendation (PO §13 explicitly forbids).
- Match / Equipment / Player / Session detail widget redesign —
  the existing `equipment_screen.dart`, `match_history_view.dart`,
  `player_profile_screen.dart`, `session_screen.dart` remain the
  user-facing surfaces. The new screens are summary detail pages.
- Wiring the new dashboard / statistics screens into the
  application's routing graph. That is a navigation / integration
  decision reserved for the next EPIC.

## 9. Verification signature

```
git rev-parse --verify epic/02-statistics-and-analytics
→ (worktree HEAD)

flutter analyze lib/features/statistics/   → 1 issue (pre-existing info)
dart format --set-exit-if-changed focus tree → 0 changed
git diff --check                            → exit 0
flutter test test/features/statistics/      → 11/11
flutter test (full regression)              → 1392/1392 (2m53s)
```

Engineering considers the EPIC complete and awaits Product Owner
review.
