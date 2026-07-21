# M5.1 Prompt Assembly Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-22

## Scope

M5.1 creates deterministic structured Prompt Assembly references. It does not
render prompt text or create Provider payloads.

## Evidence

- `PromptAssemblyContract` v1 and `PromptAssemblyBuilder` are immutable,
  versioned, replayable, and content-addressed.
- Builder consumes only AISession, Coach Context, Planning Graph, Ordered
  Recommendation View, Adaptation Projection, and Capability Registry.
- Assembly contains canonical IDs, digests, bindings, and metadata only.
- Stale/mixed/missing capability, duplicate references, and broken provenance
  fail closed.
- Focused M5.1 tests: 4/4.
- Focused analyzer: no issues.
- Combined M3 + M4 + M5 foundation tests: 145/145.
- Full app regression: 375/375.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3/M4 baselines and protected artifacts: unchanged.

## Product Review

Product Owner accepted and closed M5.1 on 2026-07-22. M5.2 Prompt Rendering
Foundation is Ready to Start. It may consume Prompt Assembly only and produce a
provider-neutral structured payload; it must not perform transport, SDK,
credential, retry, token counting, or network behavior.
