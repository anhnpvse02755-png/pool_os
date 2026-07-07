# RFC-016 - Dashboard & KPI Specification

Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

Dashboard is the Home Screen of Pool OS.

Dashboard must answer 5 questions immediately.

1.

How am I today?

2.

What should I train?

3.

Am I improving?

4.

What is my biggest weakness?

5.

What should I do next?

Dashboard MUST NOT become a statistics page.

Dashboard MUST focus on action.

---

# Dashboard Sections

Dashboard contains

1.

Daily Readiness

2.

Coach Card

3.

Today's Training

4.

Skill Radar

5.

Quick Statistics

6.

Recent Sessions

7.

Equipment Status

8.

Weekly Progress

---

# Section 1

Daily Readiness

Display

Ready Score

0~100

Color

Green

Yellow

Orange

Red

Display

Sleep

Energy

Stress

Confidence

Recovery

Coach Comment

Examples

"Sẵn sàng luyện tập."

"Chỉ nên tập nhẹ."

"Hôm nay nên nghỉ."

---

# Section 2

Coach Card

Display

Today's Focus

Example

Position Play

Coach Message

Maximum

120 characters

Example

"Hôm nay Position Play đang là điểm yếu lớn nhất."

Button

View Full Coach Report

---

# Section 3

Today's Training

Display

Warmup

Main Drill

Secondary Drill

Pressure Drill

Cooldown

Estimated Time

Completion %

Button

Start Training

---

# Section 4

Skill Radar

Display

Break

Shot Making

Position

Safety

Cue Ball Control

Mental

Consistency

Every skill

0~100

Tap one skill

↓

Open Detail Screen

---

# Section 5

Quick Statistics

Display

Win Rate

Rack Win %

Break Success

Position Accuracy

Thin Cut Accuracy

Longest Run

Current Streak

Weekly Hours

---

# Section 6

Recent Sessions

Display last

5 Sessions

Session

Result

Duration

Coach Score

Tap

↓

Session Detail

---

# Section 7

Equipment

Current Cue

Current Shaft

Current Tip

Usage Time

Replacement Reminder

Example

Tip

Used

145 hours

Recommendation

Replace Soon

---

# Section 8

Weekly Progress

Display

Training Hours

Completed Drills

Coach Score

Improvement %

Weekly Goal

Completion %

---

# Dashboard KPI

Dashboard must calculate

Ready Score

Coach Score

Skill Score

Trend Score

Weekly Progress

Monthly Progress

Lifetime Progress

---

# Trend Indicators

Every KPI must show

Current Value

Trend

History

Example

Position Accuracy

68%

↑ 5%

Last 5 Sessions

---

# Color Rules

Green

Improving

Yellow

Stable

Red

Declining

Grey

Insufficient Data

---

# Coach Score

Calculated from

Readiness

Statistics

Training Completion

Trend

Output

0~100

---

# Dashboard Refresh

Dashboard updates after

Session Save

Match Save

Rack Save

Daily Check-in

Equipment Change

---

# Empty State

If user has no data

Display

Welcome

↓

Create First Session

↓

Start Practice

No fake statistics.

---

# Localization

All Dashboard text

must support

Vietnamese

English

No hardcoded English.

---

# Performance

Dashboard loading

< 1 second

Statistics loaded asynchronously

Charts cached

---

# Acceptance Criteria

Dashboard shows today's status immediately.

Coach recommendation visible without entering other screens.

All KPI calculated from Statistics Engine.

No hardcoded values.

Every widget supports Vietnamese.

Every card can be tapped for details.
