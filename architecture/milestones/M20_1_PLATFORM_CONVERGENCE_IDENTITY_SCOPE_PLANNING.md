# M20.1 Platform Convergence Identity & Scope Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define immutable identity, scope, lineage, ownership and evidence governance for
future platform convergence. M20.1 is planning only. It introduces no runtime
contract, implementation, production code, Flutter/UI behavior, Product,
infrastructure, deployment, CI/CD, monitoring, tooling, ADR, freeze or generated
protected-artifact change.

## Authority And Protected Root

Constitution v1.4.0, accepted M20.0 planning and M19 Foundation Freeze remain
authoritative/protected. The M19 artifact-set digest
`e6628bbdaaf2a06e7bf2bb2ab4e60603c401c0188e1150cccaf95f2cf304a49e`
is the direct identity root. ADR-019 remains Proposed and grants no authority.
Architecture/Platform owns convergence identity governance; domain and contract
owners retain semantic/version authority; Product Owner owns scope acceptance.

## Immutable Convergence Candidate Identity

A convergence candidate is one immutable composite identity containing:

1. candidate ID, schema version and declared convergence target identity;
2. M19 Freeze manifest/proof identities and artifact-set digest;
3. accepted M20.0 plan, capability-graph and rule identities;
4. participating domain, public boundary, contract and capability identities;
5. Knowledge/runtime/canonicalization and compatibility-version identities;
6. accepted M19 validation finding, gap and exception identities;
7. workload, data, trust/privacy, failure and recovery class identities;
8. owner, reviewer, authority/delegation and validity identities;
9. evidence package, audit and Decision Trace reference identities;
10. predecessor, successor, rollback/repair target and deterministic digest.

Semantic IDs are stable within their owning namespaces. Any bound value change
creates a new candidate revision and cannot inherit acceptance implicitly.
Display names, paths, timestamps or provider labels cannot replace identity.

## Convergence Scope Definition

Scope is a first-class immutable object bound to the candidate. It declares
included and excluded claims, domains, public boundaries, contracts/version
ranges, capabilities, semantic invariants, M19 findings, gaps/exceptions,
Knowledge/runtime identities, workload/data/trust/failure classes, evidence and
audit requirements, owners, validity and recovery boundary.

Partial scope is valid only when exclusions, unsupported claims and deferred
items are explicit and owned. Omission means unknown, never unrestricted or
compatible. Expansion, contraction, reclassification or owner change creates a
superseding scope and repeats all affected gates.

## Convergence Lineage

Every candidate records normalized identities for the accepted M19
manifest/proof, M19 artifact-set digest, accepted M20.0 documents and transitive
M3-M19 protection status. The lineage is append-only:

`M19 Freeze -> M20.0 planning baseline -> M20.1 candidate -> successor`.

A predecessor can be referenced but never copied, rewritten, regenerated or
reinterpreted. Broken, missing, ambiguous or cyclic lineage blocks the
candidate. A successor explicitly binds predecessor identity, change set,
affected claims, reauthorization and new digest.

## Compatibility Inheritance From M19

M20.1 inherits only exact accepted M19 compatibility determination references,
including candidate, contract/version matrix, findings, exceptions, validity
and digest. It does not recalculate, widen or translate them. Inheritance is
eligible only when source identity and validity are current and the M20 scope is
not broader than the accepted claim.

Changed producer/consumer version, semantic ID, capability, Knowledge/runtime
identity, boundary, failure behavior, exception or scope invalidates inherited
compatibility and requires separately authorized M20.3 determination. Unknown,
conditional or expired compatibility fails closed.

## Ownership Boundaries

| Identity or decision | Accountable owner |
|---|---|
| Candidate and scope composition | Architecture/Platform |
| Domain semantics and source truth | Owning domain |
| Public boundary identity | Producer/consumer contract owners |
| Contract version and inherited compatibility | Contract owners |
| Knowledge/runtime identity | Knowledge publisher/runtime contract owner |
| Evidence fact, custody and provenance | Source/Evidence owner |
| Data, security and privacy scope | Data owner and Security/Privacy |
| Failure, recovery and operational scope | Operations/Recovery owner |
| Rollback, repair and supersession identity | Affected owners/Repository Authority |
| Independent review and final acceptance | Quality/Product Owner |

Candidate assembly coordinates references but cannot approve an owned claim.
Infrastructure and providers cannot own semantics, compatibility or acceptance.

## Evidence Identity

Each immutable evidence reference binds evidence ID/type/schema, candidate and
scope, M19 root and inherited finding, claim/boundary/contract, canonical input
and result digests, source/custodian, rule/tool version, positive/negative
status, reviewer authority, validity/retention/redaction, predecessor and
digest. Evidence content remains with its source owner; M20 stores references.

Duplicate semantic evidence IDs with different content, equal content presented
as authority for unrelated claims, self-review or generated self-verification
are invalid. Identical canonical candidate/scope/evidence references produce the
same ordered identity findings and digest. Ordering uses claim, evidence type,
source and evidence ID.

## Rollback And Supersession Planning

Rollback returns only to a verified compatible last-known-good convergence
candidate without deleting rejected/current candidates, findings, evidence or
audit. Forward repair creates a new versioned candidate. Supersession links
immutable predecessor/successor candidate, scope, evidence, owner decisions and
affected gates. No alias, path replacement or timeout silently supersedes an
identity.

## Fail-Closed Governance

Reject on missing/mixed/duplicate/stale identity, wrong M19 root, unknown scope,
unsupported claim, missing owner, private boundary, compatibility drift,
conflicting evidence, expired authority/exception, broken/cyclic lineage,
scope drift, unsafe rollback or nondeterministic canonicalization. No inference,
score, fallback, deadline, test result or technical completion supplies a
missing identity or approval.

## Product Owner Implementation Acceptance Gates

Any future implementation requires a separately authorized exact scope and
files, accepted predecessors, current M19 anchors, complete candidate/scope and
owner inventory, valid compatibility inheritance or M20.3 determination,
canonical positive/negative evidence, security/privacy review,
rollback/supersession, protected freeze regressions, Architecture Fitness 0 new,
clean diff and explicit PO acceptance before repository closure. M20.1 grants
planning authority only.

## Definition Of Done

- Ten immutable candidate identity groups and first-class scope are explicit.
- M19/M20.0 lineage and compatibility inheritance rules are explicit.
- Ten ownership decisions and deterministic evidence identity are defined.
- Rollback, supersession and fail-closed PO gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, runtime contract, Product, ADR, tooling or freeze change.

## Engineering Evidence

- Planning defines ten candidate identity groups and ten ownership decisions.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
