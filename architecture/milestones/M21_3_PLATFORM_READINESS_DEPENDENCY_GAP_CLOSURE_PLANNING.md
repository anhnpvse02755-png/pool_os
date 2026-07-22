# M21.3 Platform Readiness Dependency & Gap Closure Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define immutable readiness dependencies, deterministic ordering and governed gap
closure for M21 candidates. Planning only; no Product feature, runtime contract,
implementation, UI, deployment, CI/CD, monitoring, infrastructure, tooling, ADR,
freeze or generated protected-artifact change is authorized.

## Authority And Protected Inputs

Constitution v1.4.0, accepted M21.0-M21.2 and M20 Foundation Freeze remain
protected. M21.1 owns candidate/scope identity and M21.2 owns evidence/completion
semantics. M21.3 only binds their immutable IDs and digests; it cannot copy,
reinterpret, repair or widen their claims.

## Immutable Readiness Dependency Model

Each dependency binds:

1. dependency ID, schema version, candidate/scope and criterion IDs;
2. predecessor and successor semantic IDs/digests;
3. dependency class, direction, cardinality and required ordering;
4. producer/consumer owners and public contract/version constraints;
5. positive and negative evidence references and validity window;
6. gap, exception and amendment references when present;
7. compatibility, safety and completion predicates;
8. provenance, reviewer, predecessor/successor lineage and digest.

Any bound change creates a successor. Repository paths, timestamps, reports,
generated output and implementation status cannot act as semantic identity.

## Dependency Graph And Deterministic Ordering

The graph contains only declared readiness nodes and directed dependency edges.
Every edge must resolve to one exact known node, have an accountable owner and
remain inside the candidate scope. Self-edges, cycles, duplicate semantic edges,
or implicit/transitive readiness claims are invalid.

Canonical ordering uses criterion ID, predecessor ID, successor ID, dependency
class and dependency ID. A stable topological sort uses that order to break ties.
The graph digest binds the ordered node and edge digests. Identical inputs yield
identical order and digest; ambiguity or a cycle fails closed.

## Gap Identification And Classification

A gap is an immutable record binding gap ID/type/schema, candidate/scope/claim,
affected dependency and criteria, observed and required states, severity/impact,
positive/negative evidence, accountable owner, closure authority, validity,
exception/amendment references, lineage and digest.

Ten non-compensating gap classes are recognized:

1. missing or ambiguous semantic identity;
2. absent, private or reversed public dependency;
3. incompatible contract or version;
4. unresolved Knowledge/runtime/publication integrity;
5. missing, stale, mixed or invalid evidence/provenance;
6. cross-domain semantic or Decision Trace conflict;
7. nondeterministic canonicalization, replay or digest;
8. security, privacy, custody or trust failure;
9. operational, capacity, recovery or failure-mode deficiency;
10. ownership, audit, exception, amendment or freeze discontinuity.

Unknown classification remains blocking. Severity cannot waive a gap, and one
closed gap cannot compensate for another open gap.

## Dependency And Gap Ownership

| Responsibility | Accountable authority |
|---|---|
| Graph composition and canonical ordering | Architecture/Platform |
| Source semantic dependency | Owning domain |
| Public contract direction/version | Producer and consumer contract owners |
| Knowledge/runtime/publication dependency | Publisher/runtime contract owner |
| Evidence, provenance and custody relationship | Source/Evidence owner |
| Intelligence/trace and cross-domain meaning | Affected semantic owners |
| Security/privacy/trust gap | Security/Privacy/data owner |
| Operations/capacity/recovery gap | Respective operational owner |
| Independent closure verification | Quality/independent auditor |
| Exception acceptance and M22 boundary | Product Owner |

Graph assemblers, gap owners and evidence producers cannot independently verify
or accept their own closure.

## Closure Criteria And States

A gap may progress append-only through `identified`, `classified`, `owned`,
`remediationPlanned`, `evidencePending`, `closureProposed`, `closedVerified`,
`exceptionBound`, `reopened` and `superseded`. State is derived from ordered
records; historical records are never edited or removed.

Closure requires exact candidate/scope/dependency binding, source-owned repair,
current positive and negative evidence, satisfied compatibility and safety
predicates, no new dependent conflict, independent verification, accountable
owner approval and deterministic closure digest. Only `closedVerified` satisfies
the gap. `exceptionBound` is still blocking unless an explicitly authorized
criterion permits it and all scope, expiry and compensating controls are valid.

## Exception Handling

An exception binds exact gap/dependency/claim, rationale, owner and accepting
authority, scope, non-transferable constraints, compensating controls, evidence,
valid-from/expiry, review cadence, revocation, rollback and digest. Exceptions
cannot change semantic truth, conceal unknowns, waive constitutional rules,
authorize implementation or propagate to successor candidates. Missing, expired,
over-broad, conflicting or unverified exceptions fail closed.

## Evidence Relationships

Dependency and gap records reference M21.2 evidence by semantic ID and digest.
Relationships declare `supports`, `contradicts`, `blocks`, `supersedes` or
`invalidates`, plus exact claim, source owner and validity. Evidence remains
source-owned and append-only; derived reports cannot become authority. A changed
source, claim, contract, candidate or dependency invalidates affected closure and
requires re-verification.

## Rollback, Repair And Supersession

Rollback selects a verified compatible predecessor graph/candidate without
rewriting history. Repair occurs only at the accountable source under separate
authority and appends corrected evidence and gap records. Supersession links old
and new graph, dependency, gap, exception, evidence and decision digests with
reason and impact. Reopened downstream gaps are recalculated deterministically.

## Fail-Closed Governance And M22 Progression

Reject unknown/mixed/stale identity, missing owner/evidence, duplicate edge or
gap, cycle, ambiguous order, private dependency, incompatible version, semantic
conflict, invalid custody, nondeterminism, self-review, expired exception,
orphaned lineage, unsafe rollback, broken freeze or incomplete downstream
re-evaluation.

M22 planning eligibility requires an acyclic verified graph, every required gap
`closedVerified`, no blocking exception/amendment, all M21.1-M21.2 predicates
current, protected freezes intact and separate PO authorization. Eligibility is
planning-only and grants no Product or M22 implementation authority.

## Definition Of Done

- Eight-part dependency and immutable gap models are fully defined.
- Ordering is deterministic and acyclic; ten gap classes are explicit.
- Ownership, closure, exception and evidence relationships are explicit.
- Rollback, repair, supersession and fail-closed M22 progression are explicit.
- Exactly this milestone and MEMORY change; no implementation/protected change.

## Engineering Evidence

- App 961/961, Knowledge 75/75 and protected M3-M20 freezes 68/68 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated health restored; exact two-file scope and clean diff confirmed.
