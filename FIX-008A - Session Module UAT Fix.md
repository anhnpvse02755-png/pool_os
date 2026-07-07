# FIX-008A
Version: 1.0
Priority: P0
Module: Session

Source:
UAT Result (2026-07-03)

---

## IMPORTANT

Follow CURSOR_DEVELOPMENT_RULES.md

Especially

Rule 1
Rule 2
Rule 5
Rule 16

DO NOT redesign workflow unless requested.

DO NOT modify Equipment.

DO NOT modify Coach.

DO NOT modify Statistics.

Modify Session module ONLY.

---

# BUG-001

Daily Readiness

Current

Click Daily Readiness

↓

Page Not Found

Expected

Dashboard

↓

Daily Readiness

↓

Readiness Screen opens normally

Requirements

- Find root cause.
- Fix routing only.
- Do not redesign Daily Readiness workflow.

---

# BUG-002

Practice Mode

Current

Session

↓

Create Practice

↓

Result becomes Win/Lose Match

This is incorrect.

Expected

Practice

=

Single Rack Practice

No Match Result.

No Opponent.

Practice records

- Shot
- Event
- Rack Summary

Practice never behaves like Match.

Fix only business logic.

Do not redesign workflow.

---

# BUG-003

Win/Lose buttons

Current

Win/Lose

displayed on Session Screen.

Expected

Win/Lose buttons

exist ONLY

inside Match Detail.

Session screen should only

display Session list.

Session summary.

Create Session.

No Win/Lose buttons.

---

# BUG-004

Add Shot

Current

Button located outside Match Detail.

Expected

Add Shot

only exists

inside

Match Detail

or

Practice Detail.

Never on Session screen.

---

# BUG-005

Add Event

Same rule.

Only inside

Match Detail

or

Practice Detail.

---

# BUG-006

Practice Button

Current

Grey screen.

No Drill list appears.

Expected

Session

↓

Practice

↓

Drill Library opens

↓

Search

↓

Category

↓

Choose Drill

No grey screen.

Find root cause.

Do not redesign Drill Library.

Only restore correct navigation.

---

# ACCEPTANCE

After fix

Session Screen

contains ONLY

- Recent Sessions
- Create Session
- Session Summary

No Win/Lose

No Add Shot

No Add Event

Practice opens Drill Library correctly.

Daily Readiness opens correctly.

Practice never behaves like Match.

No grey screens.

---

# REPORT

Report ONLY

1.
Root Cause

2.
Files Modified

3.
Logic Changed

4.
Regression Risk

5.
Flutter Analyze

Do NOT modify unrelated modules.