# M3.7 Coach Recommendation Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Ownership And Contracts

- Learning Runtime owns prerequisite, unlock, dependency, and availability
  resolution.
- `LearningEligibilityProjection` v1 is a resolved, immutable read model. It
  carries source/resolved Knowledge IDs, availability, bounded blocker reason
  codes, source Decision provenance, and Knowledge version/digest. It contains
  no Evidence, graph, compiler internals, or score.
- `CoachContextContract` is v2 and binds the eligibility projection version and
  digest alongside existing Profile, Progress, and Experience provenance.
- `DecisionHistory` remains the existing append-only lifecycle/audit projection;
  no v2 expansion was made.
- `CoachRecommendationContract` v1 is immutable and binds Context, History,
  Plan, eligibility, Knowledge, and Recommendation policy provenance.

## Executable Scope

- An active Plan produces `continueActiveDecision` with the exact existing
  Decision ID and digest and no new Knowledge target.
- A terminal Plan may produce a concrete Technique target only from the
  resolved eligibility projection, or a persistent Mistake correction from
  Coach Context progress.
- Recommendation selection is deterministic and canonical; no score, rank,
  prose, prompt, AI, LLM, or ML output is produced.
- Recommendation Builder imports only public Coach Context, Decision History,
  Coach Plan, and Recommendation contracts. It does not read Evidence or
  Learning Runtime internals and cannot create or mutate Decisions,
  Transitions, History, Context, or Plan.
- Input binding failures and an empty resolved-candidate set fail closed.

## Verification

- Focused M3.7 tests: 8/8; combined Coach foundation tests: 27/27.
- Focused analyzer across new and changed contracts, projectors, builder, and
  tests: no issues.
- App regression: 277/277.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Architecture health projection refreshed; protected Reference Behavior,
  Golden Fixtures, production Knowledge/publication artifacts, and M2 proof
  records are unchanged.

## Product Review

The Product Owner accepted and closed M3.7 on 2026-07-21 after reviewing the
Coach Context v2 eligibility boundary, unchanged Decision History v1, active
Decision continuation, terminal target selection, deterministic provenance,
ownership separation, regression evidence, and architecture fitness.

## Explicit Non-Claims

M3.7 does not expand Decision History, resolve Knowledge graphs inside
Recommendation, create Decisions, mutate lifecycle, persist state, rank by
score, use AI/LLM/ML, generate prose, chat, Vision, Simulation, or UI output.
