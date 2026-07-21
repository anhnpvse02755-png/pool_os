# ADR-007: Product Runtime Services

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Pool OS Product Owner and Architecture Maintainers
**Supersedes:** None

## Context

M7 froze the projection-only integration boundary. M8 must plan service and
delivery layers without turning registries or operations into runtime owners.

## Decision

Adopt service composition, registry, dependency resolution, activation intent,
health, diagnostics, delivery projections, and a release gate as separate
capabilities. Runtime Core remains the sole deterministic state owner. Services
consume public ports/contracts; adapters handle persistence and transport.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections: ["Section 2", "Section 4", "Section 5", "Section 18", "Section 20"]
parentAdrs: [ADR-006]
contracts:
  - id: m7-foundation-freeze
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m7_foundation_freeze_test.dart
    status: passing
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: app/test/m8_runtime_services_foundation_test.dart
    status: planned
productionSignals:
  - metric: not_available
    owner: runtime-maintainers
    plan: Add service health, diagnostics, delivery, and release-gate signals before activation.
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Registry as runtime owner: rejected because ownership belongs to Runtime Core.
- Direct service-to-database writes: rejected by Constitution boundaries.
- Deployment-first microservices: rejected while modular monolith remains baseline.

## Consequences

M8 creates explicit delivery/readiness ownership and preserves deterministic
runtime truth. It adds governance and evidence burden for each service gate.

## Compatibility and Migration

M8 is additive to M3-M7. New contracts require SemVer, compatibility checks,
replay tests, and adapters for breaking changes.

## Security, Privacy, and Provenance

Service and delivery records preserve correlation, causation, contract versions,
provenance, retention, and erasure semantics. AI sees only approved projections.

## Enforcement

Architecture Fitness, public-port checks, replay, compatibility, migration, and
protected M3-M7 freeze tests are mandatory for each M8 implementation milestone.

## Exceptions

None.
