# ADR-008: Product Feature Architecture

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Product Application Architecture
**Supersedes:** None
**Superseded by:** None

## Context

M3-M8 now form a frozen deterministic framework. The product layer must turn
those public projections into user workflows without becoming a second source
of truth or reopening framework contracts.

## Decision

Organize product work as eight composable capabilities (M9.1-M9.8) above frozen
public ports. Product features may compose views, navigation, commands, and
adapter-level view models, but domain facts, Coach decisions, runtime state, AI
boundaries, and Knowledge remain owned by their existing contracts.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 3 Domain Boundaries"
    - "Section 7 Experience and Product Boundaries"
    - "Section 20 Constitutional Change Process"
parentAdrs:
  - ADR-007
contracts:
  - id: m3-m8.frozen-public-contracts
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m8_foundation_freeze_test.dart
    status: passing
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: app/test/product_feature_boundary_test.dart
    status: planned
productionSignals:
  - metric: product_feature_contract_violations
    owner: Product Application Architecture
    plan: Add before internal alpha.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

Planning evidence on 2026-07-22: M8 freeze accepted, app 570/570, Knowledge
75/75, protected M3-M7 16/16, Architecture Fitness 133 existing / 0 new.

## Alternatives Considered

- Feature-owned domain state: rejected because it duplicates authoritative
  framework state.
- UI-first architecture: rejected because it would drive frozen contracts.
- Microservices per feature: rejected; modular monolith remains the baseline.

## Consequences

Features can evolve independently while using stable framework contracts. The
cost is explicit adapter/view-model work and stricter boundary testing.

## Compatibility and Migration

M9 is additive at the product layer. Existing M3-M8 contracts remain readable;
no persistence migration or upcaster is authorized by this ADR.

## Security, Privacy, and Provenance

Product surfaces expose only the minimum public projection required by a
workflow. AI surfaces receive AISession/structured responses only. Evidence,
raw event data, and internal runtime state remain outside product and AI UI
boundaries.

## Enforcement

- Architecture Fitness must remain at 133 known / 0 new.
- Protected M3-M8 freeze suites must pass.
- Product code may import public ports/contracts only.
- Any new framework contract requires a separate ADR and Product Owner gate.

## Exceptions

None.
