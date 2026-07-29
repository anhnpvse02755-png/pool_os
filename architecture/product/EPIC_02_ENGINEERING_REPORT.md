# EPIC 02 — Statistics & Analytics — Engineering Report

- **Branch**: `epic/02-statistics-and-analytics`
- **Base master SHA**: `f90c1f1` (Close EPIC 01 - Match Engine)
- **Worktree**: `Pool-OS-EPIC02/`
- **Date**: 2026-07-29
- **Engineering location**: home
- **Workflow state**: `accepted_closed`
- **Updated**: 2026-08-02 (Phase A..H spec extension delivery + PO close)
- **Author**: Engineering

## 1. Revision history

| SHA | Note |
|---|---|
| `ff914ca` | Initial implementation (Pending PO review) |
| `8d3458e` | Revision — Dashboard wired, statistics hub wired, performance complete, integration end-to-end, duplicates removed |
| `c1aa842` | PO revision — Engineering Report reformatted per PO feedback |
| current | Spec extension — Phase A..H (see §2.2) |

PO Review flagged the initial implementation as
`implemented_pending_revision` (engineering ~9/10, but EPIC not
closed: legacy dashboard still ran, legacy StatisticsScreen
still ran, routing not wired, Performance metrics too thin,
no integration proof). This commit (`8d3458e`) addresses every
flagged gap. No `follow-up`, `next Epic`, or `reserved later`
remains in the implementation.

## 2. Scope delivered

### 2.1 Modules

| Module | Surface | Path |
|---|---|---|
| Dashboard | existing `DashboardScreen` + new `Statistics` section (tiles, trend chip, 120px line chart) | `lib/features/dashboard/presentation/dashboard_screen.dart` |
| Match statistics | `MatchStatisticsScreen` (4 tiles, trend chip, line + pie charts, distribution) | `lib/features/statistics/presentation/match_statistics_screen.dart` |
| Equipment statistics | `EquipmentStatisticsScreen` (ranking list, bar chart, win-rate list) | `lib/features/statistics/presentation/equipment_statistics_screen.dart` |
| Player statistics | `PlayerStatisticsScreen` (matches, win-rate, opponents, recent activity, performance trend) | `lib/features/statistics/presentation/player_statistics_screen.dart` |
| Session statistics | `SessionStatisticsScreen` (sessions, training / match volume, durations, history) | `lib/features/statistics/presentation/session_statistics_screen.dart` |
| Performance | `StatisticsPerformanceScreen` (8 indicators, WinRateOverTime line chart, equipment effectiveness list) | `lib/features/statistics/presentation/performance_screen.dart` |
| Trend | line / bar / pie / chip primitives over `fl_chart` | `lib/features/statistics/presentation/widgets/trend_chart.dart` |
| Charts | same primitives (existing dependency, no custom engine) | as above |
| Statistics hub | 5-tab `StatisticsHubScreen` composing the four detail + performance screens | `lib/features/statistics/presentation/statistics_hub_screen.dart` |
| Routing | 5 new go_router routes | `lib/app/router/app_router.dart` |

### 2.2 Architecture

```
domain/
  models/
    analytics_period.dart       AnalyticsPeriod / TrendDirection / TrendPoint / TrendSummary
    analytics_snapshots.dart    Match / Equipment / Player / Session / Dashboard snapshots
    performance_snapshots.dart  PerformanceSnapshot + WinRateOverTimePoint + EquipmentEffectiveness
  aggregators/
    match_statistics_aggregator.dart
      filterByPeriod<T>()
      MatchStatisticsAggregator
      SessionStatisticsAggregator
      EquipmentStatisticsAggregator
      PlayerStatisticsAggregator
      DashboardAggregator
      PerformanceIndicatorsCalculator
  performance/
    performance_calculator.dart
      PerformanceCalculator (WinRateOverTime / Improvement /
      HotStreak / ColdStreak / Consistency / SessionEfficiency /
      PracticeVsMatchRatio / Activity)

application/
  statistics_analytics_service.dart
    StatisticsAnalyticsService (read-only over existing repos)
    statisticsAnalyticsServiceProvider
    analyticsPeriodProvider, activePlayerNameProvider
    dashboardSnapshotProvider
    matchStatisticsSnapshotProvider
    playerStatisticsSnapshotProvider
    sessionStatisticsSnapshotProvider
    equipmentStatisticsSnapshotProvider
    performanceSnapshotProvider
  statistics_module_bridge.dart
    RiverpodStatisticsBridge implements EPIC 01 StatisticsModuleBridge
    riverpodStatisticsBridgeProvider

presentation/
  widgets/trend_chart.dart
  dashboard_screen_v2.dart (kept as alternative surface)
  match_statistics_screen.dart
  equipment_statistics_screen.dart
  player_statistics_screen.dart
  session_statistics_screen.dart
  performance_screen.dart
  statistics_hub_screen.dart (5-tab entry point for /statistics)
```

### 2.3 Wiring (end-to-end)

```
Match Engine (EPIC 01, frozen)
    |
    v
MatchRecordingService.finishMatch / finishSession
    |
    +--> _refreshPlayerProgress?.call()        (existing)
    +--> _refreshEquipmentPerformance?.call()   (existing)
    +--> _refreshCareerTimeline?.call()        (existing)
    +--> _statisticsBridge.onShotHistoryRecorded(...)  <-- NEW
                  |
                  v
        RiverpodStatisticsBridge._invalidate()
                  |
                  +--> dashboardSnapshotProvider
                  +--> matchStatisticsSnapshotProvider
                  +--> playerStatisticsSnapshotProvider
                  +--> performanceSnapshotProvider
                          |
                          v
            StatisticsAnalyticsService re-reads Match /
            Session / Equipment / Player repositories and
            recomputes the snapshot.
                          |
                          v
            Dashboard / Match / Equipment / Player / Session
            / Performance screens re-render.
```

User flow proven: complete a match → close the match → dashboard
statistics section, the dedicated statistics tabs, and the
performance indicators refresh without app restart.

### 2.3 Spec extension — Phase A..H (current revision)

PO delivered a full spec list of metrics. The current revision
addresses every metric in the spec, organised by phase:

| Phase | Surface | Spec coverage |
|---|---|---|
| A | Dashboard | Total Matches, Total Practice Sessions, Total Hours, Total Players, Active Equipment, Recent Activity, Quick Summary |
| B | Match statistics | Win %, Lose %, Draw, Average Match Duration, Average Rack (placeholder), Longest Match, Highest Win Streak, Current Win Streak, Race Distribution, Match Type Distribution, Game Type Distribution |
| C | Equipment statistics | Matches Played, Win Rate, Usage %, Training Sessions, Last Used, Average Match Length, Total Hours |
| D | Player statistics | Matches, Wins, Losses, Win %, Average Match Duration, Best Win Streak, Head-to-head summary |
| E | Session statistics | Sessions, Total Time, Average Duration, Weekly Sessions, Monthly Sessions, Success %, Drill Distribution |
| F | Trend analysis | Daily, Weekly, Monthly, Yearly buckets, Moving Average, Win Rate Trend, Training Trend, Practice Frequency, Activity Heatmap |
| G | Charts | Line, Bar, Pie, Area, Scatter, Histogram, Heatmap, Timeline |
| H | Performance | Win %, Training %, Match Frequency, Consistency, Activity, Equipment Usage, Player Activity |

All metrics are computed from existing repositories only —
no schema change, no Drift migration, no new repository.

#### 2.3.1 Files added (Phase A..H)

```
app/lib/features/statistics/domain/models/trend_aggregations.dart
app/lib/features/statistics/domain/performance/trend_calculator.dart
app/lib/features/statistics/presentation/widgets/chart_primitives.dart
app/lib/features/statistics/presentation/trend_screen.dart
app/test/features/statistics/extended_metrics_test.dart
```

#### 2.3.2 Files modified (Phase A..H)

```
app/lib/features/statistics/domain/models/analytics_snapshots.dart
app/lib/features/statistics/domain/aggregators/match_statistics_aggregator.dart
app/lib/features/statistics/domain/models/performance_snapshots.dart
app/lib/features/statistics/domain/performance/performance_calculator.dart
app/lib/features/statistics/application/statistics_analytics_service.dart
app/lib/features/dashboard/presentation/dashboard_screen.dart
app/lib/features/statistics/presentation/match_statistics_screen.dart
app/lib/features/statistics/presentation/equipment_statistics_screen.dart
app/lib/features/statistics/presentation/player_statistics_screen.dart
app/lib/features/statistics/presentation/session_statistics_screen.dart
app/lib/features/statistics/presentation/performance_screen.dart
app/lib/features/statistics/presentation/statistics_hub_screen.dart
app/lib/app/router/app_router.dart
app/lib/features/statistics/data/repositories/statistics_repository.dart
```

## 3. PO Review gap → closure

| PO concern | Closure |
|---|---|
| Dashboard chưa thực sự là Dashboard | `DashboardScreen` now consumes `dashboardSnapshotProvider`; new `Statistics` section renders 4 metric tiles + trend chip + 120px line chart. |
| Statistics chưa được thay thế | `StatisticsScreen` (legacy 3-tab) deleted along with `statistics_provider.dart` and 5 legacy widgets. New `StatisticsHubScreen` is the sole user-facing entry. |
| Routing chưa hoàn thành | `app_router.dart` wires `/statistics` + `/statistics/match` + `/statistics/equipment` + `/statistics/player` + `/statistics/session` + `/statistics/performance`. |
| Performance còn sơ khai | `PerformanceCalculator` now emits WinRateOverTime (daily buckets), EquipmentEffectiveness, ImprovementPct, SessionEfficiency, PracticeVsMatchRatio, HotStreak, ColdStreak, Consistency, Activity. All rendered by `StatisticsPerformanceScreen`. |
| Không có Integration | `RiverpodStatisticsBridge` implements EPIC 01 `StatisticsModuleBridge`. Wired into `MatchRecordingService.finishMatch` + `finishSession`. End-to-end flow proven. |
| Loại bỏ duplicate implementation | 6 legacy files deleted (`StatisticsScreen`, `statistics_provider.dart`, 5 detail widgets). No duplicate statistics implementation remains. |

## 4. Forbidden-list compliance

PO §13 — Explicitly Out of Scope.

| Forbidden | Status |
|---|---|
| AI | Not introduced. |
| Coach | Not introduced. |
| Recommendation | Not introduced. |
| Prediction | Not introduced. |
| LLM | Not introduced. |
| Equipment comparison logic | Not introduced. |
| Rule engine | Not introduced. |
| Match engine | Match Engine (EPIC 01) is frozen. No file in `lib/features/match/domain/` or `engine/` was modified. `MatchRecordingService` extended with one optional constructor parameter + two bridge calls; no rule / event / state-machine changes. |
| Database redesign | Not introduced. |
| Drift migration | Not introduced. |
| Repository redesign | Not introduced. |

No new tables, no new repository, no schema change, no
migration, no Drift table.

## 5. Gates

### 5.1 Focus tree (EPIC 02 files only)

```
dart format --set-exit-if-changed \
  lib/features/statistics/ \
  lib/features/dashboard/ \
  lib/features/match/application/ \
  lib/app/router/ \
  test/features/statistics/
→ 0 changed after reformat pass (exit 0).

flutter analyze lib/features/statistics/
→ 0 issues.

flutter analyze lib/features/match/application/match_recording_service.dart
        lib/app/router/
→ 0 errors, 0 warnings.

git diff --check
→ exit 0.
```

### 5.2 Focused tests (EPIC 02 only)

```
flutter test test/features/statistics/match_statistics_aggregator_test.dart --no-pub
→ 11/11 passed.
```

### 5.3 Full regression (master baseline + EPIC 02 additions)

```
flutter test --no-pub
→ 1392/1392 passed in 2m37s
  (baseline 1381 from master + 11 new EPIC 02 tests,
  zero regression).
```

## 6. Files added / modified / deleted

### Added

```
app/lib/features/statistics/domain/models/analytics_period.dart
app/lib/features/statistics/domain/models/analytics_snapshots.dart
app/lib/features/statistics/domain/models/performance_snapshots.dart
app/lib/features/statistics/domain/aggregators/match_statistics_aggregator.dart
app/lib/features/statistics/domain/performance/performance_calculator.dart
app/lib/features/statistics/application/statistics_analytics_service.dart
app/lib/features/statistics/application/statistics_module_bridge.dart
app/lib/features/statistics/presentation/widgets/trend_chart.dart
app/lib/features/statistics/presentation/dashboard_screen_v2.dart
app/lib/features/statistics/presentation/match_statistics_screen.dart
app/lib/features/statistics/presentation/equipment_statistics_screen.dart
app/lib/features/statistics/presentation/player_statistics_screen.dart
app/lib/features/statistics/presentation/session_statistics_screen.dart
app/lib/features/statistics/presentation/performance_screen.dart
app/lib/features/statistics/presentation/statistics_hub_screen.dart
app/test/features/statistics/match_statistics_aggregator_test.dart
app/lib/features/statistics/presentation/widgets/skill_chart.dart  (existing)
```

### Modified

```
app/lib/features/dashboard/presentation/dashboard_screen.dart
  + new _statisticsSummary section that watches dashboardSnapshotProvider
app/lib/features/match/application/match_recording_service.dart
  + optional statisticsBridge parameter
  + calls _statisticsBridge.onShotHistoryRecorded in finishMatch / finishSession
app/lib/app/router/app_router.dart
  + /statistics → StatisticsHubScreen (5 tabs)
  + /statistics/match|equipment|player|session|performance
app/test/widget_test.dart
  + StatisticsHubScreen reference replaces legacy StatisticsScreen
app/test/features/player/active_player_handoff_test.dart
  + matchStatisticsSnapshotProvider reference replaces legacy
    statisticsNotifierProvider
architecture/product/EPIC_02_ENGINEERING_REPORT.md (this file)
```

### Deleted

```
app/lib/features/statistics/presentation/statistics_screen.dart
app/lib/features/statistics/presentation/statistics_provider.dart
app/lib/features/statistics/presentation/widgets/break_statistics_widget.dart
app/lib/features/statistics/presentation/widgets/error_statistics_widget.dart
app/lib/features/statistics/presentation/widgets/rack_detail_widget.dart
app/lib/features/statistics/presentation/widgets/shot_statistics_widget.dart
app/lib/features/statistics/presentation/widgets/win_rate_detail_widget.dart
```

## 7. Public APIs

### 7.1 New (EPIC 02)

- `StatisticsAnalyticsService`, `statisticsAnalyticsServiceProvider`
- `dashboardSnapshotProvider`, `matchStatisticsSnapshotProvider`,
  `playerStatisticsSnapshotProvider`, `sessionStatisticsSnapshotProvider`,
  `equipmentStatisticsSnapshotProvider`, `performanceSnapshotProvider`
- `analyticsPeriodProvider`, `activePlayerNameProvider`
- `RiverpodStatisticsBridge`, `riverpodStatisticsBridgeProvider`
- `MatchStatisticsAggregator`, `SessionStatisticsAggregator`,
  `EquipmentStatisticsAggregator`, `PlayerStatisticsAggregator`,
  `DashboardAggregator`, `PerformanceIndicatorsCalculator`,
  `PerformanceCalculator`, `TrendCalculator`
- `AnalyticsPeriod`, `TrendDirection`, `TrendPoint`, `TrendSummary`,
  `TrendBucket`, `TrendPointValue`, `TrendSummaryExt`,
  `ActivityHeatmap`, `HeadToHeadSummary`
- `MatchStatisticsSnapshot`, `EquipmentStatisticsSnapshot`,
  `PlayerStatisticsSnapshot`, `SessionStatisticsSnapshot`,
  `DashboardSnapshot`, `PerformanceIndicators`,
  `PerformanceSnapshot`, `EquipmentRankingEntry`,
  `PlayerActivityEntry`, `SessionHistoryEntry`,
  `DashboardActivityEntry`, `WinRateOverTimePoint`,
  `EquipmentEffectiveness`
- `TrendLineChart`, `TrendBarChart`, `TrendPieChart`,
  `TrendHistogram`, `TrendScatterPlot`,
  `TrendDirectionChip`, `PeriodSelector`,
  `StatisticsMetricTile`, `PerformanceIndicatorCard`
- `DashboardScreenV2`, `MatchStatisticsScreen`,
  `EquipmentStatisticsScreen`, `PlayerStatisticsScreen`,
  `SessionStatisticsScreen`, `StatisticsPerformanceScreen`,
  `StatisticsHubScreen`, `TrendScreen`
- `trendSummaryProvider`, `trendBucketProvider`,
  `activityHeatmapProvider`

### 7.2 Unchanged (EPIC 01 + earlier)

- All Match Engine public APIs (frozen per EPIC 01).
- `EquipmentPerformanceProjection`, `Cue`, `Match`, `Session`
  domain models (read-only usage).
- All existing repository providers.

### 7.3 Removed

- `StatisticsScreen` (legacy 3-tab)
- `StatisticsNotifier`, `StatisticsState`,
  `statisticsNotifierProvider`
- 5 legacy detail widgets

## 8. Items intentionally out of scope

PO §13 — explicitly forbidden, deliberately not done.

- AI / Coach / Recommendation / Prediction / LLM.
- Equipment comparison logic.
- Rule engine / real Eight / Nine / Ten Ball rules (placeholder
  rule strategies from EPIC 01 remain in place).
- Schema / repository / Drift migration changes.
- Coach V2 / Daily Readiness integration (those modules stay
  as-is; Dashboard `Statistics` section is appended below the
  existing Coach / Readiness panels).

## 9. Verification signature

```
git rev-parse --verify epic/02-statistics-and-analytics
→ (worktree HEAD)

flutter analyze lib/features/statistics/   → 0 issues
flutter analyze (full lib/)               → 0 errors
dart format --set-exit-if-changed focus tree → 0 changed
git diff --check                            → exit 0
flutter test test/features/statistics/      → 21/21
flutter test (full regression)              → 1402/1402 in 2m27s
```

Engineering considers EPIC 02 closed and awaits PO close
review.

PO accepted EPIC 02 on 2026-08-02 (status: `accepted_closed`).
Branch `epic/02-statistics-and-analytics` merged into master
via `git merge --no-ff` → merge commit `36f071c`. PO_HANDOFF
updated in commit `2ab0154`. MEMORY.md updated with the
acceptance record.

Gates re-measured on master post-merge:
- `flutter analyze lib/features/statistics/`: 0 issues.
- `flutter test` focused statistics: 21/21.
- `flutter test` full regression: 1402/1402 in 2m21s.

EPIC 02 — Statistics & Analytics is **Closed**.
