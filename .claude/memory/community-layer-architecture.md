---
name: community-layer-architecture
description: EPIC 07 Community Layer — CommunityService sole entry, CommunityPipeline orchestrator, 6 Engines (PO 2026-07-31)
metadata:
  type: project
---

Pool OS v3 Beta — Community Layer architecture (EPIC 07 standard).

```
Community UI
  ↓
CommunityService              ← SOLE public surface; UI never reaches engines
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
Repository                ← Community data only (Friend / Challenge / Comment /
                            Notification / Activity)
```

Data ownership rules:
  Community OWNS: Friend, Challenge, Comment, Notification, Activity
  Community NEVER OWNS: Match, Training, Knowledge, Statistics
  Community REFERENCES (read-only): Match/Training/Knowledge/Statistics repos

Rules:
  - UI ONLY calls CommunityService. No engine, no repo, no upstream deps.
  - Community NEVER calls AI Coach (EPIC 06) or Knowledge Engine.
  - No AI surfaces in Community (Community is intentionally AI-free).

Beta constraints per spec §7:
  No blocking / no private messaging (Friends)
  No external social network integration (Sharing)
  Read-only timeline (Activity Feed)
  No matchmaking / no auto pairing (Challenge)
  Max 1-level nested reply (Comment)
  No reactions / no emoji engine (Comment)
  Read/unread only (Notification)
  No push notification service (Notification)
  Polling / local refresh only (Notification)

**Why:** PO 2026-07-31 — Community provides social interaction without
touching Match/AI/Knowledge. The layer prevents data ownership bleed.

**How to apply:** When adding Community surfaces, they MUST be inside this
layer. New engines register with CommunityPipeline. No new dependency on
Match/AI/Knowledge repositories.

Related: [[roadmap-v3-beta-wave-model]], [[capability-pattern]],
[[ai-layer-architecture]], [[epic-07-close]]
