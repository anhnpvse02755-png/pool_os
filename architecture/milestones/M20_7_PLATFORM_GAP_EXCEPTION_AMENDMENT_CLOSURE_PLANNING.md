# M20.7 Platform Gap, Exception & Amendment Closure Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define governance for closing or explicitly retaining every M20 convergence
gap, exception dependency and amendment dependency before the final gate. M20.7
is planning only. It introduces no exception approval, constitutional amendment,
ADR, runtime contract, implementation, production code, Flutter/UI, Product,
infrastructure, tooling, freeze or generated protected-artifact change.

## Authority And Accepted Inputs

Constitution v1.4.0 Sections 17 and 20, accepted M20.0-M20.6 and M19 Foundation
Freeze remain authoritative/protected. M20.1-M20.6 supply exact candidate,
boundary, compatibility, semantic, evidence/replay and operational identities.
Architecture/Platform owns closure governance; source/domain/contract owners
own repairs; exception/amendment authorities retain approval; Quality verifies;
Product Owner accepts the M20.7 determination.

## Platform Gap Closure Governance

An immutable gap record binds gap/schema version, candidate/scope and claim,
gap class, affected domain/boundary/contract/version/semantic IDs, source
finding and evidence, compatibility/operational impact, accountable owner,
disposition and authority, closure/acceptance criteria, repair/rollback target,
exception/amendment dependency, validity, predecessor/successor and digest.

Closure requires exact criteria, owner decision and independent evidence. A gap
cannot disappear through renaming, scope omission, report regeneration,
deadline, implementation success or aggregation into a score. Duplicate records
for one semantic gap must share explicit lineage or fail closed.

## Convergence Gap Classification

| Gap class | Required disposition owner | Closure boundary |
|---|---|---|
| Identity/scope | Architecture plus affected owner | Exact candidate/scope successor |
| Public boundary/dependency | Producer/consumer contract owners | Public direction/ownership proven |
| Compatibility/version | Contract owners | Current M20.3 determination/path |
| Semantic meaning/ownership | Source domain owners | Owner-approved stable meaning |
| Evidence/provenance/custody | Source/Evidence owner | Corrected append-only lineage |
| Replay/determinism | Contract/source owners plus Quality | Stable replay package |
| Security/privacy/data | Security/Privacy and data owner | Compliant current decision/evidence |
| Operational/failure/continuity | Operations plus source owner | Stable or bounded accepted state |
| Recovery/migration | Affected owners/Repository Authority | Verified current recovery path |
| Governance/authority | Architecture/PO or constitutional authority | Exact approval or blocking status |

Each gap has one primary class and may reference secondary impacts. Cross-class
links are directed and acyclic; classification cannot transfer source ownership.

## Gap Dispositions And Closure States

| State | Meaning | Gate effect |
|---|---|---|
| `closedVerified` | Owner repair and independent evidence satisfy exact criteria | Eligible |
| `notApplicableVerified` | Exact scoped claim proves the gap does not apply | Eligible for that scope |
| `exceptionActive` | Valid Section 20.4 exception governs the exact gap | Eligible only if final gate permits it |
| `amendmentRequired` | Resolution needs Section 20.3 constitutional change | Blocked pending separate amendment |
| `repairPending` | Authorized repair/evidence is incomplete | Blocked |
| `ownerMissing` | Accountable authority is absent or disputed | Blocked |
| `stale` | Source, scope, evidence, authority or validity changed | Blocked |
| `rejected` | Proposed disposition failed a gate | Blocked and retained |
| `superseded` | Linked successor replaces the record | Historical only |

Only `closedVerified`, exact `notApplicableVerified`, and an explicitly
permitted current `exceptionActive` can satisfy their declared claims.

## Exception Lifecycle Governance

Per Constitution Section 20.4, every immutable exception record must be:

1. explicit and bound to one exact candidate/gap/claim;
2. narrowly scoped, with prohibited scope expansion stated;
3. owned by a named role or person;
4. time-bounded by a deterministic expiry condition;
5. recorded with rationale and normative authority;
6. accompanied by impact, compensating controls and current evidence;
7. accompanied by removal/repair plan and accountable owner;
8. independently reviewed and explicitly approved by the proper authority;
9. linked to predecessor/successor/renewal without history mutation;
10. prevented from becoming precedent or implicit compatibility.

Lifecycle is `proposed -> reviewed -> approvedActive -> removalPending ->
removed/expired/revoked/superseded`. Only `approvedActive` with current scope,
evidence, owner and expiry can be referenced. Renewal creates a successor and
repeats all gates. M20.7 cannot approve an exception.

## Amendment Eligibility And Governance

M20.7 may determine only whether a gap is `amendmentNotRequired`,
`amendmentCandidateComplete`, `amendmentCandidateIncomplete` or
`amendmentConflict`. It cannot amend the Constitution or create/ratify an ADR.

Per Section 20.3, a complete amendment candidate references a problem statement,
affected rules/domains, alternatives, compatibility/migration impact,
data/provenance impact, security/privacy impact, test/enforcement changes,
required explicit approvers and proposed PATCH/MINOR/MAJOR version increment.
Boundary, ownership or dependency changes require MAJOR. Eligibility grants only
permission for separately authorized amendment planning and approval.

## Ownership And Approval Responsibilities

| Responsibility | Accountable authority |
|---|---|
| Gap inventory, identity and classification | Architecture/Platform |
| Domain semantic repair | Owning domain |
| Contract/compatibility repair | Producer/consumer contract owners |
| Evidence correction, custody and provenance | Source/Evidence owner |
| Security/privacy/data disposition | Security/Privacy and data owner |
| Operational/recovery disposition | Operations/Recovery owner |
| Exception ownership/removal | Named exception owner |
| Exception approval | Section 20.4 authorized approver |
| Amendment eligibility and constitutional process | Architecture/constitutional authority |
| Independent verification and final acceptance | Quality/Product Owner |

Assemblers cannot close their own gaps, approve their own exceptions or treat
implementation evidence as constitutional authority.

## Evidence Requirements

Evidence references bind candidate/gap/disposition, authoritative source and
finding, affected contracts/versions/semantics, positive closure and negative
rejection cases, owner/approval identities, exception scope/expiry/removal or
amendment completeness, repair/recovery results, rule/tool version, custodian,
reviewer, validity and digest. Required negatives cover missing owner, scope
widening, expired exception, silent precedent, incomplete amendment, stale
repair, conflicting approval and nondeterministic evaluation.

Evidence is immutable or superseding. A report, generated output, implementation
behavior or elapsed time cannot self-close a gap.

## Rollback, Repair And Supersession

Rollback returns to the last verified compatible closure package without
editing gaps, exceptions, amendment candidates, evidence or approvals. Repair
occurs at the accountable source under separate authority. Supersession links
immutable predecessor/successor records, changed scope/disposition, owners,
evidence, validity and rerun gates. Expired/rejected attempts remain auditable.

## Fail-Closed Governance

Reject on wrong predecessor/root, missing/mixed/stale/duplicate gap, unknown or
conflicting owner, scope omission/widening, incomplete closure evidence,
unsupported compatibility, semantic conflict, invalid provenance, unsafe
operational state, expired/unapproved/unbounded exception, missing removal plan,
silent precedent, incomplete/conflicting amendment candidate, unsafe rollback
or nondeterministic evaluation.

## Product Owner Implementation Acceptance Gates

Future implementation requires separately authorized exact scope/files,
accepted predecessors, complete gap inventory, every gap in an eligible exact
state, current owners/approvals/evidence, valid exception removal and amendment
dependencies, rollback/supersession, protected regressions, Architecture Fitness
0 new, clean diff and explicit PO acceptance. M20.7 grants planning authority
only.

## Definition Of Done

- Immutable gap closure and ten gap classes are explicit.
- Nine closure states and ten Section 20.4 exception requirements are defined.
- Amendment eligibility follows Section 20.3 without amending authority.
- Ten ownership/approval responsibilities and evidence are explicit.
- Rollback/repair/supersession and fail-closed PO gates are complete.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, ADR, Constitution, runtime contract, Product or freeze change.

## Engineering Evidence

- Planning defines ten gap classes, nine states, ten exception requirements and
  ten ownership/approval responsibilities.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
