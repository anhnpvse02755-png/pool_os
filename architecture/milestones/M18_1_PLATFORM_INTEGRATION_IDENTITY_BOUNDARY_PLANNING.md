# M18.1 Platform Integration Identity & Boundary Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define canonical identities and public-boundary governance for future platform
integration. M18.1 is planning only. It introduces no runtime contract,
implementation, Flutter, infrastructure, CI/CD, deployment, monitoring,
networking, persistence, AI execution, Product functionality, business logic,
ADR or frozen-artifact modification.

## Authority And Compatibility Root

- Constitution v1.4.0 is normative authority.
- Accepted M18.0 and Proposed ADR-017 provide planning context only.
- M17 Foundation Freeze digest
  `ffa61943bda52b5a3b18aa59293cdc2242593f4b5a886d4ddfd3ea13efb64989`
  is the immutable integration compatibility root.
- M3-M17 semantic IDs, versions, provenance and dependency directions remain
  protected.

Architecture owns boundary governance; contract/domain owners retain semantics;
Product Owner authorizes future exact scopes and accepts outcomes.

## Canonical Integration Identities

| Identity | Required binding | Owner |
|---|---|---|
| Integration candidate | Candidate schema/version, semantic ID, M17 freeze digest and source revision | Architecture/Platform |
| Participating component | Frozen milestone, public contract ID/version/digest and capability | Contract owner |
| Producer endpoint | Producing domain/port, output contract and provenance policy | Producing owner |
| Consumer endpoint | Consuming domain/port, required capability/version and rejection policy | Consuming owner |
| Boundary | Source/target domains, allowed direction, public interface and data class | Architecture plus owners |
| Integration flow | Ordered endpoints/contracts, purpose and canonical input identity set | Integration owner |
| Evidence package | Flow/candidate, tool/rule, positive/negative results and custody | Quality/source owners |
| Authorization | Actor/role, delegated scope, effective/expiry and decision digest | Product Owner/governance authority |
| Rollback/successor | Last-known-good or successor candidate, trigger and lineage | Integration plus affected owners |

Identities are stable, unique, versioned and never derived from display names,
paths, deployment locations or provider-specific identifiers.

## Identity Composition

An integration identity is a deterministic digest over the canonical candidate,
freeze, ordered participating component, boundary, capability, contract version,
provenance policy and authorization identities. Mutable operational metadata,
timestamps without semantic meaning and display labels are excluded. Same
canonical inputs produce the same identity; collection ordering follows the
owning contract. Missing, duplicate, mixed or ambiguous inputs fail closed.

## Boundary Ownership Matrix

| Boundary | Producer owns | Consumer owns | Architecture assures |
|---|---|---|---|
| Experience -> Evidence | Command contract acceptance | Input intent/presentation only | No persistence or inference leakage |
| Evidence -> Intelligence | Immutable facts/projections and provenance | Inference use and decision trace | No fact mutation or reverse dependency |
| Knowledge -> Intelligence | Published snapshot semantics | Compatible planning/inference consumption | No authoring/compiler leakage |
| Intelligence -> Simulation | Versioned physical request | Physics result/uncertainty | No player/tactic/Coach policy in Simulation |
| Intelligence -> Experience | Decision/projection/trace | Rendering and command submission | No UI inference or semantic reconstruction |
| Infrastructure -> public ports | Mechanism identity and operational evidence | Domain semantics remain with port owner | No private import or policy transfer |
| AI Session -> AI adapter | Structured input boundary and compatibility | Provider execution/output envelope | No direct deterministic internals/self-review |

Neither endpoint may redefine the other owner's semantics. Architecture can
reject an edge but cannot become domain owner.

## Public Integration Surface Governance

Every surface declares public port/contract ID, owner, producer/consumer,
supported versions/capabilities, data classification, provenance, failure and
compatibility semantics. Private persistence, compiler/runtime internals,
framework providers and UI state are never integration surfaces. An extension
uses the same public surface and cannot gain authority through registration,
deployment or provider control.

## Compatibility Inheritance

Integration inherits all frozen component guarantees; it cannot narrow or
reinterpret them. A compatibility claim binds exact producer/consumer versions,
capabilities, canonicalization and M17 freeze identity. Additive evolution,
deprecation and adapters/upcasters follow M17.2/M17.4. Unknown required
capability, expired window, canonical mismatch, stale/mixed provenance or
provider fallback fails closed.

## Provenance And Evidence

Every integration record retains candidate/freeze, component/contract,
producer/consumer, boundary/flow, input/output/evidence, tool/rule/provider,
owner/authority, compatibility, failure, rollback and successor identities.
Evidence includes positive and negative boundary/identity cases, is append-only
or superseding and excludes secrets/raw Evidence not required by the surface.

## Rollback And Supersession

- Record last-known-good candidate/component/version identities before change.
- Reject/disable a failed candidate and retain its attempt and denial evidence.
- Rollback cannot rewrite domain, Knowledge publication, Evidence, audit or
  freeze history; incompatible state uses owner-approved forward repair.
- Supersession names immutable predecessor/successor identities and restarts
  review when participating boundaries, capabilities or evidence change.
- An expired/unowned rollback or exception blocks acceptance.

## Product Owner Acceptance Gates

Future integration implementation requires accepted predecessor, exact
candidate/freeze/scope, domain/contract owners, public boundary graph,
compatibility matrix, provenance/evidence plan, positive/negative cases,
security/privacy review, rollback/supersession, protected regression,
Architecture Fitness 0 new and explicit PO acceptance before commit/push.
Planning/ADR acceptance and tool success grant no implementation authority.

## Failure Model

Fail closed on duplicate/recycled identity, unknown owner/port, private edge,
wrong dependency direction, missing/mixed/stale freeze or contract version,
unsupported capability, incomplete provenance/evidence, authority conflict,
scope drift, invalid rollback/successor or deterministic digest/replay mismatch.
There is no best-effort routing or compatibility fallback.

## Definition Of Done

- Nine integration identity classes and deterministic composition are explicit.
- Seven boundary rows define producer/consumer/Architecture ownership.
- Public surfaces, compatibility inheritance and provenance/evidence are clear.
- Rollback, supersession, fail-closed behavior and PO gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No implementation authority, runtime contract, ADR, additional planning file,
  Product behavior or frozen-artifact change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines nine identity classes and seven cross-domain boundary rows.
- Full app regression: 949/949.
- Knowledge package regression: 75/75.
- Protected M3-M17 freeze regression: 56/56.
- Architecture Fitness: 133 existing violations / 0 new.
- `git diff --check`: clean.
- Generated health restored; exact two-file scope confirmed.

Product Owner accepted and closed M18.1 on 2026-07-22 and authorized repository
closure.
