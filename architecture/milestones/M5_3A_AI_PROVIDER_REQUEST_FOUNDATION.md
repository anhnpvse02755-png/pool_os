# M5.3A AI Provider Request Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-22

## Ownership And Contracts

- `AIProviderRequestContract` v1 is the authoritative provenance binding between
  Tool Invocation Plan and the unchanged nested `CoachAIRequestEnvelope`.
- `providerPayloadDigest` is exactly the nested envelope digest consumed by the
  Provider and referenced by `AIProviderResult.requestDigest`.
- `providerRequestDigest` is the distinct deterministic digest of the outer
  request, including session/rendering/capability/registry/plan provenance.
- `AIProviderRequestBuilder` consumes only Tool Invocation Plan and the existing
  Coach AI Request Envelope.

## Boundary

No frozen Provider port, Provider Result, Coach AI Request Envelope, Tool
Invocation Plan, M3/M4 contract, network, SDK, HTTP, retry, or Provider
implementation is changed.

## Verification

- Focused M5.3A tests: 6/6.
- Focused analyzer: no issues.
- Full app regression: 397/397.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Protected artifacts and M3 Foundation Freeze: unchanged.
- `git diff --check`: PASS.

No M5.3A commit or push has been performed before Product Owner review.

## Product Review

Product Owner accepted and closed M5.3A on 2026-07-22. M5.4 AI Response
Processing Foundation is Ready to Start with Provider Request and Provider
Result as its only inputs.
