# M21.5 Platform Readiness Risk, Exception & Residual Governance Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define immutable readiness risk, exception and residual-risk governance for M21
candidates. Planning only; no Product feature, runtime contract, implementation,
UI, deployment, CI/CD, monitoring, infrastructure, tooling, ADR, freeze or
generated protected-artifact change is authorized.

## Authority And Protected Inputs

Constitution v1.4.0, accepted M21.0-M21.4 and M20 Foundation Freeze remain
protected. M21.1 owns scope identity, M21.2 evidence/criteria, M21.3 dependency/
gap semantics and M21.4 independent audit. M21.5 binds their exact IDs/digests
without reinterpreting, repairing or widening source-owned claims.

## Immutable Readiness Risk Model

Each risk binds:

1. risk ID/type/schema and exact candidate/scope/criterion identities;
2. originating claim, dependency, gap, finding and evidence digests;
3. cause, credible event, affected boundary and consequence classes;
4. likelihood and impact classes with rule-set/version identity;
5. controls, assumptions, limitations and verification references;
6. inherent and residual state without compensating aggregation;
7. owner, accountable acceptance authority, validity and review trigger;
8. exception, escalation, rollback, lineage and deterministic digest.

Any bound change creates a successor. Numeric scores may aid classification but
cannot compensate between criteria, create acceptance or replace source facts.
Unknown, disputed or insufficiently evidenced risk remains blocking.

## Risk Classification And States

Risk classes cover constitutional/ownership, contract/compatibility, Knowledge/
publication, Evidence/provenance, semantic/Decision Trace, deterministic replay,
security/privacy/trust, operational/capacity/recovery, dependency/gap and freeze/
governance continuity.

Lifecycle states are `identified`, `classified`, `owned`, `controlPlanned`,
`controlVerified`, `residualEvaluated`, `acceptancePending`, `acceptedBounded`,
`rejected`, `reopened` and `superseded`. Records are append-only. Only a current
`acceptedBounded` determination satisfies its exact permitted claim, and it
never satisfies another conjunctive readiness criterion.

## Exception Governance Model

An exception binds exception ID/type/schema, exact risk/gap/finding/claim and
candidate/scope digests, requester and accountable owner, rationale, prohibited
and permitted boundaries, compensating controls, positive/negative evidence,
independent review, accepting authority, effective/expiry/review dates,
revocation/rollback, predecessor/successor and digest.

Exceptions are narrow, explicit, non-transferable and time-bound. They cannot
change semantic truth, waive constitutional prohibitions, conceal unknowns,
authorize implementation, propagate to successor candidates or substitute for
closure. Renewal creates a successor and repeats evidence and independent review.

## Residual-Risk Governance

Residual risk is the source-owned determination remaining after independently
verified controls. It binds the inherent risk, exact control/evidence/audit
digests, unchanged assumptions, remaining exposure, affected claims, owner,
acceptance boundary, validity, review/escalation triggers and digest.

Residual risk cannot be inferred from control presence, a green test, missing
incidents or provider output. Changed inputs, ineffective controls, new evidence,
expired validity or widened scope reopen the risk and invalidate acceptance.

## Ownership And Accountability

| Responsibility | Accountable authority |
|---|---|
| Risk source and semantic claim | Owning domain |
| Candidate/scope risk composition | Architecture/Platform |
| Contract/compatibility exposure | Producer and consumer owners |
| Evidence/provenance/custody | Source/Evidence owner |
| Control implementation or repair plan | Accountable risk owner |
| Control and residual verification | Independent Quality/auditor |
| Security/privacy/trust risk | Security/Privacy/data authority |
| Operational/recovery/capacity risk | Respective operational owner |
| Exception request and maintenance | Affected accountable owner |
| Bounded acceptance/M22 boundary | Explicit governance/Product Owner authority |

Risk owner, requester, evidence producer and control implementer cannot
independently verify or approve their own acceptance.

## Acceptance Boundaries

Acceptance binds exact candidate, scope, risk/residual/exception digests,
criteria and dependencies, authority mandate, evidence/audit, constraints,
validity, review cadence, revocation and digest. It is not transferable across
scope, candidate, version, owner, contract, dependency or successor.

Constitutional violation, broken freeze, missing source authority, unknown
exposure, critical trust/custody failure, nondeterminism or unbounded Product
impact is non-acceptable. No deadline, cost, aggregate score, majority vote,
technical success or report can override these boundaries.

## Evidence Requirements

Every risk and exception requires current positive and negative source-owned
evidence, exact IDs/digests, provenance/custody, method/rules/version, canonical
success/failure results, assumptions, validity, correction/supersession lineage
and independent audit references. Evidence must demonstrate both control effect
and residual limitations. Generated summaries remain derived and cannot become
authority, self-review or fill missing evidence.

## Escalation And Review Workflow

The deterministic sequence is `identify`, `classify`, `assignOwner`,
`validateEvidence`, `defineControls`, `verifyControls`, `evaluateResidual`,
`independentReview`, `authorityDecision` and `continuousValidityReview`.
Within each stage, items order by criterion, risk class, risk and evidence IDs.
Identical inputs yield identical sequence/digest.

Escalation is mandatory for unknown ownership, disputed classification,
insufficient evidence, failed control, non-acceptable class, duty conflict,
exception expiry, scope change or reopened downstream dependency. Escalation
cannot skip a stage or grant interim acceptance.

## Rollback, Repair And Supersession

Rollback selects a verified compatible predecessor risk package without editing
history. Repair occurs only at the accountable source under separate authority,
then affected controls, residuals, exceptions and downstream claims are
re-verified. Supersession links all predecessor/successor digests, reason,
affected scope and decisions. Revocation immediately blocks dependent claims.

## Fail-Closed Governance And M22 Progression

Reject mixed/stale/duplicate identity, unknown owner, missing evidence, invalid
custody, unsupported classification, compensating score, self-review, conflict
of duties, unverified control, unbounded residual, expired/propagated exception,
open escalation, semantic conflict, nondeterminism, orphaned lineage, unsafe
rollback or broken freeze.

M22 planning eligibility requires every required risk resolved or explicitly
accepted within a valid permitted boundary, no non-acceptable/open residual,
current independent audit, intact predecessors/freezes and separate PO
authorization. It remains planning-only and grants no Product or M22
implementation authority.

## Definition Of Done

- Eight-part immutable risk, exception and residual models are explicit.
- Ten ownership/accountability and non-transferable acceptance boundaries exist.
- Evidence and deterministic ten-stage escalation/review are explicit.
- Rollback, repair, supersession and fail-closed M22 progression are explicit.
- Exactly this milestone and MEMORY change; no implementation/protected change.

## Engineering Evidence

- App 961/961, Knowledge 75/75 and protected M3-M20 freezes 68/68 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated health restored; exact two-file scope and clean diff confirmed.
