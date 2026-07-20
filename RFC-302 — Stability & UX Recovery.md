# RFC-302 — Stability & UX Recovery

**Status:** APPROVED

## Goal

Stabilize Pool OS after RFC-301.

- NO new features.
- NO refactor unrelated modules.
- ONLY fix runtime crash, state synchronization and UX completion.

---

## General Rules

This RFC is **NOT** bug patching.

This RFC is responsible for making the application **usable** after the Recording Pipeline rewrite.

**Priority:**

- **P0** — Application crash
- **P1** — State synchronization
- **P2** — UX completion

Constraints:

- No placeholder.
- No fake value.
- No silent catch.

Every `Null Check Operator` crash must be completely removed.

---

## Task 1 — Null Safety Audit

**Current UAT** — the following all throw `Null check operator used on null value`:

- Dashboard
- Ready Today
- Session
- Statistics

**Requirements:**

- Search entire project for `!` after a nullable object.
- Audit every occurrence.
- Replace with one of:
  - guard clause
  - late initialization
  - proper empty state

**Forbidden:** `value!` unless the compiler can guarantee not-null.

**Deliverable — `RFC302-NULL-AUDIT.md`** listing:

| File | Line | Cause | Fix |
| --- | --- | --- | --- |

---

## Task 2 — Recording State Synchronization

**Current issue** — the following all produce a Null crash:

- Finish Session
- Continue Session
- Save Shot

**Requirements:**

Audit:

- `RecordingCoordinator`
- `SessionNotifier`
- `MatchNotifier`
- `RackNotifier`
- `ShotRecorder`
- `EventRecorder`

Verify that `activeSession`, `activeMatch`, `currentRack`, `currentShot` **cannot become inconsistent**.

- When session finished → all recording state cleared.
- When continue session → all state rebuilt from database.
- No in-memory assumption.

---

## Task 3 — Save Feedback

**Current issue:** User records a Shot. Nothing indicates it was saved.

**Requirements:**

Every persistence operation must expose through the UI:

- `Saving...`
- `Saved`
- `Failed`

**Examples:**

- SnackBar (`Saving Shot...` → `Shot Saved`)
- small status badge
- check animation

User must always know whether data reached the database.

- Persistence first.
- UI feedback second.
- Never silent.

---

## Task 4 — Equipment Logic

**Current issue:** Only Playing Cue works. Break Cue cannot become active.

**Requirements:**

- **Playing Cue** — exactly one active.
- **Break Cue** — exactly one active.
- **Jump Cue (future)** — same rule.

**Equipment screen** must show:

- Playing cue
- Break cue

with different indicators.

**Match snapshot** must include the Playing Cue and Break Cue used during that match.

Editing a cue later must **never** affect history.

---

## Task 5 — Statistics Crash

Statistics currently crashes before rendering.

**Audit:**

- `StatisticsRepository`
- `StatisticsEngine`
- `StatisticsProvider`
- `SkillEngine`
- Dashboard aggregation

Find every nullable assumption.

Statistics must support, without crash:

- Fresh database
- One session
- One shot
- No event
- Partial data

If insufficient data → show `Not enough data` instead of `0%`. Never fabricate.

---

## Task 6 — Player Screen

**Current status:** Player Management missing.

**Implement:**

- Player List
- Create Player
- Edit Player
- Delete Player
- Active Player

Player fields:

- Avatar
- Dominant Hand
- Experience
- Primary Cue
- Break Cue
- Skill Level

Shortcuts:

- Statistics shortcut
- Session history shortcut
- Coach shortcut

No multiplayer logic yet. Single active player.

---

## Task 7 — Dashboard Recovery

Dashboard must never crash.

When data missing:

- show empty cards.
- No loading forever.
- No null exception.
- No fake recommendation.
- Coach card hidden if unavailable.

---

## Task 8 — Acceptance Checklist

- Fresh database → Dashboard opens.
- Ready Today works.
- Save readiness → Restart app → Readiness restored.
- Create Session → Continue Session → Finish Session → No crash.
- Record Shot → Saved indicator appears → Restart app → Shot exists.
- Record Event → Saved indicator appears → Restart app → Event exists.
- Equipment: Playing Cue and Break Cue switch independently.
- Statistics opens with zero data.
- Player screen fully functional.
- `flutter analyze` → 0 error, 0 warning, only info allowed.
- Build APK → success.

**STOP.**

Do not continue RFC-303. Wait for UAT.

**Deliver:** `RFC302-REPORT.md`
