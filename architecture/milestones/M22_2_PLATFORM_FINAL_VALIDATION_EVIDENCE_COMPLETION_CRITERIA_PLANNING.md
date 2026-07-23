# M22.2 Platform Final Validation Evidence & Completion Criteria Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define immutable final-validation evidence and conjunctive platform-closure
criteria. Planning only; this milestone performs no validation and authorizes no
Product, runtime, contract, UI, deployment, release, infrastructure, tooling,
ADR, freeze, generated or Knowledge/publication change.

## Authority And Accepted Inputs

Constitution v1.4.0, accepted M22.0-M22.1 and M3-M21 freezes remain protected.
M22.1 owns candidate/scope identity. Source owners retain truth/custody,
Architecture owns criteria/aggregation, Quality verifies independently and PO
accepts closure boundaries. M22.2 only defines governance.

## Immutable Final-Validation Evidence Model

Each evidence reference binds:

1. evidence ID/type/schema and exact candidate/scope/claim identities;
2. authoritative source semantic ID, range and digest;
3. public contract, Knowledge, runtime, policy and rule versions;
4. canonical input, positive result and negative result digests;
5. producer, owner, custodian and independent reviewer identities;
6. collection method, limitations, validity, retention and redaction;
7. correction, invalidation and predecessor/successor lineage;
8. affected criteria, dependencies and deterministic digest.

Evidence remains at source. Indexes, reports, generated output and providers
cannot become authority, self-review, self-verify or silently repair evidence.
Any bound change creates a successor and invalidates dependent determinations.

## Platform Closure Completion Criteria

1. Exact M21 Freeze root and accepted M22 candidate/scope lineage.
2. Final constitutional ownership, dependency and prohibition conformance.
3. Public contract/version compatibility and boundary completeness.
4. Knowledge authoring/publication/runtime identity integrity.
5. Evidence provenance, custody, privacy and correction integrity.
6. Cross-domain semantics, Decision Trace and deterministic replay.
7. Complete M3-M21 freeze-chain identity and proof continuity.
8. Security, privacy, operations, capacity and recovery readiness.
9. Zero unowned/blocking gaps, findings, risks or invalid exceptions.
10. Product-transition prerequisites, post-closure ownership and independent audit.

All criteria are mandatory and non-compensating. A criterion may be satisfied
only by exact current evidence or independently verified not-applicable proof.
No score, test count, report, deadline, exception or majority offsets failure.

## Positive And Negative Evidence Requirements

Positive evidence proves the exact current closure claim, including accepted
state, compatibility, replay and custody. Negative evidence proves rejection of
missing/mixed/stale/duplicate identity, unsupported versions, private/reversed
dependencies, semantic conflict, invalid provenance, nondeterminism, unsafe
trust/operations, broken freeze/rollback, invalid exception, self-review and
unauthorized Product or implementation access.

Absence of observed failure is not negative evidence. Not-applicable requires
source-owner proof, exact scope/impact and independent verification.

## Evidence Ownership And Custody

| Responsibility | Accountable authority |
|---|---|
| Candidate evidence index | Architecture/Platform |
| Domain semantic evidence | Owning domain |
| Contract/version evidence | Producer and consumer owners |
| Knowledge/publication/runtime evidence | Publisher/runtime owner |
| Evidence source, custody and correction | Source/Evidence owner |
| Freeze-chain/replay evidence | Repository Authority/Quality |
| Security/privacy/trust evidence | Security/Privacy/data owner |
| Operations/recovery/capacity evidence | Respective operational owners |
| Independent completion verification | Quality/independent validator |
| Closure/Product-boundary acceptance | Product Owner |

Assemblers, evidence producers, custodians and source owners cannot independently
verify or approve their own claims. Custody transfer is append-only and explicit.

## Deterministic Evidence Aggregation

Aggregation references IDs/digests ordered by criterion, claim, source, evidence
and finding IDs. The aggregate digest binds candidate/scope/root, criteria/rules,
ordered positive/negative evidence, owners, validity and limitations. Same inputs
yield identical index, JSON, determination and digest regardless of input order.

States are `complete`, `notApplicableVerified`, `incomplete`, `inconsistent`,
`unsafe`, `stale`, `verificationFailed` and `superseded`. Only the first two
satisfy an exact claim. Duplicate semantics, ambiguity or conflict fails closed.

## Independent Verification Requirements

Verification binds exact candidate/scope/evidence/rule digests, verifier identity
and independence proof, ordered checks, positive/negative findings, limitations,
validity and digest. The verifier cannot assemble the candidate, produce/correct
evidence, remediate claims, request/approve exceptions or issue PO acceptance.

Any source, contract, rule, owner, scope or validity change invalidates affected
verification and every dependent completion determination.

## Completion Lineage

Lineage is append-only and acyclic from source evidence through aggregation,
independent verification and completion determination. Corrections/supersession
bind predecessor digest, reason, authority, exact affected claims and replay
scope. Failed, rejected, expired and superseded evidence remains auditable.

## Rollback, Repair, Supersession And Fail-Closed Governance

Rollback selects verified compatible predecessor evidence without editing
history. Repair occurs only at the accountable source under separate authority.
Supersession links evidence, aggregate, verification and decision digests.

Reject wrong root/scope, missing owner/custody, stale/mixed/duplicate evidence,
private source, unsupported version, conflict, nondeterminism, self-review,
unsafe state, orphan lineage, broken freeze/rollback or unauthorized approval.
Completion grants no validation result, freeze, Product or implementation authority.

## Definition Of Done

- Eight-part immutable evidence model and ten criteria are explicit.
- Positive/negative evidence and ten ownership boundaries are defined.
- Deterministic aggregation and independent verification are explicit.
- Completion lineage, recovery, supersession and fail-closed gates are complete.
- Exactly this milestone and MEMORY change; no implementation/protected change.

## Engineering Evidence

- App 965/965, Knowledge 75/75 and protected M3-M21 freezes 72/72 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated health restored; exact two-file scope and clean diff confirmed.
