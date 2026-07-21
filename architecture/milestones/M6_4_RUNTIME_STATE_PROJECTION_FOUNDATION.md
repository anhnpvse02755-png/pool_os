# M6.4 Runtime State Projection Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

Adds an immutable deterministic snapshot projection from M6.3 execution graph.
The projector derives topology-based `Ready` and `Waiting` states only; it does
not model execution results, transitions, timers, persistence, or mutation.

## Evidence

- Focused tests: 7/7.
- Analyzer: clean.
- Full regression and protected freeze evidence are included in the Product
  Owner engineering report.

## Product Review

Product Owner accepted and closed M6.4 on 2026-07-22. M6.5 Runtime Transition
Foundation is Ready to Start.
