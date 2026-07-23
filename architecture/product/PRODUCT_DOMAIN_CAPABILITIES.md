# Product Domain Capabilities

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Governance Root

This catalog is subordinate to P1.1 Product Runtime Architecture and the
immutable M22 Platform baseline. It documents logical business capabilities and
does not create implementation authority.

## Capability Catalog

### User & Identity

Owns Product user identity references, access context and player association.
It consumes accepted Platform identity/security contracts and never owns
credentials, provider SDKs or Player Model semantics.

### Settings / Configuration

Owns versioned Product preferences and Product configuration. It cannot redefine
domain rules, Knowledge, security policy or infrastructure configuration.

### Match Management

Owns match identity, participant references and match lifecycle coordination.
Scoring remains a separate owner; Match stores only accepted score references or
projections required by its public contract.

### Scoring

Owns score commands, score ledger/state and immutable scoreboard projections
under accepted rules. It does not own match lifecycle, Knowledge authoring or UI.

### Training

Owns Product training intent, session and progression workflow. Platform
Learning Runtime remains the source of prerequisite, unlock and eligibility
truth. Training consumes those projections and does not recompute them.

### Knowledge

Provides Product access to accepted published Knowledge through public ports.
Knowledge authoring, compiler, publication and generated artifacts stay under
their Platform owners. Product retains immutable identities/references only.

### Evidence

Owns observed Product facts, provenance, custody and correction lineage. Evidence
does not infer mastery, analytics conclusions, Coach decisions or recommendations.

### Simulation

Owns deterministic physics scenario requests/results. It excludes player models,
strategy, Coach policy, training selection, persistence and UI.

### Performance Analytics

Owns deterministic, rebuildable projections over accepted source outputs. It
does not mutate or become authoritative for Match, Score, Training or Evidence.

### AI Coach

Owns Product orchestration records at the accepted AI input/output boundary. It
accepts only AISession and returns structured CoachResponse. Provider output is
generation, not verified domain truth, and cannot self-review or self-publish.

## Contract Rules

Planned capability contracts must declare owner, semantic ID, version,
compatibility, immutable canonical data, provenance, lifecycle and typed failure.
Commands have one receiver; queries return projections; events describe
completed facts. Public status is explicit and does not expose internals.

## State Ownership Matrix

| State class | Sole authority | Consumers |
|---|---|---|
| Product identity/access reference | User & Identity | Application and authorized capabilities |
| Product preference/configuration | Settings / Configuration | Authorized capability composition |
| Match lifecycle | Match Management | Scoring, Analytics, Experience |
| Score ledger/state | Scoring | Match projection, Analytics, Experience |
| Training lifecycle | Training | Analytics, Experience, AI-session composition |
| Published Knowledge | Platform Knowledge | Knowledge integration and authorized capabilities |
| Evidence facts/custody | Evidence | Owner-produced projections for Training/Analytics |
| Simulation scenario/result | Simulation | Training and authorized experiences |
| Analytics projection | Performance Analytics | Experience and AI-session composition |
| AI session/response record | AI Coach boundary | Experience and audit consumers |

Consumer access never transfers authority. Caches and projections remain
rebuildable and cannot silently become a write model.

## Dependency Edges

```text
User & Identity ----> Match Management ----> Scoring ----> Performance Analytics
        |                    |                                  ^
        +----------------> Training ----------------------------+

Settings ------------> Match Management
        +-------------> Training

Knowledge -----------> Match Management
        +-------------> Scoring
        +-------------> Training

Evidence ------------> Training
        +-------------> Performance Analytics

Simulation ----------> Training

accepted deterministic projections --> AISession --> AI Coach --> CoachResponse
```

Arrows mean public-contract consumption. They do not authorize direct imports,
shared persistence or reverse writes. AI Coach has no direct edge to owner
internals or raw Evidence.

## Evolution And Sequencing

Capability contracts precede implementation. Foundation/reference integrations
precede operational capabilities; Match precedes Scoring; stable source
projections precede Analytics; accepted deterministic projections precede AI
Coach; stable command/query contracts precede Experience.

Additive compatible evolution preserves IDs and replay. Breaking changes require
new versions, affected-owner approval, migration, rollback and evidence. Cycles,
duplicated state authority and Platform contract changes fail closed.

## Planning Constraint

This catalog does not implement a capability, package, service, controller,
repository, API, schema, route, widget, AI behavior, Knowledge processing,
scoring/training engine, infrastructure, deployment, CI/CD or telemetry.
