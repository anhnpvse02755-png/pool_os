# M4.8 AI Runtime Activation Gate Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Scope

M4.8 creates a deterministic gate between the completed Coach pipeline and a
future AI Runtime. The gate only returns Activated or Not Activated with a
structured reason. It never invokes a Provider, Orchestrator, Prompt, or AI
response.

## Contract and Behavior

- `AIRuntimeActivationGateContract` v1 is immutable and digest-bound.
- The gate consumes only AISession, Coach Adaptation Projection, and the AI
  Capability Registry.
- Activation provenance binds AISession digest, Adaptation digest, Registry
  digest, and capability ID.
- It fails closed for stale context, incompatible or unavailable capability,
  broken provenance, and duplicate activation keys.
- No AI Runtime, Provider call, Prompt, Response, Memory, Vision, RAG,
  Embedding, Scheduler, Persistence, or UI behavior is included.

## Verification

- Focused M4.8 tests: 4/4.
- Focused analyzer: no issues.
- Combined foundation tests through M4.8: 141/141.
- Full app regression: 367/367.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3 freeze proof record and protected artifacts: unchanged.

## Product Review

Product Owner accepted and closed M4.8 on 2026-07-21. M4 Foundation Freeze &
Architecture Validation is Ready to Start. The freeze is a validation gate,
not a new capability, and must produce an index-only manifest, proof record,
dependency/capability validation, replay evidence, and clean-checkout evidence
without changing M3, Knowledge, runtime, or AI behavior.
