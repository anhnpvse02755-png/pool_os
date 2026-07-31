# EPIC 06 — AI Coach

Status:
Authorized

Roadmap:
Roadmap V3 (Beta)

Owner:
Product Owner

Priority:
High

Dependencies:

- Foundation Features 001–012
- EPIC 01 — Match Engine
- EPIC 02 — Statistics & Analytics
- EPIC 03 — Training System
- EPIC 04 — Tournament & Competition System
- EPIC 05 — Knowledge System

Wave Model:
Internal — 3 Waves, but **single lifecycle** (1 Engineering Report + 1 Full
Regression + 1 PO Review + 1 Close) per PO directive 2026-07-31.

---

# §0 — Scope boundary

EPIC 06 is the **only** Epic allowed to host AI surfaces in Pool OS v3
Beta. AI must never appear in:

- EPIC 01 Match Engine
- EPIC 02 Statistics & Analytics
- EPIC 03 Training System
- EPIC 04 Tournament & Competition
- EPIC 05 Knowledge System

EPICs 01–05 are data sources only. EPIC 06 is the only consumer that
calls LLM APIs. This is enforced both statically (no AI deps in
upstream features) and at runtime through the LLM Provider Adapter.

---

# §1 — Mục tiêu

Toàn bộ AI của Pool OS phải đi qua **AI Layer** (this Epic). Cấu trúc:

```
UI
 ↓
CoachService                 ← sole entry point
 ↓
CoachPipeline                ← orchestrates engines
 ↓
Engines (deterministic + AI shells)
 ├── RecommendationEngine
 ├── StrategyEngine
 ├── PatternEngine
 ├── EquipmentEngine
 ├── TrainingEngine
 └── ReviewEngine
 ↓
LLM Provider Adapter         ← never direct LLM calls
 ├── MockAI         (default, offline)
 ├── OpenAI
 ├── Claude
 └── Gemini
```

LLM Provider Adapter exists from day 1 so the same CoachService can
swap providers without code churn. MockAI is the Beta default so no API
keys are required for offline/test runs. The other adapters are
guarded via capability (default disabled) and enabled only when the
deployment has credentials.

---

# §2 — Deliverables

## 2.1 Coach (tổng hợp)

AI Coach tổng hợp. Trả lời:

- Hôm nay nên tập gì
- Vì sao đang tiến bộ / chững lại
- Điểm mạnh
- Điểm yếu
- Kế hoạch tiếp theo

## 2.2 Recommendation

Recommendation Engine. Ví dụ:

- Bài tập nên tập
- Lesson nên học
- Knowledge nên đọc
- Pattern nên xem

Replaces the capability-closed `RecommendationService` from EPIC 05
R2 (`CapabilityResult.notAvailable`). The Beta closure stays intact
— EPIC 06 must explicitly re-open the capability via PO authorization.

## 2.3 Strategy

Chiến lược. Ví dụ:

- Race ngắn
- Race dài
- Đang dẫn
- Đang thua

## 2.4 Pattern Analysis

AI đọc:

- Shot history
- Position history
- Miss history

→ phát hiện pattern.

## 2.5 Equipment Suggestion

AI gợi ý:

- Cue
- Shaft
- Tip
- Chalk

dựa trên style, statistics, equipment history.

## 2.6 Training Suggestion

AI sinh chương trình tập.

Input:

- Goal
- Statistics
- Training History
- Knowledge

Output:

- Program
- Weekly Plan
- Daily Plan

## 2.7 Match Review

Sau mỗi trận. AI review:

- Điểm mạnh
- Lỗi
- Pattern
- Recommendation

---

# §3 — Architecture rules

| Surface | Rule |
|---|---|
| `CoachService` | Sole entry point. UI calls this — never engines directly. |
| `CoachPipeline` | Orchestrator. Owns engine ordering, fan-out, and aggregation. |
| `CoachEngine` (abstract) | One concrete subclass per §2.2–§2.7. |
| `LlmProviderAdapter` | Adapter surface; engines call this. MockAI default. |
| Data sources | Read-only via existing repositories from EPIC 01–05. |

Engines NEVER call LLM directly. Engines run through the adapter.
Engines ALWAYS use the shared `Conversation`/`Context` shape so a
debug replay can substitute MockAI for any provider.

---

# §4 — AI Boundary (static + runtime)

PO directive 2026-07-31: AI must not leak outside this Epic. Audit
gates:

1. **Static** — `grep -E "openai|anthropic|claude|gemini|huggingface|llm"`
   in `app/lib/features/{match,statistics,training,tournament,knowledge}/`
   must return zero results. Negative test as part of the regression.
2. **Runtime** — capability guard on every LLM call path. Default
   disabled in Beta; explicit PO authorization required to enable
   non-MockAI adapters.
3. **Audit document** — `architecture/product/EPIC_06_AI_BOUNDARY.md`
   documents the AI boundary, capability status, and audit results.

---

# §5 — Forbidden list (in-scope but disallowed in Beta)

- Voice coach (audio output) → deferred after Beta
- Camera AI → deferred after Beta
- Image recognition → deferred after Beta
- Cue tracking → deferred after Beta
- AR (augmented reality) → deferred after Beta
- Computer Vision → deferred after Beta
- Online multiplayer AI → deferred after Beta
- Real-time referee → deferred after Beta
- Cloud fine-tuning → deferred after Beta

---

# §6 — Data sources (read-only)

AI chỉ được đọc từ:

- `app/lib/features/match/` — EPIC 01
- `app/lib/features/statistics/` — EPIC 02
- `app/lib/features/training/` — EPIC 03 (incl. training_system, drill)
- `app/lib/features/tournament/` — EPIC 04
- `app/lib/features/knowledge/` — EPIC 05

Không tạo dữ liệu riêng. Không mutate các repository upstream.

---

# §7 — Out of scope

- Voice coach
- Camera AI / Image recognition / Cue tracking / AR
- Computer Vision
- Online multiplayer AI / Real-time referee
- Cloud fine-tuning
- AI Marketplace (any community-authored engine)
- Any AI that bypasses the LLM Provider Adapter

Tất cả Deferred after Beta.

---

# §8 — Wave Model (internal — single-lifecycle EPIC)

```
Wave 1
  Coach (entry + aggregator)
  RecommendationEngine
  LLM Provider Adapter shell + MockAI default

Wave 2
  StrategyEngine
  PatternAnalysisEngine

Wave 3
  EquipmentSuggestionEngine
  TrainingSuggestionEngine
  MatchReviewEngine
```

Engineering may organize work into these waves for control, but
**the EPIC lifecycle is exactly ONE Engineering Report + ONE Full
Regression + ONE PO Review + ONE Merge + ONE Close**, per Roadmap V3
Beta single-lifecycle discipline (PO 2026-07-31).

---

# §9 — Lifecycle gate (single)

1. Engineering implements Waves 1–3 on branch `epic/06-ai-coach` off
   master `c06417b` (post EPIC 05 close).
2. ONE Engineering Report → `EPIC_06_ENGINEERING_REPORT.md`.
3. ONE Full Regression → `flutter test`.
4. ONE PO Review.
5. ONE Merge `--no-ff` into master.
6. ONE PO Close.

No intermediate merges, no partial regressions, no PO Close between
Waves.

---

# §10 — Files (planned)

```
architecture/product/EPIC_06_AI_COACH.md           ← this spec
architecture/product/EPIC_06_AI_BOUNDARY.md        ← audit
app/lib/features/coach/domain/coach_service.dart  ← sole entry
app/lib/features/coach/domain/coach_pipeline.dart
app/lib/features/coach/domain/engines/             ← 6 engines
app/lib/features/coach/domain/llm/                 ← LLM Provider Adapter
app/lib/features/coach/presentation/coach_screen.dart
EPIC_06_ENGINEERING_REPORT.md
```

---

*Spec authored by PO 2026-07-31, recorded by Engineering.*