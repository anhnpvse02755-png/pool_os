# M18.3 Platform Integration Evidence & Verification Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define canonical evidence, custody and deterministic verification governance for
future platform integration. M18.3 is planning only. It introduces no runtime
contract, implementation detail, Flutter, infrastructure, networking,
persistence, AI execution, CI/CD, deployment, monitoring, ADR, Product
functionality or frozen-artifact change.

## Authority And Evidence Roots

Constitution v1.4.0, M17 Foundation Freeze and accepted M18.0-M18.2 identities,
boundaries and compatibility semantics are protected inputs. Evidence proves an
exact integration claim; it cannot amend authority, invent domain truth or make
an implementation/PO decision. Evidence Domain owns facts, source owners own
their records, Quality/Architecture verifies, and Product Owner accepts.

## Canonical Integration Evidence Model

| Evidence class | Required binding | Accountable custodian |
|---|---|---|
| Candidate identity | M17 freeze, M18 candidate/source, scope and authorization | Architecture/Platform |
| Boundary conformance | Producer, consumer, public port, direction and private-edge denial | Architecture |
| Contract compatibility | Interface versions/capabilities, canonicalization and M18.2 report | Contract owners/Quality |
| Positive flow | Canonical inputs, ordered steps, outputs/digests and expected semantics | Integration owner |
| Negative/failure | Rejected mixed/stale/missing/duplicate/unauthorized cases and reasons | Quality/source owners |
| Provenance lineage | Source/input/producer/tool/policy/provider and output identities | Producing owner |
| Security/privacy | Data class, purpose/access, minimization, consent/retention/redaction | Security/Privacy/data owner |
| Recovery/repair | Failure, last-known-good, rollback/forward repair and validation | Integration/domain owners |
| Review/acceptance | Independent findings, exceptions, PO decision and repository identity | Independent reviewer/PO |

## Evidence Envelope

Every record includes evidence schema/version and semantic ID, candidate/freeze,
boundary/flow/contract/capability, source/input/output digests, canonical order,
producer/tool/rule/policy/provider versions, owner/custodian/authority,
observation/result including denial/failure, time/currency semantics,
compatibility, security/privacy classification, predecessor/successor,
retention/redaction and canonical evidence digest.

Mutable display labels, secrets and raw domain/Evidence data unnecessary to the
boundary are excluded. Missing, duplicate, mixed, stale, contradictory or
unowned fields fail closed.

## Positive And Negative Verification

Positive evidence proves allowed boundary, exact compatible versions,
deterministic canonical flow and expected structural result. It never proves
all invalid cases are rejected. Negative evidence independently covers private
edge, wrong direction, unknown capability, missing required field, canonical
mismatch, mixed/stale provenance, duplicate semantic ID, expired window,
unauthorized data/access, partial failure, invalid rollback and missing PO
authority. Both sets are required for acceptance.

## Cross-Domain Evidence Correlation

Correlation uses immutable IDs/digests, not copied domain internals:

```text
candidate -> boundary -> producer input/output -> consumer result
          -> compatibility report -> failure/recovery evidence
          -> independent review -> PO decision -> repository closure
```

Each edge declares source owner, relationship meaning and canonical order.
Correlation does not turn Intelligence inference into Evidence facts, generated
Knowledge into authoring truth, Simulation into strategy, or UI into semantic
owner. Orphan, circular or contradictory edges block verification.

## Deterministic Verification And Replay

For the same canonical evidence set and rule versions, verification emits the
same ordered finding IDs, `pass`/`fail` status, reconstructed lineage and digest.
Rules cover envelope completeness, hash/reference resolution, boundary graph,
compatibility, positive/negative cases, authority, retention and repair. There
is no score threshold, warning-only success, provider fallback or mutable
latest-record lookup.

## Evidence Lifecycle And Retention

```text
planned -> collected -> validated -> reviewed -> accepted
        -> superseded/archived -> retained
```

- Collection never implies validation; validation never implies PO acceptance.
- Correction appends a superseding record and preserves the original.
- Failed, denied, rolled-back and exception evidence remains discoverable.
- Retention/access/redaction follow purpose, law/privacy and owner policy while
  preserving attributable lineage.
- Custody transfer records old/new custodians, scope and effective time.
- Lost/corrupt evidence invalidates dependent claims until verified recovery or
  owner-approved forward repair is recorded.

## Independent Verification Authority

The independent verifier cannot be the sole author, implementation owner,
provider, evidence producer or final PO authority for the reviewed claim.
Assignment/delegation is explicit, scoped and current. The verifier can record
findings/pass/fail but cannot modify evidence, waive failures, approve Product
scope or self-publish AI/tool output.

## Rollback, Supersession And Forward-Repair Evidence

Rollback evidence binds failed/current/last-known-good identities, trigger,
authority, attempted actions, domain-history effect, validation and result.
Supersession binds immutable predecessor/successor and reasons. Forward repair
binds the incompatibility, transformed identity, owner authority, input/output
lineage and independent proof. None may rewrite Evidence, Knowledge publication,
audit or freeze history.

## Fail-Closed And PO Gates

Reject verification on incomplete envelope, unresolved identity/digest,
orphan/cycle/conflict, missing negative case, stale compatibility, unowned
custody, invalid independence, expired exception, security/privacy conflict,
unverified rollback/repair, nondeterministic replay or unresolved blocking
finding. Future implementation needs exact scope, complete `pass` evidence,
protected freezes, Architecture Fitness 0 new, clean diff and explicit PO
acceptance before commit/push.

## Definition Of Done

- Nine evidence classes and a complete canonical envelope are explicit.
- Positive/negative verification and cross-domain correlation preserve owners.
- Deterministic replay, lifecycle, retention and independent authority are clear.
- Rollback, supersession, forward-repair evidence and fail-closed PO gates are
  explicit.
- Exactly this milestone and `MEMORY.md` change.
- No implementation/runtime contract, ADR, Product or frozen-artifact change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines nine evidence classes, seven lifecycle states and a
  candidate-to-closure correlation chain.
- Full app regression: 949/949.
- Knowledge package regression: 75/75.
- Protected M3-M17 freeze regression: 56/56.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Generated health restored; exact two-file scope confirmed.

Product Owner accepted and closed M18.3 on 2026-07-22 and authorized repository
closure.
