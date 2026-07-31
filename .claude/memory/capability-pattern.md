---
name: capability-pattern
description: Capability Pattern — replace throw with CapabilityResult + NotAvailable + Reason (EPIC 04 standard, EPIC 05 confirmed)
metadata:
  type: project
---

When a feature is on the Roadmap V3 Beta Forbidden list (e.g.
Recommendation, AI, LLM, RAG) but its entry points still exist in the
codebase, do NOT throw `UnsupportedError` from the entry point.
Instead, return:

  CapabilityResult<T>.notAvailable(
    CapabilityReason(code: '<surface>_closed_beta',
                     message: 'Closed in Pool OS Beta. Spec §5 Forbidden.'),
  )

The public surface uses `CapabilityResult<T>` with three statuses:

  - `implemented`  → `withValue(value)`
  - `notAvailable` → `notAvailable(reason)`  ← closed in Beta
  - `planned`      → `planned(reason)`        ← for future roadmap items

The UI gates on `<surface>Capability.unavailable` (a constant bool)
and surfaces the `CapabilityReason` in a banner. Tests assert via
`getOrThrow()` which throws `StateError` (acceptable in tests only).

Example file: `app/lib/features/knowledge/domain/knowledge_capability.dart`
ships the standard `CapabilityResult<T>` + `CapabilityReason` types
plus the `RecommendationCapability` constant set.

**Why:** PO 2026-07-31 — standardized in EPIC 04, locked in EPIC 05.
Throws from capability-closed entry points violate Roadmap V3 Beta
discipline.

**How to apply:** Any new "closed-in-Beta" surface follows this
pattern. The closure reason code is single-source-of-truth in
`<surface>Capability.reason` and the `unavailable` constant tells the
UI to surface the reason without touching the entry point.

Related: [[roadmap-v3-beta-wave-model]], [[epic-05-close]]
