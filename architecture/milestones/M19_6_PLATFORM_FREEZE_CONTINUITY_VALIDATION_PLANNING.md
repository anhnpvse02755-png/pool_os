# M19.6 Platform Freeze Continuity Validation Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define governance for validating identity and transitive continuity across Pool
OS Foundation Freezes. M19.6 is planning only. It introduces no freeze
generation or verification implementation, runtime contract, production code,
Flutter, infrastructure, deployment, CI/CD, monitoring, tooling, Product, ADR
or modification to existing frozen artifacts.

## Authority And Protected Root

Constitution v1.4.0, accepted M3-M18 Foundation Freezes and M19.0-M19.5
validation governance remain protected. M18 Foundation Freeze is the direct
M19 root with artifact-set digest
`2cbb5729111984aa825f4cd5291639e2e7c6fb452a3fbe47e93330498123f753`.
Repository Authority owns stored freeze identity; Architecture owns continuity
rules; source owners own frozen inputs; Quality independently verifies; PO
accepts.

## Freeze Continuity Validation Model

One immutable continuity candidate binds candidate/scope, head and expected root
freeze identities, ordered predecessor links, manifest/proof schema and hashes,
artifact-set digests, source inventories/status/hashes, dependency graphs,
required sections/contracts, protected range, rule versions, evidence,
owners/reviewers, findings, validity, predecessor/successor and digest.

Validation proves that each freeze directly protects its accepted source set and
anchors the immediately preceding accepted freeze, yielding an unbroken
transitive chain. It does not regenerate a manifest/proof or infer continuity
from filenames, commit ancestry or passing downstream tests.

## Continuity Identity And Lineage

Continuity identity includes milestone/schema, normalized manifest/proof hashes,
canonical artifact-set digest, predecessor anchor map and digest, source-root
and exact inventory, accepted status, graph counts/digest, verification rule
identity, protected start/end, reviewer authority and determination digest.

Each validation revision is append-only. A changed source, manifest, proof,
anchor, schema, graph, rule or protected range creates a successor and repeats
validation. Existing freeze identities remain immutable; a correction is a new
explicitly authorized freeze or superseding evidence, never overwrite.

## Freeze-Chain Integrity Rules

1. Head milestone and schema match the declared candidate.
2. Manifest/proof are parseable canonical structured objects.
3. Exact frozen source inventory is unique and accepted/closed.
4. Every normalized source hash matches retained source content.
5. Required semantic sections/contracts exist under their exact identities.
6. Every dependency target exists and the graph has zero cycles.
7. Canonical artifact-set digest replays from ordered manifest entries.
8. Proof counts, statuses, digest and manifest assertions agree.
9. Direct predecessor manifest/proof normalized hashes match retained artifacts.
10. Protected range advances exactly one accepted freeze with no missing link.

Every rule is conjunctive. A valid head with an invalid predecessor does not
form a valid chain; duplicate milestone/digest identity with conflicting content
is a blocking integrity failure.

## Transitive Protection Governance

Direct anchors form an ordered directed chain from the candidate head through
M18 and earlier accepted freezes. Transitive protection is derived only when
every direct edge validates under its recorded rules. It covers prior planning,
contracts/proofs and their immutable evidence as declared by each freeze; it
does not expand a freeze's original scope.

Continuity reports reference predecessor artifacts by normalized hash/digest and
cannot copy, reinterpret or repair them. Repository moves or line-ending
differences are handled only by declared normalization; semantic content cannot
be normalized away. Missing history results in `broken`, not a shortened chain.

## Continuity Determinations

| State | Meaning |
|---|---|
| continuous | Every declared source, proof and predecessor edge passes |
| broken | At least one identity/hash/graph/anchor rule fails |
| incomplete | Required artifact, owner, evidence or range is missing |
| incompatible | Schema/normalization/rule versions cannot be validated together |
| held | Authority, custody, privacy/security or conflict is unresolved |
| superseded | A linked successor determination replaces this evidence |

Only `continuous` passes. No partial range, score, cached report, majority edge
or downstream success can substitute for a failed link.

## Continuity Evidence Requirements

Evidence binds candidate and protected range, retained manifest/proof/source
identities, normalized hashes, canonical replay inputs/results, inventory and
status checks, required-section/contract checks, graph vertices/edges/cycles,
predecessor anchor checks, positive and tamper/missing/mixed negative cases,
tool/rule version, custodian/reviewer, validity, lineage and digest.

Negative evidence covers changed source/hash/digest, missing/extra artifact,
duplicate ID, stale/mixed proof, dangling edge, cycle, wrong predecessor,
noncanonical replay, truncated range and unauthorized regeneration. Generated
health may corroborate but cannot own or self-verify freeze truth.

## Deterministic Evaluation Ordering

Freeze nodes order by milestone sequence; within a freeze, sources order by
canonical file/semantic ID, sections/contracts by declared ID, graph edges by
source then target, anchors by protected path. Findings order by milestone,
rule ID, artifact ID and evidence ID.

Same candidate, retained artifacts, rules and evidence yield the same ordered
edge results, findings, protected range, determination and digest. Filesystem
enumeration, locale, clock and repository path do not affect evaluation.

## Ownership Responsibilities

| Responsibility | Accountable owner |
|---|---|
| Candidate/protected range | Architecture/Validation owner |
| Frozen source meaning/status | Original source/domain owner |
| Manifest/proof custody | Repository Authority |
| Contract/semantic identity | Contract owner |
| Dependency graph claim | Architecture and source owners |
| Normalization/canonicalization rule | Freeze contract owner |
| Direct predecessor anchor | Successor freeze owner |
| Independent continuity evidence | Quality |
| Security/privacy/custody exception | Security/Privacy and evidence owner |
| Final acceptance | Product Owner |

No verifier may regenerate evidence to make a failing freeze pass.

## Rollback And Supersession

Rollback returns to a previously verified continuous head/range and retains the
failed candidate and findings. Forward repair creates a separately authorized
successor freeze/evidence identity. Supersession links immutable continuity
determinations and repeats every affected edge. Removing a bad head does not
rewrite or claim continuity for it.

## Fail-Closed Governance

Return broken/incomplete/incompatible/held on missing/mixed/stale identity,
hash/digest mismatch, source/status/section drift, duplicate semantic content,
dangling edge/cycle, wrong/missing predecessor, noncanonical replay, truncated
range, self-verification, invalid custody/authority, unsafe rollback or any
blocking constitutional/security/privacy finding.

## Product Owner Acceptance Gates

Future implementation requires exact scope, accepted predecessors, complete
freeze/range inventory, owners/custody, deterministic positive/negative evidence,
all direct anchors, rollback/supersession, protected artifacts, Architecture
Fitness 0 new, clean diff and explicit PO acceptance. This plan grants no freeze
generation, verification implementation or repository mutation authority.

## Definition Of Done

- Immutable continuity model/lineage and ten integrity rules are explicit.
- Transitive protection, six determinations and evidence are defined.
- Deterministic ordering and ten ownership responsibilities are explicit.
- Rollback, supersession and fail-closed gates are explicit.
- Exactly this milestone and `MEMORY.md` change; no prohibited change.

## Engineering Evidence

- Planning defines ten integrity rules, six determinations and ten ownership
  responsibilities.
- Full app regression: 953/953 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M18 freeze regression: 60/60 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
