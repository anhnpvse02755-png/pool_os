# RFC-014 - Training Drill Library

Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

Coach MUST recommend real drills.

Coach MUST NEVER recommend only a skill name.

Bad Example

"Practice Position."

Good Example

"20 phút Stop Shot

20 phút Follow Shot

20 phút Position Ladder"

---

# Drill Categories

The Training Library consists of the following categories.

1.

Warmup

2.

Straight Shot

3.

Thin Cut

4.

Thick Cut

5.

Long Pot

6.

Position

7.

Cue Ball Control

8.

Break

9.

Safety

10.

Kick

11.

Bank

12.

Jump

13.

Pattern Play

14.

Pressure

15.

Tournament

16.

Mental

17.

Recovery

---

# Drill Structure

Every drill contains

Drill ID

Name

Category

Difficulty

Skill

Description

Equipment Needed

Duration

Target

Evaluation

Coach Notes

---

# Difficulty

Beginner

Intermediate

Advanced

Professional

---

# Warmup

## W001

Center Ball Straight Shot

Duration

5 min

Goal

Center cue ball

No side spin

Success Target

95%

---

## W002

Cue Ball Stop

Duration

5 min

Goal

Cue ball stops within one ball diameter

Success

90%

---

## W003

Distance Control

Duration

5 min

Goal

Cue ball stops inside target zone

---

# Thin Cut

## TC001

Short Thin Cut

Skill

Thin Cut

Duration

20 min

Target

80%

---

## TC002

Long Thin Cut

Distance

Long

Difficulty

Advanced

---

## TC003

Rail Thin Cut

Object Ball

Near Rail

Target

75%

---

# Long Pot

## LP001

Long Straight

Target

90%

---

## LP002

Long Cut

Target

80%

---

## LP003

Long Distance Follow

---

# Position

## P001

Stop Shot

Target

95%

---

## P002

Follow Shot

---

## P003

Draw Shot

---

## P004

Ladder Drill

---

## P005

Clock Position Drill

---

# Cue Ball Control

## CB001

Speed Control

---

## CB002

Cue Ball Ladder

---

## CB003

One Rail Position

---

## CB004

Two Rail Position

---

# Break

## B001

Power Break

---

## B002

Control Break

---

## B003

Wing Ball Practice

---

## B004

Cue Ball Control After Break

---

# Safety

## S001

Distance Safety

---

## S002

Thin Safety

---

## S003

Two Rail Safety

---

# Kick

## K001

One Rail Kick

---

## K002

Two Rail Kick

---

## K003

Diamond System

---

# Bank

## BK001

Cross Bank

---

## BK002

Long Bank

---

## BK003

Short Bank

---

# Jump

## J001

Easy Jump

---

## J002

Rail Jump

---

## Pattern

## PT001

3 Ball Pattern

---

## PT002

5 Ball Pattern

---

## PT003

Run Out Pattern

---

# Pressure

## PR001

Hill Hill Drill

Description

Every miss resets score.

---

## PR002

Race To 5

---

## PR003

Must Make Shot

---

# Mental

## M001

Pre-shot Routine

---

## M002

Breathing Routine

---

## M003

Confidence Reset

---

# Recovery

## R001

Shoulder Stretch

---

## R002

Back Stretch

---

## R003

Eye Relaxation

---

# Coach Recommendation Mapping

Example

If

Position Accuracy

<65%

Coach recommends

P001

P002

P004

---

If

Thin Cut Accuracy

<60%

Coach recommends

TC001

TC002

TC003

---

If

Break Success

<50%

Coach recommends

B001

B002

B004

---

If

Stress

High

Coach recommends

M001

M002

R001

---

If

Ready Score

<50

Coach recommends

Recovery only

No intensive drills.

---

# Training Plan Generator

Coach builds training automatically.

Example

Warmup

10 min

↓

Thin Cut

20 min

↓

Position

20 min

↓

Pressure

15 min

↓

Cooldown

5 min

---

Total

70 min

---

# Expected Improvement

Every Drill should define

Expected Improvement

Example

Stop Shot

*

Position Accuracy

*

Cue Ball Control

---

Thin Cut

*

Thin Cut Accuracy

*

Confidence

---

Power Break

*

Break Success

*

Cue Ball Control

---

# Acceptance Criteria

Coach NEVER recommends only a skill.

Coach ALWAYS recommends drills.

Every Drill has measurable goals.

Every Drill belongs to one Skill.

Every Skill contains multiple Drills.

Training plans are automatically generated from Statistics and Rule Engine.
