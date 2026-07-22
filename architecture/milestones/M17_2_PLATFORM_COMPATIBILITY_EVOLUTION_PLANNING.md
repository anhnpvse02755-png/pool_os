# M17.2 Platform Compatibility Evolution Planning

**Status:** Accepted; Closed  
**Date:** 2026-07-22

## Objective

Define compatibility governance for platform evolution from the accepted M16
Foundation Freeze through M22. M17.2 is planning only. It introduces no runtime
contract, adapter, implementation, migration, infrastructure, UI, AI execution
or Product behavior.

## Authority And Protected Baseline

- Constitution v1.4.0 remains normative authority.
- Accepted M17.0 sequencing and M17.1 identity continuity govern this plan.
- All accepted M3-M16 freezes are protected compatibility roots.
- Contract/domain owners decide semantic compatibility; Architecture verifies
  cross-boundary consistency and evidence.

No operational observation, provider behavior or generated artifact can amend
a contract by accident.

## Compatibility Policy

Compatibility is an explicit, version-bound claim between an exact producer
identity, consumer identity and contract version. It is never inferred from a
successful build, permissive parser, matching field names or provider fallback.

| Change class | Backward compatibility | Forward compatibility | Required gate |
|---|---|---|---|
| No semantic change | Required | Required | Normalized identity replay |
| Additive optional element | Required with defined absence/default semantics | Allowed only for consumers that ignore it without semantic loss | Owner matrix and negative tests |
| Additive capability | Existing flows remain unchanged | Older consumers reject requests requiring it | Capability negotiation evidence |
| Deprecation | Preserved during owned window | Replacement must not be assumed | Usage, migration and expiry evidence |
| Canonical/digest evolution | Dual verification or explicit adapter required | Not implicit | Versioned canonicalization proof |
| Required/semantic breaking change | Not compatible without amendment/migration | Not compatible | Constitutional and PO authority |

Compatibility claims retain semantic IDs, versions, provenance, canonical
ordering and digest rules established by M17.1.

## Backward-Compatibility Governance

1. A newer producer preserves all accepted meanings and required behaviors of
   the declared older contract within its compatibility window.
2. New optional data has deterministic absence and default semantics.
3. Existing consumers cannot be forced to understand a new capability.
4. Adapters/upcasters are explicit, versioned, owned and evidence-bound; they
   cannot invent Evidence or domain meaning.
5. Removal or changed meaning is breaking even when source compilation passes.

## Forward-Compatibility Governance

1. Older producers may serve newer consumers only when the consumer declares
   the older version sufficient for the requested capability.
2. Unknown required fields, capabilities or semantic versions fail closed.
3. Ignoring unknown optional data is allowed only where the owning contract
   explicitly declares it semantically safe.
4. A consumer cannot synthesize missing provenance, Evidence, Knowledge or
   Decision Trace data.
5. Provider fallback cannot transform incompatibility into compatibility.

## Deprecation Lifecycle

```text
proposed -> announced -> migrationAvailable -> usageVerified
         -> removalAuthorized -> removed
```

- The contract owner names replacement, affected consumers, window, evidence
  and rollback authority before announcement.
- Deprecation does not change semantic identity or permit silent aliasing.
- Removal requires verified consumer migration, zero unresolved critical use,
  protected replay evidence and explicit Product Owner authorization.
- A missed gate extends the window or cancels removal; it never auto-approves.
- Removed identities remain reserved and auditable.

## Compatibility Evidence Model

Every claim binds:

- exact M16 freeze and predecessor identities;
- producer, consumer, contract and capability versions;
- canonicalization/digest versions;
- compatibility direction and declared window;
- positive replay and deterministic output evidence;
- negative stale/mixed/unknown/duplicate/expired cases;
- adapter/upcaster identity where present;
- owner, reviewer, tool/rule version and authorization;
- rollback/supersession identity and retained failure evidence.

Evidence is immutable or append-only/superseding. A current pass cannot erase a
past incompatibility or exception.

## Ownership

| Concern | Accountable owner |
|---|---|
| Semantic compatibility | Contract/domain owner |
| Cross-domain dependency direction | Architecture |
| Adapter/upcaster behavior | Producing owner with consuming-owner review |
| Test and evidence integrity | Quality/Architecture |
| Security/privacy impact | Security/Privacy and data owner |
| Deprecation/removal authority | Product Owner after owner evidence |

Infrastructure may implement an accepted mechanism later, but cannot declare
semantic compatibility or widen access.

## Verification Strategy

Future executable scopes must cover a producer/consumer/version compatibility
matrix, canonical replay, collection-order invariance, optional absence/default
semantics, capability negotiation, deprecation boundary dates and negative
mixed/stale/duplicate/unknown/expired inputs. Full app, Knowledge, protected
freezes, Architecture Fitness, generated/protected checks and exact diff remain
mandatory.

## Rollback And Supersession

- Record last-known-good producer, consumer, contract and freeze identities
  before change.
- Reject or disable an incompatible candidate while retaining its evidence.
- Roll back to an accepted compatible identity only when immutable history and
  current data remain valid; otherwise use owner-approved forward repair.
- Superseding compatibility decisions append a new decision and never rewrite
  prior evidence or shorten a declared window retroactively.
- An exception is named, risk-owned, time-bounded and cannot survive M21
  stabilization without explicit amendment.

## Fail-Closed Gates

Reject a compatibility claim when identity/provenance is missing or mixed,
ownership is unresolved, direction is ambiguous, a required capability is
unknown, canonical replay differs, deprecation is expired, negative evidence
fails, rollback is undefined, protected freezes drift, or authority is absent.
There is no best-effort parsing or silent fallback.

## Definition Of Done

- Backward and forward compatibility policies are explicit.
- Deprecation lifecycle, evidence model, ownership and verification are defined.
- Rollback, supersession and fail-closed gates preserve M3-M16 freezes.
- Exactly this milestone and `MEMORY.md` change.
- No production/runtime source, runtime contract, additional ADR/planning file,
  frozen/generated artifact or Product behavior changes.
- Full app, Knowledge, protected freeze, Architecture Fitness and clean-diff
  evidence are recorded after verification.

## Engineering Evidence

- Compatibility planning defines six change classes, six deprecation states
  and six accountable ownership concerns.
- Full app regression: 945/945.
- Knowledge package regression: 75/75.
- Protected M3-M16 freeze regression: 52/52.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Exactly two authorized planning artifacts change; generated architecture
  health was restored to its protected baseline.

Product Owner accepted and closed M17.2 on 2026-07-22 and authorized repository
closure.
