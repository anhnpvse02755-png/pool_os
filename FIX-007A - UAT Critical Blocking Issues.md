# FIX-007A - UAT Critical Blocking Issues

Version: 1.0

Priority: P0

Status: REQUIRED

Source:
UAT Round 1

---

## IMPORTANT

This FIX only resolves blocking bugs.

Do NOT redesign UI.

Do NOT change business logic.

Do NOT add new features.

Do NOT modify Coach.

Do NOT modify Statistics.

Do NOT modify Database schema.

Only repair blocking behaviour.

---

# BUG-001

## Match freezes after pressing Win / Lose.

Symptoms

User presses Win or Lose.

Screen becomes gray.

Application no longer accepts input.

Expected

Win/Lose

↓

Rack Summary Dialog

↓

Save Rack

↓

Return to Match

↓

Continue next rack.

Verify

- Navigator stack
- Dialog lifecycle
- async await chain
- mounted check
- context validity
- Provider refresh

---

# BUG-002

Practice Mode has identical freeze.

Repair the same root cause.

Do not duplicate code.

---

# BUG-003

Session Summary screen cannot close.

Buttons

X

Done

must correctly return to Session screen.

No dead navigation.

---

# BUG-004

Daily Readiness screen freezes.

Find root cause.

Repair navigation or dialog lifecycle.

---

# BUG-005

Bad State

Too many elements.

Search entire project for

single()

singleWhere()

firstWhere()

where(...).single

Replace with safe handling where multiple records are valid.

Application must never crash because multiple records exist.

---

# BUG-006

Equipment

Second cue saves successfully

but list is not refreshed.

Verify

Repository

Provider

State update

UI refresh

List reload

---

# BUG-007

Player

Add Player button still does nothing.

This bug has existed through multiple fixes.

Find the root cause.

Repair completely.

Verify

Button

↓

Dialog

↓

Validation

↓

Save

↓

Refresh

↓

Player visible.

---

## VALIDATION

After implementation verify

Match

Practice

Daily Readiness

Equipment

Player

all work without freezing.

---

## OUTPUT

Generate

FIX-007A-REPORT.md

Include

Root Cause

Changed files

Verification

Regression Risk

Do not modify any other module.