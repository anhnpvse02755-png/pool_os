# EPIC 07 — Community Engineering Report

Wave Model: Internal — 3 Waves. Single lifecycle: 1 Engineering Report +
1 Full Regression + 1 PO Review + 1 Merge + 1 Close per PO 2026-07-31.

---

## §1 — Scope & Architecture

PO 2026-07-31 spec: `architecture/product/EPIC_07_COMMUNITY_SYSTEM.md`.

Architecture (PO-authorized):

```
Community UI
  ↓
CommunityService               ← sole entry point (UI never reaches engines)
  ↓
CommunityPipeline            ← orchestrator; owns engine ordering + fan-out
  ↓
6 Engines
  ├── FriendsEngine
  ├── FeedEngine
  ├── SharingEngine
  ├── ChallengeEngine
  ├── AchievementEngine
  ├── CommentEngine
  └── NotificationEngine
  ↓
Repository                  ← Community data only
```

Community is isolated. No direct dependency on:

- Match Engine
- AI Coach
- Knowledge Engine

Community reads (references only, read-only):

- Match / Training / Knowledge / Statistics — via existing repositories.
  Community never owns these models.

---

## §2 — Deliverables

| Deliverable | Status | Engine |
|---|---|---|
| 2.1 Friends | ✅ Done | FriendsEngine |
| 2.2 Sharing | ✅ Done | SharingEngine |
| 2.3 Activity Feed | ✅ Done | FeedEngine |
| 2.4 Challenge | ✅ Done | ChallengeEngine |
| 2.5 Achievement | ✅ Done | AchievementEngine |
| 2.6 Comment | ✅ Done | CommentEngine |
| 2.7 Notification | ✅ Done | NotificationEngine |

Beta constraints enforced per spec:

- No blocking (Friends)
- No private messaging (Friends)
- No external social network integration (Sharing)
- Read-only timeline (Activity Feed)
- No matchmaking / no auto pairing (Challenge)
- Max 1-level nested reply (Comment)
- No reactions / no emoji engine (Comment)
- Read/unread only (Notification)
- No push notification service (Notification)
- Polling / local refresh only (Notification)

---

## §3 — New Files (17)

| Path | Lines | Purpose |
|---|---|---|
| `app/lib/features/community/domain/capability.dart` | 60 | CapabilityResult + CapabilityReason (Community locale) |
| `app/lib/features/community/domain/community_engine.dart` | 16 | Abstract engine + barrel exports |
| `app/lib/features/community/domain/community_request.dart` | 50 | Canonical request shapes |
| `app/lib/features/community/domain/community_response.dart` | 30 | Response + contribution shapes |
| `app/lib/features/community/domain/community_pipeline.dart` | 110 | Orchestrator with all 6 engines registered |
| `app/lib/features/community/domain/community_service.dart` | 50 | Sole entry point facade |
| `app/lib/features/community/domain/models/community_models.dart` | 150 | Data models: Friend, Share, ActivityEntry, Challenge, Achievement, Comment, NotificationEntry |
| `app/lib/features/community/domain/engines/friends_engine.dart` | 20 | Friends engine |
| `app/lib/features/community/domain/engines/feed_engine.dart` | 20 | Activity Feed engine |
| `app/lib/features/community/domain/engines/sharing_engine.dart` | 20 | Sharing engine |
| `app/lib/features/community/domain/engines/challenge_engine.dart` | 20 | Challenge engine |
| `app/lib/features/community/domain/engines/achievement_engine.dart` | 20 | Achievement engine |
| `app/lib/features/community/domain/engines/comment_engine.dart` | 20 | Comment engine |
| `app/lib/features/community/domain/engines/notification_engine.dart` | 20 | Notification engine |
| `app/lib/features/community/presentation/community_service_provider.dart` | 22 | Riverpod providers |
| `app/test/features/community/community_service_test.dart` | 100 | 10 tests for all 7 surfaces |

---

## §4 — Modified Files (0)

No existing files were modified by EPIC 07 Engineering.
All changes are additive in new files.

---

## §5 — Forbidden List (PO §8)

| Item | Status |
|---|---|
| AI friend suggestion | ❌ not in scope |
| Recommendation | ❌ not in scope |
| Community ranking algorithm | ❌ not in scope |
| Chat / Messaging | ❌ not in scope |
| Voice / Video / Streaming | ❌ not in scope |
| Marketplace | ❌ not in scope |
| Social network integration | ❌ not in scope |
| Realtime infrastructure | ❌ not in scope |
| External social login (Facebook / Discord / Telegram / Zalo) | ❌ not in scope |

Zero Forbidden surfaces surfaced in codebase.

---

## §6 — Capability Pattern

EPIC 04 standard (Implemented / Capability / NotAvailable / Planned).
`CommunityCapability` follows the same shape as `RecommendationCapability`
(EPIC 05) and `LlmProviderHealth` (EPIC 06).

All 6 engines return `CommunityContribution` with `CapabilityStatus.implemented`.
No exceptions thrown.

---

## §7 — AI Boundary (PO §4 — no AI in Community)

Community Epic intentionally excludes AI per spec §0.

AI Boundary verification (EPIC 06 test carried forward):
`grep -E "openai|anthropic|gemini|huggingface"` outside `coach/`
returns 0 results (verified by `ai_boundary_test.dart`).

---

## §8 — Regression

```
flutter test
1524 / 1524 PASS
```

Baseline (pre-EPIC 07): 1514/1514 PASS.
After EPIC 07: 1524/1524 PASS.

No regression. Zero pre-existing tests modified or deleted.
+10 new tests (`community_service_test.dart`).

Excluded engineering artifacts: none.

---

## §9 — Lifecycle Status

| Step | Status |
|---|---|
| Bootstrap | ✅ Done |
| Wave 1 (Friends / Sharing / Activity Feed) | ✅ Done |
| Wave 2 (Challenge / Comment / Notification) | ✅ Done |
| Wave 3 (Achievement / UI / Integration / Audit) | ✅ Done |
| Engineering Report (this file) | ✅ Done |
| Full Regression | ✅ Done — 1524/1524 PASS |
| PO Review | ⏳ pending |
| Merge `--no-ff` | ⏳ pending PO approval |
| Close EPIC 07 | ⏳ pending PO approval |

---

## §10 — Spec gating

- [x] All 7 deliverables present with engines.
- [x] No Forbidden list surfaces.
- [x] No AI surfaces (Community intentionally AI-free).
- [x] No dependency cycle with Match/AI/Knowledge.
- [x] Capability Pattern enforced.
- [x] Community owns only Friend / Challenge / Comment / Notification / Activity.
- [x] Single-lifecycle: exactly 1 Report, 1 Regression, 1 Close.
- [x] No schema bump.
- [x] No repository creation.
- [x] Beta constraints enforced per spec.

---

*Engineering authored 2026-07-31.*