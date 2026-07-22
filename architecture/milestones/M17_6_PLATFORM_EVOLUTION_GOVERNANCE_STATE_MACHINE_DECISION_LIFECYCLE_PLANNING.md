# M17.6 Platform Evolution Governance State Machine & Decision Lifecycle Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define the deterministic, append-only governance lifecycle used to control
future platform-evolution decisions. M17.6 is planning only. It introduces no
runtime, application, UI, backend, database, API, schema, CI/CD, deployment,
infrastructure, monitoring, AI, Product, migration or generated implementation.

## Authority And Compatibility

Constitution v1.4.0, M16 Foundation Freeze and accepted M17.0-M17.5 remain
authoritative and protected. M17.1 supplies identity continuity, M17.2
compatibility, M17.3 authority/change governance, M17.4 boundary assurance and
M17.5 evidence/audit continuity. This plan changes none of them.

## Canonical States

| State | Meaning | Active? | Terminal? |
|---|---|---:|---:|
| `proposed` | Identified request with immutable proposal identity and owner | Yes | No |
| `underReview` | Scope, authority, ownership, compatibility and freeze impact are being assessed | Yes | No |
| `evidenceRequested` | Review is paused pending named, testable evidence | Yes | No |
| `approved` | Exact scope/effects are authorized but not yet repository-closed | Yes | No |
| `rejected` | Proposal is denied with retained reasons/evidence | No | Yes |
| `superseded` | A newer identified decision replaces this item without rewriting it | No | Yes |
| `archived` | Inactive record retained after abandonment/obsolescence | No | Yes |
| `closed` | Authorized work is verified, PO accepted, committed and pushed | No | Yes |

Only one current active revision may exist for the same semantic proposal ID.
Terminal records are immutable and receive no further transitions.

## Legal Transition Table

| From | To | Authority | Required evidence |
|---|---|---|---|
| none | `proposed` | Request owner | Objective, semantic ID, owner, source and affected area |
| `proposed` | `underReview` | Architecture/change authority | Complete intake and classification |
| `proposed` | `rejected` | Accountable decision authority | Named reasons and impact evidence |
| `proposed` | `archived` | Request owner plus custodian | Abandonment/duplicate/obsolete reason |
| `underReview` | `evidenceRequested` | Reviewer | Exact evidence gap, owner and acceptance criterion |
| `underReview` | `approved` | Product Owner after required owners | Scope, compatibility, freeze, rollback and verification plan |
| `underReview` | `rejected` | Product Owner or governing authority | Reasons, conflicts and retained review evidence |
| `underReview` | `superseded` | Product Owner | Successor identity and non-destructive lineage |
| `evidenceRequested` | `underReview` | Reviewer | Complete compatible evidence response |
| `evidenceRequested` | `rejected` | Product Owner/reviewer authority | Failed, stale or impossible evidence result |
| `evidenceRequested` | `archived` | Product Owner plus custodian | Abandonment/expiry with retained gap |
| `approved` | `closed` | Product Owner plus repository authority | Verification, acceptance, commit and push identities |
| `approved` | `rejected` | Product Owner | Newly discovered blocking evidence before closure |
| `approved` | `superseded` | Product Owner | New authorized successor and lineage |

Every other transition is prohibited. Reopening a terminal item creates a new
proposal/revision identity linked to the terminal predecessor.

## Transition Record

Each append-only transition binds transition ID/version, proposal and revision
IDs, from/to states, predecessor transition digest, actor and delegated
authority, decision time semantics, exact evidence IDs/digests, reasons,
affected freeze/contracts, successor identity where applicable and canonical
transition digest. Same ordered transition history must replay to the same
state, lineage and digest.

## Entry, Exit And Failure Criteria

### Proposed

- Entry: unique ID, objective, owner and source.
- Exit: classification and authority are sufficient for review, denial or
  archival.
- Failure: duplicate semantic item, missing owner or forbidden Product scope.

### Under Review

- Entry: complete intake/classification and accepted predecessor identities.
- Exit: evidence gap, approval, rejection or supersession is recorded.
- Failure: ambiguous authority, mixed provenance, freeze/compatibility conflict.

### Evidence Requested

- Entry: named evidence gap, accountable owner and objective acceptance rule.
- Exit: compatible evidence returns to review, or denial/archive is authorized.
- Failure: stale, unverifiable, self-verifying or expired evidence.

### Approved

- Entry: exact files/effects, owners, compatibility, rollback, verification and
  PO authority.
- Exit: repository closure, rejection on new evidence or explicit supersession.
- Failure: scope drift, unauthorized file/effect, protected artifact change.

### Terminal States

- Entry: required decision reason/evidence plus authority; `closed` additionally
  requires acceptance, commit and push.
- Exit: none.
- Failure: mutation, deletion, implicit reopening or missing lineage.

## Transition Invariants

1. History is append-only; states are replay projections, never mutable truth.
2. Every transition binds exact predecessor state/digest and authority.
3. State sequence, evidence ordering and digest canonicalization are versioned.
4. Terminal transitions are final; correction uses a new linked record.
5. Approval is not execution completion; only `closed` proves repository state.
6. Missing, duplicate, stale, mixed or conflicting data fails closed.
7. AI/tool output cannot self-authorize, self-review or self-publish.
8. M16 and M17.0-M17.5 identities remain transitively protected.

## Conflict Resolution

| Conflict | Resolution |
|---|---|
| Competing proposals | Keep separate identities; PO selects, rejects or supersedes explicitly |
| Duplicate semantic proposal | Retain first valid identity; archive duplicate with linkage |
| Conflicting authority | Pause in review/evidence requested; escalate through M17.3 hierarchy |
| Obsolete/abandoned planning | Archive with reason, custodian and evidence |
| Incompatible supersession | Reject successor or require governed amendment/migration |
| Conflicting evidence | Retain both; block approval until authorized resolution appends |

No timestamp, provider priority or repository access breaks a conflict silently.

## Completion Semantics

- Active: `proposed`, `underReview`, `evidenceRequested` or `approved` with no
  later valid transition.
- Completed governance: terminal state with valid replay and evidence lineage.
- Superseded: terminal item with exact successor identity; successor follows its
  own lifecycle.
- Permanently closed: `closed`, `rejected`, `superseded` or `archived`; any new
  work starts a linked revision.

## Failure Model And Verification

Reject lifecycle creation/replay on illegal transition, transition gap, wrong
binding, duplicate ID, reversed/ambiguous ordering, missing approval/evidence,
broken compatibility/freeze chain, incomplete metadata, transition after
terminal or non-canonical digest. Future executable scopes must prove legal and
illegal tables, deterministic replay, order invariance where canonicalized,
lineage and protected regression.

## Definition Of Done

- Eight states and fourteen legal transitions are explicit and deterministic.
- Authority, entry/exit/failure criteria and terminal semantics are complete.
- Six conflict classes and eight invariants preserve append-only audit history.
- Fail-closed behavior preserves M16 and M17.0-M17.5.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, test architecture, accepted artifact, Product or post-M22
  scope changes.
- Architecture Fitness, protected artifacts and clean diff are verified.

## Engineering Evidence

- State graph: eight states, fourteen legal transitions, four active and four
  terminal states.
- Full app regression: 945/945.
- Knowledge package regression: 75/75.
- Protected M3-M16 freeze regression: 52/52.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Generated health restored; exact two-file scope confirmed.

Product Owner accepted and closed M17.6 on 2026-07-22 and authorized repository
closure.
