# M9.5 Plan & Recommendation Inbox Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M9.5 adds a deterministic Product recommendation-inbox projection over the
M9.4 decision view and public M3 OrderedRecommendationViewContract.

## Deliverables

- `app/lib/contracts/recommendation_inbox_contracts.dart`
- `app/test/recommendation_inbox_foundation_test.dart`

## Contract

- `RecommendationInboxEntry` binds recommendation identity, decision-view and
  recommendation-view digests, player, canonical position, planning node, and
  lifecycle metadata.
- `RecommendationInboxContract` is immutable, versioned, content-addressed,
  and canonically ordered.
- `RecommendationInboxProjector` is pure and only creates references; it does
  not create, rerank, score, or mutate recommendations or decisions.

## Invariants

- Only `CoachDecisionViewContract` and public
  `OrderedRecommendationViewContract` are consumed.
- Stale/foreign projections, duplicate recommendations, orphan positions,
  broken provenance, and mismatched lifecycle metadata fail closed.
- No recommendation generation, execution tracking, analytics, AI, Runtime,
  persistence, or UI behavior is present.
- M3-M8 frozen contracts and protected/generated artifacts remain unchanged.

## Verification

- Focused M9.5 tests: 5/5.
- Focused analyzer: clean.
- Full app regression: 606/606.
- Knowledge package regression: 75/75.
- Protected M3-M8 freeze suites: 20/20.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.

Product Owner accepted and closed M9.5 on 2026-07-22. M9.6 Execution & Outcome
Tracking Foundation is Authorized to Start and may consume only
RecommendationInboxContract plus the public immutable M3 execution-result
projection contract or its officially mapped equivalent.
