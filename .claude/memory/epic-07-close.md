---
name: epic-07-close
description: EPIC 07 — Community close record (PO 2026-07-31); 1524/1524 PASS; 7 deliverables; CommunityService → CommunityPipeline → 6 Engines
metadata:
  type: project
---

EPIC 07 — Community System: closed on 2026-07-31.

Spec:        `architecture/product/EPIC_07_COMMUNITY_SYSTEM.md`
Report:      `EPIC_07_ENGINEERING_REPORT.md`
Branch:      `epic/07-community-system` → `master` (merge commit `22eb991`)
Regression:  `flutter test` → 1524/1524 PASS (baseline 1514 + 10 new).

7 deliverables (all done):
  2.1 Friends          → FriendsEngine
  2.2 Sharing         → SharingEngine
  2.3 Activity Feed   → FeedEngine
  2.4 Challenge       → ChallengeEngine
  2.5 Achievement     → AchievementEngine
  2.6 Comment         → CommentEngine
  2.7 Notification    → NotificationEngine

Architecture: CommunityService → CommunityPipeline → 6 Engines → Repository.
Community owns: Friend / Challenge / Comment / Notification / Activity.
Community references (read-only): Match / Training / Knowledge / Statistics.
Isolated from Match/AI/Knowledge per spec §3.

Beta constraints enforced:
  No blocking / no private messaging (Friends)
  No external social network integration (Sharing)
  Read-only timeline (Activity Feed)
  No matchmaking / no auto pairing (Challenge)
  Max 1-level nested reply (Comment)
  No reactions / no emoji engine (Comment)
  Read/unread only (Notification)
  No push notification (Notification)
  Polling / local refresh only (Notification)

AI Boundary: Community intentionally AI-free. ai_boundary_test.dart (EPIC 06)
passes with 0 leaks outside coach/.

Roadmap V3 Beta status:
  EPIC_01 closed / EPIC_02 closed / EPIC_03 closed /
  EPIC_04 closed / EPIC_05 closed / EPIC_06 closed / EPIC_07 closed.

Related: [[roadmap-v3-beta-wave-model]], [[community-layer-architecture]],
[[capability-pattern]], [[epic-06-close]]
