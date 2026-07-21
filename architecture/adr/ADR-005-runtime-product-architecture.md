# ADR-005: Runtime Product Architecture

**Status:** Proposed  
**Date:** 2026-07-22  
**Owners:** Pool OS Product Owner and Architecture Maintainers  
**Supersedes:** None  
**Superseded by:** None

## Context

M3-M5 have frozen deterministic contracts and AI boundaries. The next phase
must compose them into a product runtime without moving business ownership into
Persistence, API, Experience, or Provider infrastructure.

## Decision

M6 will proceed as a layered modular monolith. Runtime Composition and Coach
Runtime consume public contracts; Application Services expose use cases;
Persistence, transport, and Provider implementations remain adapters. M6.0 is
planning only. Each M6 capability requires its own executable scope, evidence,
Product Owner acceptance, and repository closure before the next capability.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "2 System Model"
    - "4 Domain Ownership"
    - "5 Compile-time Dependency Rules"
    - "18 Enforcement"
    - "19 Migration Strategy"
parentAdrs:
  - ADR-004-m5-ai-integration-layering
contracts:
  - id: m3-foundation
    version: frozen
  - id: m4-foundation
    version: frozen
  - id: m5-foundation
    version: frozen
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m5_foundation_freeze_test.dart
    status: passed
architectureTests:
  - ruleId: architecture_fitness
    status: active
integrationTests:
  - path: app/test/m6_runtime_composition_foundation_test.dart
    status: planned
productionSignals:
  - metric: not_available
    owner: Runtime Maintainers
    plan: Define operational signals before M6.8 activation.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

M5 Foundation Freeze accepted with 12 contracts, 11 suites, 0 cycles, full app
434/434, Knowledge 75/75, and Architecture Fitness 133 existing / 0 new.
M6 implementation evidence is not yet available.

## Alternatives Considered

- Microservices first: rejected until operational evidence justifies extraction.
- Persistence-first rewrite: rejected because projections are not sources of
  truth and migration safety is not yet proven.
- API-first implementation: rejected because application ownership must be
  established before transport.

## Consequences

The modular monolith keeps ownership visible and preserves replayability. It
requires disciplined ports and may delay independent deployment, but avoids
duplicating deterministic logic across services.

## Compatibility and Migration

M6 reuses frozen M3-M5 contracts. New contracts must be additive/versioned;
adapters/upcasters are required for breaking changes. Persistence and API work
must prove rebuild and rollback before activation.

## Security, Privacy, and Provenance

AI cannot bypass activation or write state. Persistence/API layers must preserve
provenance and support retention/erasure rules. No raw AI content is authorized
by this planning ADR.

## Enforcement

Architecture Fitness, contract compatibility tests, replay tests, protected
freeze manifests, and Product Owner review gates must fail on boundary drift.

## Exceptions

None.
