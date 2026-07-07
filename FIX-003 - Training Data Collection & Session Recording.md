# FIX-003 - Training Data Collection & Session Recording

Version: 1.0

Priority: P0

Status: Ready for Implementation

Reference:
- RFC-010 Training
- RFC-011 Coach
- RFC-019 Business Logic
- RFC-020 Definition of Done

---

# Objective

Redesign data collection for Match and Practice.

Pool OS supports TWO recording modes:

1. Match Mode
2. Practice Mode

Each mode collects different information.

Do NOT merge them.

---

# Part 1 - Match Mode

## Objective

During competition the player has very limited time.

Recording must be completed during rack setup.

Target time:

< 20 seconds.

---

# Match Recording

After every rack

↓

Open Rack Summary

Required fields

## Result

- Win / Lose

---

## Performance

- Balls Potted
- Largest Run

---

## Break

- Break Success
- Break Scratch
- Break Foul

---

## Errors

User enters quantity only.

- Easy Miss Count
- Hard Miss Count
- Scratch Count
- Position Error Count
- Safety Error Count
- Kick Error Count
- Jump Error Count

---

## Best Strength

Multiple selection

Example

□ Thin Cut

□ Thick Cut

□ Long Pot

□ Draw

□ Follow

□ Bank

□ Kick

□ Jump

□ Safety

□ Cue Ball Control

---

## Biggest Mistake

Multiple selection

Example

□ Thin Cut

□ Thick Cut

□ Long Pot

□ Draw

□ Follow

□ Bank

□ Kick

□ Jump

□ Safety

□ Cue Ball Control

---

## Mental

Confidence

Slider

1~10

---

## Notes

Optional

---

# Match Summary

Generated automatically.

Never ask user to enter match summary manually.

---

# Part 2 - Practice Mode

Practice supports full shot recording.

Workflow

Practice

↓

Start Drill

↓

Every Shot

↓

Record Shot

---

# Shot Record

Each shot stores

- Shot Type
- Success
- Miss Type
- Cue Ball Control
- Position
- Difficulty
- Notes

---

# Shot Types

Use Vietnamese.

Never use English.

Required list

- Cắt mỏng
- Cắt dày
- Bi thẳng
- Retro
- Follow
- Stun
- Bank
- Kick
- Jump
- Masse
- Combination
- Carom
- Safety
- Break
- Cue Ball Control

---

# Miss Type

- Thin
- Thick
- Under Cut
- Over Cut
- Speed
- Position
- Wrong Spin
- Wrong Aim

---

# Practice Result

Automatically generated

- Success %
- Miss %
- Average Difficulty
- Largest Run
- Recommendation

---

# Coach Input

Coach MUST read

Match Data

+

Practice Data

Together.

Never use Match data only.

Never use Practice data only.

---

# Database

Separate entities

MatchRackSummary

PracticeShot

PracticeSession

Do NOT merge.

---

# Constraints

Do NOT redesign UI.

Do NOT modify Coach logic.

Do NOT modify Statistics Engine.

Only redesign data collection.

---

# Acceptance Criteria

✓ Match Mode requires less than 20 seconds per rack.

✓ Practice Mode supports full shot recording.

✓ Shot Types displayed in Vietnamese.

✓ Match and Practice data stored separately.

✓ Coach can consume both datasets.

✓ No regression.