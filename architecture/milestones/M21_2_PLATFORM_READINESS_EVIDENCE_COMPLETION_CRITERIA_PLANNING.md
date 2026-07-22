# M21.2 Platform Readiness Evidence & Completion Criteria Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define immutable readiness evidence, conjunctive completion criteria and
deterministic aggregation. Planning only; no Product, runtime contract,
implementation, UI, infrastructure, tooling, ADR or freeze change.

## Authority And Accepted Inputs

Constitution v1.4.0, accepted M21.0-M21.1 and M20 Freeze remain protected.
Source owners retain facts/custody, contract owners semantics, Architecture
criteria/aggregation, Quality independent verification and PO acceptance.

## Immutable Readiness Evidence Model

Each reference binds evidence ID/type/schema, candidate/scope/claim, source
range, public contract/version, canonical input/result/failure digests,
positive/negative status, provenance/custody/correction lineage, owner/reviewer,
rule/tool version, validity/retention/redaction, predecessor/successor and
digest. Evidence remains at source; reports/generated output cannot self-review
or replace truth.

## Platform Completion Criteria

1. Constitutional ownership and dependency conformance.
2. Public contract and version compatibility.
3. Knowledge authoring/publication integrity.
4. Evidence provenance, custody and correction integrity.
5. Intelligence decisions and Decision Trace grounding.
6. Simulation, Experience and AI boundary conformance.
7. Deterministic replay of canonical governed outputs.
8. Security, privacy and data governance.
9. Operational, recovery and capacity readiness.
10. Freeze continuity, owned gaps and independent audit.

All are conjunctive; one criterion cannot compensate for another.

## Positive And Negative Evidence

Positive evidence proves exact current claims. Negative evidence proves rejection
of missing/mixed/stale/duplicate IDs, unsupported versions, private dependencies,
semantic conflict, invalid custody, nondeterminism, unsafe trust/data states,
unknown external outcomes, broken recovery/freeze, expired exceptions and
unauthorized approval. Not-applicable requires source-owner proof and
independent review.

## Evidence Lineage And Provenance

Lineage is append-only and acyclic. Correction/supersession binds predecessor
digest, reason, source authority, affected claims and replay scope. Provenance
binds source/custodian, method, schema/contracts/rules, canonical range/order/
digest, purpose, custody/redaction/retention, reviewer and validity. Missing,
cyclic, orphan or conflicting lineage blocks dependent claims.

## Independent Verification

Verification binds exact candidate, evidence index/rules, checks, findings,
limitations, authority, validity and digest. Verifier cannot assemble candidate,
own claims, repair evidence, approve exceptions or issue PO decision. Any input
change invalidates verification.

## Ownership And Custody

Ten owners cover candidate/index, domain truth, contracts, Knowledge publication,
Evidence custody, Intelligence/trace, Simulation/Experience/AI boundaries,
security/operations/recovery, independent verification and PO acceptance.
Assemblers cannot approve their own evidence.

## Deterministic Aggregation

Aggregation references IDs/digests ordered by criterion, claim, source, evidence
and finding IDs. Same bindings yield same index/state/digest. States are
complete, notApplicableVerified, incomplete, inconsistent, unsafe, stale,
verificationFailed and superseded. Only the first two satisfy exact claims.

## Recovery And Fail-Closed Governance

Rollback selects verified last-known-good evidence without editing history.
Repair is source-owned append-only correction; supersession links packages and
decisions. Reject wrong root/scope, absent owner/custody, stale/mixed evidence,
private source, conflict, nondeterminism, self-review, unsafe state or broken
freeze/audit.

## M22 Planning-Only Gate

Eligibility requires all exact criteria complete, current independent
verification, accepted predecessors and separate PO authorization of exact M22
planning scope. It grants no M22/Product implementation authority.

## Definition Of Done

- Ten criteria, ten ownership responsibilities and eight states are defined.
- Evidence, lineage, verification, aggregation and recovery are explicit.
- Exactly this milestone and MEMORY change; no protected/implementation change.

## Engineering Evidence

- App 961/961, Knowledge 75/75 and protected M3-M20 freezes 68/68 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated health restored; exact two-file scope and clean diff confirmed.
