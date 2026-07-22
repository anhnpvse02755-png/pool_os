# M18.2 Platform Integration Compatibility & Interface Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define compatibility and public-interface evolution governance for future
platform integration. M18.2 is planning only. It introduces no runtime
contract, implementation detail, Flutter, infrastructure, networking,
persistence, AI execution, CI/CD, deployment, monitoring, ADR, Product
functionality or frozen-artifact change.

## Authority And Identity Root

Constitution v1.4.0, M17 Foundation Freeze, accepted M18.0 and M18.1 identity/
boundary governance are protected. Compatibility claims bind the exact M18.1
candidate, boundary, producer, consumer, contract and capability identities.
Contract/domain owners decide semantic compatibility; Architecture assures
cross-boundary consistency; PO authorizes future implementation and acceptance.

## Compatibility Dimensions

| Dimension | Required claim | Fail-closed condition |
|---|---|---|
| Contract version | Producer output and consumer requirement are explicitly compatible | Unsupported/missing/mixed version |
| Capability | Required capability exists with matching semantics | Unknown required or provider-only capability |
| Schema/shape | Required fields, optional absence/default and constraints agree | Missing required or ambiguous default |
| Canonicalization | Ordering, encoding and digest versions match or use authorized bridge | Replay/digest mismatch |
| Provenance | Source, producer, policy/tool and input identities remain complete | Stale/mixed/unowned lineage |
| Lifecycle | Active/deprecated/expired interfaces and windows are valid | Removed/expired interface use |
| Failure semantics | Error/denial/partial-result meaning is understood by consumer | Silent coercion or best-effort fallback |
| Security/privacy | Data class, purpose, access, retention and redaction agree | Unauthorized exposure or widened purpose |
| Determinism | Same canonical inputs produce same structural result/digest | Nondeterministic compatibility result |

## Interface Evolution Classes

| Class | Governance | Compatibility |
|---|---|---|
| No semantic change | Preserve ID/version meaning and replay | Backward and forward compatible |
| Additive optional field | Define deterministic absence/default; old flow unchanged | Backward compatible; forward only when safe-to-ignore is declared |
| Additive capability | Negotiate explicitly; existing capability unchanged | Old consumer rejects requests requiring it |
| Constraint tightening | New version and consumer impact evidence | Breaking unless all accepted inputs remain valid |
| Deprecation | Owner, replacement, window, migration evidence and expiry | Compatible only within window |
| Canonical/digest change | New version and dual replay/bridge evidence | Never implicit |
| Required/meaning change | Amendment, migration and new identity/proof | Breaking |
| Provider replacement | Preserve public semantics; bind new implementation identity | Compatible only after conformance evidence |

Source compilation, permissive parsing, matching field names and successful
provider calls never prove semantic compatibility.

## Interface Ownership

| Responsibility | Accountable owner |
|---|---|
| Interface semantic ID/version and output meaning | Producer/contract owner |
| Required capabilities and rejection policy | Consumer owner |
| Dependency direction and private-boundary protection | Architecture |
| Adapter/upcaster behavior | Producer owner with consumer review |
| Compatibility evidence and negative cases | Quality plus both owners |
| Data/security/privacy compatibility | Security/Privacy and data owners |
| Deprecation/removal and final acceptance | Semantic owner and Product Owner |

Infrastructure/provider implements only a separately accepted mechanism and
cannot declare compatibility, invent defaults or widen an interface.

## Deterministic Compatibility Verification

For an exact producer/consumer/boundary identity, verification canonicalizes
contract versions, capabilities, schema/default rules, provenance, lifecycle
window, failure and data policies. It emits `compatible` only when every
required dimension passes; otherwise `incompatible` with stable finding IDs.
Same input set and rule version produce the same ordered findings and digest.
There is no partial score or automatic fallback.

## Evidence Requirements

Each claim retains M17 freeze/M18 candidate, boundary/interface, producer/
consumer versions, capability/schema/canonical rules, lifecycle window,
positive replay, negative unsupported/missing/mixed/stale/expired cases,
security/privacy review, adapter identity if any, owner/reviewer/authority,
rollback/successor and deterministic report digest. Evidence is append-only or
superseding; failed claims remain auditable.

## Rollback, Supersession And Forward Repair

- Record last-known-good compatible producer/consumer/interface set.
- Reject/disable incompatible candidate and retain the complete attempt.
- Rollback restores only a verified compatible identity and never rewrites
  domain, Evidence, Knowledge publication, audit or freeze history.
- If state cannot safely roll back, owners authorize a versioned forward repair
  with input/output lineage and independent verification.
- Supersession links immutable decisions and restarts assessment on identity,
  capability, scope, evidence or window change.

## Fail-Closed Gates

Reject on missing/duplicate/ambiguous identity, unknown interface owner, private
surface, wrong direction, unsupported version/capability, unclear optional
semantics, canonical mismatch, stale/mixed provenance, expired deprecation,
unknown failure meaning, security/privacy conflict, invalid bridge/rollback,
unresolved negative finding or absent PO authority. Timeout/silence is not
approval.

## Product Owner Acceptance Gates

Future implementation requires accepted predecessors, exact file/effect scope,
current compatibility report, owner approvals, positive/negative evidence,
adapter/upcaster and migration identity where used, rollback/forward repair,
protected freeze integrity, Architecture Fitness 0 new, clean diff and explicit
PO acceptance before commit/push. Planning does not grant execution.

## Definition Of Done

- Nine compatibility dimensions and eight evolution classes are explicit.
- Seven interface ownership responsibilities preserve semantics and boundaries.
- Deterministic verification and evidence expectations are defined.
- Rollback, supersession, forward repair and fail-closed PO gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No implementation/runtime contract, ADR, Product or frozen-artifact change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines nine compatibility dimensions, eight evolution classes and
  seven ownership responsibilities.
- Full app regression: 949/949.
- Knowledge package regression: 75/75.
- Protected M3-M17 freeze regression: 56/56.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Generated health restored; exact two-file scope confirmed.

Product Owner accepted and closed M18.2 on 2026-07-22 and authorized repository
closure.
