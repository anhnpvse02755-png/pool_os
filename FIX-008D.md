# FIX-008D
Version: 1.0
Priority: P1
Module: Coach

Source:
UAT Result (2026-07-03)

---

## IMPORTANT

Follow

CURSOR_DEVELOPMENT_RULES.md

Especially

Rule 1

Rule 2

Rule 5

Rule 16

Modify ONLY

Coach Module.

Do NOT modify

Session

Match

Equipment

Statistics

Dashboard

Database

Rule Engine

Recommendation Engine

Business Logic

Only improve

Coach Presentation

Coach UI

Coach UX

Localization

---

# BUG-001

Coach Screen

Current

Coach screen contains

English titles

English labels

English recommendation blocks

while application language is Vietnamese.

Expected

Entire Coach Screen

must follow

selected language.

No English UI.

No mixed language.

---

# BUG-002

Recommendation Card

Current

Recommendation card

contains large amount

of text.

Player must read

too much.

Expected

Every recommendation

contains

Problem

↓

Reason

↓

Recommended Drill

↓

Expected Benefit

Maximum

4 sections.

Easy to read.

---

# BUG-003

Today's Focus

Current

Today's Focus

is difficult to identify.

Expected

Only ONE

Primary Focus

displayed clearly.

Large card.

Highlighted.

Remaining recommendations

displayed below

as secondary.

Do NOT change

Rule Engine.

Only UI.

---

# BUG-004

Recommended Drills

Current

Coach

mentions drills

but player

cannot immediately

see drill information.

Expected

Each drill card

shows

Drill Name

Difficulty

Category

Estimated Time

Short Description

Start Drill button

If drill does not exist

display

Unavailable.

Never show empty card.

---

# BUG-005

Coach Insight

Current

Insight

looks isolated.

Expected

Every insight

must reference

real statistics.

Example

Accuracy dropped

8%

↓

Reason

Easy Miss increased

↓

Recommended Drill

Thin Cut Practice

↓

Expected Improvement

No generic advice.

---

# BUG-006

Empty State

Current

Coach

still tries

to generate advice

with almost

no data.

Expected

If insufficient data

display

Not enough data yet.

Play more matches

to unlock AI analysis.

Do NOT generate

fake recommendation.

---

# BUG-007

Localization

Translate ALL

remaining English

Examples

Coach Score

Skill Score

Trend Score

Performance

Recommendation

Insight

Consistency

Confidence

Training Distribution

Improvement

Regression

Equipment Analysis

Match Analysis

Recommendation History

and every visible title.

No English UI

when language is Vietnamese.

---

# BUG-008

Recommendation Layout

Current

Cards

have similar priority.

Expected

Priority order

Primary Focus

↓

Recommended Drill

↓

Reason

↓

Supporting Statistics

↓

Expected Result

User should understand

within

5 seconds

what to practice today.

---

# BUG-009

Recommendation History

Current

History

is difficult to read.

Expected

History grouped by

Today

Yesterday

Last 7 Days

Last 30 Days

Each item

shows

Date

↓

Recommendation

↓

Completed

↓

Result

Do not redesign

History logic.

Presentation only.

---

# BUG-010

Performance

Coach Screen

must open

smoothly.

No loading freeze.

No unnecessary rebuild.

Optimize UI rebuild only.

Do NOT modify

AI Engine.

---

# ACCEPTANCE

Coach Screen

must become

easy to understand.

Player should know

within

5 seconds

What is wrong.

Why.

Which drill to practice.

What benefit

will be obtained.

No English.

No fake recommendation.

No business logic change.

Presentation Layer only.

---

# REPORT

Report ONLY

1.

Root Cause

2.

Files Modified

3.

UI Changed

4.

Localization Updated

5.

Regression Risk

6.

Flutter Analyze

Do NOT modify

Coach Rule Engine.

Do NOT modify

Recommendation Engine.

Do NOT modify

Database.

Do NOT redesign workflow.

Presentation Layer only.