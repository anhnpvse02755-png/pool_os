# DS-002 Billiards Knowledge Base
## Part 01 - Billiards Knowledge System

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the knowledge architecture used by Coach AI.

Coach AI must think like a professional billiards coach.

Knowledge must be structured.

Knowledge must never be hardcoded.

---

# Philosophy

A coach does not evaluate only results.

A coach evaluates

Technique

Decision

Execution

Consistency

Progress

Pool OS must do the same.

---

# Knowledge Pyramid

Player

↓

Statistics

↓

Skills

↓

Mistakes

↓

Training

↓

Progress

Every recommendation originates from this hierarchy.

---

# Knowledge Categories

The knowledge base is divided into independent domains.

Shot Knowledge

↓

Skill Knowledge

↓

Mistake Knowledge

↓

Drill Knowledge

↓

Equipment Knowledge

↓

Mental Knowledge

↓

Competition Knowledge

↓

Progression Knowledge

---

# Coach Thinking Flow

Observe

↓

Analyze

↓

Identify Weakness

↓

Identify Cause

↓

Select Drill

↓

Measure Improvement

Coach never skips steps.

---

# Player Model

Every player has

Technical Ability

Mental Ability

Tactical Ability

Equipment

Goals

History

Readiness

Coach evaluates all dimensions together.

---

# Performance Sources

Coach receives information from

Practice

Competition

Daily Readiness

Equipment

Statistics

Goals

No recommendation may rely on only one source.

---

# Skill System

Every skill belongs to one category.

Example

Potting

Cue Ball Control

Position Play

Safety

Break

Kick

Jump

Bank

Mental

Pattern Play

Every skill has measurable data.

---

# Weakness Detection

Weakness is identified by

Accuracy

↓

Frequency

↓

Trend

↓

Confidence

↓

Difficulty

A single miss never defines a weakness.

---

# Strength Detection

Strength requires

Repeated Success

↓

Consistency

↓

Competition Validation

↓

Long-term Stability

---

# Recommendation Logic

Weakness

+

Importance

+

Frequency

=

Priority

Priority determines today's training.

---

# Training Loop

Practice

↓

Evaluation

↓

Adjustment

↓

Practice

↓

Evaluation

This loop never ends.

---

# Improvement Principle

Coach must compare

Player Yesterday

↓

Player Today

↓

Player Tomorrow

Coach never compares players against each other.

---

# Knowledge Separation

Knowledge

≠

Rules

Knowledge explains

Rules decide.

Example

Knowledge

Thin Cut requires accurate aiming.

Rule

If Thin Cut accuracy <70%

↓

Recommend Thin Cut drills.

---

# Extensibility

Every future knowledge document must belong to one category only.

No duplicated knowledge is allowed.

---

# Mandatory Rule

All future Coach AI development must reference DS-002.

Coach AI must never rely on undocumented billiards knowledge.

---

End of Part 01

# DS-002 Billiards Knowledge Base
## Part 02 - Shot Taxonomy

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines every shot type recognized by Pool OS.

Coach AI uses this taxonomy for

Practice

Competition

Statistics

Recommendation

Every shot belongs to one category only.

---

# Principle

Coach analyzes

Intent

↓

Execution

↓

Result

Not simply

Success

or

Failure

---

# Level 1

Shot Categories

1. Potting
2. Cue Ball Control
3. Position Play
4. Safety
5. Kick
6. Bank
7. Jump
8. Break
9. Combination
10. Specialty

---

# Category 1

Potting

Includes

Straight

Thin Cut

Medium Cut

Thick Cut

Long Pot

Short Pot

Rail Pot

Frozen Ball

Pocket Speed Pot

Power Pot

---

# Straight Shot

Definition

Object ball lies almost directly in front of cue ball.

Tolerance

Very high.

Primary Skill

Stroke

Alignment

Cue Delivery

---

# Thin Cut

Definition

Contact less than approximately 40%.

Typical Errors

Undercut

Steering

Lifting body

Wrong speed

Coach Priority

Very High

---

# Medium Cut

Definition

Approximately

40-60%

contact.

Most common competition shot.

Primary Skill

Aim

Cue Delivery

Position

---

# Thick Cut

Definition

More than

60%

contact.

Usually position-oriented.

Common Errors

Overcut

Speed

Wrong spin

---

# Long Pot

Definition

Distance greater than

2 diamonds.

Requires

Stroke

Alignment

Confidence

---

# Rail Pot

Definition

Object ball close to cushion.

Difficulty increases because

Pocket angle changes

Rail interferes

Bridge quality changes

---

# Frozen Ball

Definition

Object ball touching cushion.

Requires different contact perception.

---

# Category 2

Cue Ball Control

Includes

Stop Shot

Follow

Draw

Stun

Slow Roll

Power Stroke

Spin Transfer

Two Rail Position

Three Rail Position

Natural Roll

---

# Stop Shot

Goal

Cue ball stops after impact.

Primary Skill

Center Ball

Speed

Accuracy

---

# Follow Shot

Goal

Cue ball continues forward.

Measured by

Distance

Accuracy

Position

---

# Draw Shot

Goal

Cue ball returns.

Difficulty Levels

Short Draw

Medium Draw

Long Draw

Power Draw

---

# Stun Shot

Goal

Cue ball slides before rolling.

Important for

Position

Pattern Play

---

# Category 3

Position Play

Includes

One Rail Position

Two Rail Position

Three Rail Position

Inside Route

Outside Route

Natural Route

Small Window Position

Large Window Position

---

# Category 4

Safety

Includes

Simple Safety

Distance Safety

Hook Safety

Containment Safety

Rail Safety

Two Way Shot

---

# Category 5

Kick

Includes

One Rail Kick

Two Rail Kick

Three Rail Kick

Z Kick

Escape Kick

Kick Safe

Kick Pot

---

# Category 6

Bank

Includes

Cross Bank

Long Bank

Short Bank

Double Bank

Cross Side

Cross Corner

---

# Category 7

Jump

Includes

Short Jump

Long Jump

Controlled Jump

Jump Pot

Jump Safe

---

# Category 8

Break

Includes

Power Break

Control Break

Second Ball Break

Cut Break

Soft Break

---

# Category 9

Combination

Includes

Combination

Carom

Kiss

Billiard

Plant

---

# Category 10

Specialty

Includes

Masse

Swerve

Curve

Extreme Spin

Recovery Shot

Lucky Shot

---

# Difficulty

Every shot stores

Difficulty

1

↓

5

1

Very Easy

5

Professional Level

---

# Statistics

Every shot records

Attempts

Success

Misses

Average Difficulty

Competition Accuracy

Practice Accuracy

Trend

Confidence

---

# Coach Usage

Coach identifies

Most Played

Worst Accuracy

Most Improved

Most Repeated Mistake

Coach recommendations always originate from this taxonomy.

---

# Mandatory Rule

Every recorded shot must belong to exactly one Shot Type.

Undefined shot types are prohibited.

---

End of Part 02

# DS-002 Billiards Knowledge Base
## Part 03 - Shot Intent Taxonomy

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Every shot has an objective.

Coach AI must evaluate

Intent

↓

Execution

↓

Result

instead of only

Success

↓

Failure

This document defines all shot intents.

---

# Philosophy

A player never shoots "randomly".

Every shot is trying to achieve something.

Coach AI evaluates whether

The correct decision was chosen.

The execution matched the decision.

---

# Shot Evaluation Model

Shot

↓

Intent

↓

Execution

↓

Result

↓

Evaluation

---

# Intent Categories

Every shot belongs to one primary intent.

1.

Pot Ball

2.

Position

3.

Safety

4.

Break Out Cluster

5.

Open Table

6.

Pocket Speed

7.

Cue Ball Escape

8.

Snooker Escape

9.

Pattern Building

10.

Break Shot

---

# Intent 1

Pot Ball

Goal

Simply pocket the object ball.

Secondary position is unimportant.

Evaluation

Pot %

Accuracy

Speed

---

# Intent 2

Position

Goal

Pocket the ball

AND

leave cue ball in a target zone.

Evaluation

Pot

Cue Ball

Next Shot

Window Accuracy

---

# Intent 3

Safety

Goal

Leave opponent difficult shot.

Evaluation

Hook Quality

Distance

Cue Ball Position

Object Ball Position

---

# Intent 4

Break Cluster

Goal

Separate grouped balls.

Evaluation

Cluster Opened

Cue Ball Safe

Next Shot Available

---

# Intent 5

Open Table

Goal

Create easier pattern.

Typical examples

Remove blocker

Open key ball

Move problem ball

---

# Intent 6

Pocket Speed

Goal

Control speed instead of power.

Evaluation

Speed

Cue Ball

Pocket Acceptance

---

# Intent 7

Cue Ball Escape

Goal

Recover from bad cue ball position.

Evaluation

Recovery Quality

Risk

Execution

---

# Intent 8

Snooker Escape

Goal

Hit legal object ball.

Evaluation

Contact

Leave

Safety after escape

---

# Intent 9

Pattern Building

Goal

Prepare next

2~5 balls.

Evaluation

Pattern Quality

Future Position

Decision

---

# Intent 10

Break Shot

Goal

Maximum table advantage.

Evaluation

Spread

Cue Ball Control

Scratch

Shot Opportunity

---

# Decision Quality

Coach evaluates

Was this the correct decision?

Possible values

Excellent

Good

Acceptable

Poor

Critical Mistake

---

# Execution Quality

Coach evaluates

Stroke

Aim

Speed

Spin

Position

Independently.

---

# Result Quality

Possible outcomes

Perfect

Successful

Acceptable

Poor

Failure

---

# Examples

Example 1

Thin Cut

Intent

Pot Ball

↓

Miss

Coach

Cut Accuracy problem

-------------------

Example 2

Thin Cut

Intent

Position

↓

Ball potted

↓

Wrong cue ball

Coach

Position problem

NOT

Cut problem

-------------------

Example 3

Safety

↓

Opponent easy shot

Coach

Safety decision correct

Execution poor

-------------------

Example 4

Kick

↓

Hit legal ball

↓

Leave safe

Coach

Excellent kick

---

# Statistics

Every Intent stores

Attempts

Success

Average Difficulty

Trend

Confidence

Coach can identify

Best Intent

Worst Intent

Most Improved Intent

Most Frequent Intent

---

# Coach Recommendation

Coach must distinguish

Technique

Decision

Execution

Example

Player pots

95%

↓

Position only

42%

Coach trains

Position

NOT

Potting

---

# Future Expansion

Intent can be combined with

Shot Type

Difficulty

Pressure

Table Pattern

Opponent Level

---

# Mandatory Rule

Every recorded shot must contain

Shot Type

AND

Shot Intent

Shot Type without Intent is incomplete data.

---

End of Part 03

# DS-002 Billiards Knowledge Base
## Part 04 - Skill Tree

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the complete Pool OS Skill Tree.

Every player performance.

Every statistic.

Every recommendation.

Every drill.

must ultimately map to one or more Skills.

The Skill Tree is the foundation of Coach AI.

---

# Philosophy

Coach AI never trains shots.

Coach AI trains skills.

Shots are only evidence.

Skills are the real target.

---

# Skill Hierarchy

Player

↓

Skill Category

↓

Skill

↓

Sub Skill

↓

Measurement

↓

Trend

↓

Recommendation

---

# Level 1 Categories

Pool OS contains ten major skill groups.

1.

Potting

2.

Cue Ball Control

3.

Position Play

4.

Safety

5.

Kick

6.

Bank

7.

Jump

8.

Break

9.

Pattern Play

10.

Mental Game

---

# Category 1

Potting

Contains

Straight Pot

Thin Cut

Medium Cut

Thick Cut

Long Pot

Rail Pot

Frozen Ball

Pocket Speed

Pressure Pot

---

# Category 2

Cue Ball Control

Contains

Stop Shot

Follow

Draw

Stun

Spin Control

Distance Control

Speed Control

Natural Roll

Inside English

Outside English

---

# Category 3

Position Play

Contains

One Rail Position

Two Rail Position

Three Rail Position

Short Position

Long Position

Key Ball Position

Shape Control

Recovery Position

---

# Category 4

Safety

Contains

Distance Safety

Hook Safety

Containing Safety

Kick Safe

Two Way Shot

Rail Safety

Safety Escape

---

# Category 5

Kick

Contains

One Rail Kick

Two Rail Kick

Three Rail Kick

Kick Pot

Kick Safe

Diamond System

---

# Category 6

Bank

Contains

Cross Corner

Cross Side

Long Bank

Short Bank

Double Bank

---

# Category 7

Jump

Contains

Short Jump

Long Jump

Controlled Jump

Jump Pot

Jump Safe

---

# Category 8

Break

Contains

Power Break

Control Break

Second Ball Break

Soft Break

Cue Ball Control

Spread Quality

Scratch Prevention

---

# Category 9

Pattern Play

Contains

Table Reading

Key Ball Recognition

Cluster Management

Problem Ball Solving

Run Out Planning

End Game Planning

---

# Category 10

Mental Game

Contains

Confidence

Decision Making

Pressure Handling

Routine

Focus

Recovery After Miss

Emotional Stability

Match Discipline

---

# Skill Attributes

Every skill stores

Current Score

Previous Score

Best Score

Trend

Confidence

Training Frequency

Competition Frequency

Difficulty

Coach Priority

Last Training Date

---

# Skill Score

Each skill

0

↓

100

Levels

0-20

Beginner

20-40

Developing

40-60

Intermediate

60-80

Advanced

80-100

Elite

---

# Skill Trend

Every skill has

Improving

Stable

Declining

Unknown

Coach always considers trend.

---

# Skill Confidence

Confidence depends on sample size.

Example

5 attempts

↓

Low Confidence

200 attempts

↓

Very High Confidence

---

# Skill Dependencies

Skills influence other skills.

Example

Poor Stroke

↓

Poor Draw

↓

Poor Position

↓

Poor Pattern Play

Coach should identify root causes.

---

# Root Cause Analysis

Coach should never recommend training only the visible weakness.

Example

Player misses long pots.

Root cause

Alignment.

NOT

Long Pot itself.

---

# Training Priority

Priority is calculated using

Weakness

×

Frequency

×

Importance

×

Trend

×

Goal

Highest priority becomes

Today's Focus.

---

# Skill Progression

Every skill progresses through

Learning

↓

Understanding

↓

Consistency

↓

Automation

↓

Mastery

Coach recommendations depend on progression stage.

---

# Statistics Mapping

Every statistic must belong to one or more skills.

Example

Draw Accuracy

↓

Draw Skill

↓

Cue Ball Control

Example

Thin Cut %

↓

Thin Cut Skill

↓

Potting

---

# Drill Mapping

Every drill must improve one primary skill.

Optional

One secondary skill.

No drill should improve unrelated skills.

---

# Coach Rule

Coach recommendations must target

Skills

NOT

Statistics.

Statistics indicate problems.

Skills solve problems.

---

# Mandatory Rule

Every recorded action inside Pool OS must map to at least one Skill.

No orphan data is allowed.

---

End of Part 04

# DS-002 Billiards Knowledge Base
## Part 05 - Drill Taxonomy

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines every training drill inside Pool OS.

Coach AI does not recommend drills randomly.

Every drill must improve measurable skills.

---

# Philosophy

Drills are medicine.

Skills are diseases.

Coach AI prescribes drills.

Not exercises.

---

# Drill Hierarchy

Category

↓

Sub Category

↓

Drill

↓

Difficulty

↓

Required Skills

↓

Expected Improvement

---

# Categories

Pool OS divides drills into

1.

Potting

2.

Cue Ball Control

3.

Position Play

4.

Safety

5.

Kick

6.

Bank

7.

Jump

8.

Break

9.

Pattern Play

10.

Competition

11.

Mental

---

# Potting Drills

Examples

Straight Pot

Thin Cut

Medium Cut

Thick Cut

Long Pot

Rail Pot

Frozen Ball

Pocket Speed

Pressure Pot

---

# Cue Ball Control

Examples

Stop Shot

Follow

Draw

Long Draw

Power Draw

Stun

Distance Control

Speed Ladder

Spin Ladder

Cue Ball Routes

---

# Position Play

Examples

One Rail Position

Two Rail Position

Three Rail Position

Shape Zone

Target Zone

Recovery Position

Key Ball Drill

---

# Safety

Examples

Hook Drill

Distance Safety

Rail Safety

Containment

Two Way Shot

Escape Safety

---

# Kick

Examples

One Rail Kick

Two Rail Kick

Three Rail Kick

Kick Pot

Diamond System

Kick Escape

---

# Bank

Examples

Cross Corner

Cross Side

Long Bank

Double Bank

---

# Jump

Examples

Short Jump

Long Jump

Jump Pot

Controlled Jump

---

# Break

Examples

Power Break

Second Ball Break

Cue Ball Stop

Spread Control

Break Accuracy

---

# Pattern Play

Examples

3 Ball Pattern

5 Ball Pattern

8 Ball Runout

9 Ball Runout

Cluster Drill

Problem Ball Drill

---

# Competition

Examples

Race To 3

Race To 5

Race To 7

Pressure Rack

Sudden Death

Hill Hill Practice

---

# Mental

Examples

Routine

Breathing

Focus

Pressure Shot

Recovery After Miss

Confidence Building

---

# Drill Attributes

Every drill stores

Code

Name

Category

Difficulty

Estimated Time

Required Balls

Required Table Setup

Video

Description

Primary Skill

Secondary Skill

Expected Improvement

---

# Difficulty

1

Beginner

2

Easy

3

Intermediate

4

Advanced

5

Professional

---

# Training Time

Every drill has

5 min

10 min

15 min

20 min

30 min

45 min

60 min

Coach builds programs using available time.

---

# Required Equipment

Every drill stores

Table

Balls

Bridge

Jump Cue

Break Cue

Optional Equipment

---

# Primary Skill

Every drill improves exactly

ONE

primary skill.

Example

Thin Cut Drill

↓

Primary Skill

Thin Cut

---

# Secondary Skill

Maximum

2

secondary skills.

Example

Thin Cut Drill

↓

Cue Ball Control

↓

Position

---

# Coach Recommendation

Coach must recommend drills by

Skill

NOT

Category.

Example

Wrong

Potting Drill

Correct

Thin Cut Progressive Drill

---

# Drill Progression

Every drill has

Level 1

↓

Level 2

↓

Level 3

↓

Level 4

↓

Master

Coach increases difficulty only after mastery.

---

# Success Criteria

Every drill defines

Attempts

Success %

Passing Score

Failure Threshold

Target Score

---

# Example

Thin Cut Drill

Attempts

20

Target

80%

Current

65%

Coach Recommendation

Continue

---

# Drill Rotation

Coach should avoid recommending

the same drill

more than

3 consecutive sessions.

Coach rotates drills

while keeping

the same target skill.

---

# Drill History

Every completed drill stores

Date

Attempts

Success

Difficulty

Duration

Coach Notes

Improvement

---

# Mandatory Rule

Every drill must improve measurable skills.

Drills without measurable outcomes are prohibited.

---

End of Part 05

# DS-002 Billiards Knowledge Base
## Part 06 - Equipment Knowledge

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines all equipment knowledge used by Coach AI.

Coach AI must understand equipment.

Coach AI must never recommend equipment randomly.

---

# Philosophy

Equipment does not make a player stronger.

Equipment should fit

Player

Skill

Playing Style

Current Goal

---

# Equipment Categories

Pool OS recognizes

Playing Cue

Break Cue

Jump Cue

Shaft

Tip

Extension

Glove

Chalk

Bridge

Case

---

# Playing Cue

Attributes

Brand

Model

Weight

Balance

Length

Joint

Material

Construction

---

# Shaft

Attributes

Brand

Model

Diameter

Length

Material

Ferrule

Taper

Deflection Level

Flex

---

# Shaft Characteristics

Coach understands

Low Deflection

Medium Deflection

Traditional

Carbon

Wood

---

# Tip

Attributes

Brand

Model

Hardness

Thickness

Diameter

Installation Date

Usage Hours

Condition

---

# Hardness

Levels

Soft

Medium Soft

Medium

Medium Hard

Hard

Extra Hard

---

# Tip Condition

Possible States

New

Excellent

Good

Normal

Worn

Very Worn

Replacement Required

---

# Break Cue

Stores

Brand

Weight

Tip

Break Style

Power

Accuracy

---

# Jump Cue

Stores

Brand

Length

Weight

Tip

Jump Height

---

# Chalk

Stores

Brand

Color

Type

Usage

---

# Equipment Lifetime

Every equipment stores

Purchase Date

Usage Hours

Estimated Lifetime

Maintenance History

Replacement Recommendation

---

# Equipment Maintenance

Coach tracks

Tip Replacement

Tip Reshape

Tip Burnish

Cue Cleaning

Shaft Cleaning

Joint Maintenance

---

# Equipment Wear

Coach estimates wear using

Playing Hours

Training Frequency

Competition Frequency

Break Frequency

---

# Equipment Fit

Coach evaluates

Equipment

↓

Player Style

Possible results

Excellent Match

Good Match

Neutral

Needs Attention

Poor Match

---

# Playing Style

Coach identifies

Power Player

Control Player

Safety Player

Aggressive

Defensive

Balanced

---

# Example

Player

High Draw Usage

↓

Soft Tip

↓

Excellent

--------------------

Player

Power Break

↓

Soft Tip

↓

Recommend Harder Tip

---

# Equipment Influence

Coach may associate

Low Draw

↓

Tip Condition

--------------------

Low Spin

↓

Tip Hardness

--------------------

Poor Accuracy

↓

Loose Tip

--------------------

Inconsistent Cue Ball

↓

Worn Tip

---

# Recommendation Rules

Coach never recommends equipment

without sufficient evidence.

Equipment recommendation requires

Long-term trend

+

Enough samples

+

Stable pattern

---

# Equipment History

Every change stores

Old Equipment

New Equipment

Reason

Date

Coach Notes

Performance Before

Performance After

---

# Equipment Comparison

Coach compares

30 Days Before

↓

30 Days After

to determine

Equipment Effectiveness

---

# Warning Rules

Coach warns when

Tip Lifetime exceeded

Maintenance overdue

Equipment inconsistency detected

---

# Mandatory Rule

Equipment recommendations must always be supported by player data.

Coach AI must never recommend buying equipment without measurable justification.

---

End of Part 06

# DS-002 Billiards Knowledge Base
## Part 07 - Coach Decision Engine

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines how Coach AI makes decisions.

Coach AI does not generate random advice.

Every recommendation must follow deterministic rules.

---

# Philosophy

Coach AI behaves like a professional billiards coach.

Observe

↓

Analyze

↓

Identify Root Cause

↓

Prioritize

↓

Recommend

↓

Measure Improvement

---

# Decision Pipeline

Player Data

↓

Statistics

↓

Skill Analysis

↓

Trend Analysis

↓

Root Cause Analysis

↓

Priority Ranking

↓

Training Plan

↓

Recommendation

---

# Inputs

Coach uses

Daily Readiness

Equipment

Recent Sessions

Practice Sessions

Competition Matches

Skill Scores

Skill Trends

Goal

Training History

Equipment History

Mental Status

---

# Outputs

Coach produces

Today's Focus

Training Plan

Equipment Advice

Recovery Advice

Mental Advice

Weekly Goal

Monthly Goal

Progress Report

---

# Rule 1

One Focus Only

Every day

Coach chooses

ONE

Primary Focus.

Never two.

Never three.

---

# Rule 2

Root Cause First

Coach always fixes

Cause

before

Symptom.

Example

Poor Position

↓

Root Cause

Speed Control

↓

Train

Speed Control

NOT Position

---

# Rule 3

Trend Priority

Declining skill

always has higher priority

than

Stable weak skill.

---

# Rule 4

Goal Priority

If player goal is

Tournament

Coach increases

Competition

Pressure

Mental

weight.

---

# Rule 5

Readiness

Low Readiness

↓

Reduce intensity

↓

Increase technique work

High Readiness

↓

Hard practice

↓

Competition drills

---

# Rule 6

Equipment Influence

Equipment problems

never become

Primary Focus.

Equipment only modifies recommendations.

---

# Rule 7

Sample Confidence

Coach ignores

small sample sizes.

Example

5 shots

↓

No conclusion

200 shots

↓

Reliable

---

# Rule 8

Training Rotation

Coach avoids

training

the same skill

more than

3 consecutive sessions.

---

# Rule 9

Recovery

After

Heavy Practice

↓

Recovery Day

↓

Technique Day

↓

Competition Day

---

# Rule 10

Weakest Skill

Coach chooses

Weakest Skill

×

Most Important Skill

×

Most Frequently Used Skill

Not simply

Lowest Score.

---

# Priority Formula

Priority

=

Importance

×

Weakness

×

Frequency

×

Trend

×

Goal Weight

×

Confidence

---

# Recommendation Types

Technique

Practice

Equipment

Mental

Recovery

Competition

---

# Recommendation Limits

Maximum

1

Primary Recommendation

Maximum

3

Secondary Recommendations

Maximum

5

Suggested Drills

---

# Recommendation Lifetime

Today's Focus

expires

at midnight.

Weekly Goal

expires

after

7 days.

Monthly Goal

expires

after

30 days.

---

# Recommendation History

Every recommendation stores

Date

Reason

Target Skill

Expected Result

Actual Result

Completion

---

# Recommendation Evaluation

After training

Coach checks

Did Skill Improve?

Yes

↓

Increase Difficulty

No

↓

Find New Root Cause

---

# Coach Memory

Coach remembers

Previous Recommendations

Training Completion

Player Response

Improvement Speed

Ignored Recommendations

---

# Coach Personality

Coach should

Encourage

Never blame

Never insult

Always explain WHY

Always explain HOW

Always explain EXPECTED RESULT

---

# Mandatory Rule

Every recommendation must include

Why

How

Expected Improvement

Estimated Time

Success Criteria

No recommendation may be generated without explanation.

---

End of Part 07

# DS-002 Billiards Knowledge Base
## Part 08 - Statistics Engine

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines every statistic used inside Pool OS.

Every module must use this document.

Dashboard

Coach

Statistics

Radar

Reports

must never calculate independently.

---

# Philosophy

Data is entered once.

Statistics are calculated once.

Every module reads the same result.

---

# Statistics Architecture

Player Data

↓

Raw Events

↓

Statistics Engine

↓

Skill Engine

↓

Coach

↓

Dashboard

---

# Data Sources

Statistics Engine reads

Practice Session

Practice Shot

Match

Rack

Daily Readiness

Equipment

Goals

Training History

---

# Statistic Types

Pool OS defines

Raw Statistics

Derived Statistics

Skill Statistics

Trend Statistics

Career Statistics

---

# Raw Statistics

Directly recorded

Examples

Total Shots

Successful Shots

Missed Shots

Break Count

Jump Count

Kick Count

Safety Count

---

# Derived Statistics

Calculated

Examples

Pot %

Draw %

Safety %

Kick %

Break %

Run Out %

Average Balls

Average Run

---

# Skill Statistics

Mapped to Skill Tree

Example

Thin Cut

↓

Current Score

Trend

Confidence

Difficulty

---

# Trend Statistics

Calculated using

7 Days

30 Days

90 Days

Career

---

# Career Statistics

Lifetime values

Matches

Wins

Losses

Win Rate

Training Hours

Competition Hours

Longest Run

Highest Break

---

# Practice Statistics

Coach tracks

Sessions

Hours

Attempts

Success

Completion Rate

Consistency

---

# Match Statistics

Coach tracks

Matches

Win %

Race Wins

Rack Wins

Average Balls

Average Run

Pressure Wins

Hill-Hill Wins

---

# Break Statistics

Tracks

Break Success

Scratch

Dry Break

Cue Ball Control

Spread Quality

---

# Safety Statistics

Tracks

Safety Attempts

Successful Safety

Safety Escape

Kick Escape

Safety Win %

---

# Kick Statistics

Tracks

Kick Attempts

Kick Success

Kick Pot

Kick Safe

---

# Jump Statistics

Tracks

Jump Attempts

Jump Success

Jump Pot

Jump Safety

---

# Position Statistics

Tracks

Good Position

Bad Position

Recovery

Shape Success

---

# Cue Ball Statistics

Tracks

Draw Success

Follow Success

Stop Success

Spin Success

Speed Control

---

# Pattern Statistics

Tracks

Run Out

Cluster Solved

Problem Balls

Key Ball Success

Pattern Completion

---

# Mental Statistics

Tracks

Confidence

Recovery

Pressure

Consistency

Decision Quality

---

# Equipment Statistics

Tracks

Hours Used

Matches Used

Practice Used

Maintenance

Performance Before

Performance After

---

# Daily Readiness Statistics

Tracks

Sleep

Fatigue

Stress

Focus

Energy

Recovery

---

# Goal Statistics

Tracks

Goal Progress

Completion %

Remaining %

Expected Finish

---

# Trend Calculation

Trend

=

Current 7 Days

vs

Previous 30 Days

---

# Confidence

Every statistic stores

Confidence Score

Low

Medium

High

Very High

---

# Confidence Formula

Based on

Sample Size

Frequency

Recency

Consistency

---

# Rolling Windows

Statistics calculated using

Today

7 Days

30 Days

90 Days

365 Days

Career

---

# Personal Best

Stores

Highest Run

Best Match

Best Session

Best Practice

Fastest Improvement

---

# Ranking

Player

Skill

Equipment

Training

Competition

All rankings use Statistics Engine only.

---

# Cache

Statistics Engine recalculates

After

Practice

Rack

Match

Session

Equipment Change

Daily Readiness

Goal Update

---

# Never Recalculate in UI

UI must NEVER calculate statistics.

UI only displays

Statistics Engine output.

---

# Mandatory Rule

Statistics Engine is the single source of truth.

No module may calculate duplicate statistics.

---

End of Part 08

# DS-002 Billiards Knowledge Base
## Part 09 - Data Collection Dictionary

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines every data field that Pool OS is allowed to collect.

Every collected field must have a purpose.

If a field does not support

Statistics

Coach

Dashboard

Reports

AI

it must NOT exist.

---

# Philosophy

Collect once.

Use everywhere.

Never collect useless information.

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

Shot

↓

Event

---

# Player

Stores

Player Name

Nickname

Handedness

Bridge Style

Experience Level

Main Discipline

Dominant Style

Birthday (optional)

Weight (optional)

Height (optional)

---

# Session

Stores

Date

Start Time

End Time

Location

Table

Session Type

Practice

Competition

Lesson

Challenge

Coach

Notes

---

# Match

Stores

Opponent

Race To

Winner

Loser

Match Duration

Table Size

Game Type

9 Ball

10 Ball

8 Ball

Rotation

Straight Pool

---

# Rack

Stores

Rack Number

Winner

Balls Potted

Largest Run

Break Success

Break Scratch

Break Foul

Easy Miss

Hard Miss

Scratch

Kick Errors

Jump Errors

Safety Errors

Position Errors

Confidence

Coach Notes

Player Notes

---

# Practice Shot

Stores

Shot Number

Shot Type

Difficulty

Success

Miss Type

Cue Ball Control

Position Score

Stroke Quality

Speed Quality

Spin Quality

Notes

---

# Events

Stores

Scratch

Foul

Kick

Jump

Safety

Push Out

Break

Golden Break

Run Out

Table Run

Combination

Bank

Carom

Jump Pot

---

# Equipment

Stores

Cue

Shaft

Tip

Extension

Glove

Chalk

Weight

Diameter

Condition

Maintenance

---

# Daily Readiness

Stores

Sleep

Fatigue

Stress

Energy

Motivation

Focus

Pain

Recovery

---

# Training

Stores

Drill

Difficulty

Duration

Attempts

Success

Completion

Coach Score

---

# Statistics

Stores

Automatically generated only.

Never manually edited.

---

# Coach

Stores

Recommendation

Reason

Priority

Expected Result

Completion

Feedback

---

# Goals

Stores

Target

Deadline

Priority

Progress

Completion

---

# Video

Stores

Video Link

Session

Match

Drill

Shot

Coach Comment

---

# Photos

Stores

Table Layout

Equipment

Practice Setup

Coach Drawing

---

# AI Analysis

Stores

Vision Result

Detected Layout

Detected Shot

Suggested Route

Confidence

---

# Import Sources

Allowed

Manual

Vision

Sensor

Video

CSV

Future API

---

# Data Validation

Every field must define

Type

Range

Required

Optional

Validation Rule

Default Value

---

# Example

Balls Potted

Type

Integer

Range

0-9

Required

Yes

Default

0

---

# Data Ownership

Player owns

all personal data.

Coach AI

may analyze

but never modify

historical records.

---

# Audit Trail

Every modification stores

Old Value

New Value

Timestamp

User

Reason

---

# Privacy

Sensitive fields

must never be shared

without user approval.

---

# Mandatory Rule

No new database field may be added unless it is first documented here.

This document is the official Data Dictionary for Pool OS.

---

End of Part 09

# DS-002 Billiards Knowledge Base
## Part 10 - Coach Personality & Communication

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines how Coach AI communicates with players.

Coach AI is not a chatbot.

Coach AI behaves like a professional billiards coach.

---

# Philosophy

Coach never judges.

Coach never blames.

Coach always explains.

Coach always teaches.

Coach always motivates.

---

# Coach Personality

Coach should be

Professional

Calm

Objective

Positive

Encouraging

Patient

Data Driven

Friendly

---

# Coach Never Says

"You are bad."

"You played terribly."

"You failed."

"You have no talent."

"You always miss."

---

# Coach Should Say

"You are improving."

"Let's focus on..."

"The data shows..."

"This skill can improve."

"You are on the right track."

---

# Communication Structure

Every recommendation contains

Observation

↓

Reason

↓

Training

↓

Expected Result

↓

Next Review

---

# Example

Observation

Thin Cut accuracy dropped 8%.

Reason

Cue Ball Speed became inconsistent.

Training

Practice Long Thin Cut Drill.

Expected Result

Recover 5~8%.

Review

After next session.

---

# Tone

Never emotional.

Never exaggerated.

Never sarcastic.

Never aggressive.

---

# Daily Greeting

Examples

Good morning.

Ready for today's training?

Let's improve one thing today.

Yesterday's work was valuable.

Welcome back.

---

# After Good Session

Coach says

Excellent consistency today.

Speed control improved.

Position play became more stable.

Keep this rhythm tomorrow.

---

# After Bad Session

Coach never criticizes.

Coach says

Today was difficult.

Mistakes increased.

That is normal.

Let's simplify tomorrow's training.

---

# Confidence Messages

High Confidence

Your recent trend is reliable.

Medium Confidence

We need a little more data.

Low Confidence

Not enough data yet.

---

# Recommendation Format

Today's Focus

Why

How

Duration

Success Target

Review Time

---

# Training Explanation

Always explain

Why this drill?

What skill?

Expected improvement?

How long?

---

# Example

Today's Focus

Speed Control

Why

Speed inconsistency affects Position Play.

Training

Long Stop Shot

20 minutes

Target

80% success

Review

Next session

---

# Weekly Review

Coach summarizes

Best Improvement

Largest Regression

Most Stable Skill

Most Unstable Skill

Training Consistency

Mental Status

Equipment Status

---

# Monthly Review

Coach summarizes

Overall Progress

Skill Growth

Competition Result

Practice Quality

Suggested Goal

---

# Achievement Messages

Examples

New Personal Best

Longest Run Record

Most Consistent Week

Training Streak

Confidence Recovery

---

# Recovery Messages

Coach may recommend

Rest

Stretching

Mental Recovery

Short Practice

Video Study

Instead of forcing practice.

---

# Equipment Messages

Coach explains

Why equipment matters.

Never says

Buy this cue.

Instead

Current tip wear may reduce draw consistency.

Monitor for one more week.

---

# Motivation

Coach encourages process.

Not results.

Wrong

Win more matches.

Correct

Improve cue ball control.

Winning will follow.

---

# Language

Coach uses

Short sentences.

Simple vocabulary.

No technical overload.

---

# Message Length

Daily

1~3 paragraphs

Weekly

5~10 paragraphs

Monthly

10~20 paragraphs

---

# Humor

Very limited.

Professional first.

---

# Mandatory Rule

Coach AI must always explain

WHY

before

WHAT

Players learn better when they understand the reason.

---

End of Part 10

# DS-002 Billiards Knowledge Base
## Part 11 - Coach Memory System

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines how Coach AI remembers players.

Coach is not stateless.

Coach builds long-term understanding of every player.

---

# Philosophy

A real coach remembers

Previous lessons

Previous mistakes

Improvement speed

Training habits

Mental state

Equipment history

Pool OS Coach must do the same.

---

# Coach Memory Layers

Layer 1

Session Memory

↓

Layer 2

Weekly Memory

↓

Layer 3

Monthly Memory

↓

Layer 4

Career Memory

---

# Session Memory

Remember

Today's Focus

Completed Drills

Missed Drills

Coach Notes

Largest Improvement

Largest Problem

---

# Weekly Memory

Remember

Training Frequency

Completion Rate

Most Improved Skill

Most Declining Skill

Average Readiness

Competition Results

---

# Monthly Memory

Remember

Practice Hours

Competition Hours

Skill Growth

Equipment Changes

Goal Completion

Training Discipline

---

# Career Memory

Remember

Personal Best

Longest Run

Highest Break

Best Match

Best Tournament

Favorite Drill

Favorite Equipment

Most Common Mistake

Most Improved Skill

---

# Training Compliance

Track

Assigned Drill

Completed

Skipped

Partially Completed

Completion %

---

# Recommendation History

Store

Date

Recommendation

Reason

Priority

Completed

Result

---

# Coach Learning

If recommendation

worked

↓

Increase confidence

If recommendation

failed

↓

Reduce confidence

↓

Try different solution

---

# Improvement Speed

Track

Fast

Normal

Slow

Plateau

Regression

---

# Plateau Detection

If

Skill

changes

less than

2%

over

30 days

↓

Coach declares

Plateau

---

# Regression Detection

If

Skill

drops

more than

5%

within

14 days

↓

Coach increases priority

---

# Motivation History

Remember

Training Streak

Missed Days

Best Week

Best Month

Longest Streak

---

# Equipment Memory

Remember

Cue Changes

Tip Changes

Maintenance

Performance Before

Performance After

---

# Mental Memory

Remember

Confidence Trend

Stress Trend

Readiness Trend

Competition Pressure

---

# Competition Memory

Remember

Hill-Hill Record

Tournament Record

Close Match Record

Pressure Performance

---

# Drill Memory

Remember

Favorite Drill

Least Effective Drill

Fastest Improvement Drill

Highest Success Drill

---

# Coach Reflection

After every week

Coach answers

What improved?

What became worse?

Why?

What changes next week?

---

# Adaptive Planning

Coach never repeats

the same plan

for more than

2 consecutive weeks

unless

progress continues.

---

# Forgetting Rule

Coach never deletes

Career Memory.

Old data

becomes

lower priority

but is never lost.

---

# Memory Confidence

Recent data

has

higher weight

than

old data.

---

# Review Cycle

Daily

Session Review

Weekly

Performance Review

Monthly

Development Review

Quarterly

Career Review

---

# Player Timeline

Coach can display

Timeline

of

Major Improvements

Major Regressions

Equipment Changes

Goal Achievements

Competition Results

---

# Mandatory Rule

Every recommendation must reference memory.

Coach must never behave as if meeting the player for the first time.

Example

Correct

"Last week your cue ball control improved by 6%.
Today we will build on that."

Wrong

"Let's practice cue ball control."

---

End of Part 11

# DS-002 Billiards Knowledge Base
## Part 12 - AI Roadmap & Future Expansion

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the long-term AI roadmap for Pool OS.

The current application is designed so future AI modules can be added
without redesigning the architecture.

---

# Vision

Pool OS is not only

Training Log

or

Statistics App.

Pool OS aims to become

an intelligent personal billiards coach.

---

# AI Evolution

Phase 1

Manual Recording

↓

Phase 2

Coach AI

↓

Phase 3

Vision AI

↓

Phase 4

Video Analysis

↓

Phase 5

Real-time Coach

↓

Phase 6

Predictive AI

---

# Phase 1

Current Version

Player records

Practice

Match

Rack

Daily Readiness

Equipment

Coach generates advice.

---

# Phase 2

Coach AI

Coach understands

Statistics

Trend

History

Memory

Equipment

Mental

Goals

---

# Phase 3

Vision AI

Recognize

Table

Balls

Cue Ball

Object Ball

Pocket

Player Position

Cue Direction

---

# Vision Inputs

Camera

Phone

Tablet

Future Smart Glass

---

# Vision Outputs

Table Layout

Ball Coordinates

Recommended Route

Difficulty

Shot Type

Pattern Analysis

---

# Video Analysis

Coach analyzes

Stroke

Bridge

Stance

Grip

Cue Delivery

Head Movement

Body Stability

Follow Through

---

# Stroke Analysis

AI detects

Cue Path

Acceleration

Deceleration

Side Movement

Elevation

Impact Timing

---

# Practice Recording

Future

No manual input.

AI automatically records

Every shot

Success

Failure

Run

Position

Mistakes

---

# Match Analysis

Future

Coach automatically detects

Break

Run Out

Scratch

Kick

Jump

Safety

Miss

---

# Equipment AI

Coach detects

Tip Wear

Cue Damage

Maintenance Timing

Expected Performance Loss

---

# Smart Sensor Support

Future

Bluetooth Cue

Motion Sensor

Tip Sensor

Acceleration Sensor

Gyroscope

---

# Predictive Coach

Coach predicts

Fatigue

Performance Drop

Practice Efficiency

Tournament Readiness

Burnout Risk

---

# Opponent Analysis

Future

Coach learns

Opponent Style

Aggression

Safety Frequency

Break Style

Pressure Performance

---

# Tournament AI

Future

Coach prepares

Opponent Report

Table Strategy

Warm-up Plan

Risk Analysis

Mental Preparation

---

# Cloud Intelligence

Future

Anonymous learning

Millions of shots

Millions of racks

Millions of drills

Coach becomes smarter.

---

# Personal AI Model

Long term

Every player owns

their own AI profile.

Coach learns

only from

that player's history.

---

# Training Simulation

Future

Coach generates

Daily Plan

Weekly Plan

Monthly Plan

Season Plan

Automatically.

---

# AI Confidence

Every AI decision stores

Confidence Score

Explanation

Supporting Data

Recommendation Priority

---

# Explainable AI

Coach never says

"Because AI thinks so."

Coach always explains

Data

Reason

Evidence

Recommendation

---

# Ethics

AI never changes

historical data.

AI never fabricates

statistics.

AI always references

real recorded data.

---

# Offline AI

Future

Basic Coach

must work

without internet.

Cloud AI

is optional.

---

# API Ready

Every AI module

communicates

through service interfaces.

No UI depends directly

on AI implementation.

---

# Extensibility

Future modules may include

Voice Coach

AR Coach

VR Training

Live Streaming Analysis

Tournament Assistant

Wearable Integration

League Analytics

Academy Dashboard

---

# Mandatory Rule

Every future AI feature

must consume

existing Pool OS data structures.

AI must adapt to Pool OS.

Pool OS must never be redesigned for AI.

---

# End of DS-002
## Total Parts: 12

DS-002 Complete.