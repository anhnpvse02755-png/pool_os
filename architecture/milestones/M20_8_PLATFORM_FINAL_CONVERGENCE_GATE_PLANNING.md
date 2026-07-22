# M20.8 Platform Final Convergence Gate Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define the final governed decision for closing M20 convergence and determining
eligibility for separately authorized M21 planning. M20.8 is planning only. It
introduces no gate execution, runtime contract, implementation, production code,
Flutter/UI, Product, infrastructure, tooling, ADR, freeze or generated change.

## Authority And Protected Inputs

Constitution v1.4.0, accepted M20.0-M20.7 and M19 Foundation Freeze remain
authoritative/protected. M20.1-M20.7 supply immutable determinations and evidence
references. Source/domain/contract owners retain their truth; Architecture/
Platform owns gate composition; an independent auditor owns final verification;
Product Owner alone accepts and authorizes any exact M21 planning scope.

## Final Convergence Candidate Model

One immutable final candidate binds candidate/schema version, exact M19 Freeze
manifest/proof/digest, accepted M20.0 plan and M20.1-M20.7 determination IDs/
digests, convergence target and scope, public boundary/contract/version set,
semantic and compatibility status, evidence/provenance/replay package,
operational/failure status, gap/exception/amendment package, dependency graph,
owners/authorities, independent audit, recovery target, validity,
predecessor/successor and deterministic candidate digest.

Any source, determination, evidence, owner, exception, audit, validity or rule
change creates a successor. A final candidate cannot mutate, borrow acceptance
from a predecessor or omit a blocked/unknown determination.

## Aggregation Of M20.1-M20.7 Determinations

| Conjunctive criterion | Required accepted input |
|---|---|
| Identity and scope | M20.1 exact current candidate/scope and lineage |
| Public boundaries | M20.2 converged public contracts; no private coupling |
| Compatibility/version | M20.3 eligible current determination for every claim |
| Cross-domain semantics | M20.4 stable meaning/ownership for every composition |
| Evidence/provenance/replay | M20.5 stable replayable/envelope evidence package |
| Operations/failure/continuity | M20.6 stable or exact bounded degradation |
| Gaps | M20.7 complete inventory with eligible exact disposition |
| Exceptions/amendments | Current valid exception or no blocking amendment dependency |
| Dependency/freeze integrity | Acyclic M20 graph and intact M3-M19 chain |
| Governance/recovery | Complete owners, audit, rollback/repair/supersession |

All ten criteria are conjunctive. Aggregation references immutable identities
and digests; it cannot copy, reinterpret, repair, score or compensate one
criterion with evidence from another.

## Evidence Aggregation Rules

The final evidence index binds each criterion/claim to authoritative evidence
ID/digest, source/custodian, positive/negative status, owner decision,
rule/tool/contract version, validity/retention, correction lineage and review.
Every referenced digest must match the accepted determination and final
candidate. Duplicate semantic IDs, orphan evidence, mixed candidate bindings,
stale validity or conflicting source decisions fail closed.

Evidence stays with its source owner. Reports, projections, health output,
provider/generated content and the final candidate cannot self-review or become
source truth. Same canonical bindings yield the same ordered evidence index and
digest.

## Independent Audit Governance

The independent audit is an immutable artifact binding auditor identity and
authority, exact final candidate/evidence/dependency/rule digests, audit scope,
positive and negative checks, findings, conflicts, limitations, determination,
validity, predecessor/successor and digest.

The auditor cannot assemble the candidate, own an audited claim, create or
repair source evidence, approve its own exception, or issue the PO decision.
Any candidate/evidence/rule change invalidates the audit. A technical pass with
missing authority, evidence or owner remains a failed audit.

## Final Evaluation States

| State | Meaning | Gate effect |
|---|---|---|
| `eligibleForM21Planning` | All criteria and independent audit pass | PO may authorize exact M21 planning only |
| `incomplete` | Required input, evidence, owner or audit is missing | Blocked |
| `inconsistent` | Determinations, identities or source meanings conflict | Blocked |
| `incompatible` | Contract/version/capability requirement fails | Blocked |
| `unsafe` | Security/privacy/data/recovery/continuity invariant fails | Blocked |
| `exceptionBlocked` | Exception invalid/expired or amendment remains blocking | Blocked |
| `auditFailed` | Independent audit rejects or cannot verify candidate | Blocked |
| `stale` | Source, determination, evidence, authority or validity changed | Blocked |
| `rejected` | Product Owner rejects progression | Blocked and retained |
| `superseded` | Linked successor replaces this determination | Historical only |

Only `eligibleForM21Planning` satisfies the gate. It does not authorize M21
implementation, runtime work, Product, deployment or any unspecified file.

## Convergence Authorization Lifecycle

Authorization is append-only:

`assembled -> ownerReviewed -> evidenceVerified -> independentlyAudited ->
POAccepted/PORejected -> repositoryClosed -> superseded`.

Each transition binds sequence and transition ID, candidate/audit digest,
from/to state, actor/authority, rationale/evidence, validity and digest. Skipped,
duplicate, reordered, unauthorized or post-terminal transitions fail closed.
Repository closure requires accepted status, exact diff, commit and push; it
cannot backdate or manufacture PO acceptance.

## Ownership Responsibilities

| Responsibility | Accountable authority |
|---|---|
| Final candidate and dependency composition | Architecture/Platform |
| Identity/scope and boundary determinations | M20.1/M20.2 accountable owners |
| Compatibility/version determinations | Producer/consumer contract owners |
| Semantic truth and conflicts | Source domain owners |
| Evidence/provenance/custody | Evidence/source owners |
| Replay/negative verification | Quality/source owners |
| Operational/failure/recovery status | Operations/Recovery/source owners |
| Gap/exception/amendment package | Architecture plus authorized owners/approvers |
| Independent final audit | Independent auditor |
| Final acceptance and M21 planning authorization | Product Owner |

No role can self-approve an owned claim and its independent audit.

## Criteria For Progression To M21 Planning Only

Progression requires the exact final candidate in `eligibleForM21Planning`, all
M20.1-M20.7 accepted/closed/committed/pushed, current ten-criterion evidence,
successful independent audit, intact M3-M19 freezes, acyclic dependencies, no
unowned/expired/blocking gap, verified recovery path, clean repository audit and
explicit PO authorization of exact M21 planning files/scope.

Eligibility expires when any bound identity, evidence, owner, exception,
determination, audit, freeze or rule changes. It grants no runtime, Product,
implementation, infrastructure, deployment or M21 execution authority.

## Rollback, Repair And Supersession

Rollback returns to a verified compatible last-known-good final candidate and
retains rejected/current candidates, audits and decisions. Repair occurs at the
accountable source under separate authority, then creates a successor and new
audit. Supersession links immutable predecessor/successor candidate, evidence,
audit, PO decision and affected gates. No history is overwritten.

## Fail-Closed Governance

Reject on wrong M19/M20 root, missing/mixed/stale/duplicate determination,
private boundary, incompatible version, semantic conflict, invalid evidence/
provenance/custody, nondeterministic replay, unsafe operational state, unowned
gap, invalid exception, blocking amendment, cyclic dependency, broken freeze,
conflicted auditor, failed audit, unsafe rollback, unauthorized lifecycle or
nondeterministic evaluation. No score, fallback, timeout or technical success
grants eligibility.

## Product Owner Implementation Acceptance Gates

M20.8 itself authorizes no implementation. Any future M21 work requires the
eligible final candidate plus separately authorized exact planning files/scope,
accepted predecessors, protected regressions, Architecture Fitness 0 new, clean
diff and explicit PO acceptance. Implementation remains separately prohibited.

## Definition Of Done

- Immutable final candidate aggregates exact M20.1-M20.7 identities/digests.
- Ten conjunctive criteria and evidence aggregation are explicit.
- Independent audit, ten states and append-only authorization are defined.
- Ten owners, M21 planning-only eligibility, recovery and fail-closed gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No gate execution, implementation, runtime contract, Product or freeze change.

## Engineering Evidence

- Planning defines ten criteria, ten states and ten ownership responsibilities.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
