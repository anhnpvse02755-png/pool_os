# M3.12 AI Provider Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Ownership And Contracts

- `AIProvider` is an infrastructure port. It receives only the public
  `CoachAIRequestEnvelope` and returns an immutable `AIProviderResult`.
- `AIProviderResult` v1 is deterministic, provider-bound, request-bound, and
  carries only provider identity, request digest, invocation status, and its
  own digest.
- `DeterministicStubAIProvider` is the only implementation. Provider identity
  is injected into `CoachAIAdapter`; replacing it does not change AISession,
  CoachResponse, capability registry, or prior M3 contracts.

## Executable Scope

- Provider implementations cannot access AISession internals, Coach Context,
  Planner, Recommendation, Execution, Evidence, Event Log, Learning Runtime,
  Flutter, or persistence through the provider contract.
- Provider/request identity mismatches fail loudly at invocation and stale or
  foreign provider results fail loudly at the adapter boundary.
- Repeated invocation with the same request and provider produces the same
  result JSON and digest.
- The adapter delegates invocation only after the M3.11 capability registry
  compatibility gate succeeds.
- Provider replacement changes only the provider identity in the request
  envelope; deterministic session provenance remains unchanged.

## Explicit Non-Claims

M3.12 does not integrate OpenAI, Claude, Gemini, local models, LLMs, prompts,
prose, streaming, tools, Vision, Memory, RAG, Embedding, AI planning,
recommendation logic, persistence, transport, or UI. Providers are plugins,
not owners of Coach, Planner, Learning, or capability business logic.

## Verification

- Focused M3.12 tests: 7/7.
- Combined M3.1-M3.12 foundation tests: 91/91.
- Focused analyzer: no issues found.
- App regression: 313/313.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- `git diff --check`: PASS.
- Protected Reference Behavior, Golden Fixtures, production Knowledge and
  publication artifacts, M2 proof records, and M3.1-M3.11 identities remain
  unchanged.

## Product Review

The Product Owner accepted and closed M3.12 on 2026-07-21 after reviewing the
provider boundary, deterministic stub, fail-closed identity checks, and
regression evidence. M3.13 AI Orchestration Foundation is Ready to Start.
