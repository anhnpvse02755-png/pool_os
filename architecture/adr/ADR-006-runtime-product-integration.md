# ADR-006: Runtime Product Integration

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Pool OS Product Owner and Architecture Maintainers
**Supersedes:** None

## Context

M3-M6 froze deterministic contracts. The product now needs a runtime
integration architecture that adds lifecycle, coordination, adapters, and
activation without reopening those contracts.

## Decision

Adopt a Runtime Core plus Application Coordinator/Dispatcher and infrastructure
adapters. Runtime Core owns deterministic state and lifecycle semantics;
adapters own persistence and transport. Product activation is operational and
rollback-aware. M7 remains incremental and modular-monolith based.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections: ["Section 2", "Section 4", "Section 5", "Section 18", "Section 20"]
parentAdrs: [ADR-005]
contracts:
  - id: m6-runtime-foundation
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m6_foundation_freeze_test.dart
    status: passing
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: app/test/m7_runtime_integration_foundation_test.dart
    status: planned
productionSignals:
  - metric: not_available
    owner: runtime-maintainers
    plan: Add lifecycle, recovery, and activation telemetry before production activation.
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Direct product-to-persistence calls: rejected because they bypass Runtime Core.
- Microservices first: rejected because modular monolith remains the baseline.
- AI-driven coordination: rejected because runtime orchestration is deterministic.

## Consequences

Runtime behavior gains explicit ownership and adapters remain replaceable. The
cost is additional contracts, lifecycle proofs, and migration checkpoints.

## Compatibility and Migration

M7 is additive to frozen M3-M6 contracts. New runtime contracts use SemVer and
must provide adapters or coordinated migration for breaking changes.

## Security, Privacy, and Provenance

Runtime commands and lifecycle records must preserve correlation, causation,
contract versions, and provenance. Persistence adapters must honor retention
and erasure rules without changing canonical runtime meaning.

## Enforcement

Architecture Fitness, contract compatibility, replay, migration, and protected
M3-M6 freeze tests are mandatory for each M7 implementation milestone.

## Exceptions

None.
