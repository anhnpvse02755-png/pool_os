# Pool OS Product Roadmap V3 (Beta)

> **Status:** Accepted; Authoritative.
> **Freeze:** This roadmap is frozen. PO will only add content inside each
> Epic at its implementation turn. No further renaming or restructuring.
> **Supersedes:** None yet (current).
> **Date:** 2026-07-29.

---

## Why V3

Roadmap V2 enumerated 65+ small features. After observing the cost and
instability that produced — repeated scope renego­tiations, repeated
regression, repeated drift — Product froze V3 to:

- Keep **FEATURE_001 → FEATURE_012** exactly as currently captured in
  this repository.
- After FEATURE_012, ship **9 Epics** instead of dozens of small
  features.
- Each Epic may be split internally into many tasks, but Product
  reviews and regression runs happen **at Epic boundary**, not at every
  internal task.
- The roadmap mirrors real product release milestones:
  Foundation → Match → Statistics → Training → **Beta**.

---

## Foundation (preserved)

| ID          | Feature                                     | Status                  |
| ----------- | ------------------------------------------- | ----------------------- |
| FEATURE_001 | Player Model And Progression                | Closed                  |
| FEATURE_002 | Equipment Performance Profile               | Closed                  |
| FEATURE_003 | Player Career Timeline                      | Closed                  |
| FEATURE_004 | Atomic Active Player Lifecycle              | Closed                  |
| FEATURE_005 | Player Profile Compatibility And Provenance | Closed                  |
| FEATURE_006 | Match Identity Compatibility And Provenance | Closed                  |
| FEATURE_007 | Match Lifecycle State Policy                | Closed                  |
| FEATURE_008 | Match Recording Transaction Integrity       | Authorized              |
| FEATURE_009 | Player Timeline                             | Closed                  |
| FEATURE_010 | Equipment Recommendation                    | Closed                  |
| FEATURE_011 | Equipment History                           | Pending Close           |
| FEATURE_012 | Equipment Comparison                        | Pending Close           |

---

## EPIC 01 — Match Engine

The heart of Pool OS. The full play experience.

- Match Recording
- Live Score
- Undo
- Shot History
- Game Rules
- Race
- Winner
- Break
- Foul
- Safety
- Match Summary

## EPIC 02 — Statistics & Analytics

- Dashboard
- Match Statistics
- Equipment Statistics
- Player Statistics
- Session Statistics
- Trend
- Charts
- Performance

No AI. Analysis over existing data only.

## EPIC 03 — Training System

- Drill
- Practice Session
- Goal
- Progress
- Personal Training Program
- Lesson
- Coach Notes

## EPIC 04 — League & Tournament

- League
- Tournament
- Ranking
- Bracket
- Handicap
- Season
- Team

## EPIC 05 — Knowledge System

- Billiard Knowledge
- Learning Path
- Search
- Categories
- Video
- Article
- Pattern Library

## EPIC 06 — AI Coach

This is where AI lives. All AI surfaces are confined to this Epic.

- Coach
- Recommendation
- Strategy
- Pattern Analysis
- Equipment Suggestion
- Training Suggestion
- Match Review

## EPIC 07 — Community

- Friends
- Sharing
- Activity Feed
- Challenge
- Achievement
- Comment
- Notification

## EPIC 08 — Marketplace

- Equipment Review
- Equipment Rating
- Equipment Comparison (extended — built on FEATURE_012 foundation)
- Buy / Sell
- Marketplace
- Wishlist
- Inventory

**Note:** FEATURE_012 only compares the player's own cues. Marketplace
comparison is a separate product layer on top of that foundation.

## EPIC 09 — Administration

- Admin
- Moderation
- Configuration
- System Settings
- Audit
- Backup
- Import / Export

---

## Beta release criteria

Beta ships only when **all** of the following hold:

- FEATURE_001 → FEATURE_012 are complete.
- EPIC 01 (Match Engine) is complete.
- EPIC 02 (Statistics & Analytics) is complete.
- EPIC 03 (Training System) is complete.

The remaining Epics (04–09) are developed **after Beta**.

---

## Cadence

- Epics run sequentially: Epic N+1 starts only after Epic N is accepted
  by Product.
- Within an Epic, internal tasks are not surfaced to Product. Product
  reviews and regression runs happen at Epic boundary.
- This cadence reduces regression load and keeps the roadmap stable.
