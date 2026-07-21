# M3.9 AI Session Boundary Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Ownership And Contracts

- `AISessionContract` v1 is the single deterministic boundary exposed to
  future AI consumers.
- The contract carries Knowledge identity, Context/Plan/Recommendation/
  Execution digests and IDs, structured provenance, required runtime contract
  versions, minimum AI contract version, and a deterministic SHA-256 digest.
- `AISessionInput` is a compatibility alias for the public AISession contract;
  no second boundary or alternate input shape exists.
- `AISessionBuilder` is a pure application service importing only public
  Context, Plan, Recommendation, Execution, and AISession contracts.

## Compatibility And Failure Semantics

- Builder gates Context v2, Plan v1, Recommendation v1, Execution Record v1,
  Knowledge version/digest, and the declared runtime contract set.
- Stale Plan, stale Recommendation, stale Execution, mixed Context identity,
  unsupported AI version, provenance mismatch, duplicate semantic IDs, and
  empty/invalid runtime contract sets fail loudly.
- Runtime contract declarations are compared against the actual compiled
  contract constants, preventing compatibility metadata drift.

## Boundary Scope

- AISession exposes references and provenance only; it does not contain raw
  Evidence, Event Log, Learning Runtime, Player Model internals, Coach Context
  internals, Decision History, compiler objects, publication objects, or
  execution transition payloads.
- Builder performs no inference, planning, recommendation, scoring, prompt
  construction, persistence, API, UI, LLM, embedding, RAG, Vision, or
  Simulation work.
- Equivalent inputs and canonicalized compatibility map ordering produce the
  same AISession JSON, ID, and digest. Inputs remain unchanged.

## Verification

- Focused M3.9 tests: 7/7.
- Combined M3.1-M3.9 Coach foundation tests: 69/69.
- Focused analyzer across AISession contracts, builder, and tests: no issues.
- App regression: 291/291.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Protected Reference Behavior, Golden Fixtures, production Knowledge/
  publication artifacts, M2 proof records, and prior M3 contract identities
  remain unchanged.

## Product Review

The Product Owner accepted and closed M3.9 on 2026-07-21 after reviewing the
single AISession boundary, pure builder, compatibility gate, fail-closed
semantics, deterministic provenance, absence of deterministic internals, and
full regression evidence.

## Explicit Non-Claims

M3.9 does not call an LLM, engineer prompts, create recommendations, plan,
infer, score, persist, expose an API, add UI, or implement Chat, Embedding,
Vector DB, RAG, Vision, Simulation, or future AI behavior.
