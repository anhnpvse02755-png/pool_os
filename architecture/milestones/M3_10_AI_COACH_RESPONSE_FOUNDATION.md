# M3.10 AI Coach Response Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Ownership And Contracts

- `CoachResponseContract` v1 is an immutable structured output boundary for
  future AI adapters. It contains no prompt, prose, chat text, or tool call.
- `CoachAIRequestEnvelope` v1 binds one request to an `AISession` ID/digest,
  minimum AI contract version, and provider adapter contract version.
- `CoachAIAdapter` accepts only the public `AISessionContract` and returns a
  public `CoachResponseContract`.
- `DeterministicStubAIAdapter` proves the adapter seam without LLM integration;
  its generation status is explicitly `notGenerated`.

## Executable Scope

- Response provenance binds AISession, Coach Context digest, Knowledge version/
  digest, Recommendation ID, and Execution digest.
- Request envelopes and responses are deterministic for the same AISession and
  adapter identity.
- Generated content is a separate structured generation section and is absent
  from the stub response.
- Response creation rejects a request envelope from another AISession.
- Adapter and response creation do not mutate AISession or expose deterministic
  internals.

## Explicit Non-Claims

M3.10 does not integrate OpenAI, Claude, Gemini, local models, prompts,
streaming, chat UI, tool calling, Vision, Memory, RAG, Embedding, Vector DB,
AI planning, recommendation generation, persistence, or API transport.

## Verification

- Focused M3.10 tests: 7/7.
- Combined M3.1-M3.10 foundation tests: 76/76.
- Focused analyzer across response contracts, adapter, and tests: no issues.
- App regression: 298/298.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Protected Reference Behavior, Golden Fixtures, production Knowledge/
  publication artifacts, M2 proof records, and M3.1-M3.9 identities remain
  unchanged.

## Product Review

The Product Owner accepted and closed M3.10 on 2026-07-21 after reviewing the
complete AI input/output boundaries, AISession-only adapter seam, deterministic
stub, structured response provenance, generation separation, scope discipline,
and regression evidence.
