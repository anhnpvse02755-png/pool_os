# Product Application Services

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Contract

Product application services are public logical use-case coordinators. They
translate Product intent into ordered interactions with P1.2 capabilities and
P1.3 aggregate owners through P1.1 public contracts. They own orchestration only.

## Service Catalog

### User/Profile Application Service

Coordinates Product user/profile association and access-context queries through
accepted Identity contracts. It owns neither credentials nor Player semantics.

### Configuration Application Service

Coordinates versioned Product preferences and effective-configuration queries.
It cannot store domain rules or infrastructure configuration.

### Match Application Service

Coordinates Match and Rack lifecycle commands and Match views. Score changes are
delegated to Scoring; score state is never written through Match.

### Scoring Application Service

Coordinates accepted score commands against Match/rule identity and exposes
Scoring-owned projections. It cannot modify Match lifecycle or Knowledge rules.

### Training Application Service

Coordinates Training lifecycle with accepted eligibility, Knowledge, Evidence
and Simulation references. It does not resolve prerequisite/unlock rules.

### Knowledge Consumption Service

Coordinates queries/resolution of accepted published Knowledge references. It
has no authoring, compilation, publication or generated-artifact command.

### Evidence Recording Service

Coordinates observed-fact/correction requests with provenance and custody to the
Evidence owner. It cannot infer, classify as Intelligence or rewrite history.

### Simulation Invocation Service

Coordinates deterministic scenario requests/results through Simulation ports.
It cannot add strategy, player modeling, policy or UI semantics.

### Performance Analytics Service

Coordinates rebuild/invalidation requests and immutable snapshot queries. Source
state remains owner-controlled; Analytics projections are non-authoritative.

### AI Coach Application Service

Coordinates Coach Session boundary records using AISession and structured
CoachResponse only. It cannot access deterministic internals, prompt, provider
internals or treat generation as verified truth.

## Request Processing Model

```text
canonical request envelope
  -> boundary validation
  -> compatibility resolution
  -> owner authorization decision
  -> declared projection reads
  -> authoritative owner command
  -> committed owner result/event reference
  -> ordered downstream steps
  -> canonical result or typed failure
  -> application event reference
```

The sequence is deterministic and fail-closed. A service cannot skip an earlier
gate based on transport, cache or provider behavior.

## Command Query Event Matrix

| Concern | Command | Query | Application event |
|---|---|---|---|
| Purpose | request one owner mutation | read immutable projection | report orchestration fact |
| Side effects | owner-controlled | none | publication only after source fact |
| Authority | target aggregate owner | projection owner | Application for orchestration fact only |
| Versioning | expected aggregate/contract | bound projection version | event schema and source reference |
| Replay | idempotency-bound | version-repeatable | append-only reference |
| Failure | explicit rejection | explicit unavailable/stale | publication failure cannot rewrite owner result |

## Ownership Guardrails

Application services cannot:

- implement or override domain invariants;
- own aggregate or projection truth;
- read/write foreign persistence;
- authorize themselves or create security policy;
- publish a domain event before domain commit;
- mutate history during compensation;
- bypass public Platform contracts;
- hide business logic in validation, mapping or orchestration.

## Logical Transaction And Compensation

The atomic unit is one owner aggregate command plus its owner event. A workflow
spanning owners is a recorded sequence, not a global transaction. Later failure
returns explicit partial state. Compensation, if contractually available, is a
new owner command with authorization, idempotency and evidence.

## Failure Contract

Every failure has stable category, failing stage, accountable source, request
identity, retryability metadata and safe structured detail. Unsupported version,
stale state, provenance mismatch and owner rejection do not fallback. Unexpected
implementation errors are not normalized into successful business outcomes.

## Planning Constraint

This document creates no Dart service/class, controller, Riverpod/BLoC/ViewModel,
API, endpoint, repository, validator, authorization engine, persistence, event
bus, broker, queue, generated artifact or runtime behavior.
