# I10 Simulation MVP

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Deliver a read-only Product Simulation experience that replays and compares
existing Match and Training observations. I10 does not calculate physics,
predict outcomes or introduce a Simulation framework.

## Query Flow

```text
Simulation Screen
  -> SimulationMvpService
  -> P6 Simulation capability compatibility preflight
  -> P8 Simulation capability runtime bootstrap
  -> P9 QueryExecutor
  -> existing MatchStatisticsService / TrainingStatisticsService
  -> immutable replay samples and previews
```

## Implemented Behavior

- Selects Match replay, Training replay or combined replay scenarios.
- Builds immutable requests and deterministic newest-first previews from
  existing recorded observations only.
- Compares two previews by observed completion/success rate and duration.
- Renders a read-only comparison chart using the existing `fl_chart` package.
- Keeps an append-only, session-local replay history with an explicit clear
  action; no persistence or schema is added.
- Handles empty observations as an empty preview without fallback or
  prediction.

The screen is implemented and tested in the exact I10 allowlist. It is not
added to the application router because `app/lib/app/` was not authorized by
the Product Owner packet.

## Ownership And Reuse

- Existing Match and Training statistics services remain owners of recorded
  data access and aggregation.
- Simulation presentation adapts those records into generic immutable replay
  samples; it does not import repositories or persistence.
- P6/P8 perform Simulation capability compatibility preflight.
- P9 executes the private feature-local query and handler.
- I10 owns only scenario selection, observed-data replay, comparison and
  session-local presentation state.

No Physics Engine, Monte Carlo, AI/ML prediction, billiards engine, numerical
solver, Simulation framework, repository, schema, network, HTTP/API,
background worker, new runtime or new framework behavior was introduced.

## Verification

- Focused I10 tests: 5/5.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1172/1172.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Dependency and prohibition scans: clean.
- Generated Architecture Fitness health output restored to baseline.
- Protected Foundation M1-M22, P6-P9, Match/Training services, repositories,
  persistence, schema, router and production artifacts are unchanged.
- Diff is limited to the exact I10 allowlist.

## Scope Confirmation

I10 is a concrete read-only Product feature over accepted application services.
It replays observations and does not simulate physical behavior or create a
second Simulation abstraction.

## Repository State

Product Owner accepted I10 on 2026-07-24 and authorized repository commit and
push without redesign.
