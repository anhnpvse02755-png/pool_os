# RFC-302B — Existing Feature Completion

RFC-302A has completed Stability Recovery.

- DO NOT touch AI logic.
- DO NOT optimize architecture.
- DO NOT refactor unrelated code.

Complete only the existing unfinished product features.

---

## Task 1 — Equipment System

Current implementation only supports one Active Cue. Implement the business model defined in Product Vision.

**Equipment Categories:**

- Playing Cue
- Break Cue
- Jump Cue
- Extension
- Glove
- Tip
- Chalk
- Bridge
- Other

**Rules:**

- Each category has exactly ONE active equipment.
- Changing Active Equipment MUST NOT modify historical Matches.
- Every Match must snapshot: cue id, cue specs, tip, shaft, extension, glove.
- Historical Matches must always display the equipment actually used.
- Never read current equipment for historical matches.

---

## Task 2 — Player Module

Implement Player module. Include:

- Profile
- Avatar
- Dominant hand
- Experience
- Ranking
- Preferred cue
- Training goals
- Achievements
- Statistics summary
- Training Progress
- Session History
- Equipment

Navigation must integrate into existing application. No placeholders.

---

## Task 3 — Save Feedback

Every persistence action must clearly notify the user. Show:

- Saving...
- Saved successfully
- Save failed

Applies to: Shot, Event, Rack, Match, Session.

Never leave user guessing whether data has been stored.

---

## Task 4 — Session UX

Current Session page must always display:

```
Current Session
   ↓
Current Match
   ↓
Current Rack
   ↓
Current Shot
```

User must always know where they currently are.

---

## Rules

- Do NOT modify AI.
- Do NOT modify Statistics calculations.
- Do NOT modify Coach.
- Do NOT start RFC-303.
- Run `flutter analyze`.
- Run `flutter test`.
- Build APK.
- Produce `RFC302B-REPORT.md`.
- Stop after report.
