# FIX-005 - Statistics Engine Rebuild

Version: 1.0

Priority: P0

Status: Ready

Reference

RFC-011 Coach Engine

RFC-012 Statistics

RFC-016 Dashboard

RFC-020 Definition of Done

---

# Objective

Completely rebuild the Statistics Engine.

Current implementation does not reflect actual player performance.

Statistics must become the single source of truth for the entire application.

Dashboard

↓

Coach

↓

Training Recommendation

↓

Progress

↓

All generated from Statistics.

---

# Core Principle

Statistics are NEVER entered manually.

Statistics are ALWAYS generated automatically.

Input

↓

Rack

Practice

Shot

Daily Readiness

Equipment

↓

Statistics Engine

↓

Dashboard

Coach

Reports

---

# Statistics Categories

The engine shall generate statistics in the following categories.

--------------------------------------------------

1. Career

Overall performance.

Required

- Total Sessions
- Total Matches
- Total Racks
- Win %
- Rack Win %
- Balls Potted
- Average Balls Per Rack
- Highest Run
- Current Winning Streak
- Longest Winning Streak

--------------------------------------------------

2. Potting

Required

- Pot Success %
- Easy Pot %
- Medium Pot %
- Hard Pot %
- Thin Cut %
- Thick Cut %
- Long Pot %
- Bank %
- Combination %

--------------------------------------------------

3. Position Play

Required

- Good Position %
- Bad Position %
- Cue Ball Control
- Shape Success %
- Position Error Count

--------------------------------------------------

4. Safety

Required

- Safety Attempt
- Successful Safety
- Failed Safety
- Safety %

--------------------------------------------------

5. Break

Required

- Break Success %
- Break Scratch
- Break Foul
- Dry Break %
- Average Balls After Break

--------------------------------------------------

6. Mental

Required

- Average Confidence
- Confidence Trend
- Pressure Performance
- Match Deciding Rack %

--------------------------------------------------

7. Errors

Required

- Easy Miss
- Hard Miss
- Scratch
- Jump Error
- Kick Error
- Position Error
- Safety Error

Display

Count

Percentage

Trend

--------------------------------------------------

8. Equipment

Required

Performance grouped by

Cue

Shaft

Tip

Example

Revo

↓

Win %

↓

Pot %

↓

Confidence

↓

Largest Run

---

# Skill Radar

Skill Radar shall be generated ONLY from statistics.

No hardcoded values.

Radar Skills

- Potting
- Position
- Cue Ball Control
- Safety
- Break
- Tactical
- Mental
- Consistency

Scale

0

↓

100

---

# Trend Analysis

Every statistic must support

Today

7 Days

30 Days

90 Days

Lifetime

---

# Comparison

Support

Current

vs

Previous

Display

Improved

Stable

Declined

---

# Dashboard Integration

Dashboard must display

Today's Performance

Weekly Trend

Monthly Trend

Current Focus

Biggest Weakness

Biggest Improvement

Most Practiced Skill

---

# Coach Integration

Coach MUST read

Statistics only.

Coach must NEVER calculate raw data itself.

Coach receives

Skill Scores

Trend

Weakness

Strength

Consistency

Recent Performance

---

# Refresh Rules

Statistics refresh automatically after

Rack Saved

Practice Saved

Session Finished

Equipment Changed

Player Changed

Daily Readiness Saved

---

# Performance

Statistics refresh

< 1 second

Dashboard

< 1 second

Coach

< 2 seconds

---

# Vietnamese

All statistic titles

must be Vietnamese.

No English.

Examples

Không

Accuracy

Consistency

Confidence

Phải

Độ chính xác

Độ ổn định

Mức tự tin

---

# Constraints

Do NOT redesign UI.

Do NOT redesign Coach.

Only rebuild Statistics Engine.

---

# Acceptance Criteria

✓ All statistics generated automatically.

✓ Skill Radar based on real statistics.

✓ Dashboard uses statistics only.

✓ Coach uses statistics only.

✓ Trend analysis available.

✓ Equipment comparison available.

✓ Career statistics correct.

✓ Vietnamese complete.

✓ No regression.