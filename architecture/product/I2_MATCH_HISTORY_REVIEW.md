# I2 Match History & Review

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Expose completed Match history and review from existing persisted Session,
Match and Rack data. Users can open a completed Match, inspect its final score,
follow cumulative score progression across the Rack timeline, and navigate to
the owning Session summary.

## Read Flow

```text
Session presentation
  -> existing Session application gateway
  -> existing Session / Match / Rack repositories
  -> Match history view
  -> existing Match detail and Session summary screens
```

The existing application gateway exposes the already accepted repositories to
presentation. It adds no repository, query framework, read store, persistence
path or domain abstraction.

## Implemented Behavior

- The Match screen lists completed Matches newest first.
- Active Matches are excluded from historical review.
- Each history item shows opponent or Match number, final Rack score, owning
  Session ID/date, Rack count and game type.
- Selecting a history item opens the existing Match Detail screen.
- Match Detail now shows the owning Session link.
- Each Rack timeline row shows the cumulative player/opponent score after that
  Rack, while preserving repository-defined chronological ordering.
- The Session link opens the existing Session Summary screen.

## Ownership

- Match presentation owns Match history and review rendering.
- Session presentation owns placement of history in the Match user flow.
- Existing Session/Match/Rack repositories remain the only read owners.
- The accepted Session application gateway remains the Experience-to-data port.
- RecordingCoordinator and all write paths are unchanged.

## Verification

- Focused I2 tests: 2/2.
- Combined I1-I2 focused tests: 7/7.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1142/1142.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Real SQLite widget/integration tests verify completed-only history, final
  score, Session linkage, navigation into Match Detail, cumulative score
  progression and chronological Rack ordering.
- Generated Architecture Fitness health output was restored after verification.
- Protected artifacts, schema, RecordingCoordinator and frozen contracts are
  unchanged.
- Diff is limited to the exact I2 allowlist.

## Scope Confirmation

I2 adds no schema, repository, framework, runtime, contract, persistence path,
ownership change or product abstraction. It is a read-only vertical slice over
existing persisted data.

## Product Owner Decision

Accepted and closed on 2026-07-24. Product Owner authorized repository commit
and push without redesign.
