# M18 Platform Integration Plan

**Status:** Accepted Planning Baseline; Closed
**Date:** 2026-07-22

## Integration Contract

M18 integrates accepted platform capabilities only through frozen public
contracts and separately authorized planning/execution scopes. This plan does
not authorize an implementation, service extraction, adapter, migration,
provider or Product behavior.

## Dependency-Ordered Milestones

### M18.1 Integration Identity & Scope

Define immutable candidate, freeze, participating-contract, capability,
boundary, owner and authorization identities.

- Gate: M17 freeze identity and exact inventory.
- Evidence: unique/canonical identity plus duplicate/mixed/stale rejection.
- Rollback: discard candidate and retain attempt.

### M18.2 Evidence & Provenance Integration

Define evidence sources, custody, lineage, minimization, retention and
cross-boundary provenance without copying domain truth.

- Gate: accepted M18.1 identities and source ownership.
- Evidence: complete lineage and negative missing/unowned cases.
- Rollback: disable integration; preserve source and audit history.

### M18.3 Compatibility & Replay Integration

Define producer/consumer/version matrix, canonicalization and end-to-end replay.

- Gate: M18.1-M18.2 identities/evidence.
- Evidence: deterministic replay/digest and unsupported-combination denial.
- Rollback: return to last accepted version set or owned forward repair.

### M18.4 Failure, Recovery & Supersession Integration

Define failure taxonomy, partial-attempt custody, isolation, retry eligibility,
rollback, forward repair and supersession lineage.

- Gate: M18.2-M18.3 evidence.
- Evidence: representative failure/denial and immutable recovery history.
- Rollback: candidate-specific, never domain-history rewrite.

### M18.5 Security & Privacy Boundary Integration

Define identity/access boundaries, data classification/minimization, consent,
retention/erasure, audit and incident ownership.

- Gate: M18.3 compatibility and exact data-flow inventory.
- Evidence: allowed/denied access and exposure review.
- Rollback: revoke candidate authority and retain attributable audit.

### M18.6 Integration Conformance

Define executable conformance profile for boundaries, contracts, compatibility,
replay, evidence, failure, security/privacy and rollback.

- Gate: M18.4-M18.5 accepted criteria.
- Evidence: candidate-bound positive and negative conformance.
- Rollback: reject certification; never repair through report.

### M18.7 Integration Readiness

Aggregate evidence index, owners, gaps, exceptions, compatibility windows,
rollback and M19 transition prerequisites.

- Gate: accepted M18.6 conformance.
- Evidence: complete/current/non-conflicting readiness package.
- Rollback: remain in M18; no implied transition.

### M18.8 Final Integration Gate

Perform independent audit and record the Product Owner's binary decision.

- Gate: accepted M18.7 package and protected M3-M17 proofs.
- Evidence: immutable decision package and repository identity.
- Rollback: append superseding decision; tooling cannot auto-approve.

## Cross-Capability Invariants

- Public ports/contracts only; domain internals and persistence remain private.
- Knowledge authoring remains source of truth; generated artifacts are derived.
- Evidence facts remain distinct from Intelligence inference/decisions.
- Simulation remains free of player/tactic/Coach semantics.
- AI remains bounded by accepted AI Session/Response contracts.
- Provider behavior cannot define compatibility or business policy.
- Failures, denials, exceptions and rollback attempts remain auditable.
- Product work remains locked until M22 closes.

## M18 Completion Condition

M18 closes only after M18.1-M18.8 are separately authorized, completed,
verified, PO-accepted and repository-closed, followed by an accepted M18 freeze.
Only then may M19 begin. This plan authorizes none of those implementations.
