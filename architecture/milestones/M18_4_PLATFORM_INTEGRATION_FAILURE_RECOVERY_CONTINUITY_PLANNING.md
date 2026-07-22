# M18.4 Platform Integration Failure, Recovery & Continuity Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define failure, recovery and continuity governance for future platform
integration. M18.4 is planning only. It introduces no runtime contract,
implementation detail, Flutter, infrastructure, networking, persistence, AI,
CI/CD, deployment, monitoring, ADR, Product functionality or frozen change.

## Authority And Inputs

Constitution v1.4.0, M17 Foundation Freeze and accepted M18.0-M18.3 identities,
compatibility and evidence governance are protected. Domain owners retain fact,
semantic and recovery authority; integration owner coordinates boundaries;
Operations supports continuity evidence without owning domain truth; Product
Owner authorizes future implementation and acceptance.

## Integration Failure Taxonomy

| Failure class | Examples | Required owner |
|---|---|---|
| Identity/binding | Wrong candidate, duplicate ID, mixed freeze/provenance | Architecture/Integration |
| Boundary/dependency | Private import, wrong direction, unauthorized route | Architecture plus endpoint owners |
| Compatibility | Unsupported version/capability, expired window, digest mismatch | Producer/consumer contract owners |
| Evidence/provenance | Missing/stale/conflicting evidence, orphan lineage | Source owners/Quality |
| Data/semantic | Invalid invariant, loss/corruption, domain meaning conflict | Owning domain/data owner |
| Security/privacy | Unauthorized access/exposure, purpose/retention conflict | Security/Privacy/data owner |
| Partial execution | Producer succeeds while consumer/closure fails | Integration owner plus affected owners |
| External/provider | Timeout, unavailable dependency, malformed/late result | Adapter/provider owner |
| Recovery/continuity | Restore/repair validation fails or trusted state unknown | Recovery owner plus domains |
| Authority/governance | Missing approval, expired delegation, scope drift | Product Owner/Architecture |

A failure can carry multiple classes, but each finding has one accountable
resolution owner. Provider failure never changes domain or compatibility truth.

## Failure Domain Ownership

Failure isolation follows public boundaries. A producer owns correctness and
attributable output until accepted handoff; consumer owns processing after
handoff; contract owners share compatibility; domain owners control their
state/replay; infrastructure owns mechanism failure evidence; Integration owns
cross-boundary correlation; Operations owns continuity coordination; PO owns
acceptance. No coordinator may mutate domain history to create apparent success.

## Recovery Governance

Every recovery plan binds exact failed/current/last-known-good candidate,
freeze/components/contracts, affected boundaries/data, failure evidence,
owner/authority, target state, recovery or forward-repair identity, validation,
abort triggers and retained result. Recovery requires source/domain owner
authority and cannot be inferred from tool completion.

## Deterministic Recovery Sequencing

```text
detect -> contain -> preserve evidence -> classify/assign
       -> select authorized path -> validate prerequisites
       -> execute later under separate authority -> verify
       -> accept/reject -> supersede/close
```

Planning defines the order only; it executes nothing. Same canonical failure,
identities, evidence and rule versions yield the same eligible recovery paths,
ordered gates and plan digest. Ties use declared semantic IDs. Missing or
conflicting prerequisites yield no eligible path and fail closed.

## Continuity Rules And Operational Boundaries

- Continue only unaffected flows whose boundaries and invariants remain proven.
- Degraded operation is an explicit compatible capability, never inferred.
- Evidence, Knowledge publication, audit and freeze histories remain available
  and immutable through recovery.
- Domain recovery/replay occurs through owning public ports; Operations cannot
  edit persistence directly.
- External effects require idempotency/correlation identity before retry is
  eligible; unknown outcome is retained, not assumed failed/successful.
- Security/privacy controls and least privilege remain active during recovery.
- Continuity expiration, owner handoff and return-to-normal criteria are explicit.
- Product/AI behavior cannot be introduced as a continuity shortcut.

## Recovery Path Governance

| Path | Eligibility | Prohibition |
|---|---|---|
| Reject/disable candidate | Incompatible or untrusted candidate | No hidden fallback |
| Retry | Bounded transient failure, known outcome/idempotency and current authority | No blind/unbounded retry |
| Rollback | Verified compatible last-known-good and reversible current state | No history rewrite |
| Forward repair | Rollback unsafe/impossible; owner-approved versioned repair exists | No invented semantics |
| Rebuild/replay | Authoritative sources and deterministic replay contract intact | No projection as source truth |
| Supersede | New candidate/decision explicitly replaces failed one | No predecessor mutation |
| Escalate/hold | Authority, evidence or safe path unresolved | No timeout approval |

## Evidence Before And After Recovery

Before: failure/candidate/freeze identities, impact and isolation, source trust,
compatibility/data/security assessment, path eligibility, authority, last-known-
good, abort/rollback and expected validation. After: exact attempts and external
effects, output/state digests, failure/denial details, domain verification,
compatibility/replay, security/privacy review, continuity status, owner/reviewer,
PO decision and successor/closure identity. Evidence is append-only and retains
unsuccessful attempts.

## Rollback, Forward Repair And Supersession

Rollback restores a verified compatible identity without deleting current
attempt/history. Forward repair is versioned, owner-authorized, input/output-
bound and independently verified. Supersession links immutable predecessor and
successor. Any scope, component, compatibility, evidence or authority change
requires re-evaluation; an old approval cannot be reused.

## Fail-Closed Continuity

Stop/hold on unknown trusted state, unresolved ownership, missing evidence,
mixed identities, boundary/compatibility failure, unknown external outcome,
invalid retry identity, security/privacy conflict, unavailable last-known-good,
unverified repair, expired exception/delegation, nondeterministic replay or
unresolved blocking finding. Availability pressure cannot waive invariants.

## Product Owner Acceptance Gates

Future implementation requires exact scope/mechanism, accepted predecessors,
current candidate/failure/evidence package, owners/authority, deterministic path
plan, negative failure cases, continuity/security/privacy review, rollback or
forward repair, protected regressions, Architecture Fitness 0 new, clean diff
and explicit PO acceptance before commit/push.

## Definition Of Done

- Ten failure classes and failure-domain ownership are explicit.
- Ten ordered recovery stages and seven governed recovery paths are defined.
- Continuity/operational boundaries preserve domain truth and frozen guarantees.
- Pre/post evidence, rollback, repair, supersession and fail-closed PO gates are
  explicit.
- Exactly this milestone and `MEMORY.md` change.
- No implementation/runtime contract, ADR, Product or frozen-artifact change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines ten failure classes, ten recovery stages and seven recovery
  paths.
- Full app regression: 949/949.
- Knowledge package regression: 75/75.
- Protected M3-M17 freeze regression: 56/56.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Generated health restored; exact two-file scope confirmed.

Product Owner accepted and closed M18.4 on 2026-07-22 and authorized repository
closure.
