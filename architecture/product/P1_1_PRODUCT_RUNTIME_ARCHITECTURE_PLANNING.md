# P1.1 Product Runtime Architecture & Module Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define the Product runtime architecture and module boundaries without creating
runtime behavior. This planning milestone is rooted in P1.0 and the immutable
M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Authorized Scope

P1.1 defines logical layers, module decomposition, dependency and interface
rules, ownership, cross-module communication, composition and implementation
sequencing. It introduces no Dart, Flutter, service, repository, API, schema,
route, generated artifact, deployment, monitoring or infrastructure behavior.

## Architectural Layers

| Layer | Responsibility | May depend on |
|---|---|---|
| Experience | Render projections and issue typed commands | Application and public contracts |
| Application | Coordinate authorized use cases and composition | Public domain ports/contracts and Shared/Core primitives |
| Domain capabilities | Own semantics and deterministic behavior | Own internals, own public contracts and permitted upstream contracts |
| Infrastructure adapters | Implement explicit external ports | Port contracts and provider SDKs within later authority |
| Shared/Core | Provide domain-neutral immutable primitives | Standard library only |

Layer names describe dependency roles, not folders, processes or deployment
units. Pool OS remains a modular monolith until operational evidence authorizes
extraction.

## Logical Modules

- **Application:** use-case coordination, composition roots and transaction
  boundaries; owns no domain rule.
- **Experience:** user-facing projections and commands; owns no Mastery,
  recommendation or Evidence inference.
- **Domain:** domain-owned semantics exposed through explicit public contracts.
- **Knowledge:** authored and published Knowledge access through accepted ports;
  generated artifacts are not an authoring source.
- **Intelligence:** inferences, decisions, Coach contracts and structured traces;
  does not rewrite Evidence facts.
- **Evidence:** observed facts, provenance and custody; does not infer or decide.
- **Simulation:** deterministic physics; contains no strategy, policy, player
  model or presentation logic.
- **Shared/Core:** IDs, versions, digests, canonicalization and error primitives
  only; it is not a location for reusable business logic.

These are logical modules only. P1.1 neither creates nor renames source modules.

## Dependency Rules

Allowed dependencies are directed toward public contracts or domain-neutral
primitives. Experience may call Application. Application may coordinate public
ports. A domain may consume another domain only through an explicitly accepted
public contract allowed by Platform governance. Infrastructure may implement a
public port but may not be imported by its owning domain.

Prohibited directions include Domain to Experience, domain internals to another
domain, public contracts to infrastructure implementations, Shared/Core to any
business module, Evidence to Intelligence decisions, Knowledge to Experience
rendering and Simulation to Player/Coach policy. Circular dependencies and
reverse imports fail closed.

## Public And Internal Interfaces

A public interface has an owning module, semantic ID, version, compatibility
rules, immutable input/output, provenance requirements and deterministic failure
semantics. Internal types and persistence remain private to their owner. Public
status is explicit; directory visibility or importability does not grant it.

Interface evolution is additive when compatible. Breaking changes require a
new version, migration and separately authorized Platform successor evidence.
Product adapters cannot reinterpret or widen a Platform contract.

## Ownership

| Module | Owns | Does not own |
|---|---|---|
| Application | Use-case orchestration and composition | Domain truth or persistence internals |
| Experience | Rendering, input and accessibility | Inference, Mastery or recommendation policy |
| Domain | Its bounded semantics and invariants | Other domains' data or implementations |
| Knowledge | Authoring/publication truth and public access | Evidence facts or player inference |
| Intelligence | Inference, decision and trace semantics | Raw Evidence custody or UI |
| Evidence | Facts, provenance and custody | Decisions or recommendations |
| Simulation | Physics models and deterministic simulation | Strategy, Coach policy or UI |
| Shared/Core | Domain-neutral primitives | Business semantics or orchestration |

Platform/domain owners retain semantic authority. Product owners may compose
accepted contracts but cannot approve changes to their meaning.

## Cross-Module Communication

Communication uses typed commands, queries, immutable projections, domain
events or public ports. Every exchange preserves semantic IDs, versions,
provenance and compatibility. Direct database access, shared mutable state,
service location, internal imports and unversioned maps are prohibited.

Commands request work from one owner. Queries read owner-produced projections.
Events report completed facts and are append-only. No consumer mutates a
producer's history. Natural-language output remains grounded in structured
Decision Trace, and future AI consumes only the accepted AI boundary contracts.

## Runtime Composition Model

Application composition selects compatible public implementations and binds
them at an explicit composition root. Construction order and dependency
selection are deterministic and fail closed on missing, duplicate, cyclic or
incompatible bindings. Composition does not acquire business ownership.

Provider and infrastructure choices remain replaceable behind ports. Runtime
composition grants no persistence, network, provider, process or deployment
authority in this milestone.

## Implementation Sequencing Constraints

1. Freeze the Product composition contracts and ownership map.
2. Establish domain-neutral runtime primitives without business semantics.
3. Add one module shell at a time behind accepted public contracts.
4. Add Application composition only after provider contracts are verified.
5. Add Experience only after command/query boundaries are stable.
6. Add external adapters only through separately authorized infrastructure work.
7. Run contract, determinism, architecture and protected-freeze gates at every
   implementation milestone.

Later sequencing may be refined by separately accepted Product milestones; it
cannot bypass an upstream contract or ownership gate.

## Fail-Closed Rules

Reject ambiguous ownership, internal imports, circular dependencies, mixed
versions, missing provenance, mutable cross-module objects, duplicate bindings,
runtime logic in Shared/Core, Experience inference and any attempt to alter the
M22 terminal baseline. Repair occurs at the accountable source; no consumer
fallback may manufacture compatibility.

## Definition Of Done

- Runtime layers and the eight logical modules are defined.
- Allowed and prohibited dependency directions are explicit.
- Public/internal interfaces and module ownership are explicit.
- Cross-module communication and deterministic composition are defined.
- Sequencing constraints preserve Platform compatibility.
- ADR-023 remains Proposed and no runtime implementation exists.
- Exactly the four authorized P1.1 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.1 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
