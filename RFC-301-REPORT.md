# RFC-301 — Recording Pipeline Rewrite — Implementation Report

**Status:** Implemented · **Priority:** P0 · **Schema:** v10 → v11
**Verify:** `flutter analyze` = 0 errors · RFC-301 tests 9/9 pass · APK blocked by full disk (see §7)

This is a core architecture rewrite of the recording pipeline, not a bug fix. The pipeline now enforces: every object has a valid persisted parent, no orphan rows, no fake IDs, persist-first, transaction-safe, durable across restart.

---

## 1. Old pipeline → New pipeline

**Old (broken):**
```
Screen (const ShotRecordingScreen(), no IDs)
  → provider startRecording(rackId ?? 0)          // fake ID
  → if (rackId != null) persist   else memory-only // silent divergence
  → repo.createShot()  →  id DISCARDED             // never propagated
Event: if (shotId != null) …   // state.shotId ~always null → memory-only
  → repo.createEvent(shotId ?? 0)                  // orphan (FK to shot 0)
No transactions. finishSession → only stamps finishedAt.
Rack 14 fields → JSON blob '__RACK_DATA__' smuggled into notes.
Practice → separate PracticeShots/PracticeSessions tables via stub repo (returns 0/[]).
```

**New (RFC-301):**
```
Screen requires real IDs (rackId / shotId non-null in constructor)
  ↑ call site first: coordinator.ensurePracticeMatch → ensureCurrentRack → real rackId
  → provider → RecordingCoordinator.recordShot(rackId, shot)   [transaction]
      · validates Rack exists (else throws RecordingIntegrityException)
      · returns REAL shot.id → stored in state
  → Event opens only with a real shotId (latest shot in rack); else "record shot first"
      → RecordingCoordinator.recordEvent(shotId, event)        [transaction]
      · validates Shot exists; EventRepository rejects null/<=0 shotId
finishSession → coordinator: finish open match + stamp session, atomic.
Rack 14 fields → real columns (schema v11). No JSON blob.
Practice → SAME Match(gameType='practice')→Rack→Shot→Event pipeline. Stub deprecated.
```

Full workflow: `Player → Session → Match/Practice → Rack → Shot → Event → Database`.

---

## 2. Files modified / created

**Created**
- `lib/features/session/data/recording_coordinator.dart` — the single choke-point for the pipeline (transactions, parent validation, real-ID propagation) + `recordingCoordinatorProvider`.
- `lib/features/session/domain/recording_errors.dart` — `RecordingIntegrityException`.
- `test/rfc_301_recording_pipeline_test.dart` — 9 integration tests.

**Schema / data**
- `lib/features/player/data/database/app_database.dart` — `schemaVersion 10→11`; 14 real columns added to Dart `Racks` class; `_migrateToV11` (idempotent ALTERs); `AppDatabase.forTesting(executor)` ctor.
- `lib/features/event/data/repositories/event_repository.dart` — `createEvent` rejects null/≤0 `shotId` (removed `?? 0`).
- `lib/features/shot/data/repositories/shot_repository.dart` — added `shotExists(id)`.
- `lib/features/rack/data/repositories/rack_repository.dart` — removed `__RACK_DATA__` JSON blob in create/update/map; maps 14 real columns; added `matchExists(id)`.
- `lib/features/session/data/repositories/session_repository.dart` — `getActiveSession` order+limit 1 (no `getSingleOrNull` throw).
- `lib/features/match/data/repositories/match_repository.dart` — `getActiveMatchBySessionId` order+limit 1.

**Providers**
- `shot_provider.dart` — depends on coordinator; `recordShot`/`quickAddShot` persist-first, require non-null rackId, capture real shot id into state; removed `if (rackId != null)` memory-only guard.
- `event_provider.dart` — depends on coordinator; rejects missing shotId with error; removed silent `if (shotId != null)` guard.
- `rack_provider.dart` — `addRack` routes through `coordinator.ensureCurrentRackForResult` (validates match); exposes `currentRackId`.
- `session_provider.dart` — `finishSession` delegates to `coordinator.finishSession`; sets `clearActiveSession`.

**UI**
- `shot_recording_screen.dart` — `rackId` required (removed `?? 0`).
- `event_recording_screen.dart` — `shotId` required.
- `session_screen.dart` — practice `_openShotRecording`/`_openEventRecording` ensure match+rack, pass real IDs, guard "record shot first".
- `match_detail_screen.dart` — same for match flow (methods now take `ref`).
- `app_localizations.dart` — added `record_shot_first` (en+vi).

**Deprecated**
- `practice_repository.dart` — `@Deprecated`; superseded by unified pipeline (was a no-op stub).

---

## 3. Orphan paths removed

| Orphan source | Old | New |
|---|---|---|
| Shot with rackId=0 | `rackId: widget.rackId ?? 0` (screen:34) | `rackId` required non-null; coordinator validates Rack exists |
| Event with shotId=0 | `shotId: event.shotId ?? 0` (event_repo:34) | reject null/≤0 → `RecordingIntegrityException` |
| Event never persisted | `if (shotId != null)` ~always false → memory-only | event opens only with real shotId; persist-first |
| Shot never persisted | `if (rackId != null)` else memory-only | require rackId; no memory-only path |
| Lost auto-increment id | `createShot()` return discarded | coordinator returns real id → stored in state, feeds Event |
| Practice orphans | stub repo returned `0` | practice uses real Match→Rack→Shot→Event |

---

## 4. Transaction flow

All multi-step writes run inside `_db.transaction(...)` in `RecordingCoordinator` — any failure rolls the whole chain back (atomic):
- `ensurePracticeMatch` — find-or-create practice Match.
- `ensureCurrentRack` / `ensureCurrentRackForResult` — validate Match, find-or-create Rack.
- `recordShot` — validate Rack exists → insert Shot → return id.
- `recordEvent` — validate Shot exists → insert Event → return id.
- `finishSession` — finish open Match → stamp Session, together.

FK enforcement (`PRAGMA foreign_keys = ON`) is now effective because no code writes id `0` anymore.

---

## 5. Sequence diagram (practice add-shot then add-event)

```
User → SessionScreen._openShotRecording
  SessionScreen → Coordinator.ensurePracticeMatch(sessionId)  ⟶ matchId (txn)
  SessionScreen → Coordinator.ensureCurrentRack(matchId)      ⟶ rackId  (txn)
  SessionScreen → ShotRecordingScreen(rackId, sessionId, matchId)
User → (fills shot) → ShotProvider.recordShot
  ShotProvider → Coordinator.recordShot(rackId, shot)         ⟶ shotId  (txn, validates rack)
  ShotProvider → state.shots += shot(id: shotId)
User → SessionScreen._openEventRecording
  SessionScreen → ensurePracticeMatch → ensureCurrentRack → shotRepo.getShotsByRackId
  (latest shot.id) → EventRecordingScreen(shotId, …)
User → (fills event) → EventProvider.createEvent
  EventProvider → Coordinator.recordEvent(shotId, event)      ⟶ eventId (txn, validates shot)
User → Finish Session → SessionProvider.finishSession
  → Coordinator.finishSession(sessionId)  (finish open match + stamp session, txn)
```

---

## 6. Migration impact (v10 → v11)

- **Fresh install** (`onCreate` → `createAll`): the updated Dart `Racks` class already declares all 14 columns → created directly.
- **Upgrade from v10**: the 14 columns already exist in SQLite (added by `_migrateToV10`). `_migrateToV11` runs guarded `ALTER TABLE … ADD COLUMN` wrapped in try/catch, so pre-existing columns are a no-op (self-healing, idempotent). No FK changes.
- **Rack list fields** (`bestStrengths`, `biggestMistakes`) are stored as JSON text in real columns (`'[]'` default), decoded tolerantly.
- Legacy rows that still contain a `__RACK_DATA__` blob in `notes`: the blob is no longer parsed; those extra values are not back-migrated (the columns default to 0/'[]'). Existing racks keep their `notes` text. This is acceptable — the affected data was Match-Mode analytics on old racks, not core hierarchy.
- **Existing orphan rows** (rackId=0/shotId=0) from the pre-fix builds remain in the user's DB. They are NOT auto-deleted (out of scope, and deleting user data was not requested). New writes cannot create orphans.

---

## 7. Regression risks & verification

**Verification performed**
- `flutter analyze`: **0 errors** (21 pre-existing `info`/style lints, none from RFC-301 logic).
- `flutter test test/rfc_301_recording_pipeline_test.dart`: **9/9 pass** — practice pipeline real IDs; reject non-existent rack; reject rackId=0; reject non-existent shot; event repo rejects null shotId; arbitrary race (11) + `playerScore >= raceTo`; **restart durability** (close+reopen file); finishSession closes open match; **Rack fields round-trip via real columns, no blob**.
- `widget_test.dart` (pre-existing smoke test): fails on both baseline and after changes ("Found 0 widgets with type Scaffold") — **pre-existing, not caused by RFC-301** (verified by stashing all changes and re-running).
- **APK build: BLOCKED** — `flutter build apk` failed with `FileSystemException: … There is not enough space on the disk`. Disk C: is at 100% (≈450 MB free after `flutter clean`). This is an environment issue, not a compile error; the earlier Gradle "could not read workspace metadata" errors were the same full-disk symptom. **Action needed:** free disk space, then re-run `flutter build apk --debug`.

**Regression risks**
- Recording screens now require IDs — any not-yet-updated caller would be a compile error (analyze is clean, so none remain).
- `finishSession` now finishes the open match too — intended per Rule #6; matches previously left open on session end will now be closed.
- Practice no longer writes `PracticeShots`/`PracticeSessions`. Anything reading those tables for *new* practice data will see none; practice data is now under Matches/Racks/Shots/Events. (No live readers found — the stub was dead code.)
- `getActiveSession`/`getActiveMatchBySessionId` now pick the most recent open row instead of throwing on >1 — behavior change only in the previously-crashing multi-active case.

---

## 8. UAT checklist (for user)

- [ ] Practice → add shot → add event → restart app → shot & event still present, linked to real rack/shot.
- [ ] Match Race 11 → play racks → finish match → summary → restart → history present.
- [ ] Finish Session → Win/Lose/Shot/Event buttons disappear, activeMatch null, no grey/stuck screen.
- [ ] Add-event before any shot → shows "record a shot first", no crash, no orphan.
- [ ] Statistics reads shots; Coach reads events (unchanged modules) — data now visible.

---

## 9. Files that can now be deleted

- `lib/features/shot/data/repositories/practice_repository.dart` (deprecated stub, no live references). Kept + `@Deprecated` for now to avoid touching `practice_shot.dart`/`practice_session.dart` models out of scope; safe to delete once confirmed unused.
- `PracticeShots` / `PracticeSessions` Drift tables: retained (not dropped) to preserve any legacy rows; can be removed in a future migration if confirmed empty.

---

## 10. Future extension points (no Recording change needed)

The pipeline now emits clean, fully-linked, persisted data, so these can be built on top without touching Recording again:
- **Cloud Sync** — every row has stable ids + parents; sync by table.
- **Multiplayer** — Match already models opponent/partner/teamMode.
- **AI Coach** — reads Events by Shot (real shotId) — already correct.
- **Statistics** — reads Shots by Rack, Racks by Match — hierarchy intact.
- **Equipment Snapshot** — attach to Session/Match without pipeline change.

**After sign-off, the Recording Pipeline is LOCKED — no further changes without a new RFC.**
