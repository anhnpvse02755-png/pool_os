# M17.4 Platform Evolution Compatibility & Boundary Assurance Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define how future M17-M22 platform evolution proposals prove compatibility and
boundary preservation before execution. M17.4 is planning only and introduces
no runtime, UI, backend, database, migration, API, infrastructure, deployment,
monitoring, Product or post-M22 work.

## Authority And Inputs

- Constitution v1.4.0 and accepted freezes remain normative/protected.
- M17.1 governs identity continuity.
- M17.2 governs compatibility claims and deprecation.
- M17.3 governs authority, lifecycle, evidence and closure.
- M16 Foundation Freeze remains the exact compatibility root.

Architecture validates boundaries; contract/domain owners retain semantics;
Product Owner authorizes scope and acceptance.

## Assurance Dimensions

| Dimension | Required proof | Failure condition |
|---|---|---|
| Architecture boundary | Public dependency graph and owner review | Private implementation/persistence import or policy leakage |
| Freeze integrity | Exact protected hashes, manifests and proof replay | Direct/transitive drift or identity mismatch |
| Contract compatibility | Producer/consumer/version matrix | Missing, stale, mixed or unowned compatibility claim |
| Semantic continuity | ID, meaning, version, provenance and digest linkage | Recycled ID or silent semantic/canonical change |
| Evidence continuity | Append-only/superseding evidence lineage | Failure deletion, unattributed or self-verifying evidence |
| Repository authority | Exact files/effects and accepted predecessor | Unauthorized file, effect or dependency start |
| Evolution path | Compatibility window, migration/adapter plan and exit | Permanent bridge, fallback or undefined retirement |
| Rollback readiness | Last-known-good identity and validation | History rewrite or unverified restore/forward repair |

## Boundary Assurance Matrix

| Caller | Allowed boundary | Assurance rule |
|---|---|---|
| Experience | Public application ports/projections | No inference, persistence or domain internals |
| Intelligence | Knowledge/Evidence/Simulation public ports | No source-table access or Evidence mutation |
| Simulation | Versioned request/result contracts | No player, Coach, tactic or UI semantics |
| Evidence | Public evidence contracts | Facts remain distinct from inference/decision |
| Knowledge | Published authoring-derived contracts | Generated artifacts never become authoring truth |
| Infrastructure/extensions | Public ports and explicit capabilities | No business policy or semantic ownership |
| AI consumers | Accepted AI session/output boundaries | No direct deterministic internals or self-review |

Any newly proposed edge is denied until its owner, direction, contract,
identity, compatibility and negative evidence are explicit.

## Proposal Assurance Lifecycle

```text
identity -> owner -> boundary -> compatibility -> freezeImpact
         -> evidencePlan -> rollback -> authorization -> verification -> close
```

Each stage binds the same proposal and predecessor identities. A proposal that
changes scope restarts impact review; it cannot reuse prior authorization.
Planning/ADR acceptance does not authorize execution.

## Compatibility And Controlled Evolution Paths

1. Prefer no-change reuse of accepted public contracts.
2. Use additive optional evolution only with deterministic absence semantics.
3. Use explicit capability negotiation for behavior unavailable to old peers.
4. Use versioned adapters/upcasters only at public boundaries; they cannot
   invent semantic facts or provenance.
5. Deprecation has an owner, observed migration evidence, expiry and removal
   authorization.
6. Breaking changes require constitutional/contract amendment, staged
   migration and a new proof identity.

Fallback, best-effort parsing and provider-specific behavior cannot establish
compatibility. Temporary bridges are time-bounded and must have an exit gate.

## Evidence Continuity

An assurance package binds proposal, predecessor/freeze, source, affected
contracts, dependency graph, owners, compatibility matrix, canonicalization,
positive/negative tests, tool/rule versions, exceptions, rollback and PO
decision. Evidence is immutable or append-only/superseding and retains failed,
denied and rolled-back attempts. Secrets and raw Evidence outside the approved
boundary are excluded.

## Verification And Negative Cases

Future executable work must prove allowed dependency edges, normalized freeze
hashes, deterministic replay/digest, collection-order invariance where defined,
producer/consumer version matrices and exact-file authority. It must reject
private imports, circular edges, protected drift, unknown required capability,
expired deprecation, duplicate semantic ID, mixed provenance, unauthorized
provider fallback, self-verification and missing rollback.

Full app, Knowledge, protected freezes, Architecture Fitness,
generated/protected checks and `git diff --check` remain mandatory.

## Exceptions, Rollback And Closure

Exceptions follow M17.3: named risk owner, evidence, compensating control,
expiry and removal plan; none can weaken constitutional invariants or authorize
Product before M22. Rollback uses a verified last-known-good identity or
owner-approved forward repair and never rewrites history. Closure requires all
assurance dimensions, explicit PO acceptance, commit and push.

## Definition Of Done

- Eight assurance dimensions and seven domain/boundary rules are explicit.
- Proposal lifecycle, controlled evolution paths and negative cases are defined.
- Identity, compatibility, freeze, authority, evidence and rollback remain
  continuous with M17.1-M17.3.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, runtime contract, additional ADR/planning file, Product or
  post-M22 work changes.

## Engineering Evidence

- Planning defines eight assurance dimensions, seven boundary rows, ten
  lifecycle stages and six controlled evolution paths.
- Full app regression: 945/945.
- Knowledge package regression: 75/75.
- Protected M3-M16 freeze regression: 52/52.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Exactly two authorized files change; generated health was restored.

Product Owner accepted and closed M17.4 on 2026-07-22 and authorized repository
closure.
