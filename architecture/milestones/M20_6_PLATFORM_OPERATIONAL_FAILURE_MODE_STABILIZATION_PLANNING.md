# M20.6 Platform Operational & Failure-Mode Stabilization Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define governance for stabilizing operational claims, cross-domain failure
modes, continuity and degradation before the final M20 closure stages. M20.6 is
planning only. It introduces no monitoring, alerting, retry, timeout, failover,
recovery, deployment, runtime contract, implementation, production code,
Flutter/UI, Product, infrastructure, tooling, ADR, freeze or generated change.

## Authority And Accepted Inputs

Constitution v1.4.0, accepted M20.0-M20.5 and M19 Foundation Freeze remain
authoritative/protected. M20.1-M20.4 supply candidate, public boundary,
compatibility and semantic identities; M20.5 supplies stable evidence,
provenance and replay identities. Source/domain owners own failure semantics;
Operations coordinates operational governance; Architecture/Platform owns
cross-domain stabilization; Quality verifies; Product Owner accepts.

## Operational Stabilization Model

An immutable operational-stabilization entry binds entry/schema version,
candidate/scope, capability and public-boundary IDs, contract/version and
semantic determination, declared operational claim, workload/environment/data/
trust class, supported state, service objective or limit reference, failure-mode
set, owner/on-call/escalation role identities, continuity/degradation/recovery
decision references, evidence/provenance/replay package, validity, exception,
predecessor/successor and deterministic digest.

Stabilization records attributable operational claims. It cannot collect
telemetry, execute a runbook, send an alert, retry a request, fail over, scale,
recover data, change configuration or infer production readiness from planning.

## Failure-Mode Stabilization Model

Each immutable failure-mode entry binds failure semantic ID/type/version,
affected source and consumer boundaries, trigger/observation distinction,
scope/blast-radius class, deterministic versus external cause, detection and
evidence references, severity/priority policy identity, accountable owner,
escalation path, allowed continuity/degradation states, containment/recovery/
rollback references, unknown-outcome handling, validity and digest.

| Failure class | Required stabilized meaning | Prohibited assumption |
|---|---|---|
| Contract/version mismatch | Exact producer/consumer incompatibility | Adapter or fallback implies support |
| Semantic conflict | Source-owner meanings disagree | Platform can arbitrate truth |
| Evidence/provenance failure | Missing, stale, conflicting or invalid custody | Projection/report replaces source |
| Determinism/replay failure | Same bindings produce different governed result | Retry or majority establishes truth |
| Dependency/unavailability | Required public capability is unavailable | Transitive or degraded support is implicit |
| Data/security/privacy failure | Trust, purpose, custody or access gate fails | Operational urgency waives policy |
| External/provider uncertainty | Outcome, latency or payload is unknown/variable | Unknown equals failure or success |
| Persistence/transport failure | Public port cannot establish known outcome | Storage/client internals define semantics |
| Capacity/performance breach | Accepted objective or limit evidence is violated | Scaling/tuning occurs automatically |
| Recovery/continuity failure | Verified recovery path cannot satisfy claim | Failover or backup success is assumed |

Failures remain distinct even when one causes another. Causal links are
candidate-bound, directed and acyclic; aggregation cannot erase root ownership.

## Cross-Domain Operational Responsibilities

| Responsibility | Accountable owner |
|---|---|
| Candidate and failure inventory composition | Architecture/Platform |
| Domain failure semantics and source truth | Owning domain |
| Contract/version failure and consumer obligation | Producer/consumer owners |
| Evidence facts, custody and negative outcomes | Evidence/source owner |
| Knowledge publication/unavailability | Knowledge publisher |
| Security/privacy/trust decision | Security/Privacy and data owner |
| External/provider and transport outcome envelope | Infrastructure owner plus contract owner |
| Continuity, recovery and capacity claim | Operations/Recovery/Capacity owners |
| Independent operational evidence verification | Quality |
| Escalation policy and final acceptance | Operations authority/Product Owner |

Operations coordinates state and escalation but cannot rewrite domain semantics,
evidence, compatibility or acceptance. Infrastructure cannot define policy.

## Failure Ownership And Escalation Governance

Every failure has one accountable owner, responding role, escalation authority,
severity-policy identity, acknowledgement/decision evidence, response validity
and unresolved-owner behavior. Multiple contributors are allowed, but ownership
cannot be collective, inferred from repository paths or transferred by timeout.

Escalation is an append-only decision lineage: `observed -> acknowledged ->
owned -> dispositioned -> recovered/contained/acceptedBlocked -> closed`.
Skipping a required state, changing owner without authority, conflicting
dispositions or closing without current evidence fails closed. M20.6 defines
the lineage only and sends no alert or notification.

## Continuity And Degradation Governance

| State | Meaning | Gate effect |
|---|---|---|
| `stable` | Complete claim operates within accepted governed boundaries | Eligible |
| `degradedAccepted` | Explicit reduced capability preserves declared semantics and safety | Eligible only for bounded claim/validity |
| `contained` | Failure scope is bounded but normal claim is unavailable | Blocked for normal claim |
| `recoveryPending` | Verified recovery action/evidence remains incomplete | Blocked |
| `unknownOutcome` | External effect or source outcome cannot be proven | Blocked |
| `unsafe` | Security, privacy, data, semantic or recovery invariant fails | Blocked |
| `stale` | Claim, owner, evidence, dependency or validity changed | Blocked |
| `superseded` | Linked successor replaces this determination | Historical only |

Degradation must bind exact removed/retained capabilities, user/data safety,
contract/failure semantics, owner, evidence, time bound and recovery target. It
cannot silently drop provenance, uncertainty, correctness or authorization.

## Evidence Requirements

Evidence references bind exact candidate/entry/failure, source and boundary,
contract/version/semantic state, trigger and observed outcome, positive and
negative cases, severity/owner/escalation decisions, continuity/degradation/
recovery status, canonical input/result/failure digests, custodian, rule/tool
version, reviewer, validity/retention and digest.

Minimum evidence covers stable flow, each claimed failure class, mixed/stale/
unknown outcomes, owner/escalation conflict, accepted degradation boundaries,
unsafe denial, recovery/rollback verification and deterministic replay. Logs,
metrics, provider responses or reports cannot self-verify their meaning.

## Operational Determinations

Evaluation is conjunctive and deterministic over exact identities, owners,
states and evidence. Only `stable` and exactly scoped `degradedAccepted` pass.
Incomplete, unknown, unsafe, stale or conflicting evidence blocks the claim.
No uptime score, retry, timeout, fallback, dashboard state or implementation
success grants operational acceptance.

## Rollback, Repair And Supersession

Rollback selects a verified compatible last-known-good operational entry and
does not execute recovery or edit failure/evidence history. Repair occurs at the
accountable source under separate authority. Supersession links immutable
predecessor/successor entries, failures, owner/escalation decisions, evidence,
continuity impact and rerun gates. Failed attempts remain auditable.

## Fail-Closed Governance

Reject on wrong predecessor/root, missing/mixed/stale identity, private
dependency, unsupported compatibility, semantic conflict, invalid provenance,
nondeterministic replay, unknown outcome, missing/conflicting owner, invalid
escalation, unbounded degradation, unsafe security/privacy/data state,
unverified recovery, expired exception or nondeterministic evaluation.

## Product Owner Implementation Acceptance Gates

Future implementation requires separately authorized exact scope/files,
accepted predecessors, complete operational/failure inventory, current owners
and escalation, compatibility/semantic/evidence/replay determinations,
continuity/degradation/recovery boundaries, positive/negative evidence,
protected regressions, Architecture Fitness 0 new, clean diff and explicit PO
acceptance. M20.6 grants planning authority only.

## Definition Of Done

- Operational and failure-mode stabilization entries are immutable and explicit.
- Ten failure classes and ten ownership responsibilities are defined.
- Escalation lineage and eight continuity/degradation states are explicit.
- Evidence, rollback/repair/supersession and fail-closed PO gates are complete.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, runtime contract, Product, ADR, tooling or freeze change.

## Engineering Evidence

- Planning defines ten failure classes, ten owners and eight operational states.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
