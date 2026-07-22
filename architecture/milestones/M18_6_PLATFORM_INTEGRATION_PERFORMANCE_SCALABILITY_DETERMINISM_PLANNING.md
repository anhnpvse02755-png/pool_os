# M18.6 Platform Integration Performance, Scalability & Determinism Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define performance, scalability and determinism governance for future platform
integration. M18.6 is planning only. It introduces no runtime contract,
implementation detail, benchmark, measurement, metric, dashboard, profiler,
optimization or autoscaling algorithm, Flutter, infrastructure, networking,
persistence, AI, deployment, CI/CD, ADR, Product or frozen-artifact change.

## Authority And Protected Inputs

Constitution v1.4.0, M17 Foundation Freeze and accepted M18.0-M18.5 identity,
compatibility, evidence, recovery and trust governance remain protected. Domain
owners retain semantic and workload-source authority; contract owners govern
public boundary expectations; Platform/Integration coordinates capacity and
cross-boundary effects; Quality independently verifies; Product Owner grants
future implementation scope and acceptance.

## Integration Performance Governance

Every future integration performance claim binds the exact candidate/freeze,
workload identity and class, source and destination boundaries, capability,
contract/provenance, declared expectation class, resource responsibility,
failure/degradation semantics, evidence, owner, authority, validity window and
digest. A prior success, provider promise or infrastructure size is not proof.

Governance preserves these principles:

1. Correctness, security, privacy and provenance cannot be traded for speed.
2. Expectations belong to public boundaries and named workload classes.
3. Producer, transport/provider and consumer responsibility remains separable.
4. Queueing, batching, caching or concurrency never changes semantic ownership.
5. Degraded behavior must be an explicitly compatible capability.
6. Unknown or mixed workload identity invalidates a performance claim.
7. Evidence covers both expected and adverse workload shapes.
8. Approval is scoped, expiring and superseded when bound identity changes.

## Scalability Governance Across Platform Domains

| Scalability concern | Accountable authority | Required governance |
|---|---|---|
| Workload origin/shape | Source domain owner | Canonical class, purpose, bounds and provenance |
| Public boundary demand | Producer/consumer contract owners | Compatible admission and failure semantics |
| Cross-domain flow | Integration owner | Correlation, ordering and pressure propagation |
| Domain processing | Owning domain | Invariants, isolation and deterministic outcome |
| External provider | Adapter/provider owner | Bounded capability and attributable limitation |
| Resource capacity | Platform/Infrastructure | Declared responsibility without semantic authority |
| Continuity/degradation | Recovery/Operations plus domain owner | Explicit eligibility, expiry and restoration |
| Acceptance | Quality and Product Owner | Independent evidence and exact authorized scope |

Scaling one component cannot silently shift load, ordering, retention, privacy,
failure or cost responsibility to another. Projection replicas, caches and
provider results never become source truth. Future partitioning or extraction
requires separate authority and preserved semantic IDs, provenance and replay.

## Deterministic Integration Execution

For the same canonical candidate/freeze, workload identity, ordered inputs,
contract/rule versions, capability, boundary configuration and accepted
external-result identities, integration evaluation produces the same admission,
route selection, ordering constraints, eligibility, findings and digest.

Unordered collections use declared canonical keys; ties use stable semantic IDs.
Clock, locale, map iteration, process layout, provider preference and resource
availability cannot implicitly alter a deterministic decision. External effects
and generated content remain separately identified; determinism governs their
envelopes, bindings and acceptance, not invented equality of external content.

## Workload Ownership And Capacity Governance

A workload declaration identifies origin owner, semantic class, purpose,
candidate/freeze, boundaries, capability, ordering/idempotency needs, data/trust
class, continuity class, validity and evidence. The source owner owns workload
meaning; each boundary owner owns admission; domains own invariant-preserving
processing; Platform owns resource coordination; Operations owns continuity
coordination. No coordinator can rewrite, discard or reclassify domain work to
claim capacity.

Capacity approval is an owner-authorized compatibility claim for a declared
workload class, never an unlimited guarantee. Composition must account for all
participating boundaries and external dependencies. Any workload, capability,
contract, provider, trust or continuity change invalidates inherited approval.

## Performance Evidence Ownership

| Evidence class | Custodian | Required binding |
|---|---|---|
| Workload declaration | Source/domain owner | Canonical class, provenance, purpose and validity |
| Boundary expectation | Contract owners | Interface, capability, ordering and failure class |
| Capacity responsibility | Platform/Infrastructure | Candidate, resource scope and accountable owner |
| Execution/replay proof | Quality with domain owners | Inputs, rules, order, outputs/findings and digest |
| Adverse-case proof | Independent verifier | Rejection, overload, degradation and recovery paths |
| External dependency proof | Adapter/provider owner | Provider/result identity and bounded limitation |
| Trust/privacy proof | Security/Privacy/data owner | Purpose, access, minimization and retention |
| Acceptance/closure | PO/Repository Authority | Evidence package and exact repository identity |

Evidence is versioned, attributable, append-only and retained with failures and
denials. Infrastructure evidence cannot prove domain correctness; domain output
cannot prove cross-boundary capacity; self-verification cannot close a claim.

## Replay Determinism And Consistency

Replay binds source inputs, canonical order, candidate/freeze, workload,
contracts/rules, boundary identities, accepted external-result envelopes,
failure decisions and prior lineage. Same bindings yield the same ordered
findings, acceptance/denial, deterministic projection and digest. A mismatch is
evidence of incompatibility or nondeterminism, not permission to normalize
history after the fact.

Consistency is evaluated at declared public boundaries. Partial completion,
duplicate/late work, unknown external outcome and recovery attempts remain
visible. Replay never repeats an external effect without separately authorized
idempotency/correlation and known outcome governance.

## Performance Failure And Recovery

Fail closed or enter an explicitly governed degraded/hold state when workload,
ownership, expectation, capacity responsibility, order, compatibility, trust,
evidence, external outcome or deterministic replay is unknown or conflicting.
Resource pressure cannot authorize data loss, private access, history rewrite,
silent sampling, hidden fallback or semantic change.

Recovery binds failed and last-known-good identities, workload and affected
boundaries, evidence, owner authority, containment, eligible recovery path,
deterministic validation, abort conditions and successor. Retry, rebuild,
degrade, rollback and forward repair remain distinct governed paths. Returning
to normal requires fresh owner and independent verification.

## Rollback, Supersession And Exceptions

Rollback restores only a verified compatible last-known-good integration state
and retains the failed attempt. Forward repair creates a versioned successor.
Supersession links immutable predecessor/successor performance claims and
re-evaluates workload, boundary, trust and compatibility bindings.

An exception names the unmet rule, owner, exact scope, risk/evidence,
compensating governance, start/expiry, review and removal. It cannot permit
nondeterministic semantic decisions, weaken constitutional boundaries, convert
a temporary condition into compatibility or self-renew.

## Product Owner Acceptance Gates

Future implementation requires exact file/mechanism scope, accepted
predecessors, canonical workload/boundary inventory, owners and authority,
declared expectation and capacity responsibility, deterministic positive and
adverse evidence, replay/consistency proof, security/privacy review,
degradation/recovery/rollback, no blocking exception, protected freezes,
Architecture Fitness 0 new, clean diff and explicit PO acceptance before
commit/push. This plan authorizes none of those mechanisms.

## Definition Of Done

- Eight performance principles and eight scalability concerns are explicit.
- Deterministic execution, canonical ordering and external-result separation are
  defined.
- Workload/capacity and eight evidence-class ownership boundaries are explicit.
- Replay consistency, recovery, rollback, supersession, exceptions and
  fail-closed PO gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No measurement/benchmark/optimization/autoscaling, implementation, runtime
  contract, ADR, Product or frozen change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines eight performance principles, eight scalability concerns and
  eight performance evidence classes.
- App regression: 949/949.
- Knowledge package regression: 75/75.
- Protected foundation freezes: 56/56.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
