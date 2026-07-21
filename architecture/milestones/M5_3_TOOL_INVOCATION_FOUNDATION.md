# M5.3 Tool Invocation Foundation

**Status:** Accepted; Closed

**Date:** 2026-07-22

## Ownership And Contracts

- `ToolInvocationContract` v1 is an immutable request-plan item bound to one
  PromptRendering, AISession digest, Capability Registry v2, capability, tool,
  and structured invocation-policy reason.
- `ToolInvocationPlanContract` v1 is an immutable deterministic collection of
  invocation items with its own identity and digest.
- `ToolInvocationPlanner` consumes only PromptRendering v2 and Capability
  Registry v2. Tool identity and reason come exclusively from Registry v2.

## Executable Scope

- Planner rejects legacy/stale Rendering, mismatched Registry provenance,
  unknown capability, missing/unsupported default tool, duplicate semantic
  invocation, and broken plan binding.
- Replay of the same canonical inputs creates the same JSON and digest.
- Invocation metadata and plan collections are immutable and canonical.
- Planner validates and projects only. It does not execute tools or call
  Provider, HTTP, filesystem, database, MCP, shell, plugin, or external APIs.

## Verification

- Focused M5.3 tests: 7/7.
- Focused analyzer: no issues.
- Full app regression: 391/391.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- M3 Foundation Freeze and prior protected artifacts: unchanged.
- `git diff --check`: PASS.

No M5.3 commit or push has been performed before Product Owner review.

## Product Review

Product Owner accepted and closed M5.3 on 2026-07-22. M5.4 AI Response
Processing Foundation is Ready to Start.
