# RFC-011 - Session Data Collection Specification

Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

Pool OS must collect enough data after every Match and Rack to allow Statistics Engine and Coach Engine to generate meaningful analysis.

Data collection must be:

* Fast
* Simple
* Optional where appropriate
* Never interrupt gameplay

Target input time after one rack:

**< 10 seconds**

---

# Data Hierarchy

Player

↓

Session

↓

Match

↓

Rack

↓

Shot (Optional)

↓

Event

---

# Session Screen

Required Fields

Session Name

Session Type

* Practice
* Friendly Match
* League
* Tournament
* Money Match

Location

Table

Cloth

Ball Set

Date

Start Time

End Time

Session Goal

Examples

Improve Break

Improve Position

Tournament Practice

General Practice

---

# Match Screen

Required

Opponent

Race To

Current Score

Match Result

Optional

Opponent Level

Table Condition

Pressure Level

Notes

---

# Rack Screen

Every Rack MUST have one record.

Required

Rack Number

Win / Lose

Break By

* Me
* Opponent

Break Success

* Yes
* No

Run Out

* Yes
* No

Open Table

* Yes
* No

Balls Potted

0~9

Longest Run

0~9

Scratch

Yes / No

Foul

Yes / No

---

# Biggest Mistake

Single Select

No Mistake

Break

Thin Cut

Long Pot

Position

Safety

Kick

Bank

Jump

Speed Control

Mental

Scratch

Other

---

# Biggest Strength

Single Select

Break

Shot Making

Position

Safety

Kick

Bank

Jump

Mental

Consistency

Other

---

# Confidence

1

Very Low

2

Low

3

Normal

4

Good

5

Excellent

---

# Pressure

Normal

Important Rack

Hill-Hill

Tournament Point

Match Point

---

# Optional Note

Free text

Maximum 300 characters.

---

# Shot Collection

Disabled by default.

Can be enabled in Settings.

Shot contains

Shot Type

Difficulty

Result

Position Result

Spin

Speed

Notes

---

# Event Recording

Multiple Events can exist in one Rack.

Examples

THIN_CUT_MISS

POSITION_TOO_LONG

POSITION_TOO_SHORT

BREAK_DRY

BREAK_SCRATCH

SCRATCH

FOUL

BANK_MISS

KICK_MISS

SAFETY_SUCCESS

SAFETY_FAIL

MENTAL_RUSH

MENTAL_CONFIDENCE_DROP

PRESSURE_HILL_HILL

---

# End Of Rack Flow

User presses

Win

or

Lose

↓

Popup

Balls Potted

↓

Biggest Mistake

↓

Biggest Strength

↓

Confidence

↓

Save

↓

Next Rack

Target time

5~10 seconds

---

# End Of Match

Display Summary

Match Result

Rack Score

Win Rate

Break Success

Longest Run

Biggest Mistake

Biggest Strength

Coach Summary

---

# End Of Session

Generate

Session Summary

Statistics

Coach Recommendation

Training Suggestion

Recovery Suggestion

---

# User Experience Rules

User must never answer more than five questions after one rack.

All optional fields can be skipped.

The application should remember previous selections where appropriate.

Use large touch buttons.

No typing unless user selects Notes.

---

# Required Database Objects

Session

Match

Rack

Shot

Event

Coach can only analyze completed data.

---

# Acceptance Criteria

✓ User can record one rack in less than 10 seconds.

✓ Every rack has enough information for Coach analysis.

✓ Statistics update immediately after saving.

✓ Coach receives structured data instead of raw Win/Lose only.

✓ All fields support Vietnamese localization.
