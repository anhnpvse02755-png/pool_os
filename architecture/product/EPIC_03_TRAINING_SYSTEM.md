# EPIC 03 — Training System

**Status:** Implementation Authorized (PO direction 2026-07-30)
**Branch:** `epic/03-training-system`
**Roadmap anchor:** `architecture/product/POOL_OS_ROADMAP_V3_BETA.md` EPIC 03

---

## Objective

Provide a complete personal training platform for billiards.
Focus on training workflow, progress tracking and learning
management.

**No AI. No automatic coaching. No recommendation engine.**
Training records only.

---

## Deliverables

### 1. Drill Library

Central repository of drills. Built-in catalog lives in
`drill/DrillLibrary` (re-used). Read-only — no AI, no
recommendation, no ordering by skill.

Each drill contains:
- Name (bilingual: name + nameVi)
- Description (bilingual)
- Difficulty
- Category
- Target Skill
- Expected Duration
- Required Equipment
- Reference Images (deferred — not in MVP)

Examples in seed: Stop Shot, Follow Shot, Draw Shot, Cut Shot,
Bank Shot, Kick Shot, Position Play, Break Shot, Safety, Pattern
Play.

### 2. Practice Session

Record every practice session via `training_center/TrainingSession`
+ `DrillRun` (re-used). Each session contains multiple drills.

Fields:
- Date (startedAt)
- Duration (completedAt - startedAt)
- Location (deferred — not in MVP)
- Table (deferred — not in MVP)
- Equipment (deferred — not in MVP)
- Mood (deferred — not in MVP)
- Energy (deferred — not in MVP)
- Notes

### 3. Goal System

Personal goals only, re-using `goal_center/Goal` with v32
`GoalStatus` column. Explicit lifecycle:

- **Not Started** — created but no work has begun
- **Active** — currently being pursued (default for existing rows)
- **Completed** — finished (legacy `completedAt` preserved)
- **Archived** — hidden from active list, history preserved

Examples: Practice 5 days/week, 500 stop shots, 100 draw shots,
20 hours this month, Complete Lesson 3.

### 4. Progress

Read-only historical aggregates only (per PO direction
2026-07-30 — NO prediction). Composition across 3 repositories:

- Total Practice Time = sum(completedAt - startedAt) of completed
  TrainingCenterSessions.
- Total Sessions = count(TrainingCenterSessions).
- Completed Drills = count(DrillRun where reachedTarget).
- Goal Completion = count(Goals) per GoalStatus.
- Practice Frequency = distinct practice dates / 4 (rolling 4 weeks).
- Improvement Timeline = per-day average DrillRun.successRate over
  most-recent 30 days.

### 5. Personal Training Program

Structured programs with hierarchy
Program → Week → Day → Drill. Stored as JSON column on
`training_programs.hierarchy`.

Seeded: Beginner Program, Intermediate Program, Advanced Program.
Player can create Custom Program.

Player can enroll into a program and mark weeks completed.

### 6. Lesson

Static learning content. Re-uses `training_system/Lesson` (new in
v31).

Fields: Title, Description, Objectives, Required Drills, References,
Difficulty, Skill Level.

**Lessons are static. No adaptive learning. No completion tracking
at MVP (per PO direction 2026-07-30).**

### 7. Coach Notes

Manual notes only via `training_system/CoachNote` (new in v31).

Categories:
- Today's mistakes
- Things to improve
- Practice observations
- Coach comments

**No AI generation. Player authors every note.**

---

## Data Source

Read / Write using existing repositories where possible.
**No schema redesign. No repository redesign. No Drift migration
unless absolutely required for Training entities.**

Drift migrations:
- **v31** — 4 additive tables: Lessons, CoachNotes, TrainingPrograms,
  TrainingProgramEnrollments. Justified: no existing equivalent.
- **v32** — 1 additive column on Goals: `status` TEXT NOT NULL
  DEFAULT 'active'. Justified: PO direction requires explicit
  GoalStatus lifecycle.

---

## Architecture

```
Presentation (training_system/presentation)
  ↓
Training Service (training_system/application)
  ↓
Existing Repositories + TrainingSystemRepository
  ↓
Database (Drift, schema v32)
```

Training Service coordinates:
- Drill (drill/DrillLibrary — in-memory)
- Practice Session (training_center/TrainingSession + DrillRun)
- Goal (goal_center/Goal with GoalStatus)
- Progress (read-only composition)
- Training Program (training_system/TrainingProgram)
- Lesson (training_system/Lesson)
- Coach Notes (training_system/CoachNote)

---

## Explicitly Out of Scope

- AI Coach
- Recommendations
- Performance Prediction
- Daily Readiness
- Automatic Training Plan
- Video Analysis
- Computer Vision
- Stroke Recognition
- Equipment Recommendation
- Statistics Analytics (EPIC 02)
- Tournament System (later Epic)

---

## Acceptance Criteria

- [x] Drill Library complete
- [x] Practice Session complete
- [x] Goal System complete (with 4-status lifecycle)
- [x] Progress Tracking complete (read-only, no prediction)
- [x] Personal Training Program complete
- [x] Lesson complete (static, no completion tracking at MVP)
- [x] Coach Notes complete (manual, no AI)
- [x] Integration between all training modules complete
- [x] No duplicated business logic (4 entities re-used)
- [ ] No regression — pending full regression run
- [ ] One Engineering Report — `EPIC_03_ENGINEERING_REPORT.md`
- [ ] One PO Review — pending
- [ ] One Merge — pending
- [ ] One Final Regression — pending
- [ ] Epic Closed — pending
