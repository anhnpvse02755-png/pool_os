# EPIC 05 — Architecture & Forbidden Audit

PO authorization: 2026-07-31. Spec: `architecture/product/EPIC_05_KNOWLEDGE_SYSTEM.md`.

This audit certifies that the Beta Knowledge Layer conforms to §4
Architecture Rules and §5 Forbidden list. Single-shot, no per-feature
audit — matches the Wave Model that PO issued on 2026-07-31.

---

## §4 — Architecture Rules (orchestration only, no business logic
duplication, no AI)

| Service / Repository | File | Status |
|---|---|---|
| Knowledge Repository | `app/lib/features/knowledge/data/knowledge_repository.dart` | ✅ pre-existing, read-only adapter |
| Knowledge Search Service | `app/lib/features/knowledge/domain/services/knowledge_search_service.dart` | ✅ pre-existing, pure |
| Knowledge Search Engine | `app/lib/features/knowledge/domain/services/knowledge_search_engine.dart` | ✅ pre-existing, pure |
| Knowledge Search Facets | `app/lib/features/knowledge/domain/services/knowledge_search_facets.dart` | ✅ new in Wave 1, deterministic ranking only |
| Category Browser Service | `app/lib/features/knowledge/domain/services/category_browser_service.dart` | ✅ pre-existing, read-only aggregation |
| Learning Path Loader Service | `app/lib/features/knowledge/domain/services/learning_path_loader_service.dart` | ✅ pre-existing, read-only load |
| Pattern (no engine, only data) | `app/lib/features/knowledge/presentation/widgets/pattern_browser.dart` | ✅ new in Wave 1, view-layer |
| Bookmark List | `app/lib/features/knowledge/domain/bookmark.dart` | ✅ new in Wave 3, pure data |
| Bookmark UI | `app/lib/features/knowledge/presentation/widgets/bookmark_list.dart` | ✅ new in Wave 3 |
| Progress Log | `app/lib/features/knowledge/domain/reading_progress.dart` | ✅ new in Wave 3, pure |
| Progress UI | `app/lib/features/knowledge/presentation/widgets/reading_progress_widgets.dart` | ✅ new in Wave 3 |
| Knowledge Item View | `app/lib/features/knowledge/domain/knowledge_item_view.dart` | ✅ new in Wave 1, view adapter |
| Integration Boundary | `app/lib/features/knowledge/knowledge_integration_boundary.dart` | ✅ new in Wave cross, direction guard |

### Capability-disabled (spec §5)

| Service | File | Status |
|---|---|---|
| Recommendation Service | `app/lib/features/knowledge/domain/services/recommendation_service.dart` | ✅ disabled via capability (5 public methods throw `UnsupportedError`); legacy RFC-REC-001 algorithm retained for post-Beta reference only |
| Recommendation Loader Service | `app/lib/features/knowledge/domain/services/recommendation_loader_service.dart` | ✅ disabled via capability (4 public methods throw `UnsupportedError`) |

---

## §5 — Forbidden list

| Forbidden item | Status | Note |
|---|---|---|
| AI | ✅ NONE | Search uses deterministic count-of-matches scoring; zero learned weights |
| Recommendation | ✅ CLOSED | `RecommendationService` + `RecommendationLoaderService` capability-disabled |
| Coach | ✅ NONE | No coaching logic added |
| Prediction | ✅ NONE | No prediction module |
| LLM | ✅ NONE | No LLM dependency |
| Chat | ✅ NONE | No chat surface |
| RAG | ✅ NONE | No retrieval-augmented generator |
| Embedding | ✅ NONE | No embedding model |
| Vector Database | ✅ NONE | No vector store |
| Online Sync | ✅ NONE | No sync layer |
| Cloud Search | ✅ NONE | Search is fully local (existing `KnowledgeSearchService`) |
| Auto Translation | ✅ NONE | Articles use `localizedTitle(languageCode)` — projection only, no machine translation |
| OCR | ✅ NONE | No OCR module |

---

## §6 — Reuse (no recreation)

Existing Billiard Knowledge Module assets used:

- `Knowledge/aliases.json` (Aliases adapter)
- `Knowledge/categories.json` (Category tree)
- `Knowledge/tags.json` (Tag search)
- `Knowledge/relation_types.json` (Relationships)
- `Knowledge/drills_inventory.json` (Drill cross-link)
- `Knowledge/equipment_inventory.json`
- `Knowledge/mistakes_inventory.json`
- `Knowledge/rules_inventory.json`
- `Knowledge/safety_domain_validation.md`
- `Knowledge/spin_inventory.json` + validation
- `Knowledge/strategies_inventory.json`
- `Knowledge/techniques_inventory.json`
- `Knowledge/vietnamese_localization_data.json`
- `Knowledge/vietnamese_search_index.json`
- `Knowledge/pattern_domain_validation.md`
- `Knowledge/bridge_domain_validation.md`
- `Knowledge/DOMAIN_EXPANSION_REPORT.md`
- `BILLIARD_KNOWLEDGE_V2_ACTIONS.md`
- `app/packages/billiard_knowledge/` (the package itself)
- `app/assets/knowledge/` (assets directory)
- `app/lib/features/knowledge/` (existing service shell)

---

## §7 — Out of scope (Deferred after Beta, per PO Wave Model 2026-07-31)

| Item | Status |
|---|---|
| Knowledge Editing | Deferred after Beta |
| Knowledge Authoring | Deferred after Beta |
| Knowledge Approval Workflow | Deferred after Beta |
| Knowledge Versioning | Deferred after Beta |
| Collaborative Editing | Deferred after Beta |
| Community Upload | Deferred after Beta |
| Video Streaming | Deferred after Beta |
| Comment | Deferred after Beta |
| Rating | Deferred after Beta |
| Reaction | Deferred after Beta |
| Knowledge Marketplace | Deferred after Beta |
| Embedded video player | Deferred after Beta |
| Recommendation engine | Deferred after Beta |
| AI / LLM / RAG | Deferred after Beta |

---

## Wave Model audit (PO 2026-07-31)

| Wave | Deliverables | Status |
|---|---|---|
| **Wave 1 — Core Knowledge** | Knowledge Library, Categories, Search, Pattern Library | ✅ DONE |
| **Wave 2 — Content** | Article, Video (Beta scope: Browser/Detail/Metadata/Bookmark hook only) | ✅ DONE |
| **Wave 3 — User Layer** | Learning Path, Bookmark, Reading Progress (read-only) | ✅ DONE |

---

## Final regression gate (per PO §9)

- Single Engineering Report: pending (`EPIC_05_ENGINEERING_REPORT.md`).
- Single Full Regression: pending.
- Single PO Review: pending.
- Single Merge: pending.
- Single Close EPIC: pending.

No intermediate closures, no partial regressions.

---

*Audit authored by Claude Opus 5 (claude-opus-5[1m]) on 2026-07-31.*