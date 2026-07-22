# M17.8 Platform Evolution Governance Decision Package & Traceability Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define the canonical governance decision package and deterministic end-to-end
traceability model for future platform evolution. M17.8 is planning only. It
changes no runtime, application, UI, backend, database, API, CI/CD, deployment,
infrastructure, monitoring, AI, Product, migration, accepted governance
semantics or post-M22 planning.

## Authority And Compatibility

Constitution v1.4.0, M16 Foundation Freeze and accepted M17.0-M17.7 remain
protected. The package references M17.5 evidence, M17.6 lifecycle and M17.7
review/approval records by stable identity/digest; it does not duplicate or
reinterpret them.

## Canonical Decision Package

Every package contains these required sections:

| Section | Required content |
|---|---|
| Identity | Package schema/version, decision/proposal/revision IDs and canonical digest |
| Classification | Impact class, decision type, owning boundary and affected domains/contracts |
| Authority | Constitution/ADR/milestone references, owners, delegations and expiry |
| Scope | Exact files/effects, explicit prohibitions and predecessor/freeze identity |
| Evidence | Immutable evidence IDs/digests, tool/rule versions, positive/negative results |
| Review | Required roles, findings, independence and M17.7 record lineage |
| Approval | Decision authority, result, reasons, evidence currency and approval digest |
| Compatibility | Producer/consumer/version assertions, windows, exceptions and rollback |
| Supersession | Predecessor/successor IDs, reasons and non-destructive lineage |
| Closure | Acceptance, commit, branch, push, protected verification and retained status |

Collections use declared canonical ordering. Package digest excludes mutable
display/transport metadata and includes every semantic section.

## Traceability Graph

```text
proposal -> evidence -> reviews -> approvals -> governance state
         -> repository authority -> accepted milestone -> closure
         -> superseding decision (when present)
```

| Edge | Required binding |
|---|---|
| Proposal -> Evidence | Proposal/revision ID and evidence purpose |
| Evidence -> Review | Exact evidence digest and reviewer role |
| Review -> Approval | Complete required review set and current evidence identity |
| Approval -> Governance state | Legal M17.6 transition and approval authority |
| State -> Repository authority | Exact approved scope and predecessor digest |
| Repository -> Milestone | Commit/push identity and PO acceptance |
| Milestone -> Closure | Accepted status and protected verification |
| Decision -> Successor | Explicit supersession identity/reason; predecessor remains immutable |

All edges are explicit, directed and acyclic within one package revision. Same
canonical records reconstruct the same graph, package state and digest.

## Traceability Invariants

1. One authoritative lineage exists for each decision revision.
2. Every decision has a proposal root and no orphan evidence/review/approval.
3. Predecessor and successor links are reciprocal and never rewritten.
4. Semantic decision IDs are stable, unique and never recycled.
5. Historical references use immutable IDs/digests, not paths/display names.
6. Review/approval evidence is current for the exact package revision.
7. Closure follows legal lifecycle, PO acceptance, commit and push.
8. Replay is deterministic under versioned canonical ordering.
9. M16 and M17.0-M17.7 remain transitive protected roots.

## Package Validation

Validation fails closed on missing required section/field, duplicate package or
semantic ID, invalid authority/delegation, unauthorized scope, missing/stale or
mixed evidence, incomplete required reviews, approval before review, illegal
governance state, broken/circular lineage, invalid supersession, inconsistent
freeze/compatibility, absent rollback, closure without acceptance/commit/push,
or digest/replay mismatch. No default authority, best-effort trace or provider
fallback exists.

## Package Lifecycle

| State | Criteria |
|---|---|
| `draft` | Unique identity, proposal root and owner; incomplete package allowed |
| `reviewable` | All required sections except final review/approval/closure are valid |
| `approved` | Required reviews complete, current evidence valid and authority recorded |
| `archived` | Abandoned/duplicate/obsolete package retained with reason |
| `superseded` | Immutable package linked to a valid successor revision |
| `permanentlyRetained` | Terminal lifecycle and retention classification fixed; references remain resolvable |

Transitions append records; states are replay projections. A terminal package
cannot be edited or reopened. Correction creates a linked revision.

## Retention And Archival

- Active/draft packages remain with their accountable owner until terminal.
- Approved/closed, rejected, superseded and exception-bearing packages receive
  permanent governance retention unless law/privacy requires attributable
  redaction or restricted access.
- Archival changes availability class, never semantic identity/digest.
- Indexes preserve references and verify targets; they do not copy normative
  content or domain truth.
- Redaction, custody transfer, recovery and destruction attempts append audit
  records and preserve allowable lineage.
- Historical packages remain readable under their versioned schema or explicit
  non-semantic reader/upcast plan.

## Verification Strategy

Future executable scopes prove required/optional fields, canonical package
digest, reordered canonical collections, graph reconstruction, no orphan/cycle,
valid lifecycle and positive closure. Negative tests cover every fail-closed
validation category, terminal mutation, stale approval, invalid supersession
and missing retained reference. Full app, Knowledge, protected freezes,
Architecture Fitness, generated/protected integrity and clean diff remain
mandatory.

## Definition Of Done

- Ten package sections and eight trace edges are explicit.
- Nine traceability invariants preserve one replayable authoritative lineage.
- Validation is fail-closed and six package states have unambiguous criteria.
- Retention, archival, redaction, custody and historical access are planned.
- M16 and M17.0-M17.7 compatibility and append-only governance remain intact.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, accepted semantic, Product or post-M22 changes.
- Architecture Fitness, generated/protected artifacts and clean diff verified.

## Engineering Evidence

- Planning defines ten package sections, eight trace edges, nine invariants and
  six package states.
- Full app regression: 945/945.
- Knowledge package regression: 75/75.
- Protected M3-M16 freeze regression: 52/52.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Generated health restored; exact two-file scope confirmed.

Product Owner accepted and closed M17.8 on 2026-07-22 and authorized repository
closure.
