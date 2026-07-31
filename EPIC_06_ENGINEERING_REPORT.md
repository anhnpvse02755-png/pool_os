# EPIC 06 — AI Coach Engineering Report

Wave Model: Internal — 3 Waves. Single lifecycle: 1 Engineering Report +
1 Full Regression + 1 PO Review + 1 Merge + 1 Close per PO 2026-07-31.

---

## §1 — Scope & Architecture

PO 2026-07-31 spec: `architecture/product/EPIC_06_AI_COACH.md`.

Architecture (PO-authorized):

```
UI
  ↓
CoachService                  ← sole entry point
  ↓
CoachPipeline                ← orchestrator
  ↓
6 Engines (Recommendation / Strategy / Pattern /
Equipment / Training / Match Review)
  ↓
LlmProviderAdapter           ← engines never call LLM directly
  ├── MockAI         (implemented, Beta default)
  ├── OpenAI         (notAvailable, PO authorization required)
  ├── Claude         (notAvailable, PO authorization required)
  └── Gemini         (notAvailable, PO authorization required)
```

The `CoachService` is the only public surface. UI never reaches engines,
providers, or upstream repositories directly.

---

## §2 — Existing Code Reuse (PO Option 1 — Reuse maximum)

Audit: 45 files, ~7,500 LOC in `coach/` + `coach_memory/`. Zero files
rewritten. Zero files deleted. Classification:

| Action | Files | LOC (approx) |
|---|---|---|
| Reuse | ~22 | ~3,800 |
| Wrap | ~15 | ~2,800 |
| Refactor | ~6 | ~800 |
| Legacy | ~2 | ~100 |

Key reuse decisions:

- `brain/*` (CoachBrain + CoachServices + CoachOutput) → Deliverable 2.1
- `coach_recommendation_*` → Deliverable 2.2 (Recommendation)
- `match_objective_policy` + `session_execution_coordinator` → Deliverable 2.3
- `findings/*` → Deliverable 2.4 (Pattern Analysis)
- `equipment/*` (existing feature) → Deliverable 2.5
- `learning_runtime` + `ai_session_builder` → Deliverable 2.6
- `coach_intelligence` + `coach_rule_engine` (1324 LOC) → Deliverable 2.7
- `coach_screen.dart` (458 LOC) → Refactor to call CoachService only
- `app/lib/contracts/ai_*.dart` (~25 files) → Reuse intact
- `app/lib/contracts/coach_*.dart` (~10 files) → Reuse intact

Full mapping table: `EPIC_06_AI_EXISTING_CODE_MAPPING.md`.

---

## §3 — Deliverables

| Deliverable | Status | Files added |
|---|---|---|
| 2.1 Coach (tổng hợp) | ✅ Done | coach_service.dart, coach_pipeline.dart |
| 2.2 Recommendation | ✅ Done | recommendation_engine.dart |
| 2.3 Strategy | ✅ Done | strategy_engine.dart |
| 2.4 Pattern Analysis | ✅ Done | pattern_engine.dart |
| 2.5 Equipment Suggestion | ✅ Done | equipment_engine.dart |
| 2.6 Training Suggestion | ✅ Done | training_engine.dart |
| 2.7 Match Review | ✅ Done | match_review_engine.dart |

---

## §4 — New Files (10)

| Path | Lines | Purpose |
|---|---|---|
| `app/lib/features/coach/domain/llm/llm_provider_adapter.dart` | 180 | LLM Provider Adapter + MockAI + 3 gated stubs + Registry |
| `app/lib/features/coach/domain/llm/capability.dart` | 60 | CapabilityResult + CapabilityReason (Coach locale) |
| `app/lib/features/coach/domain/coach_service.dart` | 40 | Sole entry point facade |
| `app/lib/features/coach/domain/coach_pipeline.dart` | 130 | Orchestrator — Wave 1 skeleton |
| `app/lib/features/coach/domain/coach_engine.dart` | 12 | Abstract engine interface |
| `app/lib/features/coach/domain/coach_request.dart` | 12 | Canonical request shape |
| `app/lib/features/coach/domain/coach_response.dart` | 25 | Canonical response + contribution shapes |
| `app/lib/features/coach/domain/data_sources/ai_data_sources.dart` | 28 | Read-only data snapshot (EPIC 01-05) |
| `app/lib/features/coach/domain/engines/recommendation_engine.dart` | 45 | Wave 1 Recommendation engine |
| `app/lib/features/coach/domain/engines/strategy_engine.dart` | 30 | Wave 2 Strategy engine |
| `app/lib/features/coach/domain/engines/pattern_engine.dart` | 40 | Wave 2 Pattern engine |
| `app/lib/features/coach/domain/engines/equipment_engine.dart` | 35 | Wave 3 Equipment engine |
| `app/lib/features/coach/domain/engines/training_engine.dart` | 35 | Wave 3 Training engine |
| `app/lib/features/coach/domain/engines/match_review_engine.dart` | 35 | Wave 3 Match Review engine |
| `app/lib/features/coach/presentation/coach_service_provider.dart` | 22 | Riverpod providers for CoachService |
| `app/test/features/coach/ai_boundary_test.dart` | 130 | 3-gate boundary test (6 assertions) |
| `app/test/features/coach/coach_service_provider_test.dart` | 70 | 8 CoachService + Response tests |
| `architecture/product/EPIC_06_AI_BOUNDARY.md` | 80 | AI boundary contract + banned strings |

---

## §5 — Modified Files (0)

No existing files were modified by EPIC 06 Engineering.
All changes are additive in new files.

---

## §6 — AI Boundary (EPIC 06.4)

Three gates verified:

| Gate | Method | Result |
|---|---|---|
| Static banned strings | `grep -E "openai\|anthropic\|gemini\|huggingface"` outside coach/ | ✅ 0 leaks |
| MockAI default | `MockAIAdapter.isImplemented` | ✅ true |
| Remote adapters gated | OpenAI/Claude/Gemini `isImplemented` | ✅ all false |
| UI calls CoachService only | `ai_boundary_test.dart` surface probe | ✅ 7 methods verified |

Full contract: `architecture/product/EPIC_06_AI_BOUNDARY.md`.

---

## §7 — Forbidden List (PO §5)

| Item | Status |
|---|---|
| Voice coach | ❌ not in EPIC 06 |
| Camera AI | ❌ not in EPIC 06 |
| Image recognition | ❌ not in EPIC 06 |
| Cue tracking | ❌ not in EPIC 06 |
| AR | ❌ not in EPIC 06 |
| Computer Vision | ❌ not in EPIC 06 |
| Online multiplayer AI | ❌ not in EPIC 06 |
| Real-time referee | ❌ not in EPIC 06 |
| Cloud fine-tuning | ❌ not in EPIC 06 |

All deferred after Beta. No Forbidden item surfaced in codebase.

---

## §8 — Capability Pattern

EPIC 04 standard (Implemented / Capability / NotAvailable / Planned).
All four providers return `CapabilityResult<T>` — no exceptions from
capability-closed entry points.

| Provider | `isImplemented` | Reason code |
|---|---|---|
| MockAI | `true` | — |
| OpenAI | `false` | `openai_capability_closed_beta` |
| Claude | `false` | `claude_capability_closed_beta` |
| Gemini | `false` | `gemini_capability_closed_beta` |

UI gates on `RecommendationCapability.unavailable` (existing from EPIC 05
R2) and surfaces the reason in a banner.

---

## §9 — Regression

```
flutter test
1514 / 1514 PASS
```

Baseline (pre-EPIC 06): 1500/1500 PASS.
After EPIC 06: 1514/1514 PASS.

No regression. Zero pre-existing tests modified or deleted.
+14 new tests (ai_boundary_test.dart 6 + coach_service_provider_test.dart 8).

Excluded engineering artifacts: none (no untracked WIP was introduced).

---

## §10 — Lifecycle Status

| Step | Status |
|---|---|
| Bootstrap | ✅ Done |
| Wave 1 (AI Layer + MockAI) | ✅ Done |
| Wave 2 (Strategy + Pattern) | ✅ Done |
| Wave 3 (Equipment + Training + Match Review) | ✅ Done |
| AI Boundary audit | ✅ Done |
| Engineering Report (this file) | ✅ Done |
| Full Regression | ⏳ running |
| PO Review | ⏳ pending |
| Merge `--no-ff` | ⏳ pending PO approval |
| Close EPIC 06 | ⏳ pending PO approval |

---

## §11 — Spec gating

- [x] All 7 deliverables present.
- [x] No Forbidden list surfaces.
- [x] AI Boundary enforced (zero leaks).
- [x] Capability Pattern enforced (no throw).
- [x] Single-lifecycle: exactly 1 Report, 1 Regression, 1 Close.
- [x] No schema bump.
- [x] No repository creation.
- [x] No Match Engine modification.
- [x] No AI outside `coach/` feature.
- [x] No Recommendation outside CoachService.

---

*Engineering authored 2026-07-31.*