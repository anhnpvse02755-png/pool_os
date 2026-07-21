# M4.4 Training Session Builder Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Scope

M4.4 packages an Ordered Recommendation View into an immutable Training Session
bound to Coach Context and Planning Graph provenance. It does not create,
reorder, rescore, or regenerate Recommendations.

## Contract and Behavior

- `TrainingSessionContract` v1 contains immutable items and session metadata.
- Each item preserves Recommendation ID/digest, Planning Node ID, Context
  digest, and the exact ordered-view position.
- Builder consumes only Coach Context, Planning Graph, and Ordered
  Recommendation View public contracts.
- Same inputs replay to the same session JSON and digest.
- Duplicate item, orphan planning node, mixed/foreign player, stale view/graph,
  and broken provenance fail loudly.
- No execution, scheduling, adaptive runtime, timer, persistence, UI, analytics,
  AI, prose, prompt, scoring, timing optimization, or calendar behavior exists.

## Verification

- Focused M4.4 tests: 5/5.
- Focused analyzer: no issues.
- Combined M3.1-M3.13 + M4.1-M4.4 foundation tests: 124/124.
- Full app regression: 350/350.
- Knowledge baseline: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3 Foundation Freeze: 14 contracts, 13 suites, 0 cycles; PASS.
- Protected artifacts and M3 frozen contract identities: unchanged.

## Product Review

Product Owner accepted and closed M4.4 on 2026-07-21. M4.5 Session Execution
Coordinator Foundation is Ready to Start.
