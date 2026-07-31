---
name: ai-layer-architecture
description: EPIC 06 AI Layer — CoachService sole entry, CoachPipeline orchestrator, 6 Engines, LlmProviderAdapter (PO 2026-07-31)
metadata:
  type: project
---

Pool OS v3 Beta — AI Layer architecture (EPIC 06 standard).

```
UI
  ↓
CoachService                 ← SOLE public surface; UI never reaches lower
  ↓
CoachPipeline               ← orchestrator; owns engine ordering + fan-out
  ↓
6 Engines
  ├── RecommendationEngine
  ├── StrategyEngine
  ├── PatternEngine
  ├── EquipmentEngine
  ├── TrainingEngine
  └── MatchReviewEngine
  ↓
LlmProviderAdapter          ← engines call this; never call LLM directly
  ├── MockAI        (implemented, Beta default, offline)
  ├── OpenAI        (notAvailable — PO authorization required)
  ├── Claude        (notAvailable — PO authorization required)
  └── Gemini        (notAvailable — PO authorization required)
```

Rules:
  - UI ONLY calls CoachService. No engine, no adapter, no upstream repo.
  - Engines ONLY call LlmProviderAdapter. No direct LLM.
  - AI NEVER lives outside `app/lib/features/coach/`.
  - Data sources (EPIC 01-05) are READ-ONLY. No AI write-back.

Capability Pattern (EPIC 04 standard):
  All providers return `CapabilityResult<T>`. No exceptions.

AI Boundary (EPIC 06.4 — enforced by `ai_boundary_test.dart`):
  1. Static: grep banned strings outside coach/ = 0.
  2. Runtime: MockAI `isImplemented=true`; remotes `false`.
  3. Surface: `coach_screen.dart` calls `CoachService` only.

**Why:** PO 2026-07-31 — EPIC 06 is the only Epic allowed to host AI.
The layer prevents AI from leaking into upstream features.

**How to apply:** When adding AI surfaces, they MUST be inside this
layer. New engines register with `CoachPipeline`. New providers register
with `LlmProviderRegistry`. No new AI surface outside `coach/`.

Related: [[capability-pattern]], [[roadmap-v3-beta-wave-model]],
[[epic-06-close]]
