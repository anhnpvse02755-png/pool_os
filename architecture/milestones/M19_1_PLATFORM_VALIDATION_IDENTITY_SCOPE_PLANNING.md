# M19.1 Platform Validation Identity & Scope Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define immutable identity, scope, ownership and boundary governance for future
platform validation. M19.1 is planning only. It introduces no runtime contract,
implementation, production code, Flutter behavior, infrastructure, deployment,
CI/CD, monitoring, tooling, Product, ADR or frozen-artifact change.

## Authority And Protected Root

Constitution v1.4.0, accepted M19.0 planning and M18 Foundation Freeze remain
authoritative/protected. The M18 artifact-set digest
`2cbb5729111984aa825f4cd5291639e2e7c6fb452a3fbe47e93330498123f753`
is the direct identity root. Domain/contract owners retain semantic authority;
Architecture owns validation identity governance; PO owns scope and acceptance.

## Immutable Validation Candidate Identity

A validation candidate is one immutable composite identity containing:

1. candidate ID and schema version;
2. M18 Freeze manifest/proof identities and artifact-set digest;
3. declared platform/surface and environment class identities;
4. participating domain, public boundary, contract and capability identities;
5. Knowledge/runtime/rule/canonicalization version identities;
6. workload, data, trust/privacy and continuity class identities;
7. owner, reviewer, authority/delegation and validity identities;
8. evidence-package, predecessor/successor and deterministic digest identities.

Semantic IDs are stable within their owned namespace. Any bound value change
creates a new candidate revision; it cannot mutate or inherit acceptance from a
predecessor. Display names, paths, timestamps and provider labels cannot replace
semantic identity.

## Validation Scope Identity

Scope is a first-class immutable object bound to the candidate. It declares
included and excluded claims, surfaces, domains, boundaries, capabilities,
contract/version ranges, Knowledge identity, workload/data classes,
constitutional rules, validation methods, evidence requirements, failure and
rollback boundaries, owners and validity.

Partial scope is valid only when exclusions and unsupported claims are explicit.
An omitted field is unknown, not unrestricted. Scope expansion, contraction or
reclassification creates a superseding identity and restarts affected gates.

## Validation Boundary Definitions

| Boundary | Allowed validation view | Prohibited access |
|---|---|---|
| Experience -> Evidence | Public command/event identity and attributable result | Event-store or persistence internals |
| Experience -> Intelligence | Public commands/queries and returned projections | Coach/Player internals or raw Evidence inference |
| Knowledge -> Intelligence | Published versioned Knowledge identity/snapshot | Authoring/compiler/generated mutation |
| Evidence -> Intelligence | Immutable event/projection/snapshot contracts | Fact rewriting or decision-as-evidence |
| Intelligence -> Simulation | Versioned request/result and uncertainty | Player, tactics, Coach policy or UI semantics |
| Intelligence -> Experience | Decisions/traces/projections | UI-derived Mastery/recommendation policy |
| Infrastructure/provider -> domain | Accepted adapter/capability result envelope | Domain semantics, private imports or fallback policy |
| AI boundary | AISession input and accepted structured response | Direct deterministic/domain internals or self-review |

Validation reads only declared public artifacts and retained evidence. Boundary
observation cannot grant write authority or expose private implementation.

## Validation Ownership Model

| Identity/decision | Accountable owner |
|---|---|
| Candidate and scope composition | Architecture/Platform Validation |
| Domain/semantic claim | Owning domain |
| Public boundary and compatibility claim | Producer/consumer contract owners |
| Surface capability claim | Surface/adapter owner plus contract owner |
| Knowledge/runtime identity | Knowledge publisher/contract owner |
| Data/trust/privacy scope | Data owner and Security/Privacy |
| Evidence identity and custody | Source custodian; Quality verifies independently |
| Rollback/supersession identity | Affected owners and Repository Authority |
| Final scope/acceptance | Product Owner |

Assemblers coordinate references but cannot approve owned claims. Providers and
infrastructure never own semantic, compatibility or acceptance decisions.

## Identity Continuity From M18 Freeze

Every candidate records normalized hashes of the accepted M18 manifest/proof,
the M18 artifact-set digest and transitive protection status for M3-M18. It
validates exact schema/milestone/source-root, inventory and accepted status
before any M19 claim is eligible. A broken, missing, regenerated or ambiguous
anchor blocks the candidate.

M19 evidence may reference but cannot copy, edit, reinterpret or regenerate a
freeze. Future successors append a new link while preserving predecessor
identity and digest.

## Validation Evidence Identity

Each evidence reference binds evidence ID/type/schema, candidate/scope/freeze,
claim and boundary, source/custodian, inputs/results, rule/tool versions,
positive/negative/failure status, reviewer authority, validity, predecessor,
redaction/retention and digest. Duplicate semantic evidence IDs with different
content are invalid; equal content under different claims remains distinct.

For identical canonical candidate, scope and evidence references, identity
validation yields the same ordered findings, eligible claims, rejection set and
digest. Ordering uses evidence type, claim ID, source ID and evidence ID.

## Rollback And Supersession

Rollback returns to a verified compatible last-known-good candidate identity
without deleting the rejected/current candidate or evidence. Forward repair is
a new versioned candidate. Supersession links immutable predecessor/successor
candidate, scope, evidence and decisions; affected owners reauthorize changed
claims. No alias or path replacement can silently supersede semantic identity.

## Fail-Closed Governance

Reject on missing/mixed/duplicate/stale identity, wrong M18 root, unknown
scope/exclusion/owner, private boundary, unsupported version/capability,
conflicting evidence, expired authority, scope drift, unsafe rollback, broken
lineage or nondeterministic canonicalization. No inference, score, fallback,
deadline or technical success supplies a missing identity or approval.

## Product Owner Acceptance Gates

Future implementation requires exact file/mechanism and candidate scope,
accepted predecessors, current M18 anchors, complete owner/boundary inventory,
canonical identity and evidence, positive/negative cases, trust/privacy review,
rollback/supersession, protected freezes, Architecture Fitness 0 new, clean diff
and explicit PO acceptance before repository closure. M19.1 authorizes planning
only.

## Definition Of Done

- Eight immutable candidate identity groups and first-class scope are explicit.
- Eight public validation boundaries and nine ownership decisions are defined.
- M18 continuity and deterministic evidence identity are explicit.
- Rollback, supersession and fail-closed PO gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No runtime contract, implementation, Product, ADR, tooling or frozen change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines eight candidate identity groups, eight validation boundaries
  and nine ownership decisions.
- Full app regression: 953/953 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M18 freeze regression: 60/60 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
