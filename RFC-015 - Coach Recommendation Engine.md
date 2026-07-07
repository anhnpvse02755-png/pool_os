# RFC-015 - Coach Recommendation Engine

Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

Generate personalized daily training plans.

Coach MUST combine

Readiness

*

Statistics

*

Rule Engine

*

Training Library

↓

Training Plan

Coach MUST NEVER recommend drills randomly.

---

# Input

Coach receives

Player

Daily Readiness

Equipment

Current Session

Statistics

Trend

Rule Engine Output

Training Library

---

# Recommendation Pipeline

Daily Readiness

↓

Statistics

↓

Rule Engine

↓

Skill Priority

↓

Training Drill Selection

↓

Training Schedule

↓

Coach Message

---

# Step 1

Readiness Check

Input

Sleep

Energy

Stress

Confidence

Recovery

Output

Training Level

Heavy

Normal

Light

Recovery

---

# Step 2

Skill Priority

Coach ranks every skill

Break

Shot

Position

Safety

Kick

Bank

Jump

Mental

Consistency

Example

Position

54

↓

Highest Priority

---

# Step 3

Weakest Skill Selection

Coach selects

Top 3 weakest skills.

Example

Position

Thin Cut

Mental

---

# Step 4

Drill Selection

Every skill contains

Easy

Medium

Hard

Coach chooses based on

Player Level

Readiness

Current Trend

Example

Intermediate Player

↓

Position

↓

Stop Shot

↓

Follow

↓

Position Ladder

---

# Step 5

Training Time Distribution

Heavy Day

90~120 min

Normal Day

60~90 min

Light Day

30~45 min

Recovery

15~30 min

---

# Time Allocation

Weak Skill

50%

Medium Skill

30%

Strong Skill

20%

---

# Session Structure

Warmup

↓

Main Drill

↓

Secondary Drill

↓

Pressure Drill

↓

Cooldown

---

# Warmup

Always included.

5~10 min.

Examples

Center Ball

Straight Shot

Cue Ball Stop

---

# Pressure Drill Rules

Only include

if

Readiness > 70

AND

Confidence > 3

Otherwise

Skip.

---

# Mental Rules

Stress > 7

↓

Reduce difficulty.

↓

No Pressure Drill.

↓

Recommend breathing routine.

---

# Recovery Rules

Sleep < 5h

↓

No intensive drills.

↓

Stretching

↓

Stop Shot

↓

Recovery only.

---

# Equipment Rules

Tip changed

↓

Do not recommend advanced drills.

↓

Recommend calibration drills.

---

# Regression Rules

If one skill decreases

3 consecutive sessions

↓

Increase drill frequency.

---

# Improvement Rules

If one skill improves

5 consecutive sessions

↓

Reduce training volume.

↓

Move focus to next weakest skill.

---

# Recommendation Limits

Maximum

5 drills

per day.

Never recommend

more than

2 difficult drills

in one session.

---

# Daily Plan Example

Warmup

10 min

Center Ball

↓

Position

20 min

Stop Shot

↓

Position

20 min

Position Ladder

↓

Thin Cut

20 min

Short Thin Cut

↓

Pressure

15 min

Hill-Hill Drill

↓

Cooldown

5 min

Stretch

---

# Weekly Rotation

Coach should rotate drills.

Avoid repeating

same drill

more than

3 consecutive sessions.

---

# Adaptive Recommendation

Coach must adapt based on

Player Level

Current Trend

Equipment

Fatigue

Mental State

Recent Sessions

---

# Coach Explanation

Every recommendation must explain

Observation

↓

Evidence

↓

Why this drill

↓

Expected Improvement

---

# Example Output

Observation

Position Play is declining.

Evidence

Position Accuracy dropped from 72% to 63%.

Recommendation

20 min Stop Shot

20 min Position Ladder

15 min Follow Shot

Expected Result

Position Accuracy should improve by 5~8%.

---

# Recommendation History

Store

Date

Recommendation

Completed

Skipped

Success Rate

Coach uses history to avoid repetition.

---

# Acceptance Criteria

Training plans are personalized.

Training intensity adapts daily.

Recommendations are data-driven.

No repeated drills.

No random output.

Coach always explains WHY.
