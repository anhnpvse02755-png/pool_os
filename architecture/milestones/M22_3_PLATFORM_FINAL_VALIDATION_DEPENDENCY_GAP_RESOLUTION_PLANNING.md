# M22.3 Platform Final Validation Dependency & Gap Resolution Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define immutable dependency and gap-resolution governance for final platform
validation. Planning only; this milestone performs no resolution or validation
and authorizes no Product, runtime, contract, UI, release, deployment, tooling,
ADR, freeze, generated or Knowledge/publication change.

## Authority And Protected Inputs

Constitution v1.4.0, accepted M22.0-M22.2 and M3-M21 freezes remain protected.
M22.1 owns candidate/scope identity and M22.2 owns evidence/completion semantics.
M22.3 binds their exact IDs/digests without reinterpreting or repairing claims.

## Immutable Final-Validation Dependency Model

Each dependency binds:

1. dependency ID/type/schema and exact candidate/scope/criterion identities;
2. predecessor/successor semantic IDs and digests;
3. dependency class, direction, cardinality and required ordering;
4. producer/consumer owners and public contract/version constraints;
5. positive/negative evidence and validation-rule references;
6. gap, finding, risk, exception and amendment references;
7. completion, compatibility, safety and validity predicates;
8. provenance, correction/supersession lineage and digest.

Any bound change creates a successor. Paths, timestamps, reports, aggregate
scores and implementation state cannot replace semantic identity.

## Deterministic Dependency Graph And Ordering

The graph contains only declared final-validation claims and directed dependency
edges. Every edge resolves to exact known nodes, has accountable owners and stays
inside candidate scope. Self-edges, cycles, duplicate semantic edges, private/
reversed dependencies and implicit transitive completion are invalid.

Canonical order is criterion ID, predecessor ID, successor ID, dependency class
and dependency ID. Stable topological sorting uses that order for ties. The graph
digest binds ordered node/edge digests. Same inputs yield the same order/digest;
ambiguity or a cycle fails closed.

## Gap Identification And Classification

A gap binds gap ID/type/schema, candidate/scope/claim, affected dependency and
criteria, observed/required states, impact, evidence, owner, closure authority,
validity, exception/amendment, lineage and digest.

Ten non-compensating classes are:

1. missing or ambiguous candidate/closure identity;
2. constitutional ownership or dependency violation;
3. absent, private, reversed or incompatible public boundary;
4. Knowledge/publication/runtime identity failure;
5. missing, stale, mixed or invalid evidence/provenance;
6. cross-domain semantic, Decision Trace or replay conflict;
7. incomplete or broken M3-M21 freeze chain;
8. security, privacy, operations, capacity or recovery deficiency;
9. unresolved finding, risk, exception or Product prerequisite;
10. audit, custody, authority, lineage or rollback discontinuity.

Unknown classification remains blocking. Severity, deadline or progress elsewhere
cannot waive or compensate a gap.

## Dependency And Gap Ownership

| Responsibility | Accountable authority |
|---|---|
| Graph composition and canonical order | Architecture/Platform |
| Source semantic dependency | Owning domain |
| Public boundary/version | Producer and consumer owners |
| Knowledge/runtime/publication dependency | Publisher/runtime owner |
| Evidence/provenance/custody relationship | Source/Evidence owner |
| Freeze-chain/replay dependency | Repository Authority/Quality |
| Security/privacy/operational gap | Respective accountable owner |
| Product-transition prerequisite gap | Architecture/Product owner |
| Independent closure verification | Quality/independent validator |
| Exception/closure boundary acceptance | Product Owner/governance authority |

Graph assemblers, gap owners, evidence producers and remediators cannot verify
or approve their own closure.

## Gap Closure Governance

States are `identified`, `classified`, `owned`, `resolutionPlanned`,
`evidencePending`, `closureProposed`, `closedVerified`, `exceptionBound`,
`reopened` and `superseded`. Ordered records derive state; history is immutable.

Closure requires exact binding, source-owned repair, current positive/negative
evidence, satisfied dependency/compatibility/safety predicates, no downstream
conflict, independent verification, accountable approval and deterministic
closure digest. Only `closedVerified` satisfies a required gap.

## Exception Handling Boundaries

An exception binds exact gap/dependency/claim, owner/requester/authority,
rationale, narrow scope, prohibited uses, compensating controls, evidence,
independent review, validity/expiry, revocation/rollback and digest. Exceptions
cannot alter truth, waive Constitution, hide unknowns, propagate to successors,
close a gap or authorize validation, Product or implementation.

## Completion Dependencies

Every M22.2 criterion declares exact predecessor criteria, evidence, gap/finding/
risk state and validation prerequisites. A criterion is complete only after all
predecessors are complete or independently not-applicable, with no blocking
downstream inconsistency. Completion is recomputed deterministically after every
successor; no cached/report state can override the source graph.

## Rollback, Repair, Supersession And Fail-Closed Governance

Rollback selects a verified compatible predecessor graph without editing
history. Repair occurs only at the accountable source under separate authority,
followed by downstream revalidation. Supersession links graph, dependency, gap,
exception, evidence and decision digests.

Reject mixed/stale/duplicate identity, missing owner/evidence, cycle, ambiguous
order, private dependency, unsupported version, open gap, invalid exception,
semantic conflict, invalid custody, nondeterminism, self-review, unsafe rollback,
orphan lineage or broken freeze. Governance grants no resolution, validation,
Product or implementation authority.

## Definition Of Done

- Eight-part immutable dependency and ten-class gap models are explicit.
- Deterministic acyclic ordering and ten ownership boundaries are defined.
- Closure, exception and completion dependencies are governed.
- Rollback, repair, supersession and fail-closed rules are explicit.
- Exactly this milestone and MEMORY change; no implementation/protected change.

## Engineering Evidence

- App 965/965, Knowledge 75/75 and protected M3-M21 freezes 72/72 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated health restored; exact two-file scope and clean diff confirmed.
