# I3 Training Session Vertical Slice

Status: Accepted; Closed

Date: 2026-07-24

## Objective

Deliver a concrete Training Session flow on the existing recording hierarchy.
A user can create a Training Session, add Exercises, record each Exercise
result, finish the Session, and recover the complete history after restart.

## Executable Flow

```text
Training presentation
  -> Session-owned feature-local P3 command handler
  -> P9 CommandExecutor
  -> RecordingCoordinator
  -> existing Session / Match / Rack repositories
```

An Exercise uses the already accepted drill recording representation:

```text
Session(type=training)
  -> Match(gameType=drill, exercise identity)
  -> Rack(attempt/success summary)
```

No parallel Training Center persistence is used. Session remains the lifecycle
owner and RecordingCoordinator remains the atomic write owner.

## Implemented Behavior

- The Session start control offers Match or Training.
- Training Session creation executes through a private P3 handler and P9.
- Adding an Exercise atomically creates its drill Match and first Rack through
  `RecordingCoordinator.startDrillMatch`.
- Users record Success/Miss attempts and complete each Exercise.
- Exercise completion validates Match/Rack binding, persists attempts,
  successes and success rate summary, and closes the drill Match atomically
  through `RecordingCoordinator.finishDrillMatch`.
- Training Session completion uses `RecordingCoordinator.finishSession`.
- Active Exercise state reloads from the existing Match/Rack persistence.
- Completed history survives database close/reopen.

## Failure Semantics

- A Training Session cannot start while another Session is active.
- Exercise creation rejects missing, terminal or non-Training Sessions.
- Exercise completion rejects invalid counts, terminal/non-drill Matches and
  mismatched Match/Rack bindings before any write.
- No fallback or partial write path is present.

## Ownership And Reuse

- Session owns Training Session lifecycle.
- RecordingCoordinator owns atomic drill and Session writes.
- Existing Session, Match and Rack repositories own persistence.
- Private feature-local P3 handlers adapt I3 commands to P9 execution.
- The separate legacy `training_center` persistence is not imported or changed.

No coordinator, runtime, repository, schema, framework, contract or persistence
path was added.

## Verification

- Focused I3 tests: 3/3.
- Focused analyzer: clean.
- Focused formatter and `git diff --check`: clean.
- Full app regression: 1145/1145.
- Knowledge package regression: 75/75.
- Foundation freeze: 76/76.
- Architecture Fitness: 133 existing violations, 0 new.
- Real SQLite integration verifies lifecycle persistence, binding fail-closed,
  widget recording, Session completion and database restart recovery.
- Generated Architecture Fitness health output was restored after verification.
- Protected artifacts, schema, RecordingCoordinator and frozen contracts are
  unchanged.
- Diff is limited to the exact I3 allowlist.

## Scope Confirmation

I3 is a Product vertical slice over frozen framework and persistence owners. It
does not introduce Training planning, recommendation, AI, new business
frameworks or a competing Session model.

## Product Owner Decision

Accepted and closed on 2026-07-24. Product Owner authorized repository commit
and push without redesign.
