# I6 Training Statistics & Performance

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Display aggregate and recent Training performance from the persisted I3/I4
Session history. I6 is read-only statistics, with no AI, prediction, new
repository, projection or Analytics engine.

## Read Flow

```text
Training presentation
  -> Training application service
  -> accepted Session application service
  -> existing Session / Match / Rack repositories
  -> persisted Training statistics
```

The Training application service aggregates Dart records already exposed by
the Session application boundary. Training source does not import persistence.

## Implemented Behavior

- Displays completed Training Session count, Exercise count, Attempt count,
  Success count, aggregate Success rate and total duration.
- Displays recent completed Sessions with date/order, duration, Exercise count,
  Attempts, Successes and Success rate.
- Aggregates per-Drill Attempts, Successes and Success rate.
- Displays chronological Success-rate trend for the last five completed
  Sessions.
- Active Training Sessions are excluded through the accepted completed-history
  source.
- The panel is integrated into Training History.

## Ownership And Reuse

- Session application remains the persistence-facing owner.
- Training application owns Product display aggregation only.
- Training presentation consumes only the Training application service.
- Existing repositories and RecordingCoordinator are unchanged.

No Analytics Engine, TrainingStatisticsRepository, read model, projection,
cache, AI, recommendation, prediction, ML, runtime, framework, contract,
registry, schema, coordinator or repository change was introduced.

## Verification

- Focused I6 tests: 2/2.
- Combined I4/I6 interaction tests: 4/4.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1151/1151.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Real SQLite tests verify aggregate/recent/per-Drill/trend statistics and
  database restart recovery.
- An I4 navigation test now scrolls its history tile into view after I6 adds the
  statistics panel above it; Product behavior was unchanged.
- Generated Architecture Fitness health output was restored after verification.
- Protected artifacts, schema, coordinator, repositories and frozen P1-P9 are
  unchanged.
- Diff is limited to the exact I6 allowlist.

## Scope Confirmation

I6 is Product-level display aggregation only and does not create a new
Analytics capability or framework responsibility.

## Product Owner Decision

Accepted and closed on 2026-07-24. Product Owner authorized repository commit
and push without redesign and recognized I1-I6 as the first Internal Alpha
baseline.
