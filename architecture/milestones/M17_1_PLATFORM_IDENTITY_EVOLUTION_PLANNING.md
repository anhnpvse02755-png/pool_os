# M17.1 Platform Identity Evolution Planning

**Status:** Accepted; Closed  
**Date:** 2026-07-22

## Objective

Plan how platform identity remains continuous and auditable from the accepted
M16 Foundation Freeze through M17-M22. This milestone is planning only. It
defines no new runtime contract and implements no identity, migration,
infrastructure, persistence, networking, AI, UI or Product behavior.

## Authority And Compatibility Root

- Constitution v1.4.0 is the normative authority.
- The accepted M17.0 platform evolution plan supplies program sequencing.
- M16 Foundation Freeze is the immutable identity and compatibility root.
- Accepted M3-M16 freeze manifests and proof records remain transitively
  protected.
- Semantic owners retain authority over their identifiers and versions.

M17.1 belongs to the Architecture Control Plane. It changes no business-domain
model, behavior or cross-domain contract.

## Identity Classes

| Identity class | Continuity requirement | Owner |
|---|---|---|
| Platform freeze | Every candidate cites the exact M16 freeze digest until a later accepted freeze supersedes it | Architecture and Product Owner |
| Source | Source revision and authorized file set remain attributable | Repository/Release owner |
| Public contract | Semantic ID, version and normalized digest remain inseparable | Contract owner |
| Knowledge release | Version, manifest digest and publication provenance remain authoritative | Knowledge |
| Evidence history | Stream/event IDs and correction/supersession lineage remain immutable | Evidence |
| Intelligence output | Input identities, policy/model versions, trace and digest remain bound | Intelligence |
| Simulation result | Request/result and engine/model identities remain bound | Simulation |
| Experience projection | Source projection versions and digests remain attributable | Experience |
| Provider/extension | Provider-neutral capability ID and implementation identity remain distinct | Platform and capability owner |
| Verification evidence | Candidate, tool/rule version, input set and result identity remain bound | Quality/Architecture |

No class in this plan replaces an existing contract or grants a consumer access
to an owner's internal state.

## Identity Continuity Strategy

1. Every M17-M22 artifact cites its accepted predecessor and the exact M16
   Foundation Freeze identity.
2. Existing semantic IDs are never recycled, repurposed or inferred from
   display names, paths or provider identifiers.
3. Canonical serialization and normalized digest rules remain version-bound;
   changing a canonicalization rule creates an explicitly versioned identity.
4. Derived identities retain the complete ordered input identity set and the
   producing contract/policy/tool version.
5. Generated or deployed artifacts remain evidence of implementation reality,
   never normative identity authorities.
6. Missing, duplicate, mixed, stale, ambiguous or unowned identity bindings
   fail closed.

## Version Evolution Policy

| Change | Required treatment | Compatibility result |
|---|---|---|
| Documentation-only, no semantic effect | Preserve contract version and digest rules | Compatible |
| Additive optional field/capability | Owner-approved compatible version with canonical default/absence semantics | Compatible within declared window |
| Deprecation | Preserve old identity through a dated, owned compatibility window | Compatible until explicit expiry |
| Canonicalization or digest-rule change | New version plus dual verification/migration evidence | Not implicitly compatible |
| Required field or semantic meaning change | Constitutional/contract amendment and migration plan | Breaking; fail closed without authority |
| Provider implementation replacement | Preserve provider-neutral capability identity; bind new implementation identity | Compatible only after conformance proof |

Versions identify semantics, not deployment freshness. A higher version cannot
silently override owner approval, provenance or compatibility evidence.

## Ownership Evolution

- Identity ownership moves only through an accepted governance decision naming
  the old owner, new owner, effective boundary and retained audit history.
- A receiving owner cannot rewrite historical IDs or provenance.
- Architecture validates ownership boundaries but does not become owner of
  domain semantics.
- Infrastructure may issue implementation/artifact identities but cannot issue
  Knowledge, Evidence, Intelligence, Simulation or Experience semantic IDs.
- Delegated authority is explicit, scoped, revocable and never inferred from
  repository access or operational control.

## Provenance Evolution

Every evolved identity retains:

- predecessor and compatibility-root identities;
- semantic ID and contract/schema version;
- normalized digest and canonicalization version;
- producer/tool/policy/model identity where applicable;
- owner and authorizing decision;
- input identity set and ordering rule;
- creation/effective time semantics where time is meaningful;
- supersession or deprecation status without destructive replacement.

Provenance additions must be compatible and must not expose secrets, raw
Evidence or internal compiler/runtime objects across boundaries.

## Evidence Evolution

Future identity-evolution evidence must include positive replay, negative
mixed/stale/duplicate/unknown-owner cases, compatibility-window boundaries,
canonical ordering, predecessor linkage, owner authorization and exact source
identity. Evidence is append-only or superseding; a later pass cannot erase an
earlier failure. Documentation records intent but executable proof establishes
implementation maturity.

## Rollback And Supersession Planning

1. Before evolution, record the last-known-good identity and compatibility
   window.
2. A rejected candidate is discarded while its attempt and failure evidence
   remain attributable.
3. Rollback restores use of a compatible prior identity; it never rewrites
   Knowledge publication, Evidence, audit or freeze history.
4. When rollback cannot preserve semantics, use an owner-approved forward
   repair or versioned upcast and retain both lineage identities.
5. An accepted freeze or governance decision is superseded only by a new
   explicit Product Owner decision with its own identity and proof.

## Acceptance Gates

Any future identity evolution fails closed unless:

- predecessor and M16 freeze identities are exact and verified;
- the semantic owner and authorizing authority are named;
- version and compatibility impact are explicit;
- canonicalization, digest, provenance and replay rules are testable;
- mixed, stale, duplicate and unowned cases are rejected;
- rollback or forward repair preserves immutable history;
- security/privacy exposure is reviewed;
- protected freezes and Architecture Fitness remain intact;
- Product Owner acceptance precedes repository closure.

## Definition Of Done

- Identity continuity from M16 Freeze through M22 is explicit.
- Version, ownership, provenance and evidence evolution rules are defined.
- Rollback, supersession, failure semantics and acceptance gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No production/runtime source, new contract, additional ADR/planning artifact,
  frozen/generated artifact or Product behavior changes.
- Full app, Knowledge, protected freeze, Architecture Fitness and clean-diff
  evidence are recorded after verification.

## Engineering Evidence

- Identity planning covers ten identity classes and six fail-closed continuity
  rules rooted in the accepted M16 Foundation Freeze.
- Full app regression: 945/945.
- Knowledge package regression: 75/75.
- Protected M3-M16 freeze regression: 52/52.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Exactly two authorized planning artifacts change; generated architecture
  health was restored to its protected baseline.

Product Owner accepted and closed M17.1 on 2026-07-22 and authorized commit and
push with no additional repository modifications.
