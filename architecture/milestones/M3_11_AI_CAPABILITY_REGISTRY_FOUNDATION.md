# M3.11 AI Capability Registry Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Ownership And Contracts

- `AICapabilityRegistryContract` v1 is an immutable, deterministic registry of
  declared AI capabilities; it does not implement any provider or capability.
- `AICapabilityDefinition` binds capability ID/version, minimum AI contract
  version, required runtime contract versions, and compatibility rules.
- `AICapabilityBinding` is a deterministic proof that one capability was
  resolved against one compatible AISession and registry digest.
- `CoachAIAdapter` now requires a registry and capability ID before creating a
  request or response. AISession, CoachResponse, and prior M3 contracts remain
  unchanged.

## Executable Scope

- Registry capability IDs are canonicalized and duplicate IDs fail loudly.
- Resolution rejects unknown capabilities, incompatible AI contract versions,
  and runtime contract mismatches.
- Adapter calls are permitted only after registry resolution succeeds.
- Registry and binding digests are deterministic across capability ordering and
  repeated resolution.
- Registry, AISession, and adapter inputs remain immutable and unchanged.
- No provider integration is present; the existing deterministic stub remains
  the only adapter implementation.

## Explicit Non-Claims

M3.11 does not integrate OpenAI, Claude, Gemini, local models, LLMs, prompts,
tool calling, Vision, Memory, RAG, Embedding, AI planning, persistence, or API
transport. Capability declarations are metadata, not implementations.

## Verification

- Focused M3.11 tests: 8/8.
- Combined M3.1-M3.11 foundation tests: 84/84.
- Focused analyzer across Registry, adapter gate, and tests: no issues.
- App regression: 306/306.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Protected Reference Behavior, Golden Fixtures, production Knowledge/
  publication artifacts, M2 proof records, and M3.1-M3.10 identities remain
  unchanged.

## Product Review

The Product Owner accepted and closed M3.11 on 2026-07-21 after reviewing the
immutable registry, capability compatibility binding, adapter enforcement,
provider separation, deterministic behavior, and regression evidence.
