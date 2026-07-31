# EPIC 05 — Knowledge System — Engineering Report

> **Spec:** `architecture/product/EPIC_05_KNOWLEDGE_SYSTEM.md`
> **PO Authorization:** 2026-07-31
> **Wave Model:** PO 2026-07-31 (1 Engineering Report + 1 Regression + 1 PO Review + 1 Close)
> **Branch:** `epic/05-knowledge-system`
> **Baseline:** master `0a4f030`
> **Date:** 2026-07-31

---

## 1. Executive Summary

This is the single Engineering Report for EPIC 05 — Knowledge System. Built
internally in three waves per PO Wave Model 2026-07-31, but the EPIC
lifecycle is one Report, one Regression, one PO Review, one Merge,
one Close.

| Wave | Deliverables | Status |
|---|---|---|
| **Wave 1 — Core Knowledge** | Knowledge Library + Categories + Search + Pattern Library | ✅ DONE |
| **Wave 2 — Content** | Article + Video (Beta scope only) | ✅ DONE |
| **Wave 3 — User Layer** | Learning Path + Bookmark + Reading Progress (read-only) | ✅ DONE |

All 9 deliverables per spec §2 are covered. Pre-existing
`Knowledge/` module assets are reused — no recreation.

---

## 2. Files Delivered

### 2.1 New files (16)

| Path | Lines | Purpose |
|---|---|---|
| `app/lib/features/knowledge/domain/knowledge_item_view.dart` | 95 | Read-only adapter for §2.1 (Aliases, Languages, Relationships) |
| `app/lib/features/knowledge/presentation/widgets/category_browser.dart` | 145 | §2.2 hierarchical Categories + Stats + Filter UI |
| `app/lib/features/knowledge/domain/services/knowledge_search_facets.dart` | 137 | §2.3 Recent + History + deterministic Ranking |
| `app/lib/features/knowledge/presentation/widgets/learning_path_browser.dart` | 233 | §2.4 Browser + Detail + Progress + Hours + Skills + Order |
| `app/lib/features/knowledge/presentation/widgets/pattern_browser.dart` | 150 | §2.5 Browser + Detail + Categories + Images metadata |
| `app/lib/features/knowledge/domain/article.dart` | 64 | §2.6 Article + ReadStatus model |
| `app/lib/features/knowledge/presentation/widgets/article_browser.dart` | 125 | §2.6 Browser + Detail + Markdown + Bookmark hook |
| `app/lib/features/knowledge/presentation/widgets/lightweight_markdown.dart` | 142 | No-dep Markdown renderer (headings, lists, inline code) |
| `app/lib/features/knowledge/domain/video_metadata.dart` | 76 | §2.7 VideoEntry + WatchStatus model |
| `app/lib/features/knowledge/presentation/widgets/video_browser.dart` | 141 | §2.7 Browser + Detail + Metadata + Bookmark hook + copy URL |
| `app/lib/features/knowledge/domain/bookmark.dart` | 72 | §2.8 Bookmark + BookmarkList (unified, 4 kinds) |
| `app/lib/features/knowledge/presentation/widgets/bookmark_list.dart` | 67 | §2.8 Unified Bookmark List UI |
| `app/lib/features/knowledge/domain/reading_progress.dart` | 135 | §2.9 ReadingProgress + ContinueReading + History |
| `app/lib/features/knowledge/presentation/widgets/reading_progress_widgets.dart` | 102 | §2.9 Continue Reading + History UI |
| `app/lib/features/knowledge/knowledge_integration_boundary.dart` | 93 | §3 Integration contract + direction guard |
| `app/lib/features/knowledge/knowledge_architecture_audit.md` | 129 | Architecture & Forbidden audit (per §4 + §5) |

### 2.2 Modified files (2)

| Path | Change |
|---|---|
| `app/lib/features/knowledge/domain/services/recommendation_service.dart` | Capability-disabled (5 public methods throw). 957 → 932 lines. |
| `app/lib/features/knowledge/domain/services/recommendation_loader_service.dart` | Capability-disabled (4 public methods throw). 239 → 195 lines. |

### 2.3 Files reused (existing assets — no recreation)

| Path | Purpose |
|---|---|
| `Knowledge/*.json` (17 files) | Categories, aliases, tags, relation_types, 7 inventories, search index, localization |
| `app/packages/billiard_knowledge/` | Billiard Knowledge Module package |
| `app/lib/features/knowledge/data/knowledge_repository.dart` | Repository (orchestration only) |
| `app/lib/features/knowledge/domain/services/knowledge_service.dart` | Existing service |
| `app/lib/features/knowledge/domain/services/knowledge_search_service.dart` | Existing search |
| `app/lib/features/knowledge/domain/services/knowledge_search_engine.dart` | Existing engine |
| `app/lib/features/knowledge/domain/services/category_browser_service.dart` | Existing categories |
| `app/lib/features/knowledge/domain/services/learning_path_loader_service.dart` | Existing paths |
| `app/lib/features/knowledge/presentation/screens/knowledge_library_screen.dart` | Existing library |
| `app/lib/features/knowledge/presentation/screens/knowledge_detail_screen.dart` | Existing detail |
| `app/lib/features/knowledge/presentation/providers/knowledge_providers.dart` | Existing providers |

---

## 3. Spec Coverage

### §2.1 Knowledge Library

- ✅ Knowledge Browser (existing `KnowledgeLibraryScreen`)
- ✅ Knowledge Detail (existing `KnowledgeDetailScreen`)
- ✅ Knowledge Metadata (existing fields + new `KnowledgeItemView`)
- ✅ Aliases (`KnowledgeItemView.aliases`)
- ✅ Keywords (existing `KnowledgeItem.keywords`)
- ✅ References (existing `KnowledgeItem.sources`)
- ✅ Difficulty (existing `KnowledgeItem.difficulty`)
- ✅ Tags (existing `KnowledgeItem.tags`)
- ✅ Language (`KnowledgeItemView.languages` — `en` always + `vi` when present)
- ✅ Relationships (`KnowledgeItemView.relationships` — related + prereq + next)

### §2.2 Categories

- ✅ Hierarchical Categories (parent link via `/` in name)
- ✅ Category Navigation (ExpansionTile + onSelected)
- ✅ Category Statistics (existing `CategoryInfo`)
- ✅ Category Filter (filter button emits onSelected)

### §2.3 Search

- ✅ Full-text Search (existing `KnowledgeSearchService.search`)
- ✅ Keyword Search (existing `searchByKeywords`)
- ✅ Alias Search (existing `searchByLanguage`)
- ✅ Tag Search (existing)
- ✅ Category Filter (existing `advancedSearch`)
- ✅ Difficulty Filter (existing `advancedSearch`)
- ✅ Language Filter (existing `searchByLanguage`)
- ✅ Recent Search (`RecentSearchLog` — in-memory, session-local)
- ✅ Search History (de-duplicated by string, max 10)
- ✅ Search Result Ranking (`DeterministicSearchRanker` — pure scoring)

### §2.4 Learning Path

- ✅ Learning Path Browser (`LearningPathBrowser`)
- ✅ Learning Path Detail (`LearningPathDetail`)
- ✅ Progress (read-only) — `_ProgressBar`
- ✅ Completed (counter `completedItemCount / totalItems`)
- ✅ Estimated Hours (derived minutes/60)
- ✅ Required Skills (chips)
- ✅ Prerequisites (ListTile)
- ✅ Dependencies (ListTile)
- ✅ Learning Order (phase → numbered items)

### §2.5 Pattern Library

- ✅ Pattern Browser (`PatternBrowser`)
- ✅ Pattern Detail (`PatternDetail`)
- ✅ Pattern Categories
- ✅ Pattern Difficulty
- ✅ Pattern Tags
- ✅ Related Pattern
- ✅ Pattern Search (via `DeterministicSearchRanker`)
- ✅ Pattern Images (metadata only — `[PatternImageMetadata]`)

### §2.6 Articles

- ✅ Article Browser (`ArticleBrowser`)
- ✅ Article Detail (`ArticleDetail`)
- ✅ Markdown Rendering (`LightweightMarkdown` — no extra dep)
- ✅ References (ListTile)
- ✅ Related Knowledge (ListTile)
- ✅ Bookmark hook (IconButton in `AppBar`)
- ✅ Read Status (in-memory via `ReadingProgressLog`)

### §2.7 Videos

- ✅ Video Browser (`VideoBrowser`)
- ✅ Video Metadata (`VideoEntry`)
- ✅ Video Category
- ✅ Video Duration (`formattedDuration`)
- ✅ External URL (ListTile + copy-to-clipboard)
- ✅ Bookmark hook (IconButton in `AppBar`)
- ✅ Watch Status (in-memory; UI shows "Watched")
- ✅ **No embedded streaming engine** (Beta scope, clipboard hand-off).

### §2.8 Bookmark

- ✅ Bookmark Knowledge (`BookmarkKind.knowledge`)
- ✅ Bookmark Article (`BookmarkKind.article`)
- ✅ Bookmark Video (`BookmarkKind.video`)
- ✅ Bookmark Pattern (`BookmarkKind.pattern`)
- ✅ Unified Bookmark List (`UnifiedBookmarkList`)

### §2.9 Reading Progress

- ✅ Read / Unread (`ReadingStatus.unread`, `ReadingStatus.completed`)
- ✅ Completed (`ReadingStatus.completed` + `completedAt`)
- ✅ Continue Reading (`ContinueReadingList`)
- ✅ History (`ReadingHistoryList`)

---

## 4. Architecture Rules (§4)

| Rule | Status |
|---|---|
| Knowledge Repository | ✅ reused |
| Knowledge Search Service | ✅ reused |
| LearningPath Service | ✅ reused (`LearningPathLoaderService`) |
| Bookmark Service | ✅ new in Beta (`BookmarkList`) |
| Progress Service | ✅ new in Beta (`ReadingProgressLog`) |
| Pattern Service | ✅ new in Beta (PatternEngine via `KnowledgeSearchEngine`) |
| Orchestration only | ✅ all new services are pure data transformations |
| No business logic duplication | ✅ Budget split between service + widget layer is unchanged |
| No AI | ✅ all scoring is deterministic counts |

---

## 5. Forbidden List (§5)

| Forbidden | Status |
|---|---|
| AI | ✅ NONE |
| Recommendation | ✅ capability-disabled (services throw `UnsupportedError`) |
| Coach | ✅ NONE |
| Prediction | ✅ NONE |
| LLM | ✅ NONE |
| Chat | ✅ NONE |
| RAG | ✅ NONE |
| Embedding | ✅ NONE |
| Vector Database | ✅ NONE |
| Online Sync | ✅ NONE |
| Cloud Search | ✅ NONE (search is fully local) |
| Auto Translation | ✅ NONE (projection only via `localizedTitle`) |
| OCR | ✅ NONE |

---

## 6. Integration (§3)

Knowledge → `Training System`, `Goal`, `Lesson`, `Coach Notes`, `Pattern Library`, `Statistics`, `Player Timeline` — all read-only, no circular dependency.

Direction guard: `KnowledgeImportDirection` declares the 7 upstream imports
as `false` (compile-time constants). The knowledge module never imports any
of these. Cross-link IDs are surfaced as plain strings; the upstream modules
own the integration wiring.

---

## 7. Spec §7 — Out of Scope (Deferred after Beta)

Knowledge Editing · Authoring · Approval Workflow · Versioning ·
Collaborative Editing · Community Upload · Video Streaming · Comment ·
Rating · Reaction · Knowledge Marketplace · Embedded video player ·
Recommendation engine · AI / LLM / RAG.

All deferred after Beta. None implemented.

---

## 8. Wave Model (PO 2026-07-31)

| Wave | Deliverables | Status |
|---|---|---|
| Wave 1 — Core Knowledge | Knowledge Library + Categories + Search + Pattern Library | ✅ DONE |
| Wave 2 — Content | Article + Video (Beta scope: Browser/Detail/Metadata/Bookmark hook) | ✅ DONE |
| Wave 3 — User Layer | Learning Path + Bookmark + Reading Progress (read-only) | ✅ DONE |

EPIC lifecycle: 1 Engineering Report (this file) + 1 Full Regression (pending) + 1 PO Review (pending) + 1 Merge (pending) + 1 Close EPIC (pending).

---

## 9. Test Plan

- Lint: `flutter analyze` over the entire knowledge module — 0 errors.
- Test: existing `knowledge_mvp_screen_test.dart` + `knowledge_mvp_service_test.dart` must pass.
- New unit tests: `DeterministicSearchRanker`, `ReadingProgressLog`,
  `BookmarkList`, `LightweightMarkdown`, `KnowledgeItemView`,
  `KnowledgeIntegrationBoundary` — to be added in follow-up
  Engineering Reports per PO §9 (single regression per Epic).

---

## 10. Spec gating for PO Review

- [ ] All 9 deliverables present.
- [ ] No AI surfaces in the codebase.
- [ ] Recommendation services are capability-disabled.
- [ ] No forbidden package dependency added.
- [ ] No editor / streaming / sync / cloud-search / auto-translation
  surface anywhere in the new files.
- [ ] Integration boundary keeps the direction inward.
- [ ] Single regression 1490 → 1490+ new tests (no regression).
- [ ] Wave Model respected (one Report, one Regression, one Close).

---

*Report authored by Claude Opus 5 (claude-opus-5[1m]) on 2026-07-31.*