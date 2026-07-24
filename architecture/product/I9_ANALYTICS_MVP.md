# I9 Analytics MVP

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Deliver a read-only Product Analytics dashboard using the already-calculated I5
Match and I6 Training statistics. I9 does not create an Analytics, Trend, KPI or
Report engine.

## Query Flow

```text
Analytics Dashboard
  -> AnalyticsMvpService
  -> P6 Analytics capability compatibility preflight
  -> P8 Analytics capability runtime bootstrap
  -> P9 QueryExecutor
  -> existing MatchStatisticsService / TrainingStatisticsService
  -> existing repositories and persistence behind those services
  -> immutable AnalyticsDashboardView
```

## Implemented Behavior

- Displays Match count, Rack count, Win rate and recorded Match duration.
- Displays Training Session count, Exercise count, Success rate and recorded
  Training duration.
- Uses the existing `fl_chart` dependency for basic rate and duration charts.
- Merges existing recent Match and Training rows into a deterministic,
  newest-first activity timeline with stable tie-breaking.
- Handles empty persisted sources as zero rates without fallback or prediction.
- Supports pull-to-refresh over the same read-only query.

The dashboard screen is implemented and tested in the exact I9 allowlist. It is
not added to the application router because `app/lib/app/` was not authorized by
the Product Owner packet.

## Ownership And Reuse

- I5 Match statistics remains owner of Match aggregation.
- I6 Training statistics remains owner of Training aggregation.
- Existing application services remain the persistence-facing read boundaries.
- Analytics presentation adapts those existing Dart records into generic source
  values; it does not import repositories or persistence.
- The I9 application service owns Product dashboard query traversal and recent
  activity composition only.
- P6/P8 perform Analytics capability compatibility preflight.
- P9 executes the private feature-local query and handler.

No Analytics Engine, Trend Engine, KPI Framework, Report Framework, repository,
schema, ML, AI prediction, network, HTTP/API, background job, new runtime or new
framework behavior was introduced.

## Verification

- Focused I9 tests: 5/5.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1167/1167.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Dependency and prohibition scans: clean.
- Generated Architecture Fitness health output restored to baseline.
- Protected Foundation M1-M22, P6-P9, Match/Training services, repositories,
  persistence, schema, router and production artifacts are unchanged.
- Diff is limited to the exact I9 allowlist.

## Scope Confirmation

I9 is a concrete read-only Product feature over accepted application services.
It does not duplicate Match/Training aggregation or add an Analytics engine.

## Repository State

Product Owner accepted I9 on 2026-07-24 and authorized repository commit and
push without redesign.
