# ADR-NNN: Decision Title

**Status:** Proposed | Accepted | Deprecated | Superseded  
**Date:** YYYY-MM-DD  
**Owners:**  
**Supersedes:** None  
**Superseded by:** None

## Context

Describe the problem, constraints, affected domains, and why a durable decision
is required.

## Decision

State the decision precisely. Separate semantic invariants from implementation
mechanisms that may evolve.

## Normative Authority

```yaml
constitution:
  version: 1.4.0
  sections:
    - "Section X.Y"
parentAdrs: []
contracts:
  - id: contract.example
    version: 1.0.0
```

An ADR cannot grant itself authority that conflicts with the Constitution.

## Architecture Evidence Plan

```yaml
contractTests:
  - path: test/contracts/example_contract_test.dart
    status: planned
architectureTests:
  - ruleId: domain_dependency
    status: active
integrationTests:
  - path: test/integration/example_flow_test.dart
    status: planned
productionSignals:
  - metric: not_available
    owner: team-or-person
    plan: Describe the signal to add before production rollout.
healthReports:
  - path: build/architecture/health.json
```

## Evidence Status

Record the latest verification date, known drift, and links to retained CI or
production evidence. Updating evidence status does not rewrite the decision.

## Alternatives Considered

List credible alternatives and why they were rejected.

## Consequences

Document positive consequences, costs, operational burden, and new failure modes.

## Compatibility and Migration

Describe SemVer impact, adapters/upcasters, rollout checkpoints, rollback, and
data migration.

## Security, Privacy, and Provenance

Describe data exposure, retention, erasure, audit, model/source versions, and
Decision Trace impact.

## Enforcement

List the executable gates that must fail when this ADR is violated.

## Exceptions

List approved, owned, and time-bounded exceptions. Use `None` when there are no
exceptions.
