# RFC-010 - Coach Intelligence Engine
Version: 1.0
Status: REQUIRED
Priority: P0

---

# Objective

Coach AI MUST generate training recommendations based on real user data.

Coach AI MUST NOT use hardcoded recommendations.

Coach AI MUST NOT generate advice without supporting data.

Recommendation = Data -> Statistics -> Rule -> Coach Output

---

# Architecture

Player
    ↓
Daily Readiness
    ↓
Session
    ↓
Match
    ↓
Rack
    ↓
Shot
    ↓
Event
    ↓
Statistics Engine
    ↓
Coach Rule Engine
    ↓
Coach Recommendation

---

# Data Collection

Coach Rule depends on Session Data.

If Session Data is missing,
Coach MUST return:

"Chưa có đủ dữ liệu để đưa ra khuyến nghị."

Never fabricate recommendation.

---

# Required Session Data

## Daily Readiness

Sleep

Energy

Stress

Focus

Confidence

Shoulder

Elbow

Wrist

Back

Nutrition

Hydration

Warmup Completed

---

## Match

Opponent

Race

Table

Tournament / Practice

Start Time

End Time

---

## Rack

Rack Number

Win / Lose

Break Success

Break Type

Run Out

Balls Potted

Longest Run

Safety Count

Kick Count

Bank Count

Jump Count

Scratch

Foul

Pressure

Confidence (1-5)

Biggest Mistake

Biggest Success

Notes

---

## Shot

Shot Type

Shot Difficulty

Long Pot

Thin Cut

Rail Shot

Bank

Kick

Jump

Draw

Follow

Stop Shot

Spin Used

Shot Result

---

## Event

Every mistake MUST be recorded as Event.

Example

BREAK_DRY

BREAK_SCRATCH

POSITION_TOO_LONG

POSITION_TOO_SHORT

THIN_CUT_MISS

LONG_POT_MISS

BANK_MISS

KICK_MISS

SCRATCH

FOUL

MENTAL_RUSH

MENTAL_LOST_CONFIDENCE

PRESSURE_HILL_HILL

...

---

# Coach Rule Engine

Coach NEVER reads Session directly.

Coach ALWAYS reads Statistics.

Statistics are generated from:

Session

↓

Rack

↓

Shot

↓

Event

---

# Rule Categories

## Readiness

Should user train today?

Training intensity?

Recovery needed?

---

## Skill Priority

Weakest Skill

Most Improved Skill

Regression Skill

---

## Match Review

Why user won?

Why user lost?

Largest mistake

Largest strength

---

## Equipment

Equipment impact

Tip impact

Cue impact

---

## Mental

Pressure

Confidence

Rush

Focus

Hill Hill

---

## Training Plan

Coach MUST generate

Warmup

Main Drill

Match Practice

Cooldown

---

# Coach Output

Every recommendation MUST contain

1. Observation

2. Evidence

3. Recommendation

4. Expected Improvement

Example

Observation

Đi bi đang là kỹ năng yếu nhất.

Evidence

Position Accuracy giảm 9% trong 5 buổi gần nhất.

Recommendation

20 phút Stop Shot

20 phút Follow Shot

20 phút Position Drill

Expected Improvement

Tăng Position Accuracy khoảng 5~8%.

---

# No Hardcode

Forbidden

"You should practice Position."

Required

Use user statistics.

Use user trend.

Use user readiness.

Use equipment history.

Use match history.

---

# Acceptance Criteria

Coach MUST explain

WHY

Coach MUST explain

WHAT

Coach MUST explain

HOW

Coach MUST explain

EXPECTED RESULT

---

# Blocking Rule

If Statistics are insufficient,

Coach MUST NOT generate fake advice.

Instead display

"Chưa có đủ dữ liệu. Hãy hoàn thành ít nhất 3 buổi chơi để Coach có thể phân tích."