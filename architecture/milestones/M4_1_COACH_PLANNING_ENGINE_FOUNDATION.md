# M4.1 Coach Planning Engine Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Scope

M4.1 adds a deterministic, immutable and replayable execution-structure graph
over frozen M3 public contracts. It does not choose Knowledge, resolve Knowledge
graphs, mutate Decision/Recommendation/Execution, or add AI behavior.

## Ownership and Contracts

- Coach owns `CoachPlanningGraphContract`, its nodes/edges, and
  `CoachPlanningEngine`.
- Learning Runtime remains the sole owner of Knowledge prerequisite, unlock,
  availability, and dependency resolution.
- Inputs are frozen public Coach Context, Decision, Recommendation, and
  Execution contracts. Player Progress and Experience are consumed through
  Coach Context.
- The M3 frozen contract manifest and contract-set digest remain unchanged.

## Behavior

- Nodes are bound to player, session, semantic ID, semantic digest, and kind.
- Edges express only Decision -> Recommendation and Recommendation -> Execution
  dependencies.
- Nodes and edges are canonicalized before graph digest calculation.
- Same inputs replay to the same JSON and digest.
- Duplicate nodes/edges, mixed player/session, orphan edges, invalid/cyclic
  dependency shapes, stale Recommendation, and stale Execution fail loudly.
- Graph output contains no prose, prompt, score, AI output, scheduling,
  optimization, persistence, UI, network, or provider behavior.

## Verification

- Focused M4.1 tests: 9/9.
- Focused analyzer: no issues.
- Combined M3.1-M3.13 plus M4.1 foundation tests: 108/108.
- Full app tests: 334/334.
- Knowledge package tests: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3 Foundation Freeze: 14 contracts, 13 suites, 0 cycles; PASS.
- Protected Constitution, Reference Behavior, Golden Fixtures, production
  Knowledge/publication artifacts, and M3 contract identities: unchanged.

## Product Review

Product Owner accepted and closed M4.1 on 2026-07-21. M4.2 Adaptive
Recommendation Engine Foundation is Ready to Start.
