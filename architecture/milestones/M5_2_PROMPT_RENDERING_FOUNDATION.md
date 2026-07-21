# M5.2 Prompt Rendering Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-22

## Scope

M5.2 deterministically renders Prompt Assembly into a provider-neutral
structured representation. It does not create provider payloads or perform
transport.

## Evidence

- `PromptRenderingContract` v1 and `PromptRenderer` are immutable, versioned,
  replayable, and digest-bound to Prompt Assembly.
- Rendering consumes Prompt Assembly only.
- Sections are canonical structured references: variables, ordered references,
  system block, user block, and assistant context block.
- Unsupported target, strategy, invalid ordering, duplicate sections, and broken
  provenance fail closed.
- Focused M5.2 tests: 4/4.
- Focused analyzer: no issues.
- Combined foundation tests: 149/149.
- Full app regression: 379/379.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3/M4 baselines and protected artifacts: unchanged.

## Product Review

Product Owner accepted and closed M5.2 on 2026-07-22. M5.3 Tool Invocation
Foundation is Ready to Start. It may plan deterministic tool requests from
Prompt Rendering only and must not execute tools or access HTTP, filesystem,
database, MCP, shell, plugin, or external APIs.
