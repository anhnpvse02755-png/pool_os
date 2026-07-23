# ADR-028: Product Experience Navigation

**Status:** Proposed
**Date:** 2026-07-23
**Owners:** Product Owner, Product Architecture, Experience Owner, Capability Owners, Quality
**Supersedes:** None
**Superseded by:** None

## Context

P1.1-P1.5 define Product runtime, capabilities, state, application services and
workflows. User journeys need logical navigation boundaries before UI or route
implementation can be authorized.

## Decision

Define Experience-owned logical navigation over Application commands/queries and
owner-produced projections. Routes cover startup, profile, Home, Match/Scoring,
Training, AI Coach, Knowledge, Analytics, Settings, Simulation and typed recovery.
Route entry is read/navigation-only; mutations require explicit application
commands and accepted owner results.

Deep links pass compatibility, access, route-version, target-owner and projection
gates. Offline/stale/unknown states are explicit and fail closed. This ADR is
planning-only and selects no UI, route or state-management implementation.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section 1.3 Target architecture is not implementation maturity"
    - "Section 1.5 Normative authority and architecture evidence"
    - "Section 4 Domain Ownership"
    - "Section 5 Dependency Rules"
    - "Section 17 Explicit Prohibitions"
    - "Section 18 Enforcement"
    - "Section 20 Governance and Amendments"
parentAdrs:
  - ADR-023-product-runtime-architecture
  - ADR-026-product-application-services
  - ADR-027-product-domain-workflows
contracts:
  - id: m22.foundation.freeze
    version: 1
  - id: product.experience-navigation.plan
    version: 1
```

## Architecture Evidence Plan

```yaml
contractTests:
  - path: app/test/m22_foundation_freeze_test.dart
    status: active
architectureTests:
  - ruleId: architecture_fitness_ratchet
    status: active
  - ruleId: experience_no_domain_inference
    status: active
  - ruleId: experience_navigation_no_mutation
    status: planned
integrationTests:
  - path: planned/product-navigation-contract-tests
    status: planned
productionSignals: []
healthReports:
  - path: build/architecture/health.json
```

## Alternatives Considered

- Let each feature navigate ad hoc: rejected; access, deep-link and recovery
  behavior would diverge.
- Navigate on optimistic assumed mutation: rejected; Experience would claim
  domain state before owner acceptance.
- Put business workflow in navigation/state management: rejected; Experience
  would acquire Application/Domain ownership.
- Use deep-link paths as identity: rejected; mutable presentation paths are not
  stable semantic identities.

## Consequences

Future UI can implement consistent journeys against stable logical routes and
visible states while capabilities remain independent. Every target resolution
requires explicit gates, adding steps but preventing navigation from bypassing
authorization, compatibility or ownership.

## Compatibility And Migration

P1.6 changes no runtime route or UI contract. Future route contracts require
semantic IDs/versions and explicit migration for breaking changes. Product route
evolution cannot change Platform ownership or capability contracts.

## Security Privacy And Provenance

Deep links contain no secret, raw Evidence or embedded mutable domain objects.
Target authorization is re-evaluated. Displayed projections retain provenance
and stale/offline marking; failures expose only safe structured detail.

## Enforcement

Navigation graph/route-resolution tests, Experience import/ownership checks,
command/query separation, authorization/deep-link recovery tests, Architecture
Fitness, protected freezes, exact scope and independent verification fail closed.

## Exceptions

None.
