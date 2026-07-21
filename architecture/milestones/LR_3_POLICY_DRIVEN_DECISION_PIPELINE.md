# LR-3 - Policy-driven Availability and Recommendation Pipeline

**Status:** Accepted; Closed

**Date:** 2026-07-21

**Implementation commit:** `35a5457d7bf97f08f16bc421b339f69a061114e6`

**Branch:** `m2/evidence-runtime-hardening`

## Outcome

The Technique decision path is now an explicit, injectable pipeline. Each
stage returns a typed result and no stage reconstructs the output of a previous
stage.

```text
Evidence
  -> Availability Resolver
  -> Mastery Policy
  -> Recommendation Resolver
  -> Correction Resolver
  -> Decision Record
```

| Gate | Result |
| --- | --- |
| Availability returns typed status/blockers, not recommendations | PASS |
| Mastery returns assessment/reasons, not candidates | PASS |
| Recommendation consumes resolved availability and mastery | PASS |
| Correction has no Mastery or Recommendation input | PASS |
| Authorized stage order | PASS |
| Structured availability reason taxonomy | PASS |
| LR-3 stage conformance | 4/4 |
| LR-1/LR-2/Golden-focused regression | 26/26 |
| App tests | 219/219 |
| Knowledge package tests | 67/67 (unchanged LR-2 baseline) |
| Architecture Fitness | 133 existing / 0 new |

## Preserved Behavior

- The public `LearningDecisionEngine`, `DecisionRecord`, policy versions,
  candidate scores, deterministic ordering, and trace ordering are unchanged.
- Direct dependency and implicit ALL semantics remain exactly LR-2.
- Active correction continues to block the authored next recommendation.
- Mistake lifecycle and correction candidate semantics are unchanged.
- Existing Golden Fixtures replay without modification.

## Preserved Identities

- LR-2 RC digest:
  `ee09ca62a354fb6cf8c3754f72dac105e2e1d46f087a7a349145e8794cfe189b`.
- LR-2 Candidate Pack digest:
  `531a7e6d5066fc1dca33aaca10b6080648dfdc70dfd2b1278bd3d3959a6dcc82`.
- M2.3 RC digest:
  `fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac`.
- M2.3 Candidate Pack digest:
  `22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02`.

Production Knowledge `0.2.1`, current, Compiler, Publication, Evidence,
Golden Fixtures, Reference Behavior, and the Constitution are unchanged.

## Scope Boundary

LR-3 does not add Unlock Expressions, OR/NOT operators, recursive dependency
evaluation, probabilistic mastery, dynamic categories, attempt-level Evidence,
or production activation. Passing engineering gates does not imply Product
acceptance.

## Product Review

Product Owner Nguyễn Phú Việt Anh accepted and closed LR-3 on 2026-07-21.
The next authorized executable capability is LR-4 - Unlock Expression Contract,
limited to `allOf`/AND. OR, NOT, XOR, and other expression operators remain out
of scope.
