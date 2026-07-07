# FIX-006 - Coach AI Rule Engine

Version: 1.0

Priority: P0

Status: Ready

Reference

RFC-011 Coach Engine

RFC-012 Statistics

RFC-020 Definition of Done

---

# Objective

Replace the current hardcoded Coach.

Coach AI must generate recommendations entirely from player data.

No hardcoded advice.

No random suggestions.

Every recommendation must have a reason.

---

# Coach Input

Coach MUST read only these sources.

Daily Readiness

Statistics Engine

Practice History

Match History

Rack Summary

Equipment

Player Goal

Never read raw database directly.

Always use Statistics Engine.

---

# Coach Output

Coach generates

1. Daily Readiness

2. Training Focus

3. Weakness Analysis

4. Strength Analysis

5. Weekly Plan

6. Daily Drills

7. Equipment Suggestions

8. Recovery Advice

9. Progress Report

---

# Priority Rule

Coach always chooses

ONE

highest priority.

Never recommend improving everything.

Priority order

Critical Weakness

↓

Current Goal

↓

Recent Trend

↓

Long-term Weakness

↓

Maintain Strength

---

# Daily Readiness

Input

Sleep

Energy

Stress

Body Pain

Practice Time

Output

Excellent

Good

Normal

Poor

Recovery

---

Example

Sleep

4h

Stress

High

↓

Coach

Recovery Day

↓

No intensive drills

---

# Weakness Detection

Coach evaluates

Potting

Position

Safety

Break

Mental

Cue Ball

Consistency

Each skill

0

↓

100

---

Rule

Below 50

Critical

50~70

Needs Improvement

70~85

Good

85+

Excellent

---

# Training Focus

Coach selects

ONE

main skill.

Example

Position

↓

Today's focus

Position Play

Not

Position

+

Safety

+

Potting

+

Break

All together.

---

# Daily Training

Coach generates

Warm-up

↓

Main Drill

↓

Support Drill

↓

Challenge

↓

Cooldown

---

Target duration

15

30

45

60

90

Minutes

---

# Drill Selection

Coach recommends drills based on

Weakness

Difficulty

Recent Practice

Player Level

Current Readiness

Never recommend

same drill

more than

3 consecutive sessions.

---

# Match Analysis

After every match

Coach generates

Overall Score

Strength

Weakness

Most Common Error

Largest Improvement

Next Training Focus

Confidence Trend

---

# Weekly Report

Every 7 days

Coach generates

Practice Hours

Match Hours

Improvement

Decline

Skill Radar

Top Weakness

Top Strength

Training Recommendation

---

# Equipment Advice

Coach analyses

Cue

Tip

Shaft

Performance

Example

Player Win %

↓

Changed Tip

↓

Performance +8%

↓

Recommend keeping current tip.

---

# Recovery

When

Stress High

Sleep Poor

Confidence Low

Coach reduces workload.

Recommend

Recovery

Mental Training

Easy Drills

---

# Notification

Coach notifications

must be Vietnamese.

Examples

Không

Good Job!

Need Improvement.

Excellent.

Phải

Hôm nay bạn có tiến bộ.

Độ ổn định đang giảm.

Nên tập bài cắt mỏng hôm nay.

Bạn nên nghỉ ngơi.

---

# Explainability

Every recommendation must explain WHY.

Example

Hôm nay nên tập Cắt Mỏng.

Lý do

Bạn chỉ đạt 48%

ở các cú cắt mỏng trong 7 ngày gần đây.

---

# Recommendation History

Store every recommendation.

Allow user to review

Yesterday

Last Week

Last Month

---

# Constraints

Do NOT use hardcoded recommendations.

Do NOT generate random drills.

Every recommendation must be traceable to statistics.

---

# Acceptance Criteria

✓ Coach uses Statistics Engine only.

✓ One primary focus per day.

✓ Every recommendation has explanation.

✓ Training plan generated automatically.

✓ Weekly report generated.

✓ Match report generated.

✓ Daily readiness affects training.

✓ Equipment analysis supported.

✓ Recommendation history available.

✓ 100% Vietnamese.

✓ No hardcoded text.

✓ No regression.