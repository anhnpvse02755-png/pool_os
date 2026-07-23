# Product Error Model

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Boundary

Product errors are stable structured references to authoritative source failures,
plus safe Product use-case context. They are not exceptions, log records,
telemetry events or user-interface strings.

## Taxonomy Summary

| Family | Categories | Recovery posture |
|---|---|---|
| Input/access | boundaryInvalid, unauthenticated, unauthorized | correct/resolve access; no blind retry |
| Identity/state | notFound, staleConflict, duplicateMismatch | re-query/new intent or stop |
| Contract/trust | incompatible, provenanceInvalid | repair compatible source; fail closed |
| Business | invariantRejected, cancelled | new valid intent only if lifecycle allows |
| Dependency/execution | dependencyUnavailable, externalExecutionFailed | owner-declared retry/new attempt |
| Workflow | partial, outcomeUnknown | preserve committed; reconcile/resume/compensate |
| Defect | unexpectedDefect | isolate and escalate |

## Error Invariants

1. One authoritative source owns the failure fact.
2. Wrapping preserves source identity/category/disposition.
3. Unknown does not default to retryable.
4. Rejection changes no accepted owner state.
5. Outcome unknown blocks duplicate mutation until reconciliation.
6. Partial preserves committed owner results in order.
7. Recovery is a new query/command or exact idempotent resolution.
8. Degradation is explicit and cannot broaden semantics/access.
9. User acknowledgement does not resolve domain state.
10. Audit is minimal, immutable and safe.

## Recovery Decision Matrix

| Condition | Recovery owner | Allowed next action |
|---|---|---|
| malformed intent | User/Experience + Application validation | correct and create new canonical intent |
| access failure | Identity/Security | resolve context or choose safe authorized path |
| stale aggregate | capability owner | query current version, reconfirm new intent |
| unknown outcome | Application + target owner | resolve exact request/idempotency identity |
| dependency unavailable | dependency owner/Application | isolate; eligible query/exact retry only |
| partial workflow | Application plus committed owners | resume or explicit compensation |
| invariant rejection | capability owner | stop or form materially new valid intent |
| incompatibility/provenance | contract/source owner | repair source/version; no consumer fallback |
| unexpected defect | implementation/operations owner | fail closed, preserve reference, escalate |

## Degradation Invariants

A degraded capability declares identity, affected operations, start evidence,
allowed read/write behavior, stale-data policy, dependencies, exit condition and
owner. Degradation cannot be inferred from elapsed time or a single UI error.
Writes default to blocked unless an accepted contract explicitly proves safety.

Unrelated capabilities may continue only when the P1.2 dependency graph shows no
required edge. Product cannot select a different provider/package/version as a
recovery shortcut.

## Deterministic Recovery Pipeline

```text
contain
 -> preserve source error and committed results
 -> classify scope and outcome certainty
 -> reconcile unknown outcome
 -> refresh access/version/provenance
 -> select declared recovery
 -> authorize
 -> execute one recovery action
 -> verify owner state
 -> render/audit final disposition
```

## Planning Constraint

No exception mapping code, retry/backoff/circuit breaker, logging, telemetry,
monitoring, synchronization, network/storage recovery, API or runtime resilience
mechanism is implemented.
