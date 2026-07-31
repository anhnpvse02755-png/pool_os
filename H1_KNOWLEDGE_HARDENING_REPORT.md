# H1 — Knowledge Hardening Report

**Status: Updated with PO decisions 2026-07-31**

> ⚠️ **PO Clarification — What NOT to do:**
> Do NOT edit the 890 existing articles. Do NOT rewrite content.
> Only ADD metadata, taxonomy, and relationships.
> The 890 articles stay as-is.

---

## PO Decisions (2026-07-31)

| Decision | Status |
|---|---|
| Schema ready | ✅ Accepted |
| Content quality (890 items) | ✅ Accepted — "enough for Beta" |
| Relationship audit (broken/duplicate/orphan) | ✅ Accepted |
| Search audit | ✅ Accepted |
| Edit 890 articles | ❌ Rejected — only add metadata |
| Player Assessment | ✅ Accepted as Deliverable 0 |

---

## Revised Priority Order

```
H1.1  Knowledge Metadata        ← PRIORITY 0 (blocker for all H1 work)
H1.2  Relationship Audit
H1.3  Search Audit
H1.4  Video Knowledge Mapping  ← expanded from chapterMarkers
H1.5  Player Assessment Design ← model + flow, no UI yet
```

---

## Section 0: Player Assessment (Deliverable 0)

Full design: `H1_PLAYER_ASSESSMENT.md`

Assessment = gateway to entire ecosystem. Not a new feature — it orchestrates EPIC 02/03/05/06.

```
First Launch → Assessment (15 questions, 2-3 min) → Level + Confidence → Personalized Path → Full Ecosystem Activates
```

---

## Section 1: Schema Audit

Status: Audit Complete
Author: Engineering
Date: 2026-07-31

---

## Executive Summary

**The Knowledge Base is structurally sound but needs restructuring to align with PO's Learning Journey vision.**

The existing schema already supports PO's requirements:
- Articles have difficulty, prerequisites, drillRefs, coachNotes, successCriteria, failureCriteria, commonMistakes, corrections ✅
- 890 knowledge items across 10+ categories ✅
- Vietnamese localization (titleVi) ✅
- Learning paths with phases and milestones ✅
- Drill mapping (200 drills) ✅
- Skill dependency graph ✅

**The critical gap is the player level system.** Current uses I/H/G/F/E... but PO wants Beginner → K → I → H → G → F.

---

## Section 1: Schema Audit

### Article Schema (`article.dart`)

| Field | H1 Requirement | Status |
|---|---|---|
| `difficulty` | Beginner/Intermediate/Advanced | ✅ Already exists |
| `prerequisites` | Skill prerequisites | ✅ Already exists |
| `drillRefs` | Links to drills | ✅ Already exists |
| `coachNotes` | Coach-specific guidance | ✅ Already exists |
| `successCriteria` | What mastery looks like | ✅ Already exists |
| `failureCriteria` | Common mistakes | ✅ Already exists |
| `commonMistakes` | Mistakes to avoid | ✅ Already exists |
| `corrections` | How to fix mistakes | ✅ Already exists |
| `relatedKnowledgeIds` | Cross-links | ✅ Already exists |
| `tags` | Search keywords | ✅ Already exists |
| `references` | External sources | ✅ Already exists |
| `titleVi` | Vietnamese localization | ✅ Already exists |

**Verdict: Schema is ready for H1. No schema change needed.**

### Video Schema (`video_metadata.dart`)

| Field | H1 Requirement | Status |
|---|---|---|
| `duration` | HH:MM:SS format | ✅ Already exists |
| `externalUrl` | Link to video | ✅ Already exists |
| `category` | Video category | ✅ Already exists |
| `channel` | Source channel | ✅ Already exists |
| `tags` | Search keywords | ✅ Already exists |
| `titleVi` | Vietnamese localization | ✅ Already exists |
| Timestamp/chapter markers | Per PO §Video Strategy | ❌ **MISSING** — needs integration |

**Action: Add `chapterMarkers` field to VideoEntry. Each marker = `{offset: Duration, title: String, drillRef: String?}`**

### Pattern Schema (`pattern_browser.dart`)

| Field | H1 Requirement | Status |
|---|---|---|
| `difficulty` | Beginner/Intermediate/Advanced | ✅ Already exists |
| `category` | Pattern category | ✅ Already exists |
| `tags` | Search keywords | ✅ Already exists |
| `relatedPatternIds` | Cross-links | ✅ Already exists |
| `images` | Pattern diagrams | ✅ Already exists (metadata only) |

**Verdict: Pattern schema supports H1 requirements.**

---

## Section 2: Content Inventory

### Knowledge Items by Category

| Category | Count | Status |
|---|---|---|
| aim | 13 | ✅ |
| bank | 8 | ✅ |
| bridge | 28 | ✅ |
| cue_ball | 7 | ✅ |
| equipment | ~50 | ✅ |
| drill_mapping | 200 drills | ✅ |
| learning_paths | 12 paths, 87 skills | ✅ |
| gap_analysis | ~4 | ✅ |
| jump | TBD | ✅ |
| kick | TBD | ✅ |
| **Total** | **~890** | ✅ |

### Content Quality Sample (aim.fundamentals.json)

```json
{
  "id": "aim.fundamentals",
  "difficulty": "beginner",
  "prerequisites": [],
  "setup": ["..."],
  "execution": ["..."],
  "successCriteria": ["..."],
  "failureCriteria": ["..."],
  "commonMistakes": ["..."],
  "corrections": ["Drill: Straight shot practice"],
  "drillRefs": ["AIM001", "AIM002"],
  "coachNotes": "...",
  "relatedKnowledge": [{"id": "aim.ghost_ball", "type": "technique"}],
  "recommendedFor": ["I", "H", "G", "F", "E", "D", "C", "B", "A"],
  "sources": ["Dr. Dave", "WPA coaching manual"]
}
```

**Verdict: Content quality is excellent. Structured, actionable, bilingual.**

---

## Section 3: H1.1 — Knowledge Metadata (PRIORITY 0)

**PO Decision: DO NOT edit the 890 articles. Only ADD metadata.**

### What to Add (no content changes)

Every article gets NEW metadata fields:

```json
{
  "id": "cue_ball.stop_shot",
  "difficulty": 2,                    // NEW: 1-6 scale (1=Beginner, 6=F)
  "estimatedMinutes": 15,            // NEW: time to learn
  "prerequisites": ["aim.fundamentals", "bridge.fundamentals"],  // NEW: skill IDs
  "nextKnowledge": ["cue_ball.follow_shot", "cue_ball.draw_shot"], // NEW: progression
  "recommendedDrills": ["STOP001", "STOP002"],   // NEW: drill codes
  "recommendedVideos": [           // NEW: video knowledge mapping
    { "videoId": "tor_lowry_stop_shot", "timestamp": "00:42", "topic": "grip" },
    { "videoId": "tor_lowry_stop_shot", "timestamp": "04:53", "topic": "practice" }
  ],
  "estimatedMastery": "15_minutes"  // NEW: time to master
}
```

### Difficulty Scale (6 levels)

| Level | Value | Description |
|---|---|---|
| Beginner | 1 | Never played |
| K | 2 | Played, no fundamentals |
| I | 3 | Rank I |
| H | 4 | Rank H |
| G | 5 | Rank G |
| F | 6 | Rank F+ |

### What Engineering Does

1. Add `difficulty` (int 1-6), `estimatedMinutes`, `prerequisites`, `nextKnowledge`, `recommendedDrills`, `recommendedVideos`, `estimatedMastery` to JSON schema
2. Write metadata generator tool (not manually edit 890 files)
3. Populate metadata using AI extraction (see Video section) or rule-based generation

### What Engineering Does NOT Do

❌ Edit article markdown content
❌ Rewrite articles
❌ Change article structure
❌ Manually edit 890 files

---

## Section 4: H1.2 — Relationship Audit

| Item | Status | Priority |
|---|---|---|
| Broken `relatedKnowledge` links | ❌ NOT AUDITED | **HIGH** |
| Broken `drillRefs` links | ❌ NOT AUDITED | **HIGH** |
| Orphaned articles (no category) | ❌ NOT AUDITED | **HIGH** |
| Duplicate articles | ❌ NOT AUDITED | **MEDIUM** |
| Circular prerequisites | ❌ NOT AUDITED | **HIGH** |

---

## Section 5: H1.3 — Search Audit

| Item | Status | Priority |
|---|---|---|
| Alias coverage (english/spin/draw/follow) | ❌ NOT AUDITED | **HIGH** |
| Tag coverage | ❌ NOT AUDITED | **MEDIUM** |
| Search ranking quality | ❌ NOT AUDITED | **HIGH** |
| VI keyword coverage | ❌ NOT AUDITED | **MEDIUM** |

---

## Section 6: H1.4 — Video Knowledge Mapping

**PO Expansion: chapterMarkers → full video-knowledge mapping.**

### Target Structure

```dart
class VideoChapterMarker {
  final Duration offset;
  final String topic;           // maps to knowledge skillId
  final String? drillRef;      // linked drill
  final String titleEn;
  final String titleVi;
}

class VideoKnowledgeMapping {
  final String videoId;
  final List<VideoChapterMarker> chapters;
}
```

### Example: Tor Lowry "How to Draw Shot"

```
Video chapters:
  00:00  Intro
  01:42  Grip                   → knowledge: "grip.fundamentals"
  04:53  Cue Action             → knowledge: "stroke.fundamentals"
  08:11  Practice Drill         → drill: "DRAW001"

Knowledge article "Draw Shot" gets:
  recommendedVideos: [
    { videoId: "tor_lowry_draw", timestamp: "01:42", topic: "grip" },
    { videoId: "tor_lowry_draw", timestamp: "04:53", topic: "cue_action" },
    { videoId: "tor_lowry_draw", timestamp: "08:11", topic: "drill", drillRef: "DRAW001" }
  ]
```

### This enables AI Coach to say:

> "Watch this drill at 08:11 of the Draw Shot video."

---

## Section 7: H1.5 — Player Assessment Design

Full design: `H1_PLAYER_ASSESSMENT.md`

Assessment = trigger mechanism for entire ecosystem. Design drafted.

Pending: PO decision on rule-based vs AI-based scoring.

---

## Section 8: Revised Action Plan (PO Priorities)

### H1.1 — Knowledge Metadata (PRIORITY 0 — BLOCKER)

1. Add 7 new metadata fields to article schema (difficulty, estimatedMinutes, prerequisites, nextKnowledge, recommendedDrills, recommendedVideos, estimatedMastery)
2. Write metadata generator tool
3. Generate metadata for all 890 articles (automated, not manual)

### H1.2 — Relationship Audit

1. Script to find broken `relatedKnowledge` IDs
2. Script to find broken `drillRefs`
3. Script to find orphaned articles
4. Script to find duplicates
5. Fix or flag issues

### H1.3 — Search Audit

1. Check alias coverage (common terms)
2. Verify tag completeness
3. Audit search ranking

### H1.4 — Video Knowledge Mapping

1. Add `chapterMarkers` to VideoEntry schema
2. Add `recommendedVideos` to Article schema
3. Map chapters → knowledge skillIds
4. Map chapters → drill codes

### H1.5 — Player Assessment Design

1. Finalize question set (15 questions)
2. Design assessment result model
3. Design learning path auto-generation
4. Design reassessment trigger

---

## Section 9: Summary

| Priority | Item | Action |
|---|---|---|
| **0 — BLOCKER** | Knowledge Metadata | Add 7 fields to schema, write generator tool |
| 1 | Relationship Audit | Script to find broken links/orphans/duplicates |
| 2 | Search Audit | Alias coverage, tag completeness, ranking |
| 3 | Video Knowledge Mapping | chapterMarkers + recommendedVideos |
| 4 | Player Assessment | Finalize model + flow |

**PO confirmed: Do NOT edit 890 articles. Only add metadata.**
This approach gives AI Coach the data it needs without rewriting content.

---

## PO Decisions Accepted

| PO Decision | Engineering Action |
|---|---|
| Schema ready | ✅ No schema restructure |
| 890 articles sufficient | ✅ No content rewrite |
| Relationship audit | ✅ Script + fix |
| Search audit | ✅ Audit + fix |
| No article edits | ✅ Only add metadata |
| Player Assessment as Deliverable 0 | ✅ Design drafted |

---

*Audit completed by Engineering 2026-07-31. Updated with PO decisions 2026-07-31.*
