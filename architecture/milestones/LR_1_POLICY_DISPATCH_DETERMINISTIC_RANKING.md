# LR-1 - Policy Dispatch and Deterministic Ranking

**Status:** Accepted; Closed

**Date:** 2026-07-21

**Implementation commit:** `75dbec2`

**Branch:** `m2/evidence-runtime-hardening`

## Scope

LR-1 is the first executable batch of Learning Runtime Generalization. It
generalizes the accepted deterministic learning slice by policy and semantic
model without implementing new mastery categories or changing publication
architecture.

Domain ownership remains unchanged:

- Knowledge owns Technique, Mistake, Outcome, Measurement, Drill, category,
  and policy declarations.
- Evidence owns immutable learning batches and replay.
- Intelligence owns policy resolution, Mastery, recommendation ranking, and
  DecisionRecord creation.
- Experience consumes the generalized Learning Runtime application service.

No cross-domain contract version changed. Evidence Batch v1, Observation v1,
DecisionRecord, Golden Fixtures, and Reference Behavior remain unchanged.

## Executable Outcome

- `LearningDecisionEngine.evaluateEntry` dispatches through payload kind and
  versioned policy resolution, never through Knowledge ID.
- `LearningRuntime.replay` returns a typed `TechniqueSnapshot` or
  `MistakeSnapshot` through one application entry point.
- Existing typed APIs remain compatibility wrappers.
- The implementation now lives in `learning_runtime.dart`;
  `stop_shot_runtime.dart` is a compatibility export only.
- Recommendation ordering is deterministic:
  1. policy score descending;
  2. stable semantic ID ascending.
- Unsupported Knowledge kinds, missing policy capability, unknown IDs, and
  probabilistic policies throw `ExecutableKnowledgeException`; there is no
  warning, ignore, fallback, or default policy.

## Published Candidate Fixture

The third Technique proof is not a test-only runtime object. Five Markdown
fixtures pass through:

```text
Markdown
  -> Compiler
  -> Entry Candidate
  -> Scoped Review
  -> Release Candidate
  -> Isolated Candidate Publication
  -> Runtime Load
```

The fixture contains:

- `technique.bank_shot` using the existing `advanced` policy with 20 attempts;
- `technique.kick_shot` to prove Evidence isolation;
- two equal-score Bank Shot corrections;
- one knowledge-only Concept that runtime must reject.

Fixture identities:

- Release Candidate digest:
  `f9b7d6f5fd280d183e2f973fab9e46c43f4a8c3d614bdb8f16ff671e629bdc8d`
- Candidate Pack digest:
  `4d4faab782d90d389cfc1d49e6b9703f47fdbc26a04e354b5346842e463e4060`

The authoring and generated proof live under
`packages/billiard_knowledge/test/fixtures/lr_1/`. They are conformance
artifacts and do not activate or publish a production Knowledge package.

## Verified Behavior

| Gate | Result |
| --- | --- |
| LR-1 fixture drift | PASS |
| Compile, scoped review, isolated publication | PASS |
| Source-order deterministic RC and Candidate Pack | PASS |
| Advanced threshold 15/20 below, 16/20 achieved | PASS |
| Multi-Technique and Mistake Evidence isolation | PASS |
| Equal-score ranking independent of pack order | PASS |
| Unsupported policy/kind/capability failure paths | PASS |
| Existing Golden vertical slice | 14/14 |
| Knowledge package tests | 63/63 |
| App tests | 211/211 |
| Focused analyzer | No issues |
| Architecture Fitness | 133 existing / 0 new |
| Production compiler/publication/runtime drift | PASS |
| M2.3/M2.4 identity regression | PASS |

## Preserved Invariants

- Reference Behavior 0.6.0 Revision 2 and Golden Fixtures are unchanged.
- Runtime and policy implementation contain no Knowledge-ID branch.
- Production Knowledge remains `0.2.1`; `current` is unchanged.
- M2.3 RC and Candidate Pack digests are unchanged.
- No publication architecture changes were made.
- Architecture debt remains ratcheted at 133 existing / 0 new.

## Out of Scope

- probabilistic Mastery implementation;
- attempt-level Evidence V2;
- Knowledge dependency or unlock expressions;
- dynamic mastery categories;
- learning-path migration or production corpus publication;
- Vision and Simulation.

Learning Runtime Generalization remains In Progress after LR-1. Subsequent
batches require their own executable scope and must not reopen LR-1 unless a
regression or governance decision requires it.

## Product Review

**Decision:** Accepted

**Decision date:** 2026-07-21

**Outcome:** LR-1 is closed. The reviewer confirmed that implementation and
evidence satisfy the approved DoD without reopening Evidence, publication,
Golden, or Reference Behavior contracts.

**Next capability:** LR-2 - Dependency-aware Learning Decisions. LR-2 must be
scoped separately and does not amend or reopen LR-1.
