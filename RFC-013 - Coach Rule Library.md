# RFC-013 - Coach Rule Library
Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

Coach Engine MUST generate recommendations based on predefined rules.

Coach MUST NEVER randomly generate advice.

Every recommendation must be supported by Statistics.

---

# Rule Priority

Priority 1

Health

↓

Priority 2

Readiness

↓

Priority 3

Mental

↓

Priority 4

Skill Weakness

↓

Priority 5

Training Plan

↓

Priority 6

Equipment

---

# Coach Output Format

Every recommendation MUST include

Observation

↓

Evidence

↓

Recommendation

↓

Expected Result

Example

Observation

Position Play đang giảm.

Evidence

Position Accuracy giảm 8% trong 5 Session gần nhất.

Recommendation

20 phút Stop Shot

20 phút Follow Shot

20 phút Position Drill

Expected Result

Position Accuracy tăng khoảng 5%.

---

# Rule Group 1

Daily Readiness

Input

Sleep

Energy

Stress

Recovery

Confidence

Output

Training Intensity

Rule

Ready Score >= 85

↓

Heavy Training

Ready Score 70~84

↓

Normal Training

Ready Score 50~69

↓

Light Training

Ready Score < 50

↓

Recovery Day

---

# Rule Group 2

Sleep

Sleep < 5 hours

↓

Reduce Training Volume

Sleep < 4 hours

↓

No Match Practice

Sleep > 7 hours

↓

Normal

---

# Rule Group 3

Stress

Stress >= 8

↓

No Pressure Drill

Focus Technique Only

---

# Rule Group 4

Confidence

Confidence <= 2

↓

Avoid Competition

Practice Basic Skills

Confidence >= 4

↓

Pressure Drill Allowed

---

# Rule Group 5

Break

Break Success < 50%

↓

Recommend

Break Drill

Power Control

Cue Ball Control

---

# Rule Group 6

Thin Cut

Thin Cut Accuracy < 60%

↓

Recommend

Thin Cut Drill

Ghost Ball Drill

Reference Drill

---

# Rule Group 7

Long Pot

Long Pot Accuracy < 55%

↓

Recommend

Long Straight Drill

Long Cut Drill

Distance Control

---

# Rule Group 8

Position

Position Accuracy < 65%

↓

Recommend

Stop Shot

Follow Shot

Draw Shot

Position Ladder

---

# Rule Group 9

Cue Ball Control

Scratch Rate > 10%

↓

Recommend

Cue Ball Speed Drill

Center Ball Drill

Stop Shot

---

# Rule Group 10

Safety

Safety Success < 60%

↓

Recommend

Safety Drill

Distance Safety

Thin Safety

---

# Rule Group 11

Kick

Kick Success < 50%

↓

Recommend

1 Rail Kick

2 Rail Kick

Diamond System

---

# Rule Group 12

Bank

Bank Success < 40%

↓

Recommend

Cross Bank

Long Bank

Short Bank

---

# Rule Group 13

Hill Hill

Hill-Hill Lose > Win

↓

Recommend

Pressure Drill

Routine Practice

Breathing Routine

---

# Rule Group 14

Consistency

Consistency < 70

↓

Reduce Difficulty

Increase Repetition

---

# Rule Group 15

Equipment

Performance decreased after Tip Change

↓

Recommend

Continue Testing

OR

Return Previous Tip

---

# Rule Group 16

Fatigue

Training

> 5 consecutive days

↓

Recovery Day

---

# Rule Group 17

Regression

Skill decreases

3 Sessions continuously

↓

High Priority Training

---

# Rule Group 18

Improvement

Skill increases

5 Sessions continuously

↓

Reduce Training Time

Move Focus To Next Weakest Skill

---

# Rule Group 19

Training Distribution

Coach should distribute training time

Weak Skill

50%

Medium Skill

30%

Strong Skill

20%

---

# Rule Group 20

No Recommendation Rule

If Statistics are insufficient

↓

Display

"Chưa đủ dữ liệu để đưa ra khuyến nghị."

Never fabricate advice.

---

# Coach Recommendation Rules

Coach must always explain

Why

↓

Evidence

↓

Training Plan

↓

Expected Improvement

Never output only

"Hãy luyện Position."

---

# Acceptance Criteria

Coach recommendations are

Data-driven

Consistent

Explainable

Repeatable

No Random Output

No Hardcoded Recommendation

All recommendations generated from Statistics and Rule Engine only.