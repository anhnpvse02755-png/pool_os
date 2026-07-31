# EPIC 07 — Community

Status:
Authorized

Roadmap:
Roadmap V3 (Beta)

Owner:
Product Owner

Priority:
Medium

Dependencies:

- Foundation Features 001–012
- EPIC 01 — Match Engine
- EPIC 02 — Statistics & Analytics
- EPIC 03 — Training System
- EPIC 04 — Tournament & Competition System
- EPIC 05 — Knowledge System
- EPIC 06 — AI Coach

Wave Model:
Internal — 3 Waves, but **single lifecycle** (1 Engineering Report +
1 Full Regression + 1 PO Review + 1 Close) per PO directive 2026-07-31.

---

# §0 — Objective

Introduce a lightweight Community layer allowing players to interact while
keeping Pool OS primarily a personal training application. This Epic focuses
on social interaction.

This Epic does NOT introduce:

- AI
- Recommendation
- Ranking algorithm changes
- Match Engine changes
- Knowledge changes

---

# §1 — Deliverables

## 2.1 Friends

Implement:

- Friend list
- Friend request
- Accept / Reject
- Remove friend
- Friend profile preview

Beta limitation:

- No blocking.
- No private messaging.

## 2.2 Sharing

Allow users to share:

- Match
- Training Session
- Achievement
- Pattern
- Lesson

Share types:

- Public
- Friends only
- Private

No external social network integration.

## 2.3 Activity Feed

Timeline displaying:

- Match completed
- Goal achieved
- Training completed
- New achievement
- Shared lesson
- Shared pattern

Ordered by timestamp. Read-only timeline.

## 2.4 Challenge

Player can create challenge:

- Race to 9
- Practice challenge
- Drill challenge

States: Pending / Accepted / Declined / Completed / Cancelled.

No matchmaking. No automatic pairing.

## 2.5 Achievement

Community achievements:

- Win streak
- 100 matches
- 30 training days
- Pattern master
- Breaking specialist

Only display existing statistics. No AI.

## 2.6 Comment

Comments on:

- Shared match
- Shared lesson
- Shared article
- Shared pattern

Nested reply: Maximum 1 level. No reactions. No emoji engine.

## 2.7 Notification

Notification Center.

Types:

- Friend request
- Challenge
- Comment
- Achievement
- Share interaction

Read / unread state only. No push notification service.

---

# §2 — Architecture

```
Community UI
  ↓
CommunityService          ← sole entry point
  ↓
CommunityPipeline        ← orchestrator
  ↓
6 Engines
 ├── FriendsEngine
 ├── FeedEngine
 ├── ChallengeEngine
 ├── AchievementEngine
 ├── CommentEngine
 └── NotificationEngine
  ↓
Repository              ← Community data only
```

Community is isolated. No direct dependency on:

- Match Engine
- AI Coach
- Knowledge Engine

Only consumes their published data. Capability Pattern enforced for
unavailable features (same as EPIC 04 + EPIC 06).

---

# §3 — Scope

## Included

- Friends
- Feed
- Share
- Challenge
- Achievement
- Comment
- Notification

## Excluded

- Chat
- Voice / Video / Live streaming
- Club / Guild / Marketplace
- Social ranking
- Tournament matchmaking
- AI moderation
- Realtime websocket
- External social login (Facebook / Discord / Telegram / Zalo)

---

# §4 — Capability Pattern

Unavailable Community features must return:

```
CapabilityResult.notAvailable(...)
```

No production exception. Same pattern as EPIC 04 and EPIC 06.

---

# §5 — Data Ownership

Community owns:

- Friend
- Challenge
- Comment
- Notification
- Activity

Community never owns:

- Match
- Training
- Knowledge
- Statistics

It references them.

---

# §6 — UI Requirements

Required screens:

- Friends
- Activity Feed
- Challenge
- Achievement
- Notification
- Share Dialog
- Comment Sheet

---

# §7 — Beta Constraints

- No realtime synchronization.
- No websocket.
- No online presence.
- No typing indicator.
- No push notification.
- Polling / local refresh only.

---

# §8 — Forbidden

Engineering must NOT implement:

- AI friend suggestion
- Recommendation
- Community ranking algorithm
- Chat / Messaging / Voice / Video / Streaming
- Marketplace
- Social network integration
- Realtime infrastructure

---

# §9 — Lifecycle (single — Roadmap V3 Beta)

```
Wave 1  — Social Foundation (Friends / Sharing / Activity Feed)
Wave 2  — Interaction (Challenge / Comment / Notification)
Wave 3  — Recognition (Achievement / UI polish / Integration / Architecture audit)
         ↓
1 Engineering Report
         ↓
1 Full Regression
         ↓
1 PO Review
         ↓
1 Merge
         ↓
1 Close
```

No review, regression, or merge between Waves.

---

*Spec authored by PO 2026-07-31, recorded by Engineering.*