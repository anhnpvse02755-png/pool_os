# FIX-008B
Version: 1.0
Priority: P0
Module: Equipment

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

Modify ONLY Equipment Module.

Do NOT modify

Session

Match

Coach

Statistics

Dashboard

---

# BUG-001

Tip Brand

Current

Tip Brand list contains

Zan Medium

Zan Soft

Zan Hard

etc.

This is incorrect.

Brand and Hardness are mixed together.

Expected

Tip Brand

contains ONLY manufacturer.

Examples

Zan

Kamui

HOW

Taom

Navigator

Tiger

Moori

Predator

Triangle

Elk Master

etc.

No hardness information inside Brand.

---

# BUG-002

Tip Hardness

Current

Hardness is embedded inside Brand.

Expected

Separate field

Tip Hardness

Options

Soft

Medium Soft

Medium

Medium Hard

Hard

No duplicated information.

---

# BUG-003

Tip Size

Current

Maximum

13.0 mm

Expected

Cue Type determines available range.

Playing Cue

11.5 ~ 13.0

Break Cue

12.5 ~ 14.0

Jump Cue

12.5 ~ 14.0

Break+Jump

12.5 ~ 14.0

Support

13.2

13.5

13.75

13.9

14.0

---

# BUG-004

Cue Type

Current

Missing.

Expected

Every cue must have

Cue Type

Options

Playing Cue

Break Cue

Jump Cue

Break + Jump

Display selected item clearly.

---

# BUG-005

Current Break Cue

Current

Selecting Break Cue

does not display checkmark.

Expected

Current Break Cue

must display

✓

same as

Current Playing Cue.

User must immediately know

which cue is active.

---

# BUG-006

Equipment List Refresh

Verify

Adding

Editing

Deleting

Changing Active Cue

always refreshes UI immediately.

No restart required.

---

# ACCEPTANCE

Equipment screen must support

✓ Playing Cue

✓ Break Cue

✓ Jump Cue

✓ Break+Jump Cue

Tip Brand

and

Tip Hardness

are completely separated.

Break Cue

shows active checkmark.

Tip Size

supports up to

14.0 mm.

All CRUD refreshes immediately.

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