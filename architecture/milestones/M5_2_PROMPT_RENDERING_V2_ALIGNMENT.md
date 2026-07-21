# Prompt Rendering v2 Contract Alignment

**Status:** Accepted; Closed

**Date:** 2026-07-22

## Scope

Product Owner approved one additive alignment before M5.3: Prompt Rendering v2
carries `sessionDigest` and `registryDigest`, copied unchanged from Prompt
Assembly. No other scope is changed.

## Evidence

- PromptRenderer still consumes Prompt Assembly only.
- Rendering v2 copies both provenance values without inference or recomputation.
- Prompt Rendering v1 artifacts remain readable and replay-safe; missing v2
  provenance stays explicit and cannot satisfy M5.3.
- Assembly digest and rendering section semantics are unchanged.
- Focused rendering tests: 5/5.
- Focused analyzer: no issues.
- Full app regression: 380/380.
- Knowledge package regression: 75/75.
- Architecture Fitness: 133 existing / 0 new.
- Protected artifacts and M3/M4 baselines: unchanged.

## Product Review

Product Owner accepted and closed the alignment on 2026-07-22. Prompt
Rendering v2 is the official baseline for M5.3 Tool Invocation Foundation.
