# Product Runtime Architecture

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Governance Root

This architecture consumes the immutable Platform baseline rooted at M22 digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.
It defines logical runtime boundaries only and grants no implementation authority.

## Layer And Module Model

```text
Experience
    |
    v
Application / Composition
    |
    v
Public contracts and ports
    |
    +--> Domain
    +--> Knowledge
    +--> Intelligence
    +--> Evidence
    +--> Simulation
             ^
             |
Infrastructure adapters implement explicit ports

Shared/Core supplies domain-neutral primitives only.
```

The arrows express allowed dependency direction, not data ownership transfer.
Each domain remains the sole owner of its semantics and internals.

## Dependency Matrix

Legend: `P` means public contract/port only, `N` means domain-neutral primitive
only and `-` means prohibited unless a later accepted contract explicitly adds
an edge.

| Consumer / Provider | Application | Experience | Domain | Knowledge | Intelligence | Evidence | Simulation | Shared/Core |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Experience | P | - | - | - | - | - | - | N |
| Application | - | - | P | P | P | P | P | N |
| Domain | - | - | owner | P | - | P | P | N |
| Knowledge | - | - | - | owner | - | - | - | N |
| Intelligence | - | - | P | P | owner | P | P | N |
| Evidence | - | - | P | - | - | owner | - | N |
| Simulation | - | - | P | P | - | - | owner | N |
| Shared/Core | - | - | - | - | - | - | - | owner |

Every `P` edge remains subject to the accepted Platform dependency graph. This
table cannot create a contract or authorize an import that Platform forbids.

## Interface Contract

Every public boundary declares:

- owning module and semantic contract ID;
- schema/contract version and compatibility range;
- immutable canonical input and output;
- provenance, knowledge and runtime bindings where applicable;
- deterministic digest and replay semantics where required;
- explicit typed failures with no fallback;
- lifecycle and deprecation/supersession rules.

Everything else is internal. Persistence schemas, compiler objects, provider
SDKs and domain implementation types never become cross-module contracts merely
because they are technically importable.

## Interaction Contract

- Commands have one accountable receiver and do not mutate another owner's log.
- Queries return immutable owner-produced projections.
- Events describe completed facts, are append-only and provenance-bound.
- Ports invert infrastructure dependencies and expose no provider internals.
- Composition validates uniqueness, version compatibility and acyclicity before
  constructing a runtime graph.
- Replay over the same canonical inputs produces the same deterministic state
  and digest for deterministic capabilities.

## Runtime Ownership And Composition

Application owns orchestration but never domain semantics. A single explicit
composition root binds port implementations. Infrastructure remains outside the
domain graph. Experience only renders/querys projections and issues commands.
Shared/Core cannot become a dependency shortcut or business-policy container.

No module may directly read another module's persistence, mutate another
module's state, infer authority from a digest, or bypass AISession and structured
Coach response boundaries.

## Compatibility And Change

Compatible additions preserve semantic IDs, canonical forms and existing
consumer behavior. Breaking changes require a successor version, migration,
rollback path, architecture evidence and separate Platform authorization where
Platform contracts are involved. Product ADRs cannot supersede Platform ADRs.

Missing contracts, mixed versions, stale provenance, duplicate providers,
cycles or ownership conflicts fail closed. Recovery repairs the source or rolls
back to a verified compatible Product predecessor.

## Planning Constraint

No source layout, process boundary, package, service, API, repository, schema,
route, widget, provider, infrastructure or deployment is created by this plan.
Each requires an exact later milestone authorization.
