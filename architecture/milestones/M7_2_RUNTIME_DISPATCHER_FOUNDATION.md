# M7.2 Runtime Dispatcher Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

Adds a deterministic dispatch projection from M7.1 coordination. It creates
canonical dispatch keys and positions only; it does not execute, schedule,
queue, retry, persist, call APIs/providers, or mutate runtime.

## Evidence

- Focused tests: 7/7.
- Analyzer: clean.
- Full regression and protected freeze evidence are included in the Product
  Owner report.
