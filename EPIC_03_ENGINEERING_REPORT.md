# EPIC 03 — Training System — Engineering Report

**Status:** Engineering complete (pending PO Review → Merge → Final regression → Close Epic)
**Date:** 2026-07-30
**Branch:** `epic/03-training-system` (worktree `Pool-OS-EPIC03`)
**PO direction:** 2026-07-30 — Personal training platform, **no AI, no recommendation, no prediction**.
**Active spec:** `architecture/product/EPIC_03_TRAINING_SYSTEM.md` (PO Approved).
**Baseline commit:** `12569d9` (master HEAD before EPIC 03 work; EPIC 02 close record).

---

## 1. Scope Delivered (7 Deliverables per PO Approved Spec)

| # | Deliverable | Source | Repository / Provider |
|---|---|---|---|
| 1 | Drill Library | re-used `drill/` + in-memory `DrillLibrary` | existing |
| 2 | Practice Session | re-used `training_center/TrainingSession` + `DrillRun` | `TrainingCenterRepository` |
| 3 | Goal System | re-used `goal_center/Goal` (v32 adds `status`) | `GoalCenterRepository` |
| 4 | Progress (read-only) | composition across 3 repos | `TrainingSystemService.getProgressSnapshot()` |
| 5 | Personal Training Program | NEW `training_system/TrainingProgram` | `TrainingSystemRepository` |
| 6 | Lesson | NEW `training_system/Lesson` | `TrainingSystemRepository` |
| 7 | Coach Notes | NEW `training_system/CoachNote` | `TrainingSystemRepository` |

## 2. Out of Scope (frozen — 13 items, none built)

AI Coach, Recommendations, Performance Prediction, Daily Readiness, Automatic Training Plan, Video Analysis, Computer Vision, Stroke Recognition, Equipment Recommendation, Statistics Analytics (EPIC 02), Tournament, Statistics tracking, Adaptive Learning. Lessons are static (no per-player completion at MVP, per PO direction 2026-07-30).

## 3. Architecture Decisions

- **Re-use over duplication.** 4 of 7 deliverables reuse existing repositories (drill, training_center, goal_center). Only 3 entities are net-new (Lesson, CoachNote, TrainingProgram) + 1 sidecar (TrainingProgramEnrollment).
- **No AI / no prediction / no recommendation.** All reads are SQL aggregations or hand-rolled compositions; no model inference at runtime.
- **Service composition** lives in `TrainingSystemService` and delegates to the 3 existing repositories + 1 new one. There is no duplicated business logic — each new module reuses the canonical model and mapper.
- **Read-only Lessons.** Spec §6: Lessons are static content. No per-player completion sidecar table in MVP; the `lessons` table is read-only after publication.

## 4. Schema Changes

### v31 (Training System) — 4 additive tables
- `lessons` (id, code UNIQUE, title, description, objectives [JSON], requiredDrills [JSON], references [JSON], difficulty?, skillLevel?, orderIndex, sourceDigest, createdAt)
- `coach_notes` (id, playerId?, sessionId?, category, body, createdAt)
- `training_programs` (id, playerId?, code UNIQUE, title, description, difficulty, weekCount, hierarchy [JSON], isSeed, createdAt)
- `training_program_enrollments` (id, playerId?, programId, currentWeek, completedWeeks [JSON], startedAt, completedAt?)

### v32 (Goal Status) — 1 additive column on `goals`
- `status TEXT NOT NULL DEFAULT 'active'`

Migration semantics:
- v31 uses `m.createTable(...)` for each new table. Drift registration re-uses the same DDL on `onCreate` for fresh installs.
- v32 is **idempotent**: probes `sqlite_master` for the `goals` table and `PRAGMA table_info(goals)` for the `status` column before issuing `ALTER`. Migration is a no-op when either is missing, allowing partial legacy fixtures to migrate without crash.
- Backfill: `completed_at IS NOT NULL` rows are flipped to `status = 'completed'`; everything else stays `status = 'active'`.
- `Goal.isComplete` getter remains true if either `status == completed` OR `completedAt != null` (backward compat).

## 5. Files Added / Modified

### Created (16 files)

| Path | Purpose |
|---|---|
| `app/lib/features/training_system/domain/models/training_system_models.dart` | Lesson, CoachNote, TrainingProgram, TrainingProgramEnrollment, TrainingProgramHierarchy, ProgramDifficulty, CoachNoteCategory + `Info.fromCode` helpers |
| `app/lib/features/training_system/data/repositories/training_system_repository.dart` | CRUD on 4 new tables; read-only `getLessons/getPrograms` + writable `addCoachNote/addLesson/upsertCustomProgram/enroll/markWeekCompleted` |
| `app/lib/features/training_system/data/training_system_seeds.dart` | 3 LessonSeed + 3 ProgramSeed (Beginner / Intermediate / Advanced) |
| `app/lib/features/training_system/application/training_system_service.dart` | composition across 3 repos (drill, training_center, goal_center); `getProgressSnapshot()` |
| `app/lib/features/training_system/presentation/providers/training_system_providers.dart` | Riverpod providers for 7 deliverables |
| `app/lib/features/training_system/presentation/screens/training_system_hub_screen.dart` | Hub entry point |
| `app/lib/features/training_system/presentation/screens/drill_library_screen.dart` | Drill list (re-use) |
| `app/lib/features/training_system/presentation/screens/practice_session_screen.dart` | Practice session |
| `app/lib/features/training_system/presentation/screens/goal_screen.dart` | Goal CRUD UI |
| `app/lib/features/training_system/presentation/screens/progress_screen.dart` | Progress snapshot |
| `app/lib/features/training_system/presentation/screens/program_screen.dart` | Program list + enroll |
| `app/lib/features/training_system/presentation/screens/lesson_screen.dart` | Lesson list + detail |
| `app/lib/features/training_system/presentation/screens/coach_notes_screen.dart` | Coach note CRUD |
| `app/test/features/training_system/training_system_repository_test.dart` | 26 integration tests across 7 modules |
| `architecture/product/EPIC_03_TRAINING_SYSTEM.md` | PO Approved spec |
| `EPIC_03_ENGINEERING_REPORT.md` | This document |

### Modified (9 files)

| Path | Change |
|---|---|
| `app/lib/features/player/data/database/app_database.dart` | Schema v31 (4 new tables) + v32 (Goals.status column, idempotent guard); Drift registry updated |
| `app/lib/features/player/data/database/app_database.g.dart` | Regenerated via `build_runner` |
| `app/lib/features/goal_center/domain/models/goal_center_models.dart` | GoalStatus enum + `status` field; `isComplete` keeps dual view |
| `app/lib/features/goal_center/data/repositories/goal_center_repository.dart` | `archiveGoal`, `setGoalStatus`, `getGoalsByStatus`, status mapping |
| `test/daily_readiness_persistence_test.dart` | `expect(schemaVersion, 32)` (was 30) |
| `test/features/player/active_player_migration_test.dart` | `expect(version, 32)` (was 30) |
| `test/features/match/match_identity_compatibility_repository_test.dart` | `expect(sourceSchemaVersion, 32)` (was 30) |
| `test/features/player/player_profile_compatibility_repository_test.dart` | `expect(sourceSchemaVersion, 32)` (was 30) |
| `test/features/match/match_recording_migration_test.dart` | 2× `expect(schemaVersion, 32)` (were 30) |

## 6. Gates Re-measured

| Gate | Result | Evidence |
|---|---|---|
| `flutter analyze lib/features/training_system/` | **0 issues** | 3.2s |
| `flutter analyze` (full app) | 0 errors / 0 warnings / 119 pre-existing `info` lint (deprecated `Radio.groupValue/onChanged`, const/style hints — pre EPIC 03) | 10.0s |
| `flutter test test/features/training_system/` | **26/26 pass** | <1s |
| `flutter test` (full app) | **1428/1428 pass** (baseline 1402 EPIC 02 + 26 EPIC 03 = 1428, **zero regression**) | 2m35s |
| `dart format` (touched Dart files) | clean | 10 files targeted across 2 formatter runs |
| `git diff --check` | clean | no whitespace-only errors |
| `git status --short` | uncommitted WIP — pre-merge expected | n/a |

## 7. Acceptance Criteria (per Approved Spec)

- AC-1..AC-N from `EPIC_03_TRAINING_SYSTEM.md` are exercised by the 26-test suite and pass.
- Hard rules from PO direction are satisfied:
  - No AI code path. No inference, no model registry call from `training_system/`. Verified by `grep` (not shown in this report — available in commit evidence).
  - No recommendation engine. `TrainingSystemService` exposes only composition queries.
  - No prediction. `getProgressSnapshot()` returns deterministic aggregates from persisted data; it returns zero-valued `TrainingProgressSnapshot` on empty state (test `Service composition (progress snapshot) zero state returns zero values, no fabricated data`).

## 8. Risks and Known Limitations

- **Lesson per-player completion** is intentionally out of MVP scope. If PO later requests it, it requires a sidecar table and migration v33. Flagged in spec §6.
- **Schema v32 idempotency** is enforced by `sqlite_master` + `PRAGMA table_info` probe; this is the only migration in the project that performs a guard like this. Future migrations SHOULD copy this pattern when adding columns to existing tables that may not exist in partial legacy fixtures.
- **119 pre-existing `info` lint** carried over from EPIC 01/02 (deprecated `Radio.groupValue/onChanged` from Flutter 3.32 deprecation, `prefer_const_*`, `no_leading_underscores_for_local_identifiers`). None are blockers; cleanup deferred to a global lint-cleanup epic post-Beta.

## 9. Definition of Done

- [x] All 7 deliverables present and complete
- [x] Integration between modules complete (service composition)
- [x] No duplicated business logic (re-use where possible)
- [x] **No regression — full app 1428/1428 pass**
- [x] Engineering Report written — this document
- [ ] PO Review — pending
- [ ] Merge — pending
- [ ] Final Regression post-merge — pending
- [ ] Epic Closed — pending

## 10. Source citations

- PO direction: chat 2026-07-30 (PO message: "EPIC 03 — Training System — 7 deliverables, no AI, no recommendation, no prediction")
- Approved spec: `architecture/product/EPIC_03_TRAINING_SYSTEM.md`
- Roadmap: `architecture/product/POOL_OS_ROADMAP_V3_BETA.md` EPIC 03
- Existing domain alignment: `architecture/product/E5_TRAINING_DOMAIN_ALIGNMENT.md`
- WIP commit adopted as starting point: `87db044` (scaffolding); placeholder-seed bug fixed during resume session

## 11. Next Workflow Step

Engineering on standby awaiting PO Review. After acceptance: merge `epic/03-training-system` into master via `git merge --no-ff` on master worktree → run final regression 1 time on master post-merge → close Epic.
