# I5 Match Statistics & Performance

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Display basic Match performance from existing persisted Match and Rack data.
Statistics are read-only, completed-only and derived without schema changes,
new repositories, framework or Analytics runtime behavior.

## Read Flow

```text
Match presentation
  -> Match application service
  -> existing Match / Rack repositories
  -> persisted Match performance
```

The application service returns Dart records and owns only aggregation for the
I5 view. It creates no repository, read store, analytics engine or contract.

## Implemented Behavior

- Completed Matches are aggregated newest first; active Matches are excluded.
- Displays completed Match count, total Rack count, Rack win rate and total
  Match duration.
- Displays up to five recent Match performance rows with opponent/Match number,
  final score, per-Match Rack win rate and duration.
- The panel is integrated with the existing Match History view.

## Ownership And Reuse

- Existing Match and Rack repositories remain read owners.
- Match application owns the feature aggregation.
- Match presentation only consumes the application service.
- Session FK ownership remains enforced in real SQLite tests.

No repository, schema, framework, runtime, Analytics capability, AI or write
path was introduced.

## Verification

- Focused I5 tests: 2/2.
- Combined I2/I5 interaction tests: 4/4.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1149/1149.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Real SQLite tests verify completed-only aggregation, Session FK ownership,
  final scores, win rate, duration and metrics rendering.
- An I2 assertion was scoped to its history tile after I5 legitimately added a
  second rendering of the same opponent/score; Product behavior was unchanged.
- Generated Architecture Fitness health output was restored after verification.
- Protected artifacts, schema, frozen contracts and write owners are unchanged.
- Diff is limited to the exact I5 allowlist.

## Scope Confirmation

I5 adds Product-level display aggregation only. It does not create an Analytics
domain/runtime or expand the frozen framework.

## Product Owner Decision

Accepted and closed on 2026-07-24. Product Owner authorized repository commit
and push without redesign.
