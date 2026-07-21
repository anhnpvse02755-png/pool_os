# M5.0 AI Integration Architecture Planning

**Status:** Accepted; Closed

**Date:** 2026-07-21

## Objective

Plan real AI integration without adding production code, runtime contracts,
Providers, Prompts, LLM calls, or network use. M3 and M4 remain frozen.

## Capability Roadmap

1. M5.1 Prompt Assembly Foundation
2. M5.2 AI Response Processing
3. M5.3 Tool Invocation Framework
4. M5.4 Conversation Memory Foundation
5. M5.5 Provider Runtime Integration
6. M5.6 Safety & Policy Enforcement
7. M5.7 AI Observability
8. M5.8 Production AI Activation

Each capability requires its own executable scope, evidence, Product Owner
review, and repository closure.

## Dependency And Layering

```text
M3 AI boundaries + M4 Activation Gate
  -> Prompt Assembly
  -> Response Processing
  -> Tool Invocation
  -> Conversation Memory
  -> Provider Runtime
  -> Safety Enforcement
  -> Observability
  -> Production Activation
```

The deterministic core remains Knowledge -> Learning Runtime -> Coach. AI only
consumes an activated AISession. AI application services own Prompt assembly,
response validation, tool mediation, memory projection, and observability.
Provider SDKs, transports, credentials, retries, and provider errors stay in
infrastructure. Experience renders structured results and human controls.

AI cannot directly write Player Progress, Learning Runtime, Coach Decision,
Decision History, Recommendation, Knowledge, or Evidence.

## Provider And Prompt Strategy

Providers are replaceable plugins behind frozen Provider/Capability boundaries.
No fallback may cross capability, safety, cost, or provenance policy. Prompt
artifacts are versioned, immutable, capability-bound, AISession-bound, and
content-addressed. Creation, review, activation, deprecation, and rollback are
auditable lifecycle steps. Prompts never become Knowledge, Evidence, Decision
Trace, or source-of-truth state.

## Response, Memory, And Tools

Provider output is untrusted. Response Processing validates schema,
session/capability/provider binding, safety, provenance, and Decision Trace
references before creating a structured Coach Response.

Conversation Memory is an erasable, scoped, derived projection. It is not
Evidence, Player Progress, Knowledge, or Coach history; it cannot self-promote
into canonical state.

AI may propose only allowlisted versioned tool intents. A deterministic gateway
validates arguments, authorization, idempotency, safety, cost, and human
approval before dispatch. AI never calls repositories or tools directly.

## Human Override, Cost, And Safety

Humans may deny, cancel, correct, or disable AI actions without rewriting
Evidence or frozen decisions. External side effects require explicit approval.
Overrides append audit records.

Requests declare provider-neutral cost/token/latency ceilings before dispatch.
Exhaustion or timeout returns a structured deferred result and never bypasses
safety or silently changes Provider.

Provider output, Memory, retrieved text, and tool results are untrusted. Enforce
schema/capability allowlists, secret isolation, minimal disclosure, and complete
model/Provider/Prompt/policy/session provenance. AI content cannot self-review,
self-verify, or self-publish. Prose remains grounded in Decision Trace.

## Vision Placement

Vision remains deferred. When separately authorized it enters only as a
versioned Evidence producer: Vision -> Evidence -> Learning Runtime -> Coach ->
AISession. It never bypasses the deterministic pipeline.

## Exit Criteria

- ADR-004 and this roadmap are Product Owner Accepted.
- Dependency graph remains acyclic; Architecture Fitness stays 133/0.
- M3/M4 manifests and protected artifacts remain unchanged.
- `git diff --check` passes.
- No production code, runtime contract, Prompt, Provider, LLM, or network work.

## Product Review

Product Owner accepted and closed M5.0 on 2026-07-21. M5.1 Prompt Assembly
Foundation is Ready to Start. AI artifacts must preserve the strict separation
Assembly -> Rendering -> Transport; M5.1 implements Assembly only.
