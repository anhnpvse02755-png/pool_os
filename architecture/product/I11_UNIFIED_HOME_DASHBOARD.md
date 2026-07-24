# I11 Unified Home Dashboard

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Deliver one Product Home surface that composes the accepted Match, Training,
Coach, Knowledge, Analytics and Simulation MVP services. Home introduces no new
business calculation, ownership or Dashboard engine.

## Composition Flow

```text
Home Dashboard
  -> MatchStatisticsService
  -> TrainingStatisticsService
  -> CoachConversationService
  -> KnowledgeMvpService
  -> AnalyticsMvpService
  -> SimulationMvpService
  -> immutable HomeDashboardView
```

## Implemented Behavior

- Displays six stable destination cards for Match, Training, Coach, Knowledge,
  Analytics and Simulation.
- Uses existing Match and Training service results for summary counts/rates.
- Uses the structured Coach next-action response already produced by the Coach
  service; Home does not make a coaching decision.
- Uses the existing Knowledge browse result for article/category counts.
- Uses the existing Analytics view for recent activity and aggregate rates.
- Uses the existing Simulation replay preview for observed sample summary.
- Displays existing recent Match/Training activity without calculating a new
  timeline.
- Opens existing feature screens with local `Navigator.push` actions.
- Supports pull-to-refresh over the same composed services.

The Home screen is intentionally not added to the application router because
`app/lib/app/` is outside the exact I11 allowlist.

## Ownership And Reuse

Each I5-I10 service remains owner of its data and behavior. Home only adapts and
composes their public results into immutable summaries. It imports no repository
or persistence implementation and adds no business rule.

No repository, schema, runtime, framework, AI, HTTP/API, cache, background
worker or Dashboard engine was introduced.

## Verification

- Focused I11 tests: 5/5.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1177/1177.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Dependency and prohibition scans: clean.
- Generated Architecture Fitness health output restored to baseline.
- Protected Foundation M1-M22, P1-P9, accepted I5-I10 services, repositories,
  persistence, schema, router and production artifacts are unchanged.
- Diff is limited to the exact I11 allowlist.

## Scope Confirmation

I11 is a concrete Product composition surface. It does not duplicate the
behavior of any source service and does not create a second Dashboard engine.

## Repository State

Product Owner accepted I11 on 2026-07-24 and authorized repository commit and
push without redesign.
