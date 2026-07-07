# FIX-002 - Match Workflow & Recording

Version: 1.0

Priority: P0 (Critical)

Status: Ready for Implementation

Reference:
- RFC-008 Match
- RFC-009 Rack
- RFC-019 Business Logic
- RFC-020 Definition of Done

---

# Objective

Correct the Match workflow.

The current implementation does not match the expected business process.

This FIX focuses ONLY on Match workflow.

Do NOT modify Coach, Dashboard, Statistics or UI Design.

---

# Issue 1

## Race To N Logic

Current

Race To 7

Player reaches 6

↓

System declares Winner

This is incorrect.

---

Required

Winner only when

PlayerScore >= RaceTarget

Example

Race To 7

0

1

2

3

4

5

6

↓

Continue Match

7

↓

Winner

↓

Finish Match

---

Validation

Race To 5

Winner only at 5

Race To 7

Winner only at 7

Race To 9

Winner only at 9

No early finish.

---

# Issue 2

Current Workflow

Match Finished

↓

Popup Summary

↓

User remembers whole match

↓

Input data

This is rejected.

Users cannot accurately remember long matches.

---

Required Workflow

Each Rack

↓

Player presses

Win

or

Lose

↓

Immediately open

Rack Summary Dialog

↓

User records THIS RACK ONLY

↓

Save Rack

↓

Return to Match

↓

Next Rack

Repeat until Match ends.

---

# Rack Summary Fields

The following fields must be collected immediately after EACH rack.

Required

- Balls Potted
- Largest Run
- Easy Miss Count
- Hard Miss Count
- Scratch Count
- Safety Errors
- Position Errors
- Kick Errors
- Jump Errors
- Break Success
- Break Foul
- Cue Ball Control
- Confidence (1~10)
- Biggest Mistake
- Biggest Strength
- Optional Note

Future AI fields are NOT included in this FIX.

---

# Match Summary

When Match finishes

DO NOT ask user to re-enter any rack information.

Generate automatically.

Display

- Match Score
- Total Racks
- Win / Lose
- Largest Run
- Total Balls Potted
- Common Mistake
- Common Strength
- Average Confidence

All values are aggregated from Rack records.

---

# Data Flow

Rack End

↓

Rack Summary

↓

Save Rack

↓

Refresh Match Score

↓

Open Next Rack

↓

...

↓

Match Finished

↓

Generate Match Summary

↓

Finish

---

# Constraints

Do NOT redesign UI.

Do NOT modify Coach.

Do NOT modify Statistics Engine.

Do NOT modify Dashboard.

Do NOT introduce new architecture.

Modify only Match workflow.

---

# Acceptance Criteria

✓ Winner only at Race Target.

✓ Rack Summary appears after EVERY rack.

✓ No Match Summary input required.

✓ Match Summary generated automatically.

✓ Match data equals sum of all Rack data.

✓ No regression.

After implementation

Cursor MUST run Validation again before building APK.