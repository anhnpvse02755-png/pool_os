# M4.2 Adaptive Recommendation Engine Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Scope

M4.2 creates an ordered read view over immutable Recommendations. It applies
deterministic, explainable priority bands using execution state, Player
Progress, and Experience projections. It does not mutate Recommendation or
introduce AI/ML scoring.

## Contract and Behavior

- `OrderedRecommendationViewContract` v1 is immutable and digest-bound to Coach
  Context.
- Priority is represented by an enum band and structured reason codes, never a
  numeric score, probability, or model output.
- Accepted execution resumes first; deferred execution follows; persistent
  mistake and experience/mastery rules provide deterministic policy bands;
  terminal execution is last; canonical Recommendation ID breaks ties.
- Recommendation order is canonicalized and replayable to the same JSON and
  digest.
- Stale Context/Recommendation, duplicate Recommendation, inconsistent or
  orphaned Execution, and mixed bindings fail loudly.
- The source Recommendation contract remains unchanged and is never mutated.

## Ownership

The engine consumes Coach Context, Recommendation, and Execution public ports.
Learning Runtime remains the owner of prerequisite, unlock, availability and
dependency resolution. No AI, LLM, ML score, provider, persistence, scheduler,
calendar, or network behavior is present.

## Verification

- Focused M4.2 tests: 8/8.
- Focused analyzer: no issues.
- Combined M3.1-M3.13, M4.1, and M4.2 foundation tests: 116/116.
- Full app regression: 342/342.
- Knowledge package tests: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3 Foundation Freeze: 14 contracts, 13 suites, 0 cycles; PASS.
- Protected Constitution, Reference Behavior, Golden Fixtures, production
  Knowledge/publication artifacts, and all M3 contract identities: unchanged.

## Product Review

Product Owner accepted and closed M4.2 on 2026-07-21. M4.3 Intelligence Trace
and Explanation Foundation is Ready to Start.
