# M19.7 Platform Evolution Readiness Validation Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define governance for validating whether the frozen platform is eligible to
advance from M19 validation toward M20 conformance planning. M19.7 is planning
only. It introduces no evolution execution, runtime contract, implementation,
production code, Flutter, infrastructure, deployment, CI/CD, monitoring,
tooling, Product, ADR or frozen-artifact change.

## Authority And Protected Inputs

Constitution v1.4.0, M18 Foundation Freeze and accepted M19.0-M19.6 identity,
surface, compatibility, compliance, replay and freeze-continuity governance
remain protected. Each owner retains authority for its validation claim;
Architecture assembles readiness rules; Quality independently audits evidence;
PO owns final readiness acceptance and any next scope.

## Evolution Readiness Validation Model

One immutable readiness candidate binds M19 candidate/scope and M18 Freeze,
target transition and exclusions, accepted predecessor validation identities,
dependency graph, eligibility criteria, evidence index, gaps/exceptions,
owners/reviewers, rollback/forward-repair paths, blocking findings, validity,
predecessor/successor and deterministic digest.

Readiness means every applicable criterion is current and accepted for the same
candidate, protected range and target. It is not implementation maturity,
schedule confidence, document completeness or permission to execute evolution.

## Readiness Identity And Lineage

Readiness identity includes schema/candidate/scope/freeze digests, target
milestone/capability, predecessor determination digests, dependency-graph and
rule-set digests, evidence-package identity, owner decisions, exception/gap
identities, determination, validity and predecessor/successor links.

Any changed candidate, target, predecessor, dependency, rule, evidence, owner,
gap or exception creates a successor and repeats affected validation. Lineage is
append-only and retains not-ready/held attempts. A prior acceptance cannot be
reused outside its exact scope or validity.

## Evolution Eligibility Criteria

| Criterion | Required accepted claim |
|---|---|
| Identity/scope | Exact immutable candidate, target, claims and exclusions |
| Freeze continuity | Direct M18 root and transitive M3-M18 chain are continuous |
| Cross-surface | Supported claims are equivalent; variation/unsupported states explicit |
| Compatibility | Required matrices/versions/capabilities are compatible |
| Constitutional compliance | Applicable rules are compliant or validly exception-bound |
| Deterministic replay | Required structured outputs and findings replay deterministically |
| Dependency readiness | All predecessors and cross-domain handoffs are current and acyclic |
| Evidence completeness | Positive/negative/failure evidence is attributable and nonconflicting |
| Trust/privacy/security | Authority, purpose, data handling and revocation remain current |
| Recovery/evolution path | Rollback/repair/supersession and M20 boundary are explicit |

Criteria are conjunctive. One criterion cannot compensate for another; a scoped
exception remains visible and cannot convert a prohibited boundary into ready.

## Dependency Readiness Validation

Every node binds semantic ID/version, owner, accepted predecessor identity,
entry/exit claims, public handoff, evidence, blocking status and digest. Every
edge binds source/target, dependency type, compatibility, required determination
and owner. Nodes and edges are unique; targets must exist; the graph is acyclic.

Canonical topological order uses semantic node ID for ties. A downstream node is
eligible only when all required predecessor determinations are current for the
same candidate. Missing, stale, circular, optional-as-required or privately
coupled dependencies block readiness rather than being skipped.

## Evidence Aggregation Requirements

The readiness index references immutable M19.1-M19.6 evidence and decisions by
identity/digest without copying or reclassifying source truth. Each requirement
records criterion/claim, expected and received evidence IDs, custodian, reviewer,
current/superseded/missing/conflicting status, validity, finding severity,
exception/gap and lineage.

Positive, negative, failure, unsupported and recovery evidence are required as
applicable. Missing operational evidence remains `notAvailable` with owner and
plan, never proof. Duplicate semantic evidence with different content and any
unresolved conflict block aggregation.

## Deterministic Readiness Evaluation

Canonical order is criterion ID, dependency topological position/node ID,
claim ID, finding/rule ID and evidence ID. Same candidate, predecessors, graph,
rules, evidence and owner decisions yield the same completeness matrix, ordered
findings, blocking/gap/exception sets, determination and digest.

Determinations are `ready`, `notReady`, `incomplete`, `held`,
`exceptionBound` or `superseded`. Only `ready`, or `exceptionBound` within its
exact nonprohibited scope when explicitly accepted by PO, can satisfy that
specific transition claim. No score, majority, fallback or deadline applies.

## Ownership Responsibilities

| Responsibility | Accountable owner |
|---|---|
| Candidate/target/readiness package | Architecture/Validation owner |
| Domain semantic readiness | Owning domain |
| Contract/compatibility readiness | Producer/consumer contract owners |
| Surface claim readiness | Surface owner plus domain/contract owners |
| Constitutional compliance | Architecture and affected owners |
| Replay evidence | Source owners and independent Quality |
| Freeze/dependency continuity | Repository Authority/Architecture |
| Trust/privacy/security | Data owner and Security/Privacy |
| Recovery/evolution constraint | Affected owners |
| Final transition acceptance | Product Owner |

Package assembly and technical completion cannot self-approve readiness.

## Gaps And Exceptions

A gap binds criterion/claim, severity/blocking status, owner, evidence, repair or
removal plan, dependency impact and target revision. It stays open until new
evidence closes or supersedes it. An exception must meet Constitution 20.4 and
cannot waive constitutional invariants, freeze continuity or missing authority.
Both remain visible in every successor package.

## Rollback And Supersession

Rollback returns to a verified prior readiness identity/target and retains the
failed package. Forward repair creates a versioned successor criterion,
dependency or evidence set. Supersession links immutable packages, gaps,
exceptions and decisions and reruns affected downstream gates. It cannot turn a
not-ready history into a ready predecessor.

## Fail-Closed Governance

Return notReady/incomplete/held on mixed/stale identity, broken freeze chain,
unsupported surface or contract, constitutional noncompliance, nondeterministic
replay, missing/cyclic/private dependency, incomplete/conflicting evidence,
unknown owner/authority, invalid exception, unresolved blocking gap, unsafe
rollback or any trust/privacy/security conflict.

## Product Owner Acceptance Gates

Future implementation requires exact scope/target, accepted predecessors,
complete eligibility/dependency/evidence package, owners and independent review,
current gaps/exceptions, recovery/rollback/supersession, protected freezes,
Architecture Fitness 0 new, clean diff and explicit PO acceptance. M19.7 grants
no evolution execution or M20 implementation authority.

## Definition Of Done

- Immutable readiness model/lineage and ten criteria are explicit.
- Dependency readiness and deterministic six-state evaluation are defined.
- Evidence aggregation and ten ownership responsibilities are explicit.
- Gaps/exceptions, rollback, supersession and fail-closed gates are explicit.
- Exactly this milestone and `MEMORY.md` change; no prohibited change.

## Engineering Evidence

- Planning defines ten eligibility criteria, six determinations and ten
  ownership responsibilities.
- Full app regression: 953/953 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M18 freeze regression: 60/60 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
