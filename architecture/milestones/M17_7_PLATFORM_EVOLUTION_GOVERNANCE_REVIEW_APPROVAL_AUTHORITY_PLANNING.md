# M17.7 Platform Evolution Governance Review & Approval Authority Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define deterministic review, approval, delegation and authority boundaries for
future platform-evolution governance. This is planning only and assigns no
implementation responsibility or authority. Runtime, application, UI, backend,
database, API, CI/CD, deployment, infrastructure, monitoring, AI, Product,
migration and post-M22 work remain prohibited.

## Authority And Compatibility

Constitution v1.4.0, M16 Foundation Freeze and accepted M17.0-M17.6 are
protected. M17.3 supplies the authority hierarchy; M17.5 supplies audit
continuity; M17.6 supplies decision states and transitions. Review/approval
records append to that lifecycle and cannot reinterpret it.

## Canonical Roles

| Role | Responsibility | Cannot do |
|---|---|---|
| Proposal Author | Define objective, scope, identities and initial evidence | Approve or independently verify own proposal |
| Technical Reviewer | Assess feasibility, failure modes and testable evidence | Decide architecture or PO authority |
| Architecture Reviewer | Assess boundaries, freeze, contracts and compatibility | Own domain semantics or final PO acceptance |
| Product Owner | Authorize planning scope and accept/reject milestone outcomes | Delegate constitutional or semantic ownership |
| Repository Authority | Verify exact scope, commit/push identity and closure | Convert repository access into semantic approval |
| Independent Reviewer | Verify evidence without producing the reviewed claim | Self-review or change the proposal |
| Final Approval Authority | Record the required decision after all gates | Approve with missing/stale/conflicting evidence |

One actor may hold multiple roles only where the approval matrix does not require
separation. Role identity, assignment, scope and effective/expiry times are
explicit.

## Approval Matrix

| Decision | Required review | Required approval | Independent review | Blocks approval |
|---|---|---|---|---|
| Planning/documentation | Technical or Architecture as affected | Product Owner | Optional unless freeze claim | Scope ambiguity, unauthorized files |
| Compatible contract evolution | Technical, Architecture, producer and consumer owners | Product Owner plus semantic owner | Required for freeze/compatibility proof | Missing matrix, negative failure, owner conflict |
| Deprecation/removal | Producer/consumer owners, Architecture, migration owner | Product Owner and semantic owner | Required | Active unresolved consumers, expired evidence |
| Implementation behind public port | Technical, Architecture, Security/Privacy as affected | Product Owner scope and implementation owner | Required for protected evidence | Boundary drift, missing rollback |
| Breaking/invariant change | All affected owners and Architecture Council | Constitutional authority plus Product Owner | Mandatory | Missing amendment/migration or freeze conflict |
| Repository closure | Quality/Architecture evidence and repository audit | Product Owner acceptance, Repository Authority records | Independent evidence where required above | Failed tests, scope drift, no push identity |

Consultation never substitutes for a required review or approval. Approval order
is semantic/architecture authority, independent evidence, Product Owner
decision, then repository closure.

## Delegation Boundaries

- Delegable: evidence collection, technical review, repository recording and
  time-bounded operational review within a named scope.
- Non-transferable: constitutional amendment authority, domain semantic
  ownership, Product Owner acceptance and independent verification of one's
  own claim.
- Delegation records delegator/delegate, role, exact scope, start/expiry,
  constraints and revocation identity.
- Delegation cannot exceed the delegator's authority or survive expiry,
  revocation, supersession or material scope change.
- Temporary delegation creates no permanent role or precedent.

## Separation Of Duties

Proposal authors cannot be sole reviewers; evidence producers cannot be sole
independent verifiers; implementation owners cannot grant final acceptance;
Repository Authority cannot infer PO approval; and AI/tooling cannot hold an
approval role. A required independent reviewer has no authorship,
implementation, provider or approval conflict for the assessed claim.

## Deterministic Review Lifecycle

```text
pending -> inReview -> evidenceDeferred -> inReview
                  -> complete
                  -> rejected
                  -> superseded
                  -> closed
```

| Transition | Authority | Required record |
|---|---|---|
| none -> pending | Proposal Author/change authority | Proposal/revision and reviewer requirements |
| pending -> inReview | Review coordinator | Assigned eligible reviewers and current evidence |
| inReview -> evidenceDeferred | Any required reviewer | Exact gap, owner and acceptance rule |
| evidenceDeferred -> inReview | Review coordinator | Compatible evidence response |
| inReview -> complete | All required reviewers | Signed findings with no unresolved blocker |
| pending/inReview/evidenceDeferred -> rejected | Final Approval Authority | Reasons and retained evidence |
| pending/inReview/evidenceDeferred/complete -> superseded | Product Owner | Successor identity and lineage |
| complete -> closed | Product Owner plus Repository Authority | Approval, commit and push identities |

Unlisted transitions are illegal. Terminal `rejected`, `superseded` and
`closed` reviews are immutable; re-review creates a linked revision.

## Approval Record And Invariants

Each append-only review/approval record binds proposal/revision, M17.6 state,
role/actor/authority assignment, delegation if any, evidence digests,
findings/decision, predecessor digest, affected freeze/contracts, time/currency,
successor and canonical digest.

1. Same ordered records replay to the same review state and digest.
2. Every required role is unique, eligible and current.
3. Approval cannot precede required reviews/evidence.
4. A scope/evidence identity change invalidates stale approvals.
5. Terminal and superseded records cannot receive approval.
6. No circular delegation or approval dependency is allowed.
7. Repository closure follows PO acceptance, never precedes it.
8. M16 and M17.0-M17.6 guarantees remain transitive.

## Failure Model

Fail closed on missing/ineligible reviewer, missing approval, invalid/expired
delegation, authority conflict, separation-of-duties violation, circular
approval, approval after supersession/terminal state, stale/mixed evidence,
wrong proposal binding, incomplete lineage, boundary/freeze conflict or
non-deterministic replay. No quorum inference, implicit consent or timeout
approval exists.

## Completion Semantics

- Pending: required review has not begun or evidence remains deferred.
- Complete: all required reviewers finished without blockers; not yet approved
  or repository-closed.
- Rejected: final denial with retained reasons/evidence.
- Superseded: immutable record linked to a successor revision.
- Permanently closed: accepted decision plus verified commit/push; any later
  change starts a new governance item.

## Definition Of Done

- Seven roles, six approval decision classes and authority boundaries are clear.
- Delegation, expiry/revocation and separation of duties are explicit.
- Eight legal review transitions are deterministic and append-only.
- Eight approval invariants and fail-closed cases preserve M16/M17.0-M17.6.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, accepted semantic, Product or post-M22 scope changes.
- Architecture Fitness, generated/protected artifacts and clean diff verified.

## Engineering Evidence

- Planning defines seven roles, six approval classes, eight review transitions
  and eight invariants.
- Full app regression: 945/945.
- Knowledge package regression: 75/75.
- Protected M3-M16 freeze regression: 52/52.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Generated health restored; exact two-file scope confirmed.

Product Owner accepted and closed M17.7 on 2026-07-22 and authorized repository
closure.
