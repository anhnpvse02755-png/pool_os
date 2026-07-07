# FIX-008C
Version: 1.0
Priority: P1
Module: Statistics

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

Modify ONLY

Statistics Module.

Do NOT modify

Coach

Session

Match

Equipment

Dashboard

Database

Business Logic

Statistics Engine

Only improve

Statistics UI

Statistics UX

Statistics Presentation.

---

# BUG-001

Statistics Detail

Current

Detail page only displays

Total Win

Total Lose

Accuracy

Win Rate

These are summary values.

This is NOT detailed statistics.

Expected

Detail page

must provide

drill-down analysis.

Example

Win Rate

↓

Matches Won

↓

Average Balls Potted

↓

Average Largest Run

↓

Average Break Success

↓

Average Confidence

↓

Common Mistakes

↓

Common Strengths

↓

Coach Insight

If no data exists

display

"No Data"

instead of zero.

---

# BUG-002

Statistics should explain WHY

Current

Only numbers.

Expected

Every important KPI

should explain

why it became

high

or

low.

Example

Accuracy

↓

Accuracy Trend

↓

Main Reason

↓

Common Miss Type

↓

Most Frequent Error

↓

Improvement Suggestion

---

# BUG-003

Trend Page

Current

Still contains

English.

Examples

Improve Tip

Accuracy Trend

etc.

Expected

Entire Trend page

must follow

current language.

No English UI.

---

# BUG-004

Trend Detail

Current

Trend only displays chart.

Expected

Every trend

contains

Current

↓

Previous

↓

Difference

↓

Reason

↓

Recommendation

Example

Accuracy

Current

72%

Previous

69%

+3%

Reason

Better cue ball control

Recommendation

Continue Position Practice

---

# BUG-005

Statistics Detail Layout

Current

Flat list.

Expected

Statistics

↓

Category

↓

Metric

↓

Detail

↓

Recommendation

Example

Match

Win Rate

↓

Detail

↓

Recommendation

------------

Break

↓

Success Rate

↓

Detail

↓

Recommendation

------------

Position

↓

Detail

↓

Recommendation

------------

Safety

↓

Detail

↓

Recommendation

---

# BUG-006

Empty State

Current

Shows

0

0%

0%

Expected

If insufficient data

display

Not enough data yet.

Play more matches

to unlock analysis.

Do NOT generate fake statistics.

---

# BUG-007

Recommendation Source

Current

Recommendation appears isolated.

Expected

Recommendation

must reference

actual statistics.

Example

Because

Easy Miss

occurred

18 times

↓

recommend

Thin Cut Practice.

Not

generic recommendation.

---

# ACCEPTANCE

Statistics module must

NOT only display totals.

Statistics must explain

what happened

why

and

what player should improve.

No English text.

No fake data.

No duplicated summary.

All Detail pages provide

real drill-down analysis.

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
Logic Changed

5.
Regression Risk

6.
Flutter Analyze

Do NOT modify

Statistics Engine.

Do NOT modify

Database.

Do NOT redesign workflow.

Presentation Layer only.