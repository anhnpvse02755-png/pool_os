# M18.8 Platform Integration Final Integration Gate Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define the final governance gate for future platform integration. M18.8 is
planning only. It introduces no production/runtime code, runtime contract,
deployment execution, CI/CD, operational tooling, monitoring implementation,
rollout automation, Flutter, infrastructure, networking, persistence, AI, ADR,
Product or frozen-artifact change.

## Authority And Protected Inputs

Constitution v1.4.0, M17 Foundation Freeze and accepted M18.0-M18.7 planning are
protected. Domain/contract owners retain semantic and boundary authority;
evidence custodians retain source custody; Quality/Architecture independently
audit; Platform Integration assembles but cannot approve its own package;
Product Owner grants final acceptance and any later implementation scope.

## Final Integration Gate Identity

One final-gate candidate binds exact gate/candidate/freeze identities, accepted
M18 planning lineage, components/domains/boundaries/capabilities, contract and
Knowledge identities, evidence-package digest, audit identity, compatibility
determination, readiness/rollout identity, owner decisions, blocking findings,
exceptions, validity, predecessor/successor and deterministic digest.

Gate identity is immutable. Any change to a bound input produces a new candidate
and invalidates inherited approval. Repository state, elapsed time, technical
completion or provider availability cannot imply gate passage.

## Consolidated Integration Acceptance Criteria

| Gate | Required accepted claim | Primary authority |
|---|---|---|
| Scope/identity | Exact integration surface, boundaries, owners and exclusions | Architecture/Integration |
| Dependency/sequence | Acyclic prerequisites, handoffs and deterministic order | Architecture plus domain owners |
| Compatibility/interface | Supported versions/capabilities and failure semantics | Producer/consumer contract owners |
| Evidence/provenance | Complete, current, attributable positive/negative lineage | Evidence owners/Quality |
| Failure/recovery | Classified failures and safe retry/rollback/repair eligibility | Recovery/domain owners |
| Security/privacy/trust | Least authority, purpose, data handling and revocation | Security/Privacy/data owners |
| Performance/determinism | Declared workload/capacity ownership and replay consistency | Platform/domain owners/Quality |
| Operational readiness | Conjunctive readiness and cross-domain coordination | Integration/Operations/owners |
| Rollout/continuity | Explicit stages, hold/abort, continuity and restoration | Operations/domain/contract owners |
| Governance/closure | Independent audit, exceptions, PO decision and repository identity | PO/Repository Authority |

All criteria apply to the same candidate. No score, waiver by majority, inferred
approval or substitution across criteria exists.

## Cross-Domain Evidence Consolidation

The final package references immutable evidence identities and digests from
M18.1 scope/identity, M18.2 compatibility, M18.3 evidence/verification, M18.4
recovery/continuity, M18.5 trust/privacy, M18.6 performance/determinism and
M18.7 readiness/rollout. It does not copy, edit, reinterpret or reclassify their
owned facts.

Each reference records required/received/current/superseded status, owner,
custodian, independent verifier, scope/identity, validity, findings, exception
and lineage. Same canonical references, rules and decisions yield the same
ordered completeness/conflict findings, blocking set, determination and digest.
Missing, duplicate-semantic, stale, mixed or conflicting evidence fails closed.

## Independent Integration Audit Governance

The auditor must be independent of package assembly and implementation ownership.
Audit binds exact candidate/package/rule versions and verifies completeness,
identity/provenance, public-boundary ownership, compatibility, separation of
duties, negative evidence, failure/recovery, trust/privacy, determinism,
readiness/rollout, exception validity and protected freezes.

Audit results are append-only and include ordered findings, severity/blocking
status, inspected evidence identities, denied claims, auditor authority and
digest. An audit cannot create missing owner approval, change domain truth or
approve its own remediation.

## Final Compatibility Verification Governance

Final compatibility re-evaluates the exact assembled candidate rather than
trusting component-level success. It checks Knowledge and runtime contracts,
producer/consumer version/capability intersection, boundary direction,
failure/degradation semantics, provider constraints, security/privacy/trust,
workload/continuity combinations, predecessor support and rollback target.

For the same canonical candidate, rules and evidence, verification produces the
same ordered findings, `compatible`/`incompatible` result and digest. Unknown or
conditional support is incompatible until explicitly resolved and reverified.

## Integration Release Authorization Workflow

```text
candidateAssembled -> ownerDecisionsCollected -> evidenceConsolidated
                   -> independentAudit -> finalCompatibilityVerified
                   -> readinessConfirmed -> poReviewed
                   -> authorizedOrRejected -> repositoryClosed -> retained
```

Each transition appends actor/authority, exact input/output identities, findings,
decision/reason, predecessor and digest. `authorized` is governance approval for
a separately scoped future implementation/release; this plan performs no
deployment and grants no runtime, infrastructure or Product authority.

Rejection/hold retains all evidence and identifies accountable remediation.
Timeout, silence, partial completion or repository merge never advances state.

## Rollback And Supersession Governance

Final authorization requires an exact verified compatible last-known-good
target or an owner-approved forward-repair/hold path. Rollback restores a
successor operational identity without deleting current candidate, decision,
audit or evidence. Supersession links immutable predecessor/successor gate
packages and repeats every affected criterion, audit and owner decision.

An exception names rule, risk owner, exact scope, evidence, compensating
governance, start/expiry, review and removal. It cannot bypass constitutional
boundaries, a blocking compatibility/trust finding, independent audit or PO
acceptance, and cannot self-renew.

## Fail-Closed Final Integration Gate

The final determination is `rejected` or `held` on mixed/stale identity,
incomplete predecessor lineage, missing owner/authority, private dependency,
incompatible contract/capability, stale/conflicting evidence, failed audit,
security/privacy/trust conflict, nondeterministic replay, unknown external
outcome, incomplete readiness, unsafe rollback, expired exception or any
blocking finding. There is no fallback candidate or default approval.

## Product Owner Implementation Acceptance Gates

Any later implementation requires a new explicitly authorized milestone with
exact files/mechanisms, this final planning gate accepted/closed, current
candidate and evidence, all owner decisions, independent audit, final
compatibility/readiness, negative cases, rollback/repair/supersession, no
blocking exception, protected freezes, Architecture Fitness 0 new, clean diff
and PO acceptance before commit/push. M18.8 itself authorizes planning only.

## Definition Of Done

- One immutable final-gate identity and ten consolidated criteria are explicit.
- Seven predecessor evidence groups are consolidated only by identity/digest.
- Independent audit and deterministic final compatibility are defined.
- Ten-state authorization, rollback/supersession and fail-closed PO gates are
  explicit.
- Exactly this milestone and `MEMORY.md` change.
- No deployment/CI/CD/tooling/monitoring/automation, implementation, runtime
  contract, ADR, Product or frozen change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines ten consolidated acceptance criteria, seven predecessor
  evidence groups and ten authorization states.
- App regression: 949/949.
- Knowledge package regression: 75/75.
- Protected foundation freezes: 56/56.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
