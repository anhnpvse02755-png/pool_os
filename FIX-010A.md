# FIX-010A
Version: 1.0
Priority: P2
Module: UX / UI Polish

---

## IMPORTANT

Follow

CURSOR_DEVELOPMENT_RULES.md

Especially

Rule 4
Rule 5
Rule 8
Rule 10
Rule 17

This FIX is UI/UX only.

Do NOT modify

Business Logic

Database

Repository

Provider

Coach Engine

Statistics Engine

Drift

Migration

Navigation

Workflow

---

# PURPOSE

Improve usability and consistency.

This FIX exists ONLY to improve user experience.

No functionality changes.

---

# BACKGROUND

Most critical bugs have been fixed.

Application is now entering Product Polish phase.

Focus:

Consistency

Readability

Visual Feedback

Navigation

---

# BUG-001

Selection Feedback

Where user selects

Cue

Player

Break Cue

Jump Cue

Practice Category

Training Category

Difficulty

Brand

Tip

Hardness

Cue Type

Always display

✓ Selected

or

Highlighted Card

Never leave user guessing.

---

# BUG-002

Loading Feedback

Every async operation must show

Loading

Disabled Button

Progress Indicator

Examples

Save

Delete

Create

Update

Import

Generate Report

Coach Analysis

Statistics Refresh

---

# BUG-003

Empty State

Every list must have

Friendly Empty State

Examples

No Sessions

No Matches

No Equipment

No Practice

No Statistics

No Coach Recommendation

Never show blank pages.

---

# BUG-004

Confirmation Dialog

Dangerous actions

must require confirmation.

Examples

Delete Cue

Delete Match

Delete Session

Delete Player

Delete Practice

Confirmation wording must be localized.

---

# BUG-005

SnackBar Consistency

Every success

uses same style.

Every warning

uses same style.

Every error

uses same style.

Do not mix colors or durations.

---

# BUG-006

Button Consistency

Primary Button

Secondary Button

Outlined Button

Text Button

must follow same sizing.

Same padding.

Same radius.

Same typography.

---

# BUG-007

Card Consistency

Dashboard

Statistics

Coach

Equipment

Player

Practice

Session

must use same spacing

same elevation

same border radius.

---

# BUG-008

Typography

Review

Headers

Titles

Subtitle

Body

Caption

No inconsistent font sizes.

---

# BUG-009

Icon Consistency

Use one icon style.

Do not mix

Filled

Outlined

Rounded

Random icons.

---

# BUG-010

Localization

Remove remaining English UI text.

Everything user can see

must use localization.

Internal enum names

may remain English.

---

# ACCEPTANCE

No workflow changes.

No database changes.

No business logic changes.

No repository changes.

No provider changes.

UI becomes visually consistent.

Flutter analyze

0 errors.

---

# REPORT

Report ONLY

1.

Files Modified

2.

UX Improvements

3.

Visual Consistency Improvements

4.

Regression Risk

5.

Flutter Analyze

6.

Remaining UI Improvements