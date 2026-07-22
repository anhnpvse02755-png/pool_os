# ADR-009: Production Runtime And Application Delivery

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Application Runtime and Runtime Operations
**Supersedes:** None
**Superseded by:** None

## Context

M3-M9 now provide frozen deterministic domain, Runtime, Coach, AI, service,
delivery, and Product projections. Production startup needs an application host
and infrastructure composition boundary without moving business ownership into
DI, adapters, deployment tooling, or Product code.

## Decision

Organize production runtime delivery as eight capabilities M10.1-M10.8. A
single modular-monolith Composition Root owns dependency wiring and resource
lifetime only. Application bootstrap and lifecycle coordinate Runtime Core
through public ports. Configuration, persistence, API, transport, provider, and
deployment mechanisms remain adapters. Readiness and delivery authorization
are immutable fail-closed proofs and do not become runtime state owners.

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
contracts:
  - id: m3-m9.frozen-public-contracts
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m9_foundation_freeze_test.dart
    status: passing
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: app/test/application_bootstrap_foundation_test.dart
    status: planned
  - path: app/test/runtime_delivery_gate_foundation_test.dart
    status: planned
productionSignals:
  - metric: runtime_bootstrap_failures
    owner: runtime-operations
    plan: Add before Internal Alpha activation.
  - metric: readiness_gate_rejections
    owner: release-governance
    plan: Add before production delivery is enabled.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

Planning evidence on 2026-07-22: M9 freeze accepted; focused freeze 5/5, app
626/626, Knowledge 75/75, protected M3-M8 20/20, Architecture Fitness 133
existing / 0 new. Production signals are `not_available` until the relevant
M10 capability and Internal Alpha instrumentation are approved.

## Alternatives Considered

- Put wiring in feature modules: rejected because dependency lifetime and
  startup order would be distributed across business owners.
- Let adapters call Runtime internals: rejected by dependency and ownership
  rules.
- Make health/readiness canonical runtime state: rejected because they are
  operational projections and gates.
- Extract microservices for production: rejected; the modular monolith remains
  the accepted baseline without operational evidence for extraction.

## Consequences

Production mechanisms can change without redesigning frozen domain contracts,
and startup/delivery failures become explicit and auditable. Costs include a
strict Composition Root, lifecycle cleanup rules, adapter compatibility gates,
and additional operational proof before activation.

## Compatibility and Migration

M10 planning is additive. M3-M9 remain unchanged. Later M10 contracts require
versioned compatibility, deterministic replay where applicable, and adapters
for breaking external mechanisms. No persistence or deployment migration is
authorized by this ADR.

## Security, Privacy, and Provenance

Configuration adapters must minimize and redact secrets before creating public
metadata. Secrets, raw environment values, credentials, and provider payloads
must not enter digests or diagnostics. Bootstrap, activation, lifecycle,
readiness, and delivery records preserve contract versions and source digests.
Existing privacy, erasure, Evidence, and AI boundaries remain authoritative.

## Enforcement

- Planning graph must be valid and acyclic.
- Protected M3-M9 freeze suites must pass unchanged.
- Architecture Fitness must introduce zero new violations.
- Composition Root and adapters may import public contracts/ports only.
- Deterministic domains may not import platform, persistence, HTTP, provider,
  environment, or deployment implementations.
- No M10 capability starts before Product Owner approval of its executable
  scope.

## Exceptions

None.
