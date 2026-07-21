# M3.13 AI Orchestration Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Ownership And Contracts

- `AIOrchestrationRequest` v1 is an immutable, canonical request bound to one
  AISession, one capability registry, and one or more requested capability IDs.
- `AIOrchestrationRoute` is infrastructure wiring owned by the orchestrator;
  callers do not select providers.
- `AIOrchestrationStepResult` and `AIOrchestrationResult` are immutable,
  deterministic outputs bound to exact session, registry, capability binding,
  provider request, and Coach Response digests.
- `DeterministicAIOrchestrator` is an Intelligence application service over
  the public M3.9-M3.12 contracts and provider port.

## Executable Scope

- The orchestrator resolves every requested capability through the M3.11
  compatibility gate, selects its single configured provider route, invokes
  the M3.12 provider-backed adapter, and emits a completed structured result.
- Single and multi-capability/provider requests are canonical and replay to the
  same JSON and digest.
- Duplicate capability requests, duplicate provider identities, ambiguous
  routes, unknown capabilities, missing providers, stale session/registry
  bindings, and foreign result steps fail loudly.
- Callers request capabilities only. Provider selection remains inside the
  orchestrator and provider implementations remain free of business logic.
- All inputs remain unchanged.

## Explicit Non-Claims

M3.13 does not implement network calls, real retry, fallback, timeout, async
execution, queues, persistence, prompts, prose, LLMs, tool calling, Vision,
Memory, RAG, Embedding, AI planning, Coach policy, recommendation logic, API,
or UI. Lifecycle is a synchronous immutable request-to-completed-result proof.

## Verification

- Focused M3.13 tests: 8/8.
- Combined M3.1-M3.13 foundation tests: 99/99.
- Focused analyzer: no issues found.
- App regression: 321/321.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- `git diff --check`: PASS.
- Protected Reference Behavior, Golden Fixtures, production Knowledge and
  publication artifacts, M2 proof records, and M3.1-M3.12 identities remain
  unchanged.

## Product Review

The Product Owner accepted and closed M3.13 on 2026-07-21 after reviewing the
orchestration ownership, capability/provider routing, deterministic multi-step
results, fail-closed behavior, and regression evidence. M3 Foundation Freeze &
Architecture Validation is Ready to Start.
