# ADR-012: Production Behavior Implementation

**Status:** Proposed
**Date:** 2026-07-22
**Owners:** Application Runtime, Infrastructure Adapters, Product Application, and Release Governance
**Supersedes:** None
**Superseded by:** None

## Context

M3-M12 establish frozen deterministic domain, runtime, product, application, and
infrastructure planning contracts. Pool OS now needs real external effects and
runtime lifecycle execution without allowing framework or mechanism concerns to
reinterpret those contracts, move ownership, or introduce hidden mutation.

## Decision

Implement production behavior as M13.1-M13.8 behind frozen public ports.
Configuration, persistence, transport, and AI provider effects remain private to
their adapters. The Composition Root constructs and activates implementations;
Runtime Application executes frozen lifecycle/dispatch state machines; Product
Application binds Flutter only after the host is running; end-to-end production
runtime and release validation are last. Each effect has explicit ownership,
security, compatibility, idempotency, cancellation, cleanup, and rollback
semantics. No behavior capability may redesign a frozen contract.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.2 Architectural style"
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 6 Contract Constitution"
    - "Section 7 Versioning and Provenance"
    - "Section 10 Evidence and Event Store Constitution"
    - "Section 16 Experience Constitution"
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-011
contracts:
  - id: m3-m12.frozen-public-contracts
    version: 1.0.0
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m12_foundation_freeze_test.dart
    status: passing
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: app/test/m13_production_runtime_integration_test.dart
    status: planned
productionSignals:
  - metric: runtime_startup_failures
    owner: runtime-operations
    plan: Add before internal alpha.
  - metric: external_effect_failures
    owner: infrastructure-operations
    plan: Add per adapter before activation.
  - metric: rollback_failures
    owner: release-governance
    plan: Add before production rollout.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

Planning evidence on 2026-07-22 starts from the accepted M12 freeze: 8 sources,
40 public symbols, 7 dependency edges, 0 cycles, and contract-set digest
`2018debf2dbedd649c947c526f8365eacdba5c4e6b204888b563ad2b78c3b02d`.
No M13 production signal or behavior implementation exists yet.

## Alternatives Considered

- Put effects directly in deterministic planners: rejected because replay and
  ownership would be lost.
- Let Flutter, storage, provider, or network SDKs define public contracts:
  rejected because mechanisms are replaceable and private.
- Use a global service locator: rejected because dependencies and lifetimes
  become hidden.
- Implement an end-to-end host before individual adapters: rejected because
  failure, cleanup, security, and rollback semantics would be unprovable.
- Extract microservices now: rejected because the modular monolith remains the
  constitutional baseline without operational evidence.
- Implement behavior during M13.0: rejected because every effect requires a
  separate executable scope and acceptance gate.

## Consequences

The frozen architecture remains stable while production effects become
replaceable, observable, and independently testable. Costs include adapter
translation, explicit lifecycle/disposal code, migration and rollback tooling,
security controls, failure isolation, and broader integration testing.

## Compatibility and Migration

M13.0 is documentation-only and changes no frozen contract. Each implementation
must support the accepted contract versions or fail closed. Storage migrations
and external API/provider compatibility require capability-specific rollout and
rollback plans. Breaking public changes require SemVer, constitutional
governance, migration evidence, and Product Owner approval.

## Security, Privacy, and Provenance

Secrets stay inside configuration/transport/provider adapters and never enter
public digests, logs, or UI. Personal data is minimized and follows retention
and legal erasure. AI receives only AISession. Every effect preserves source
identity, version, digest, provenance, and a structured Decision Trace where
required. Logs and diagnostics must redact secrets and sensitive payloads.

## Enforcement

- M13 capability graph must contain eight nodes and zero cycles.
- Protected M3-M12 freeze suites and hashes must remain unchanged.
- Architecture Fitness must introduce zero new violations.
- Frozen deterministic code may not import behavior mechanisms or SDKs.
- Framework, SDK, storage, protocol, and provider types may not cross public
  contracts.
- External effects require explicit authorization and typed fail-closed
  compatibility, provenance, security, timeout/cancellation, cleanup, and
  rollback semantics.
- Composition must be explicit; global service location and hidden mutable
  singletons are forbidden.
- No M13 implementation begins without a Product Owner executable directive.

## Exceptions

None.
