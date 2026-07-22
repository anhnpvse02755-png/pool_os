# M20.2 Platform Public Contract & Boundary Convergence Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define governance for converging declared public contracts and cross-domain
boundaries without changing their runtime semantics. M20.2 is planning only. It
introduces no runtime contract, implementation, production code, Flutter/UI,
Product, infrastructure, deployment, CI/CD, monitoring, tooling, ADR, freeze or
generated protected-artifact change.

## Authority And Accepted Inputs

Constitution v1.4.0, accepted M20.0-M20.1 and M19 Foundation Freeze remain
authoritative/protected. The M19 artifact-set digest
`e6628bbdaaf2a06e7bf2bb2ab4e60603c401c0188e1150cccaf95f2cf304a49e`
is the direct root. M20.1 candidate/scope identity is the required predecessor.
Domain and producer/consumer contract owners retain semantics and versions;
Architecture/Platform owns boundary-convergence governance.

## Public Contract Convergence Model

Each immutable convergence entry binds entry/schema version, M20.1 candidate and
scope, source/consumer domains, public port/contract semantic ID and version,
producer/consumer capability IDs, direction, canonical request/result/failure
envelope identities, Knowledge/runtime identities, compatibility reference,
owner/reviewer/authority, evidence, exception, validity, predecessor/successor,
recovery target and deterministic digest.

Convergence establishes one attributable declaration for an already accepted
public surface. It cannot merge semantically distinct contracts, rename an ID,
select a runtime mechanism, expose an internal type or convert implementation
similarity into compatibility.

## Boundary Convergence Governance

| Boundary class | Converged public view | Explicitly private/prohibited |
|---|---|---|
| Experience -> Evidence | command/event identity and attributable result | persistence/event-store internals |
| Experience -> Intelligence | command/query and immutable projection | Coach/Player internals or UI inference |
| Knowledge -> Intelligence | published versioned Knowledge identity | authoring/compiler/generated mutation |
| Evidence -> Intelligence | immutable facts/projections/snapshots | fact rewriting or decision-as-evidence |
| Intelligence -> Simulation | versioned request/result with uncertainty | Player, strategy, Coach or UI policy |
| Intelligence -> Experience | decision/trace/projection contracts | presentation-owned mastery/recommendation |
| AI input/output | AISession and accepted structured response | direct domain internals or self-review |
| Infrastructure/provider -> domain | accepted adapter/capability envelope | semantic, compatibility or fallback policy |
| Persistence -> domain | public repository/unit-of-work port | storage schema/client or migration internals |
| Operations -> platform | accepted status/evidence reference | monitoring, deployment or provider internals |

Every declared boundary has one direction, source owner, consumer, purpose,
contract version, failure owner and recovery boundary. Undeclared, bidirectional,
privately coupled or ownerless boundaries fail closed.

## Contract Inheritance From M19

An M20.2 entry may inherit only an exact contract/boundary reference accepted by
the M19 candidate: semantic ID, producer/consumer, version/range, direction,
capability, Knowledge/runtime identity, canonicalization, result/failure
semantics, compatibility determination, owner, validity and digest.

Inheritance never copies authority or revalidates a claim. Any missing source,
changed identity/version/direction/owner/failure behavior, wider scope, expired
exception or M19 finding drift invalidates inheritance. The entry remains
`unconverged` until separately authorized M20.3 or source-owner repair exists.

## Compatibility Preservation Rules

1. Exact accepted bindings remain exact; no alias substitutes semantic ID.
2. Additive change requires declared consumer tolerance and owner evidence.
3. Breaking change requires new version, migration window and recovery target.
4. Capability intersection must be explicit; unsupported is never degraded.
5. Canonical ordering, digest and failure semantics remain version-bound.
6. Knowledge/runtime identity mismatch invalidates the complete entry.
7. Private adapters cannot become public compatibility authorities.
8. Mixed, stale, duplicate, ambiguous or conditional bindings fail closed.

M20.2 records these constraints; it does not perform compatibility resolution,
migration, adaptation, fallback or runtime negotiation.

## Boundary Ownership

| Concern | Accountable owner |
|---|---|
| Convergence entry and boundary inventory | Architecture/Platform |
| Source semantics and public port | Source domain |
| Consumer obligation and tolerated versions | Consumer/contract owner |
| Contract version and canonical envelope | Producer/consumer contract owners |
| Knowledge identity/publication reference | Knowledge publisher |
| Evidence fact and custody | Evidence/source owner |
| AI/provider/persistence adapter boundary | Infrastructure owner plus contract owner |
| Data purpose, security and privacy | Data owner and Security/Privacy |
| Failure and recovery boundary | Source/consumer/Operations owners |
| Independent verification and acceptance | Quality/Product Owner |

An assembler cannot self-approve an owned claim. Infrastructure cannot own
domain semantics, and consumers cannot redefine producer source truth.

## Evidence Requirements

Evidence references bind exact candidate/scope/entry, contract and boundary,
source and consumer identities, canonical input/result/failure digests,
positive/negative case, M19 determination, rule/tool version, source/custodian,
reviewer, validity/retention/redaction and digest. Minimum evidence covers exact
binding, supported flow, unsupported/mixed/stale/private denial, owner approval,
failure/recovery behavior and deterministic replay.

Evidence is immutable or superseding and remains at its authoritative source.
Generated/provider output cannot self-review or establish convergence.

## Convergence Exception Handling

An exception is an immutable candidate-bound record with exception ID/type,
affected entry/claim, normative authority, rationale, impact, owner, approver,
compensating controls, evidence, start/expiry, recovery/closure criteria,
predecessor/successor and digest. It cannot waive constitutional ownership,
Evidence/Intelligence separation, freeze integrity or PO acceptance.

Unknown, unowned, expired, scope-widened or conflicting exceptions block the
entry. Renewal or change creates a successor and repeats affected gates.

## Rollback, Supersession And Fail-Closed Governance

Rollback selects only a verified compatible last-known-good boundary entry and
never edits rejected/current entries, source contracts, evidence or audit.
Forward repair is versioned. Supersession links immutable predecessor/successor,
change set, owners, evidence and rerun gates.

Fail closed on wrong M19/M20.1 identity, missing/duplicate/mixed/stale contract,
private or reversed dependency, unknown owner/purpose, unsupported version or
capability, compatibility drift, Knowledge/runtime mismatch, incomplete or
conflicting evidence, invalid exception, unsafe recovery or nondeterministic
ordering. No fallback, adapter behavior, test pass or deadline grants approval.

## Product Owner Implementation Acceptance Gates

Future implementation requires separately authorized files/scope, accepted
predecessors, complete public contract/boundary inventory, source and consumer
owner decisions, valid M19 inheritance, current compatibility evidence,
positive/negative cases, exception/recovery governance, protected regressions,
Architecture Fitness 0 new, clean diff and explicit PO acceptance. M20.2 grants
planning authority only.

## Definition Of Done

- Immutable public contract convergence entries are defined.
- Ten boundary classes and ten ownership responsibilities are explicit.
- M19 inheritance and eight compatibility-preservation rules are defined.
- Evidence, exceptions, rollback, supersession and fail-closed gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No runtime contract, implementation, Product, ADR, tooling or freeze change.

## Engineering Evidence

- Planning defines ten boundary classes, ten owners and eight compatibility rules.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
