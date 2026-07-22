# M20.3 Platform Compatibility & Version Stabilization Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define compatibility and semantic-version stabilization governance for M20
convergence candidates. M20.3 is planning only. It introduces no runtime
negotiation, migration, adapter, contract, implementation, production code,
Flutter/UI, Product, infrastructure, tooling, ADR, freeze or generated change.

## Authority And Accepted Inputs

Constitution v1.4.0, accepted M20.0-M20.2 and M19 Foundation Freeze remain
authoritative/protected. M20.1 supplies candidate/scope identity; M20.2 supplies
public contract/boundary entries. Producer/consumer contract owners retain
version and semantic authority. Architecture/Platform owns stabilization
governance; Quality verifies; Product Owner accepts.

## Compatibility Stabilization Model

An immutable stabilization candidate binds candidate/schema version, M20.1
identity, M20.2 entry set/digests, M19 compatibility references, producer and
consumer contract/capability versions, Knowledge/runtime/canonicalization
identities, semantic evolution class, request/result/failure behavior,
dependency constraints, migration/recovery references, evidence, owners,
exceptions, validity, predecessor/successor and deterministic digest.

Stabilization confirms a declared compatibility state; it does not implement
negotiation, convert versions, alter semantics, select adapters or infer support.
Any bound change creates a new candidate and repeats affected gates.

## Version Stabilization Model

Each contract lineage is an immutable ordered sequence of semantic ID, schema
and contract version, status, supported predecessor/successor ranges, capability
intersection, canonicalization/failure version, owner decision, effective and
retirement bounds, migration/recovery identity, evidence and digest.

Version aliases, paths, package labels and provider model names cannot replace
semantic identity. Gaps, cycles, overlapping incompatible ranges, unknown
owners or ambiguous active versions invalidate the lineage.

## Convergence Compatibility Determinations

| Determination | Meaning | Gate effect |
|---|---|---|
| `stableExact` | Exact accepted versions and semantics | Eligible |
| `stableAdditive` | Additive evolution with proven consumer tolerance | Eligible |
| `stableWindowed` | Accepted bounded migration/compatibility window | Eligible only within validity |
| `conditionallyBlocked` | Required owner/evidence/dependency unresolved | Blocked |
| `breakingBlocked` | Breaking change lacks complete new authority/path | Blocked |
| `unsupported` | Capability/version intersection is absent | Blocked |
| `stale` | Source, evidence, exception or validity has changed | Blocked |
| `invalid` | Mixed, duplicate, conflicting or malformed identity | Blocked |

Only the first three determinations can satisfy a declared claim, and each
requires all conjunctive gates. No score or partial compatibility compensates
for a blocked dimension.

## Semantic Version Evolution Rules

1. Patch evolution cannot change public semantics, canonical output or failure class.
2. Minor evolution is additive and requires explicit consumer tolerance evidence.
3. Major evolution is breaking and requires separate authority and new identity.
4. Deprecated behavior remains version-bound with owner and retirement criteria.
5. Capability additions cannot widen an existing consumer declaration implicitly.
6. Knowledge/runtime/canonicalization version drift invalidates compatibility.
7. Migration windows bind exact source/target versions, validity and recovery.
8. Unknown, pre-release, provider-specific or conditional support is blocked unless explicitly accepted.
9. Rollback targets must be verified compatible, current and independently evidenced.
10. A superseding determination preserves every prior determination and lineage link.

These are governance rules, not runtime SemVer parsing or migration mechanisms.

## Compatibility Evidence Requirements

Each evidence reference binds candidate and M20.2 entry, producer/consumer
versions, capability intersection, canonical request/result/failure identities,
Knowledge/runtime versions, evolution class, positive/negative case, source and
custodian, rule/tool version, reviewer, validity/retention, predecessor and
digest. Required cases cover exact, additive, breaking, unsupported, mixed,
stale, duplicate, failure/degradation, migration-window and rollback behavior.

Same canonical candidate, matrix, rules and evidence references yield the same
ordered findings, determination and digest. Evidence remains immutable or
superseding; generated/provider output cannot self-verify compatibility.

## Ownership Boundaries

| Concern | Accountable owner |
|---|---|
| Stabilization candidate and evaluation order | Architecture/Platform |
| Producer semantics and version | Producer contract owner |
| Consumer obligation and tolerated range | Consumer contract owner |
| Capability intersection | Producer/consumer capability owners |
| Knowledge/runtime/canonicalization identity | Respective contract owner |
| Migration window and retirement | Affected owners/Repository Authority |
| Evidence facts and custody | Source/Evidence owner |
| Security/privacy impact | Security/Privacy and data owner |
| Failure, rollback and forward repair | Contract/Operations owners |
| Independent verification and acceptance | Quality/Product Owner |

Infrastructure, adapters and providers cannot own semantic-version or
compatibility policy.

## Rollback, Repair And Supersession

Rollback selects only a verified current `stableExact`, `stableAdditive` or
valid `stableWindowed` last-known-good candidate. Forward repair creates a new
version and evidence package. Supersession links immutable predecessor and
successor determinations, changed claims, owners, migration/recovery path and
rerun gates. Rejected and expired determinations remain auditable.

## Fail-Closed Governance

Reject on wrong predecessor/root, mixed/stale/duplicate identity, missing owner,
malformed/cyclic lineage, unsupported intersection, semantic/version ambiguity,
Knowledge/runtime drift, incomplete or conflicting evidence, unbounded
migration, unsafe rollback, expired exception or nondeterministic evaluation.
No fallback, adapter success, production observation, score or deadline grants
compatibility.

## Product Owner Implementation Acceptance Gates

Future implementation requires separately authorized exact scope/files,
accepted predecessors, complete current matrix/lineage, owner decisions,
semantic-evolution classification, positive/negative evidence, migration and
recovery governance, protected regressions, Architecture Fitness 0 new, clean
diff and explicit PO acceptance. M20.3 grants planning authority only.

## Definition Of Done

- Compatibility/version stabilization candidates and lineage are defined.
- Eight determinations and ten semantic evolution rules are explicit.
- Evidence, ten ownership boundaries, recovery/supersession and fail-closed
  gates are complete.
- Exactly this milestone and `MEMORY.md` change.
- No runtime contract, implementation, Product, ADR, tooling or freeze change.

## Engineering Evidence

- Planning defines eight determinations, ten evolution rules and ten owners.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
