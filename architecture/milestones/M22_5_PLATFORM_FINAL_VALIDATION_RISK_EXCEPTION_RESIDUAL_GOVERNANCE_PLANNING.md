# M22.5 Platform Final Validation Risk, Exception & Residual Governance Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define immutable risk, exception and residual-risk governance for final platform
validation. Planning only; no assessment, approval, audit, Product, runtime,
contract, UI, deployment, release, tooling, ADR, freeze or generated change.

## Authority And Protected Inputs

Constitution v1.4.0, accepted M22.0-M22.4 and M3-M21 freezes remain protected.
M22.1-M22.4 retain identity, evidence, dependency and audit ownership. M22.5
binds exact IDs/digests without evaluating or altering source determinations.

## Immutable Final-Validation Risk Model

A risk binds risk ID/type/schema, candidate/scope/criterion, originating claim/
dependency/gap/finding/evidence digests, cause/event/consequence, likelihood and
impact classes/rules, controls/assumptions/limitations, inherent/residual state,
owner/acceptance authority/validity, exception/escalation/rollback, lineage and
digest. Any bound change creates a successor. Scores cannot create acceptance.

States are `identified`, `classified`, `owned`, `controlPlanned`,
`controlVerified`, `residualEvaluated`, `acceptancePending`, `acceptedBounded`,
`rejected`, `reopened` and `superseded`; history is append-only.

## Immutable Exception Governance Model

An exception binds exact risk/gap/finding/claim and candidate/scope digests,
requester/owner, rationale, prohibited/permitted boundaries, controls, positive/
negative evidence, independent review, accepting authority, effective/expiry/
review dates, revocation/rollback, lineage and digest.

Exceptions are narrow, non-transferable and time-bound. They cannot change
truth, waive Constitution, hide unknowns, close gaps, propagate to successors or
authorize validation, Product, implementation, release or deployment. Renewal
creates a successor and repeats review.

## Residual-Risk Governance

Residual risk binds inherent risk, exact verified control/evidence/audit digests,
remaining exposure, assumptions, affected claims, owner, acceptance boundary,
validity, review/escalation triggers and digest. It cannot be inferred from a
control's presence, passing test, absent incident, report or provider output.
Changed inputs or ineffective controls reopen the risk and invalidate acceptance.

## Ownership And Accountability Boundaries

| Responsibility | Accountable authority |
|---|---|
| Risk source/semantic claim | Owning domain |
| Candidate risk composition | Architecture/Platform |
| Contract/version exposure | Producer and consumer owners |
| Evidence provenance/custody | Source/Evidence owner |
| Control/repair plan | Accountable risk owner |
| Control/residual verification | Independent Quality/auditor |
| Security/privacy/operations risk | Respective authority |
| Exception request/maintenance | Affected accountable owner |
| Bounded exception acceptance | Explicit governance authority |
| Final closure/Product boundary | Product Owner |

Owner, requester, evidence producer and control implementer cannot independently
verify or approve their own acceptance.

## Exception Eligibility And Constraints

Eligibility requires exact non-prohibited risk/scope, accountable owner, current
positive/negative evidence, independently verified controls, bounded residual,
explicit authority, expiry/review/revocation and no downstream contradiction.
Constitutional violation, broken freeze, unknown exposure, missing authority,
nondeterminism or critical custody/trust failure is never eligible.

## Residual-Risk Acceptance Governance

Acceptance binds exact candidate/scope/risk/residual/exception digests, criteria,
dependencies, authority mandate, evidence/audit, constraints, validity, review,
revocation and digest. It cannot transfer across candidate, scope, version,
owner, contract or successor, and never compensates another closure criterion.

## Evidence Ownership And Custody

Every determination references current source-owned positive/negative evidence,
semantic IDs/digests, provenance/custody, methods/rules, canonical results,
assumptions, validity, limitations, correction lineage and independent review.
Reports remain derived and cannot self-review or fill missing evidence.

## Deterministic Review And Escalation Workflow

Order is `identify`, `classify`, `assignOwner`, `validateEvidence`,
`defineControls`, `verifyControls`, `evaluateResidual`, `independentReview`,
`authorityDecision`, `validityReview`. Items order by criterion, risk class, risk
and evidence IDs. Same inputs yield same sequence/digest. Unknown ownership,
dispute, failed control, non-acceptable class, conflict, expiry or scope change
requires escalation; stages cannot be skipped.

## Rollback Repair Supersession And Fail-Closed Governance

Rollback selects a verified predecessor without editing history. Repair occurs
at the accountable source and triggers downstream review. Supersession links all
risk, control, residual, exception, evidence and decision digests.

Reject mixed/stale identity, unknown owner, missing evidence, invalid custody,
compensating score, self-review, unverified control, unbounded residual, expired
exception, open escalation, conflict, nondeterminism, orphan lineage, unsafe
rollback or broken freeze. This plan performs no assessment or approval and
grants no authority.

## Definition Of Done

- Immutable risk, exception and residual models are explicit.
- Ten ownership and bounded acceptance rules are defined.
- Evidence and deterministic ten-stage review/escalation are explicit.
- Recovery, supersession and fail-closed governance are complete.
- Exactly this milestone and MEMORY change; no implementation/protected change.

## Engineering Evidence

- App 965/965, Knowledge 75/75 and protected M3-M21 freezes 72/72 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated health restored; exact two-file scope and clean diff confirmed.
