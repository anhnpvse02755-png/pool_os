---
name: epic-05-close
description: EPIC 05 — Knowledge System close record (PO 2026-07-31); 1500/1500 PASS; capability-closed recommendations
metadata:
  type: project
---

EPIC 05 — Knowledge System: closed on 2026-07-31.

Spec:        `architecture/product/EPIC_05_KNOWLEDGE_SYSTEM.md`
Report:      `EPIC_05_ENGINEERING_REPORT.md`
Branch:      `epic/05-knowledge-system` → `master` (merge commit `23c18a6`)
Regression:  `flutter test` → 1500/1500 PASS against official master baseline.
Capability:  Recommendation closed in Beta — 11 entry points now return
             `CapabilityResult.notAvailable(reason)` with reason code
             `recommendation_closed_beta`. UI gates on
             `RecommendationCapability.unavailable`.

Wave Model summary:
  - Wave 1 — Core Knowledge       : KnowledgeItemView + CategoryBrowser +
                                     KnowledgeSearchFacets + PatternBrowser
  - Wave 2 — Content (Beta scope) : Article + Video
  - Wave 3 — User Layer (RO)      : LearningPathBrowser + BookmarkList +
                                     ReadingProgress

Forbidden list status: zero AI / LLM / RAG / Embedding / Vector DB /
Cloud Search / Auto Translation / OCR surfaces introduced. All
recommendation surfaces closed via Capability Pattern.

Excluded engineering artifact: `app/test/features/training_system/training_system_polish_test.dart`
(unmerged EPIC 03 WIP, out of scope per PO R1 Option 2).

Roadmap V3 Beta status:
  EPIC_01 closed / EPIC_02 closed / EPIC_03 closed / EPIC_04 closed /
  EPIC_05 closed.

**Why:** All 5 EPICs closed via the single-lifecycle pattern; the
next active feature is EPIC_06, pending PM scope authorization.

**How to apply:** When the new EPIC_06 spec lands, bootstrap from the
single closed master. Do not reopen EPIC_05 except for bug fix.

Related: [[roadmap-v3-beta-wave-model]], [[capability-pattern]],
[[excluded-engineering-wip]]
