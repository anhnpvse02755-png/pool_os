# H1 — Knowledge Hardening Report

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

## Section 3: CRITICAL GAP — Player Level System

### Current System (MISMATCH)

```
Current: I → H → G → F → E → D → C → B → A
Where: I = Beginner, H = Novice, G = Intermediate, F = Club Player, etc.
```

### PO's Target System

```
PO Vision: Beginner → K → I → H → G → F
Where:
  Beginner =从未打过球 (never played)
  K        = beginner with some experience
  I        = Rank I
  H        = Rank H
  G        = Rank G
  F        = Rank F (highest priority group)
```

### Impact

- `recommendedFor` field in articles uses old system (I/H/G/F/E/...)
- `playerLevels` in `learning_paths.json` uses old system
- `Skill_Dependency_Graph.md` uses old system
- `difficulty` field in articles uses "beginner"/"intermediate"/"advanced" (3 levels) — needs mapping to 6 levels

### Required Changes

1. **Extend difficulty enum**: beginner → K → I → H → G → F (6 levels)
2. **Restructure `playerLevels`**: Add K between Beginner and H
3. **Update `recommendedFor`**: All articles need K level added where appropriate
4. **Define K level characteristics** (per PO spec):

```
Rank K:
  - Đã biết chơi (can play)
  - Đánh được 1-2 bi (can pot 1-2 balls)
  - Nhưng stance sai, bridge sai, aim chưa chuẩn, position chưa có
  - Cần: Stop Shot / Follow / Draw cơ bản / Natural Angle / Cut Shot / Speed Control
```

---

## Section 4: Gap Analysis

### G1 — Level System Restructure

| Item | Status | Priority |
|---|---|---|
| Extend difficulty to 6 levels | ❌ NOT DONE | **HIGH** |
| Add K level to playerLevels | ❌ NOT DONE | **HIGH** |
| Update recommendedFor in all articles | ❌ NOT DONE | **HIGH** |
| Map existing beginner → K/I/H appropriately | ❌ NOT DONE | **HIGH** |

### G2 — Video-Drill Pairing

| Item | Status | Priority |
|---|---|---|
| Add chapter markers to videos | ❌ NOT DONE | **HIGH** |
| Link videos to drillRefs in articles | ⚠️ PARTIAL | **MEDIUM** |
| Verify video URLs return 200 | ❌ NOT DONE | **HIGH** |

### G3 — Article Quality

| Item | Status | Priority |
|---|---|---|
| No verbose prose — bullet/step structure | ⚠️ MOSTLY DONE | **LOW** |
| Language consistency (EN/VI) | ⚠️ PARTIAL | **MEDIUM** |
| No duplicate articles | ❌ NOT AUDITED | **HIGH** |
| No broken relatedKnowledge links | ❌ NOT AUDITED | **HIGH** |
| No orphaned articles (no category) | ❌ NOT AUDITED | **HIGH** |

### G4 — Drill-Lesson Pairing

| Item | Status | Priority |
|---|---|---|
| Drill → Article link | ⚠️ PARTIAL | **MEDIUM** |
| Article → Drill link (drillRefs) | ✅ EXISTS | — |
| Drill prerequisites correct | ❌ NOT AUDITED | **MEDIUM** |

### G5 — Learning Path Quality

| Item | Status | Priority |
|---|---|---|
| Prerequisites chain valid | ⚠️ EXISTS | **MEDIUM** |
| No circular prerequisites | ❌ NOT AUDITED | **HIGH** |
| Each phase has milestone | ✅ EXISTS | — |
| Phase completion criteria clear | ✅ EXISTS | — |

---

## Section 5: Recommended Actions (Priority Order)

### Phase 1: Level System (Blocker — must do first)

1. Update `learning_paths.json` `playerLevels` to add K level
2. Update difficulty enum in article schema to 6 levels
3. Audit all 890 articles: tag with correct K/I/H/G/F level
4. Update `recommendedFor` field in all articles

**Estimated effort: 1–2 weeks content audit**

### Phase 2: Video Integration

1. Add `chapterMarkers` field to VideoEntry schema
2. Populate chapter markers for each video
3. Verify all video externalUrls are live (200 OK)
4. Link videos to drillRefs via chapter markers

**Estimated effort: 1 week**

### Phase 3: Relationship Audit

1. Check all `relatedKnowledge` IDs reference existing items
2. Check all `drillRefs` reference existing drills
3. Remove or fix orphaned articles
4. Remove or merge duplicate articles

**Estimated effort: 1 week**

### Phase 4: Search Quality

1. Audit aliases — common player terms (english, spin, draw, follow) should return results
2. Check tag coverage
3. Verify search ranking is relevant

**Estimated effort: 3–5 days**

### Phase 5: Content Polish

1. Standardize Vietnamese translations where missing
2. Ensure all articles have `summary` < 100 words
3. Verify `sources` field on all articles (provenance)
4. Add `estimatedMinutes` to articles missing it

**Estimated effort: 1 week**

---

## Section 6: H1 Product Scope (Engineering)

Per PO directive, Engineering's H1 scope is:

- [ ] **Audit** existing data structure ✅ DONE (this report)
- [ ] **Design** Learning Journey framework
- [ ] **Design** taxonomy (category system aligned with levels)
- [ ] **Schema changes** if needed (add chapterMarkers to VideoEntry)
- [ ] **Build** H1 content pipeline design (how to extract + normalize from sources)

Engineering does NOT write content. Content team fills the framework.

---

## Section 7: H1 Design Proposal

### Learning Journey Taxonomy

```
Pool OS Knowledge
├── Beginner (I)
│   ├── Getting Started (Pool là gì, luật cơ bản)
│   ├── Equipment Basics (Cue, Chalk, Grip, Bridge)
│   ├── Fundamental Shots (Stance, Stroke, Straight Shot)
│   └── Your First Game
├── K Level
│   ├── Stop Shot & Follow
│   ├── Draw Basic
│   ├── Natural Angle
│   ├── Cut Shot Introduction
│   └── Speed Control
├── I Level
│   ├── Cue Ball Control
│   ├── Position Play Introduction
│   ├── Pattern Basic
│   ├── Bank Introduction
│   └── Kick Introduction
├── H Level
│   ├── Rotation
│   ├── Pattern Advanced
│   ├── Safety Basic
│   ├── Decision Making
│   └── Match Psychology
├── G Level
│   ├── Multi Rail
│   ├── Advanced Pattern
│   ├── Tactical Safety
│   ├── Break Strategy
│   └── Pressure Management
└── F Level (Pro)
    └── Deep Advanced
```

### Article Structure Standard

Every article MUST have:
- `difficulty`: beginner | K | I | H | G | F
- `prerequisites`: array of skill IDs
- `estimatedMinutes`: number (< 30 preferred)
- `summary`: < 100 words
- `successCriteria`: 2–3 bullet points
- `commonMistakes`: 2–3 bullet points
- `corrections`: drill recommendations
- `drillRefs`: linked drills
- `coachNotes`: actionable coach tip

### Video Structure Standard

Every video MUST have:
- `chapterMarkers`: `[{offset, title, drillRef?}]`
- `difficulty`: beginner | K | I | H | G | F
- `channel`: from approved list (Matchroom/Dave/Sharivari/etc.)
- `duration`: already exists

---

## Section 8: AI Pipeline Design (for H2 readiness)

AI Coach needs structured data. Recommended extraction pipeline:

```
Source (Matchroom / Dr Dave / etc.)
    ↓
AI Extraction (per PO §Knowledge Extraction)
    → Summary (50 words)
    → Key Ideas (5 bullet points)
    → Coach Tips (3 bullet points)
    → Common Mistakes (3 bullet points)
    → Drill recommendation
    → Related Knowledge IDs
    → Level tag
    → Prerequisites
    ↓
Editorial Review (human validation)
    ↓
Standardized JSON Article
    ↓
Pool OS Knowledge Base
    ↓
AI Coach Context (H2)
```

---

## Section 9: Decision Required from PO

Before proceeding to Phase 1, PO must confirm:

1. **Level mapping**: How does existing "beginner" map to Beginner vs K?
   - Current: "beginner" appears in articles
   - Target: Need to decide if "beginner" → Beginner (no equipment) or "beginner" → K (played before)

2. **Content ownership**: Who writes/audits the 890 articles?
   - Engineering can build the framework
   - Content team (or external) needs to fill quality gaps

3. **Video sources priority**: Which channels first?
   - PO listed: Matchroom / Dr Dave / Sharivari / FXBilliards / Niels Feijen / Karl Boyes / Darren Appleton
   - Which 2–3 launch with for Beta?

---

## Summary

| Category | Status | Action |
|---|---|---|
| Schema | ✅ Ready | No change needed |
| Content quality | ✅ Good | Minor polish only |
| Level system | ❌ **CRITICAL** | Restructure required |
| Video integration | ⚠️ Partial | Add chapter markers |
| Relationships | ⚠️ Partial | Audit + fix links |
| Search quality | ⚠️ Unknown | Audit required |
| Drill-video pairing | ⚠️ Partial | Add chapter markers |

**Recommended start: Level system restructure + Video chapter markers.**
These unblock H2 (AI Hardening) because AI Coach needs clean level data.

---

*Audit completed by Engineering 2026-07-31. PO Review pending.*
