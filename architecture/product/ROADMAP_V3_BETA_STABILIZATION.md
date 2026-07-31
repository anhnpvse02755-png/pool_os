# Roadmap V3 — Beta Stabilization

Status:
Active

Roadmap:
V3 (Beta → Release Candidate)

Phase:
H1 — Knowledge Hardening

---

# Status

## ✅ H0 Final Stabilization — COMPLETE

- 0 errors / 0 warnings / 112 infos (cosmetic, backlogged)
- Regression: 1531/1531 PASS
- Analyzer: all 12 MEDIUM warnings fixed
- PO Accepted: 2026-07-31

## ▶ H1 Knowledge Hardening — ACTIVE

Priority: **HIGHEST** in the entire stabilization effort.

---

# H0 Summary

| Gate | Result |
|---|---|
| Regression | ✅ 1531/1531 PASS |
| Analyzer errors | ✅ 0 |
| Analyzer warnings | ✅ 0 |
| 112 remaining infos | ✅ Cosmetic — backlogged per PO directive |

---

# H1 — Knowledge Hardening

## Strategic Goal

**H1 ≠ add more knowledge. H1 = make existing knowledge ACTUALLY LEARNABLE.**

The value of Pool OS lives in its Knowledge Base being deep enough for a player
to learn something new. A pool of 900 items that is disorganized, duplicated,
or confusing is worth less than 100 well-structured items.

**⚠️ PO Decision: Do NOT edit the 890 articles. Only ADD metadata.**

## H1 Target

Make Knowledge Base the reason players come back.

## Priority Order (PO-defined)

```
H1.1  Knowledge Metadata         ← PRIORITY 0 — BLOCKER
H1.2  Relationship Audit
H1.3  Search Audit
H1.4  Video Knowledge Mapping
H1.5  Player Assessment Design
```

## H1.1 — Knowledge Metadata (PRIORITY 0 — BLOCKER)

Add NEW metadata fields to every article (no content changes):

- `difficulty` (int 1-6: Beginner/K/I/H/G/F)
- `estimatedMinutes`
- `prerequisites` (skill IDs)
- `nextKnowledge` (progression IDs)
- `recommendedDrills` (drill codes)
- `recommendedVideos` (video knowledge mapping)
- `estimatedMastery`

Write automated metadata generator. Do NOT manually edit 890 files.

## H1.2 — Relationship Audit

- Broken `relatedKnowledge` links
- Broken `drillRefs` links
- Orphaned articles
- Duplicate articles
- Circular prerequisites

## H1.3 — Search Audit

- Alias coverage (english/spin/draw/follow)
- Tag completeness
- Search ranking quality

## H1.4 — Video Knowledge Mapping

chapterMarkers + full knowledge mapping per PO §Video Strategy.

## H1.5 — Player Assessment

Full design in `H1_PLAYER_ASSESSMENT.md`.

Assessment = trigger mechanism for entire ecosystem.
Design complete. PO decision pending on rule-based vs AI-based scoring.

## Focus Areas

### Content Quality

- [ ] **Hierarchical organization** — content grouped by skill level
  (Beginner / Intermediate / Advanced). Players see what matches their level.
- [ ] **Clear language** — no verbose prose, no jargon without explanation,
  no "lorem ipsum" or placeholder text.
- [ ] **Correct categorization** — no orphaned items, no items in wrong categories.

### Video Quality

- [ ] **Correct timestamps** — chapter markers / drill points accurate.
- [ ] **Video-drill pairing** — each video links to at least one relevant drill.
- [ ] **No dead URLs** — every video URL returns 200.

### Drill Quality

- [ ] **Drill-lesson pairing** — each drill links to at least one relevant lesson.
- [ ] **Prerequisites** — drills have correct prerequisite knowledge.
- [ ] **Difficulty labeling** — each drill tagged Beginner / Intermediate / Advanced.

### Lesson Quality

- [ ] **Prerequisite chain** — lessons form a logical progression.
- [ ] **Lesson-video pairing** — each lesson links to relevant videos.
- [ ] **No circular prerequisites** — no lesson requires itself.

### Pattern Quality

- [ ] **Correct category** — patterns in right categories.
- [ ] **Difficulty labeling** — Beginner / Intermediate / Advanced.
- [ ] **Pattern-drill pairing** — each pattern links to relevant drills.

### Search Quality

- [ ] **No duplicate results** — search doesn't return near-identical items.
- [ ] **Relevant ranking** — best match surfaces first.
- [ ] **Alias matching** — common player terms (e.g. "english", "spin") return results.

### AI Integration (H1 enables H2)

- [ ] **AI context** — Coach reads from: Articles / Videos / Drills / Lessons / Patterns.
- [ ] **Completeness** — Coach prompt has sufficient context from all 5 sources.
- [ ] **No hallucination triggers** — Coach doesn't need to guess what a drill is.

### Relationship Graph

- [ ] **No isolated nodes** — every knowledge item links to ≥1 other item.
- [ ] **No circular links** — A→B→A chains broken.

## Constraints

- **No new knowledge content** (editing only)
- **No schema changes**
- **No new screens**
- **No AI features** (H1 enables H2; H2 uses H1's clean data)

## Deliver

`H1_KNOWLEDGE_HARDENING_REPORT.md` — item-by-item audit with before/after.

---

# H2 — AI Hardening

## Prerequisites

H1 must be complete and approved before H2 begins.

## Strategic Goal

AI Coach uses real player data + clean knowledge from H1 to give useful analysis.

## Focus Areas

- Prompts — context-complete, no hallucinations
- Reasoning pipeline — output format consistent
- Data snapshot — Coach reads all 9 sources
- Recommendation quality — surface-relevant suggestions
- Strategy quality — context-aware, player-skill-appropriate
- Review quality — specific, actionable feedback

## Constraints

- MockAI remains default provider
- No external API dependency for H2
- No Coach architecture redesign

## Deliver

`H2_AI_HARDENING_REPORT.md`

---

# H3 — UX Hardening

## Prerequisites

H2 must be complete and approved before H3 begins.

## Strategic Goal

Every screen handles every state. No blank screens.

## Focus Areas

- Loading states (every async screen)
- Empty states (every list screen)
- Error states with retry
- Pull-to-refresh where applicable
- Responsive layout

## Deliver

`H3_UX_HARDENING_REPORT.md`

---

# H4 — Release Candidate

## Prerequisites

H3 must be complete and approved before H4 begins.

## Strategic Goal

Build and ship.

## Focus Areas

- Release APK (signed, optimized)
- Release build verified
- Known issues documented
- Feedback template ready

## Deliver

Internal Beta APK + release notes.

---

# Forbidden

Engineering MUST NOT:

- ❌ Create EPIC 10
- ❌ Redesign architecture
- ❌ Rewrite modules
- ❌ Migrate database
- ❌ Add AI features outside EPIC 06
- ❌ Add knowledge content (H1 = edit existing only)
- ❌ Change H1 goal to "add more knowledge"

---

# Workflow

```
H0 ✅ → PO Review ✅ → H1 → PO Review → H2 → PO Review → H3 → PO Review → H4 → Internal Testing → Bug Fix → Release Candidate
```

---

# Three Core Values

Every hardening decision filters through these:

1. **Knowledge Base** — does this change help a player learn something?
2. **AI Coach** — does this change make Coach smarter with real data?
3. **Training System** — does this change connect play → analysis → training → improvement?

---

*Roadmap updated by PO 2026-07-31. H0 accepted. H1 active.*