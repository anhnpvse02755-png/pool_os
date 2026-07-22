# ADR-010: Production Application Implementation

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Application Runtime and Product Application
**Supersedes:** None
**Superseded by:** None

## Context

M3-M10 provide frozen deterministic domain, Runtime, Product, AI boundary, and
production-delivery contracts. Pool OS now needs an implementation plan that
connects those contracts to a production application without moving business
truth into Flutter, dependency injection, persistence, configuration,
transport, provider, or observability mechanisms.

## Decision

Organize production application implementation as M11.1-M11.8. The modular
monolith has one Composition Root that owns construction, wiring, lifetime, and
disposal only. Application Runtime coordinates bootstrap and host lifecycle
through frozen public ports. Application Services expose use cases to Product
features. Infrastructure and UI remain adapters. Startup validation consumes
M10 readiness/delivery gates and fails closed; it does not deploy or activate.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 2 System Model"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 6 Contract Constitution"
    - "Section 7 Versioning and Provenance"
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-009
contracts:
  - id: m3-m10.frozen-public-contracts
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m10_foundation_freeze_test.dart
    status: passing
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: app/test/application_bootstrap_implementation_test.dart
    status: planned
  - path: app/test/end_to_end_application_composition_test.dart
    status: planned
productionSignals:
  - metric: application_startup_failures
    owner: application-runtime
    plan: Add before production startup is enabled.
  - metric: startup_gate_rejections
    owner: release-governance
    plan: Add before production exposure is enabled.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

Planning evidence on 2026-07-22: M10 freeze accepted; focused freeze 5/5, app
679/679, Knowledge 75/75, protected M3-M9 25/25, Architecture Fitness 133
existing / 0 new. M11 implementation and production signals are not available
until each capability receives explicit authorization.

## Alternatives Considered

- Put startup and service wiring in Flutter widgets: rejected because UI is an
  adapter and cannot own application/runtime coordination.
- Use a global service locator: rejected because dependencies, lifetime, and
  test boundaries become hidden.
- Let Product features call Runtime directly: rejected because application
  service ownership and compatibility gates would be bypassed.
- Extract deployment services now: rejected because the modular monolith
  remains authoritative without operational evidence for extraction.

## Consequences

Production mechanisms can evolve behind stable ports, wiring stays auditable,
and startup failures remain fail-closed. Costs include explicit application
services, lifecycle cleanup, adapter compatibility, observability integration,
and end-to-end composition proofs before production exposure.

## Compatibility and Migration

M11 planning is additive and changes no frozen contract. Concrete adapters must
preserve semantic IDs, versions, digests, provenance, and compatibility. Any
breaking boundary change requires SemVer evolution and the accepted contract
migration process. No data or deployment migration is authorized here.

## Security, Privacy, and Provenance

Secrets and raw configuration remain inside infrastructure adapters and must
not enter public diagnostics or digests. Product and AI receive only approved
public projections. Startup, wiring, lifecycle, and authorization evidence must
retain source contract versions and digests without exposing private payloads.

## Enforcement

- M11 capability graph must contain eight nodes and zero cycles.
- Protected M3-M10 freeze suites must pass unchanged.
- Architecture Fitness must introduce zero new violations.
- Composition Root may import public contracts/ports and adapter factories only.
- Product features may depend on application services, not Runtime internals.
- Infrastructure mechanisms may not contain domain, Coach, Learning, or Product
  policy.
- No M11 implementation begins before Product Owner approval of its executable
  scope.

## Exceptions

None.
