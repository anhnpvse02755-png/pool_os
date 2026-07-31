# EPIC 06 — Existing Coach Code Mapping

PO 2026-07-31 — Reuse-tối-đa directive. Bảng này được Engineering
audit từ `app/lib/features/coach/` và `app/lib/features/coach_memory/`
trước khi viết code EPIC 06.

Audit (locked baseline `c06417b`): 45 files, ~7,500 LOC. Frozen upstream
of EPIC 06; classifier = Reuse / Refactor / Wrap / Legacy. Số liệu được
Engineering báo cáo qua `flutter analyze` + `wc -l` chứ không phải
phỏng đoán.

## Class shape

| Class | Action | Reason |
|---|---|---|
| Reuse | giữ nguyên class body | vừa khớp EPIC 06 contract |
| Refactor | giữ public surface, cải thiện implementation | đúng intent nhưng code style cần cập nhật |
| Wrap | giữ class làm inner, expose qua adapter mới | class đúng intent nhưng signature/path không khớp deliverable |
| Legacy | không có trong 7 deliverables EPIC 06, không expose ra UI | giữ lại trong codebase, đánh dấu khu vực riêng |

Nguyên tắc PO: không được thêm deliverable thứ 8 chỉ vì code cũ có.

## Mapping table — 45 files

### Deliverable 2.1 — Coach (tổng hợp)

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `coach/domain/brain/coach_brain.dart` | 322 | **Reuse** | Sole decision-maker; orchestrator. |
| `coach/domain/brain/coach_services.dart` | 240 | **Reuse** | Focused services for brain. |
| `coach/domain/brain/coach_output.dart` | 165 | **Reuse** | Feed shaping. |
| `coach/domain/brain/knowledge_registry.dart` | 125 | **Reuse** | Knowledge cross-link. |
| `coach/domain/coach_decision_builder.dart` | 145 | **Refactor** | Public surface ổn; tighten guard. |
| `coach/domain/coach_decision_lifecycle_projector.dart` | 181 | **Reuse** | Lifecycle projector. |
| `coach/application/coach_conversation_service.dart` | 225 | **Wrap** | Trở thành user-side entry vào CoachService. |
| `coach/application/ai_orchestrator.dart` | 87 | **Wrap** | Trở thành CoachPipeline. |
| `coach/application/coach_ai_adapter.dart` | 71 | **Refactor** | Abstract `CoachAIAdapter` giữ nguyên; rename namespace cho rõ ràng. |
| `coach/domain/context/coach_context.dart` | 154 | **Reuse** | Context shape. |
| `coach/domain/coach_execution_projector.dart` | 121 | **Reuse** | Execution projection. |
| `coach/presentation/coach_provider.dart` | 1033 | **Refactor** | Riverpod graph lớn; refactor nhẹ quanh edges. |
| `coach/presentation/coach_conversation_provider.dart` | 65 | **Reuse** | Conversation provider. |

### Deliverable 2.2 — Recommendation

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `coach/domain/coach_recommendation_engine.dart` | 630 | **Reuse** | Already implements recommendation shape. |
| `coach/domain/coach_recommendation_builder.dart` | 70 | **Reuse** | Builder. |
| `coach/domain/adaptive_recommendation_engine.dart` | 157 | **Wrap** | Becomes EPIC 06 `RecommendationEngine`. |
| `knowledge/.../recommendation_service.dart` | 230 | **Wrap** | Was capability-closed in EPIC 05 R2; re-open via CoachService. |
| `knowledge/.../recommendation_loader_service.dart` | 105 | **Wrap** | Loader side. |

### Deliverable 2.3 — Strategy

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `coach/domain/match_objective_policy.dart` | 55 | **Reuse** | Match objective policy drives strategy. |
| `coach/domain/coach_planning_engine.dart` | 109 | **Wrap** | Becomes part of StrategyEngine. |
| `coach/domain/coach_planner.dart` | 38 | **Wrap** | Planner. |
| `coach/domain/session_execution_coordinator.dart` | 52 | **Refactor** | Session-by-session strategy. |

### Deliverable 2.4 — Pattern Analysis

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `coach/domain/findings/support_producers.dart` | 199 | **Reuse** | Pattern producer. |
| `coach/domain/findings/shot_context_producer.dart` | 151 | **Reuse** | Shot history. |
| `coach/domain/findings/finding.dart` | 93 | **Refactor** | Finding shape. |
| `coach/domain/findings/mastery_snapshot_producer.dart` | 38 | **Wrap** | Mastery snapshot. |
| `coach/domain/findings/performance_snapshot_producer.dart` | 24 | **Wrap** | Performance. |
| `coach/domain/findings/coach_memory_producer.dart` | 23 | **Reuse** | Memory-driven producer. |

### Deliverable 2.5 — Equipment Suggestion

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `equipment/.../*` | (out-of-coach) | **Wrap** | Equipment feature reused through CoachService. |

### Deliverable 2.6 — Training Suggestion

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `coach/domain/training_session_builder.dart` | 41 | **Reuse** | Session builder. |
| `coach/domain/training_outcome_projector.dart` | 56 | **Reuse** | Outcome projector. |
| `coach/application/learning_runtime.dart` | 227 | **Wrap** | Becomes training orchestrator. |
| `coach/application/learning_eligibility_projector.dart` | 71 | **Reuse** | Eligibility gate. |
| `coach/application/ai_session_builder.dart` | 124 | **Wrap** | AI session builder. |
| `coach/application/coach_context_builder.dart` | 21 | **Reuse** | Context builder. |
| `coach/application/prompt_assembly_builder.dart` | 69 | **Wrap** | Adapter side. |

### Deliverable 2.7 — Match Review

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `coach/domain/coach_intelligence.dart` | 662 | **Wrap** | Becomes MatchReviewEngine core. |
| `coach/domain/coach_adaptation_projector.dart` | 31 | **Reuse** | Adaptation projector. |
| `coach/domain/coach_rule_engine.dart` | 1324 | **Refactor** | Big rule engine; refactor pattern. |

### Coach Memory (transverse)

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `coach_memory/data/coach_memory_repository.dart` | 111 | **Reuse** | Memory storage. |
| `coach_memory/domain/coach_memory_consolidator.dart` | 92 | **Reuse** | Memory consolidator. |
| `coach_memory/domain/coach_memory.dart` | 55 | **Reuse** | Memory model. |

### UI (presentation)

| Existing file | LOC | Action | Note |
|---|---|---|---|
| `coach/presentation/coach_screen.dart` | 458 | **Refactor** | UI screen; main entry only via CoachService. |
| `coach/presentation/coach_v2_provider.dart` | 160 | **Refactor** | Provider V2. |
| `coach/presentation/stop_shot_providers.dart` | 99 | **Reuse** | Stop-shot specific. |
| `coach/presentation/coach_action_navigation.dart` | 33 | **Reuse** | Navigation. |
| `coach/presentation/decision_reason_presenter.dart` | 28 | **Reuse** | Reason presenter. |
| `coach/application/stop_shot_runtime.dart` | 1 | **Reuse** | Trivial re-export. |

### Cross — AI Boundary / Contracts

| Existing file | Action | Note |
|---|---|---|
| `app/lib/contracts/ai_*.dart` (~25 files) | **Reuse** | LLM surface contracts already defined. |
| `app/lib/contracts/coach_*.dart` (~10 files) | **Reuse** | Coach surface contracts already defined. |

## Legacy classification

Các file đánh dấu **Wrap** mà không có deliverable hiện hữu sẽ được
giữ nguyên trong codebase để không phá architecture freeze của EPIC
01–05. Không thêm UI/Route mới cho chúng. Nếu sau này EPIC 06 cần
chúng, sẽ mở lại một EPIC mới (không update trong EPIC 06 lifecycle).

## Next steps

1. `CoachService` thin entry — facade ngắn, điều phối 6 engines.
2. `CoachPipeline` — orchestrator (wraps `ai_orchestrator.dart`).
3. `LlmProviderAdapter` — chuẩn EPIC 04 capability pattern
   (Implemented / Capability / NotAvailable / Planned).
4. `MockAI` default + `OpenAI` / `Claude` / `Gemini` capability-gated.
5. `CoachBoundary` — guard chính thức (companion test: grep AI deps
   outside `coach/` returns zero).

Implementation theo Roadmap V3 Beta single-lifecycle: 1 Engineering
Report + 1 Full Regression + 1 PO Review + 1 Merge + 1 Close.
