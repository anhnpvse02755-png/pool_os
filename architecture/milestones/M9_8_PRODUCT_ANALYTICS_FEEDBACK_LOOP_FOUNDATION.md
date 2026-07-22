# M9.8 Product Analytics & Feedback Loop Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M9.8 adds a deterministic Product analytics projection over the four public
Product read models explicitly authorized by the Product Owner. Despite the
milestone name, this foundation creates reference identity only; it does not
calculate analytics or generate feedback.

## Deliverables

- `app/lib/contracts/product_analytics_projection_contracts.dart`
- `app/test/product_analytics_projection_foundation_test.dart`

## Contract

- `ProductAnalyticsEntry` binds the player, capability, canonical position,
  recommendation ID, execution-outcome ID, interaction ID, and all four source
  projection digests.
- `ProductAnalyticsProjectionContract` v1 is immutable, versioned,
  content-addressed, replay-safe, and canonically ordered.
- `ProductAnalyticsProjector` is a pure reference projector over
  `PlayerProfileProjectionContract`, `RecommendationInboxContract`,
  `ExecutionOutcomeProjectionContract`, and
  `AICoachInteractionSurfaceContract` only.

## Invariants

- The execution outcome must bind the Recommendation Inbox digest, and the AI
  Coach interaction surface must bind the execution-outcome digest.
- Player identity, capability identity, source digests, semantic IDs,
  contiguous positions, equal coverage, and uniqueness fail closed when stale,
  foreign, malformed, duplicated, or incomplete.
- Profile is used only for player/profile identity. Profile feature coverage is
  not joined to interaction count and is not interpreted as analytics.
- No KPI, scoring, trend detection, recommendation, feedback generation, AI,
  persistence, dashboard/UI, or input mutation is present.
- M3-M8 frozen contracts and protected/generated artifacts remain unchanged.

## Verification

- Focused M9.8 tests: 5/5.
- Focused analyzer: clean.
- Full app regression: 621/621.
- Knowledge package regression: 75/75.
- Protected M3-M8 freeze suites: 20/20.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.

Product Owner accepted and closed M9.8 on 2026-07-22. The next authorized
capability is M9 Foundation Freeze & Architecture Validation.
