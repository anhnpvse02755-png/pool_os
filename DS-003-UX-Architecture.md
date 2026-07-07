# DS-003 Product Specification
## Part 01 - UX Architecture

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the complete user experience architecture.

Every screen must follow this specification.

Cursor must not invent UX.

---

# Design Philosophy

Pool OS is designed for players.

Not for developers.

Every click should reduce thinking.

Every screen should answer one question.

---

# Golden Rules

One screen

One purpose.

One primary action.

One clear exit.

---

# Navigation

Bottom Navigation

Home

Session

Coach

Statistics

More

Maximum

5 tabs.

Never exceed.

---

# Screen Levels

Level 1

Main Navigation

↓

Level 2

Feature Screen

↓

Level 3

Detail Screen

↓

Level 4

Popup

Never deeper.

---

# Popup Rules

Popup must

Never contain popup.

Never navigate.

Never become fullscreen.

Maximum

1 popup

at a time.

---

# User Flow

Home

↓

Session

↓

Match

↓

Rack

↓

Summary

↓

Back

Home

---

# Screen Lifetime

Main Screen

Persistent

Detail Screen

Disposable

Popup

Temporary

---

# Header Rules

Every screen contains

Title

Back Button (if needed)

Primary Action

Never more.

---

# Empty State

Every empty page

must explain

Why it is empty.

How to create data.

Primary action.

---

# Loading

Every async operation

must display

Loading

or

Skeleton.

Never freeze UI.

---

# Error Handling

Every error

must explain

What happened.

How to retry.

Never expose

Exception text.

---

# Success Feedback

Every successful action

must display

SnackBar

Toast

Animation

or

State Change.

---

# Save Rule

User never wonders

whether data

was saved.

Always confirm.

---

# Delete Rule

Every delete

requires confirmation.

Soft delete preferred.

---

# Search

If list

>

20 items

Search required.

---

# Filter

If list

>

30 items

Filter required.

---

# Sorting

Always remember

last sorting method.

---

# Scrolling

Return

to previous position

after leaving page.

---

# Form Rules

Required

fields

must be obvious.

Validation

before save.

No hidden validation.

---

# Input Speed

Target

Complete

common task

under

15 seconds.

---

# Match Recording

Target

One rack

under

20 seconds.

---

# Practice Recording

Target

One shot

under

3 seconds.

---

# Dashboard

Must answer

What should I do today?

within

5 seconds.

---

# Coach

Must answer

Why?

before

How?

---

# Statistics

Must answer

Am I improving?

within

10 seconds.

---

# Equipment

Must answer

Is my equipment affecting performance?

---

# Daily Readiness

Must answer

Should I train today?

---

# Session

Must answer

What am I doing now?

---

# Accessibility

Buttons

Minimum

44dp

Touch Area

Readable fonts

High contrast

---

# Animation

Fast

200~300ms

Never decorative.

Only informative.

---

# Performance

Screen

opens

under

300ms.

---

# Offline

Every feature

must explain

Offline limitation.

---

# Mandatory Rule

Every new screen

must first be documented

inside DS-003

before implementation.

Cursor must never invent UX.

---

End of Part 01

# DS-003 Product Specification
## Part 02 - Home Dashboard

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the complete behavior of the Home Dashboard.

The Dashboard is the first screen users see.

Its purpose is not to display data.

Its purpose is to tell the player

"What should I do today?"

---

# Dashboard Principles

Dashboard answers

Current Status

↓

Today's Focus

↓

Training

↓

Recent Progress

↓

Long-term Goal

---

# Layout Order

1.

Greeting

↓

2.

Daily Readiness

↓

3.

Today's Coach Focus

↓

4.

Today's Training Plan

↓

5.

Skill Radar

↓

6.

Recent Sessions

↓

7.

Quick Statistics

↓

8.

Equipment Status

↓

9.

Upcoming Goal

---

# Greeting Card

Display

Good Morning

Good Afternoon

Good Evening

Player Name

Training Streak

Today's Date

---

# Daily Readiness Card

Shows

Readiness Score

0-100

Color

Green

Yellow

Red

Displays

Sleep

Energy

Stress

Focus

Recovery

Button

Update Readiness

---

# Daily Readiness Behavior

If not completed

Always appears first.

Cannot hide.

---

# Coach Card

Shows ONLY ONE focus.

Never show

2

3

or

5 focuses.

Example

Today's Focus

Cue Ball Speed

Reason

Position Control declined 6%.

Expected Time

20 minutes.

---

# Coach Card Buttons

Start Training

View Details

Dismiss (optional)

---

# Today's Training

Displays

Maximum

5 drills.

Order

Highest Priority

↓

Lowest Priority

Each Drill

Name

Difficulty

Duration

Target

Expected Success Rate

Start Button

---

# Skill Radar

Displays

Top 8 skills.

Green

Strong

Yellow

Average

Red

Weak

Tap

↓

Skill Detail

---

# Skill Detail

Displays

Current Score

30 Day Trend

Coach Comment

Recommended Drill

Training History

---

# Recent Sessions

Display

Latest

10 sessions.

Each Card

Date

Type

Duration

Score

Result

Tap

↓

Session Detail

---

# Quick Statistics

Shows

Career Win Rate

Current Streak

Longest Run

Practice Hours

Competition Hours

---

# Equipment Status

Shows

Current Cue

Current Shaft

Current Tip

Tip Health

Maintenance Reminder

---

# Goal Card

Displays

Current Goal

Progress

Remaining Days

Completion %

---

# Empty State

If

No Session

Display

Start Your First Session

Button

Create Session

---

# Refresh Rules

Dashboard refreshes after

Readiness Saved

Session Finished

Match Finished

Rack Saved

Equipment Changed

Goal Updated

Player Changed

Coach Updated

---

# Dashboard Cache

Maximum Cache

5 minutes.

Manual Refresh

always allowed.

---

# Loading

Skeleton

preferred.

Never blank page.

---

# Error State

Display

Unable to load dashboard.

Retry Button

---

# Performance Target

Open Dashboard

<300ms

Refresh

<500ms

---

# Scroll Behavior

Remember

last position.

---

# Animation

Card Fade

200ms

Only when data changes.

---

# User Actions

Dashboard must never require

more than

2 taps

to begin today's training.

---

# Dashboard KPIs

Always visible

Coach Score

Skill Score

Consistency

Readiness

Trend

---

# Coach Priority Rule

Dashboard always follows

Coach Rule Engine.

Dashboard never creates

its own recommendation.

---

# Mandatory Rule

Dashboard never becomes

a statistics page.

Dashboard always acts

as

Today's Command Center.

---

End of Part 02

# DS-003 Product Specification
## Part 03 - Session Module

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the complete lifecycle of a Session.

A Session is the highest level container of all player activities.

Nothing exists outside a Session.

---

# Session Definition

One Session may contain

Practice

Match

Challenge

Assessment

Mixed Activities

---

# Session Lifecycle

Create

↓

Preparation

↓

Activities

↓

Summary

↓

Finish

↓

Archive

---

# Session Types

Practice

Competition

Tournament

Training Camp

Free Play

Assessment

---

# Session Screen Layout

Header

↓

Session Information

↓

Activity List

↓

Current Progress

↓

Quick Statistics

↓

Primary Action

---

# Header

Display

Session Name

Date

Start Time

Elapsed Time

Status

---

# Session Status

Planned

Running

Paused

Completed

Cancelled

Archived

---

# Session Information

Display

Player

Location

Table

Cue

Goal

Coach Focus

---

# Session Goal

User must select

or

Coach recommends

one goal

before session starts.

Examples

Cue Ball Control

Position Play

Break

Safety

Pattern Play

---

# Activity List

A Session may contain

Multiple Practice Blocks

Multiple Matches

Multiple Challenges

Order is chronological.

---

# Activity Card

Each Activity shows

Type

Duration

Result

Status

Tap

↓

Open Detail

---

# Session Progress

Display

Elapsed Time

Completed Activities

Remaining Activities

Current Focus

---

# Quick Statistics

Display

Total Shots

Total Racks

Practice Success %

Win Rate

Largest Run

Current Confidence

---

# Session Actions

Create Activity

Pause Session

Resume Session

Finish Session

Delete Session

---

# Create Activity

User chooses

Practice

Match

Challenge

Assessment

---

# Practice Flow

Session

↓

Practice

↓

Drill

↓

Shot Recording

↓

Practice Summary

↓

Back to Session

---

# Match Flow

Session

↓

Match

↓

Rack

↓

Rack Summary

↓

Next Rack

↓

Match Summary

↓

Back to Session

---

# Challenge Flow

Session

↓

Challenge

↓

Result

↓

Challenge Summary

↓

Back to Session

---

# Session Pause

Pausing

must save

all progress.

No data loss.

---

# Resume Session

Resume exactly

where user stopped.

Never restart.

---

# Finish Session

Before finish

show

Session Summary.

User confirms.

Then archive.

---

# Session Summary

Display

Duration

Activities

Practice Hours

Competition Hours

Coach Score

Skill Improvement

Largest Run

Win Rate

Training Completion

Coach Comment

---

# Coach Review

After Session

Coach generates

Strength

Weakness

Priority

Tomorrow's Focus

---

# Session Validation

Cannot finish

while

Activity is still running.

Must close

all activities first.

---

# Auto Save

Every

30 seconds

or

after every important action

Session auto-saves.

---

# Recovery

If app crashes

Resume unfinished Session

at launch.

---

# Duplicate Protection

Never allow

two Running Sessions

for

the same player.

---

# Session History

Display

Latest first.

Support

Search

Filter

Sort

---

# Search

Search by

Date

Location

Opponent

Goal

Session Name

---

# Filter

Practice

Competition

Tournament

Assessment

Completed

Running

---

# Sort

Newest

Oldest

Duration

Performance

---

# Empty State

Display

No Sessions Yet

Button

Create Session

---

# Delete Rule

Completed Sessions

cannot be permanently deleted.

Use Soft Delete.

---

# Archive Rule

Archived Sessions

remain available

for Statistics

Coach

Timeline

---

# Performance Target

Open Session

<300ms

Create Session

<2 seconds

Resume Session

<2 seconds

---

# Mandatory Rule

Every Match

Every Drill

Every Challenge

must belong

to one Session.

No standalone activity exists.

---

End of Part 03

# DS-003 Product Specification
## Part 04 - Match Module

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the complete lifecycle of a Match.

A Match represents one competitive event inside a Session.

A Match always belongs to exactly one Session.

A Match contains one or more Racks.

---

# Match Lifecycle

Create Match

↓

Pre-Match

↓

Rack Loop

↓

Match Summary

↓

Coach Analysis

↓

Back to Session

---

# Match Creation

Required Information

Player

Opponent

Game Type

Race To

Break Rule

Table Size

Notes (optional)

---

# Supported Game Types

9 Ball

10 Ball

8 Ball

14.1

Chinese 8 Ball

Custom

---

# Race To

Supported

Race 3

Race 5

Race 7

Race 9

Race 11

Custom

Winner is declared ONLY when

Player Score == Race To

Never use

>=

---

# Opponent

Opponent may be

Known Player

Guest

AI

Practice Ghost

If Guest

Create temporary profile.

If repeated

Suggest merging.

---

# Match Screen

Header

↓

Current Score

↓

Current Rack

↓

Timeline

↓

Quick Actions

↓

Finish Match

---

# Header

Display

Player Name

Opponent

Game Type

Race To

Elapsed Time

---

# Scoreboard

Display

Player Score

Opponent Score

Current Rack

Remaining Racks (estimated)

---

# Rack Counter

Display

Rack 1

Rack 2

...

Current Rack highlighted.

---

# Timeline

Each Rack displayed as

Rack #

Winner

Largest Run

Confidence

Coach Marker

Tap

↓

Rack Detail

---

# Quick Actions

Player Wins Rack

Opponent Wins Rack

Pause Match

Edit Previous Rack

Add Note

---

# Rack Completion

After each rack

ALWAYS

open Rack Summary.

Never skip.

---

# Rack Summary

Collect

Balls Potted

Largest Run

Break Success

Break Scratch

Break Foul

Easy Miss

Hard Miss

Scratch Count

Position Errors

Safety Errors

Kick Errors

Jump Errors

Best Strengths

Biggest Mistakes

Confidence

Rack Notes

---

# Data Entry Target

Complete

Rack Summary

under

20 seconds.

---

# Match Auto Save

Every Rack

immediately saves.

Never wait until

Match Finish.

---

# Match Statistics

Realtime update

Score

Win %

Break %

Largest Run

Confidence Trend

---

# Match Finish

Automatically triggered

when

Player Score == Race To

or

Opponent Score == Race To

---

# Match Summary

Automatically generated.

User does NOT re-enter data.

Summary includes

Winner

Final Score

Rack Count

Duration

Largest Run

Break %

Average Confidence

Most Common Mistake

Most Common Strength

---

# Coach Analysis

Immediately after Match Summary

Coach generates

Main Problem

Main Strength

Priority Drill

Confidence Analysis

Equipment Observation

---

# Match Report

Stored permanently.

Never overwritten.

---

# Editing

Previous Rack

may be edited.

Editing triggers

Statistics Recalculation

Coach Recalculation

Dashboard Refresh

---

# Pause Match

Save

everything.

Resume

from same rack.

---

# Crash Recovery

If application closes

Resume Match

from

last completed rack.

Never lose current score.

---

# Match History

Display

Date

Opponent

Game Type

Score

Duration

Result

Coach Score

Tap

↓

Match Detail

---

# Search

Opponent

Date

Game Type

Result

---

# Filter

Won

Lost

Practice Match

Tournament

Race To

---

# Match Detail

Display

General Information

↓

Rack Timeline

↓

Statistics

↓

Coach Analysis

↓

Equipment Used

↓

Notes

---

# Performance Target

Open Match

<300ms

Save Rack

<500ms

Finish Match

<2 seconds

---

# Validation Rules

Cannot Finish Match

if current Rack

is incomplete.

Cannot modify

Race To

after Match starts.

Cannot delete

completed Rack

without confirmation.

---

# Integration

Every Rack updates

Statistics

Coach

Dashboard

Timeline

Session

immediately.

---

# Mandatory Rule

Match data

must always be

the sum

of Rack data.

Never maintain

independent statistics.

---

End of Part 04

# DS-003 Product Specification
## Part 05 - Rack Module

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the complete lifecycle of one Rack.

Rack is the smallest competitive unit.

Every Match consists of one or more Racks.

All Match statistics are calculated from Rack data.

---

# Rack Lifecycle

Rack Starts

↓

Rack Playing

↓

Rack Ends

↓

Rack Summary

↓

Save

↓

Next Rack

---

# Definition

One Rack represents

one complete rack

from break

until winner.

---

# Rack Status

Waiting

Running

Completed

Edited

Deleted (Soft Delete)

---

# Rack Header

Display

Rack Number

Current Match Score

Current Race To

Elapsed Rack Time

---

# Rack Timer

Starts automatically

when Rack begins.

Stops automatically

when Rack finishes.

Store

Duration

in seconds.

---

# Quick Actions

Player Wins Rack

Opponent Wins Rack

Pause

Add Event

Undo Last Event

---

# Undo Rule

Only

latest action

can be undone.

Undo is disabled

after Rack Summary is saved.

---

# Rack Finish

Immediately after

Player Wins

or

Opponent Wins

open

Rack Summary.

Never skip.

---

# Rack Summary Sections

Section A

Result

↓

Section B

Performance

↓

Section C

Mistakes

↓

Section D

Strengths

↓

Section E

Mental

↓

Section F

Notes

---

# Section A

Display

Winner

Player

Opponent

Final Score

(auto)

---

# Section B

Fields

Balls Potted

Largest Run

Break Success

Break Scratch

Break Foul

---

# Validation

Balls Potted

0~9

Largest Run

0~9

Largest Run

cannot exceed

Balls Potted

---

# Section C

Mistake Counter

Easy Miss

Hard Miss

Scratch

Position Error

Safety Error

Kick Error

Jump Error

Bank Error

Wrong Pattern

Mental Error

---

# Validation

Each counter

Minimum

0

Maximum

99

---

# Section D

Best Strength

Multi-select

Available

Thin Cut

Thick Cut

Long Pot

Draw

Follow

Stop Shot

Safety

Kick

Jump

Bank

Cue Ball Control

Pattern Play

Break

Position Play

Mental

---

# Multi-select Rule

No limit.

Player may select

multiple strengths.

---

# Section E

Confidence

Slider

1~10

Mental State

Very Bad

Bad

Normal

Good

Excellent

---

# Section F

Notes

Optional

Maximum

500 characters.

---

# Save Button

Save Rack

must

Save Database

↓

Update Statistics

↓

Update Coach

↓

Update Dashboard

↓

Update Timeline

↓

Return to Match

---

# Cancel Button

Ask

Discard changes?

Yes

No

---

# Auto Save

No automatic save

inside Rack Summary.

Only save

after confirmation.

---

# Edit Rack

Player may edit

completed Rack.

Every edit

must trigger

Statistics

Coach

Dashboard

recalculation.

---

# Delete Rack

Soft Delete only.

Never hard delete.

Confirmation required.

---

# Timeline Display

Every Rack

shows

Winner

Largest Run

Confidence

Coach Marker

Duration

---

# Coach Marker

Green

Good Rack

Yellow

Average Rack

Red

Bad Rack

---

# Performance Target

Open Summary

<200ms

Save Rack

<500ms

Close Summary

<200ms

---

# Accessibility

Large buttons

Single hand operation

No scrolling

for common data.

---

# Default Values

Every counter

starts at

0

Confidence

starts at

5

Notes

empty

---

# Offline

Rack can always

be saved offline.

Synchronization

happens later.

---

# Mandatory Rule

Rack Summary

must require

less than

20 seconds

to complete.

Never ask

for unnecessary information.

---

# Mandatory Rule

Every Match statistic

must be generated

from Rack records.

Never maintain

duplicate values.

---

End of Part 05

# DS-003 Product Specification
## Part 06 - Practice Module

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the complete Practice Mode.

Practice Mode is separated completely from Match Mode.

Practice is designed to collect technical skill data.

Match is designed to collect competition performance.

Coach AI combines both datasets.

---

# Philosophy

Match

answers

How do I perform?

Practice

answers

Why do I perform like this?

---

# Practice Lifecycle

Create Practice

↓

Choose Drill

↓

Practice Session

↓

Record Data

↓

Practice Summary

↓

Coach Analysis

↓

Back to Session

---

# Practice Types

Single Drill

Multi Drill

Coach Assigned

Free Practice

Warm Up

Skill Test

---

# Practice Screen

Header

↓

Current Drill

↓

Current Progress

↓

Quick Recording

↓

History

↓

Finish Practice

---

# Header

Display

Practice Name

Current Drill

Elapsed Time

Current Success %

---

# Drill Selection

User may

Search

Filter

Favorite

Coach Recommended

Recent

---

# Drill Categories

Beginner

Intermediate

Advanced

Professional

Competition

Mental

Position Play

Cue Ball Control

Break

Safety

Bank

Kick

Jump

Pattern

---

# Default View

Open by

Difficulty

not

Alphabetical Order.

---

# Drill Card

Display

Drill Name

Difficulty

Estimated Time

Target Skill

Coach Rating

Favorite

---

# Start Drill

Display

Instruction

Reference Image

Reference Video (optional)

Target

Success Criteria

---

# Recording Philosophy

Practice Mode

records

individual shots.

Never record

only Win/Lose.

---

# Shot Recording

Each Shot records

Shot Type

Success

Difficulty

Cue Ball Control

Position

Miss Type

Notes

---

# Shot Types

Thin Cut

Thick Cut

Straight Shot

Draw

Follow

Stop Shot

Bank

Kick

Jump

Safety

Break

Combination

Carom

Masse

Cue Ball Control

Pattern Play

---

# Display Language

Shot Type

must follow

selected application language.

Vietnamese

English

No mixed language.

---

# Success

Only

Success

Fail

---

# Difficulty

1

Very Easy

2

Easy

3

Normal

4

Hard

5

Professional

---

# Cue Ball Control

Rate

1~5

---

# Position Control

Rate

1~5

---

# Miss Type

Thin

Thick

Wrong Speed

Wrong Spin

Wrong Line

Wrong Position

Mental

Unknown

---

# Quick Recording

Target

Less than

3 seconds

per shot.

---

# Auto Counter

Display

Total Shots

Successful Shots

Failed Shots

Current Streak

Longest Streak

---

# Coach Live Feedback

Every

20 shots

Coach recalculates

Current Accuracy

Main Error

Recommended Focus

---

# Finish Practice

Generate automatically

Practice Summary.

User does not type summary.

---

# Practice Summary

Display

Success %

Average Difficulty

Longest Success Streak

Most Used Shot

Most Failed Shot

Most Common Miss

Coach Score

---

# Coach Analysis

Display

Top Strength

Top Weakness

Today's Improvement

Recommended Drill

Estimated Recovery Time

---

# Practice History

Display

Date

Drill

Duration

Accuracy

Coach Score

---

# Search

Drill Name

Skill

Difficulty

Date

---

# Filter

Beginner

Intermediate

Advanced

Coach

Favorite

Recent

---

# Favorite

User may

Favorite Drill.

Coach uses

Favorites

when generating plans.

---

# Offline

Entire Practice

must work

without internet.

---

# Performance Target

Open Practice

<300ms

Save Shot

<100ms

Generate Summary

<2 seconds

---

# Validation

Cannot finish

while recording dialog

is open.

Cannot save

without

Shot Type.

---

# AI Integration

Every Practice

updates

Skill Engine

Coach Engine

Statistics

Training History

Dashboard

---

# Mandatory Rule

Practice

never asks

Match information.

Opponent

Score

Winner

must never appear.

---

# Mandatory Rule

Practice data

must never

modify

Match statistics.

Both datasets

remain independent.

---

# Mandatory Rule

Coach AI

must analyze

Practice

+

Match

+

Daily Readiness

together.

Never use

only one dataset.

---

End of Part 06

# DS-003 Product Specification
## Part 07 - Drill Library

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

This document defines the complete Drill Library.

Drill Library is the core knowledge base of Pool OS.

Coach AI recommends drills from this library.

Users never create random drills.

Every drill follows a standard structure.

---

# Philosophy

Coach

↓

Analyze Weakness

↓

Find Best Drill

↓

Assign Practice

↓

Measure Improvement

---

# Drill Structure

Every Drill contains

Metadata

↓

Instruction

↓

Setup

↓

Execution

↓

Evaluation

↓

Coach Tags

---

# Drill Metadata

Unique ID

Name

Difficulty

Primary Skill

Secondary Skill

Estimated Time

Estimated Shots

Recommended Level

Author

Version

---

# Difficulty Levels

Beginner

Intermediate

Advanced

Professional

Elite

---

# Player Levels

APA 2

APA 3

APA 4

APA 5

APA 6

APA 7

Professional

---

# Categories

Fundamental

Position Play

Cue Ball Control

Break

Safety

Thin Cut

Thick Cut

Long Pot

Bank

Kick

Jump

Combination

Pattern Play

Mental

Speed Control

Rail Shot

Special

---

# Drill Screen

Header

↓

Difficulty

↓

Preview Image

↓

Video

↓

Description

↓

Setup

↓

Practice

↓

History

---

# Header

Display

Drill Name

Difficulty

Favorite

Coach Rating

---

# Preview Image

Always display

table layout.

Never text only.

---

# Video

Optional

Display

Play Button

Duration

Coach Tip

---

# Drill Description

Explain

Purpose

Benefits

Common Mistakes

Success Criteria

---

# Setup

Display

Table Layout

Ball Positions

Cue Ball Position

Required Balls

Pocket Target

---

# Execution

Explain

Step 1

↓

Step 2

↓

Step 3

↓

Repeat

---

# Success Rule

Clearly define

Success

Failure

Restart

Completion

---

# Evaluation

Display

Attempts

Success Rate

Longest Streak

Average Difficulty

Coach Rating

---

# Coach Tags

Primary Skill

Secondary Skill

Common Mistakes

Recovery Drill

Related Drill

---

# AI Tags

Every Drill

must include

Machine Tags

Example

cut

cueball

draw

pattern

bank

kick

jump

safety

confidence

pressure

---

# Favorite

User may

Favorite Drill.

Favorite

appears first

in search.

---

# Recent

Display

Last 20 drills

opened.

---

# Coach Recommendation

Coach may

Recommend

Pin

Lock

or

Replace

drills

inside

Today's Training.

---

# Search

Search by

Name

Skill

Tag

Difficulty

Author

---

# Filter

Difficulty

Category

Player Level

Favorite

Coach

Recent

Duration

---

# Sort

Coach Priority

Difficulty

Most Practiced

Recently Used

Highest Rating

Alphabetical

---

# Empty State

Display

No Drill Found

Suggestion

Remove Filters

---

# Practice Entry

Start Practice

↓

Create Practice Session

↓

Open Recording Screen

---

# Statistics

Each Drill stores

Attempts

Completion

Average Accuracy

Best Accuracy

Longest Streak

Total Practice Time

---

# Coach Learning

Coach remembers

Which drills

improve player

Which drills

do not improve player.

Future recommendations

must adapt.

---

# Drill Version

Coach recommendations

always use

latest version

of Drill.

History

must remain intact.

---

# Offline

Entire Drill Library

works

without internet.

Images

Videos

cached locally.

---

# Performance Target

Open Drill

<300ms

Search

<100ms

Filter

<100ms

---

# Validation

Every Drill

must have

Category

Difficulty

Setup

Evaluation

Coach Tags

---

# Mandatory Rule

Coach

never recommends

drills

outside

player level

unless

Stretch Goal

is enabled.

---

# Mandatory Rule

Search

must support

Vietnamese

English

without changing

application language.

---

# Mandatory Rule

Drill Library

must remain

fully functional

with

1000+

Drills.

---

End of Part 07

# DS-003 Product Specification
## Part 08 - Coach AI Engine

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Coach AI is the decision engine of Pool OS.

Coach never guesses.

Coach always makes recommendations based on data.

Every recommendation must be explainable.

---

# Coach Inputs

Coach analyzes

Match Data

+

Practice Data

+

Daily Readiness

+

Equipment

+

Historical Progress

↓

Recommendation

---

# Data Priority

Priority 1

Recent Match

Priority 2

Recent Practice

Priority 3

Skill Trend

Priority 4

Daily Readiness

Priority 5

Equipment

Priority 6

Long-term History

---

# Coach Philosophy

Coach never says

"You are bad."

Coach always says

"What should improve next."

---

# Recommendation Rule

Every day

Coach outputs

ONE

Primary Focus

Only.

Never

2

Never

3

Never

5

---

# Output Structure

Today's Focus

↓

Reason

↓

Evidence

↓

Recommended Drills

↓

Expected Improvement

---

# Example

Today's Focus

Improve Position Play

Reason

Position errors increased.

Evidence

Position Error

18%

Largest Run

decreased

Confidence

6→4

---

# Drill Recommendation

Maximum

5 drills.

Priority order

1

2

3

4

5

Never show

random drills.

---

# Recommendation History

Store

Date

Focus

Reason

Completed

Ignored

Result

---

# Recommendation Life Cycle

Generated

↓

Shown

↓

Accepted

↓

Completed

↓

Evaluated

↓

Archived

---

# Acceptance

Player may

Accept

Skip

Ignore

Delay

---

# Completed

Coach measures

Improvement

after

practice.

---

# Improvement Evaluation

Compare

Before

↓

After

↓

Trend

---

# Trend Levels

Strong Improvement

Improvement

Stable

Regression

Strong Regression

---

# Skill Detection

Coach evaluates

Accuracy

Largest Run

Position

Safety

Break

Jump

Kick

Mental

Consistency

Confidence

---

# Mental Analysis

Coach evaluates

Confidence

Consistency

Fatigue

Practice Frequency

Recent Match Pressure

---

# Equipment Analysis

Coach checks

Cue

Tip

Weight

Balance

Maintenance

Replacement History

---

# Equipment Recommendation

Examples

Replace Tip

Clean Shaft

Adjust Weight

Replace Wrap

No Recommendation

---

# Daily Readiness

Coach checks

Sleep

Energy

Stress

Motivation

Pain

Practice Time

---

# Readiness Rule

Low Readiness

↓

Reduce Training

High Readiness

↓

Increase Training

---

# Training Recommendation

Coach chooses

Recovery

Technique

Competition

Mental

Physical

Mixed

---

# Match Analysis

Coach generates

Strength

Weakness

Turning Point

Largest Run

Critical Error

Confidence Curve

---

# Session Analysis

Coach summarizes

Entire Session

instead of

individual Match.

---

# Weekly Analysis

Coach compares

Current Week

↓

Previous Week

---

# Monthly Analysis

Coach detects

Long-term Trend

Skill Growth

Training Frequency

Plateau

Regression

---

# Plateau Detection

If

Skill

changes

<2%

during

30 days

↓

Generate

Plateau Warning

---

# Regression Detection

If

Skill decreases

3 consecutive sessions

↓

Generate

Regression Alert

---

# Skill Priority

Coach always ranks

1

Highest Priority

↓

10

Lowest Priority

---

# Recommendation Score

Each recommendation

has

Confidence Score

0~100

---

# Explainability

Every recommendation

must include

Why

Evidence

Expected Result

---

# Never Recommend

Coach never recommends

Advanced Jump

to

Beginner

Never recommends

Break Training

if

Break Success >90%

---

# Personalization

Coach learns

Favorite Drills

Completed Drills

Ignored Drills

Improvement History

Training Time

---

# AI Memory

Coach remembers

last

365 days.

---

# Performance

Recommendation

<1 second

Weekly Analysis

<2 seconds

Monthly Analysis

<3 seconds

---

# Validation

Coach must never

produce

empty recommendation.

If insufficient data

display

Collect More Data

instead.

---

# Mandatory Rule

Every recommendation

must be supported

by

real data.

No random advice.

---

# Mandatory Rule

Coach

must never

repeat

the same focus

more than

3 consecutive days

unless

no improvement exists.

---

# Mandatory Rule

Coach

must always

recommend

actionable drills.

Never provide

advice only.

---

End of Part 08

# DS-003 Product Specification
## Part 09 - Coach Screen

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Coach Screen is the most important screen in Pool OS.

Users should open this screen every day.

The screen must answer one question.

"What should I do today to become a better player?"

Never become a statistics page.

Never become a dashboard.

Coach Screen is an action page.

---

# Design Philosophy

Coach

does not report.

Coach

guides.

Coach

prioritizes.

Coach

explains.

Coach

plans.

---

# Screen Layout

Header

↓

Today's Focus

↓

Why?

↓

Today's Training

↓

Performance

↓

Progress

↓

Recommendation History

---

# Header

Display

Coach Avatar

Coach Score

Today's Date

Player Name

---

# Coach Score

Range

0~100

Display

Excellent

Good

Average

Needs Improvement

Poor

---

# Today's Focus

Display ONLY ONE item.

Example

Improve Position Play

Improve Break

Improve Safety

Improve Confidence

Improve Cue Ball Control

Never display

multiple priorities.

---

# Focus Card

Contains

Focus

Priority

Difficulty

Estimated Days

Expected Improvement

---

# Why Section

Coach explains

WHY

this became

today's priority.

---

# Evidence

Display

Maximum

3 reasons.

Example

Largest Run decreased.

↓

Position errors increased.

↓

Confidence dropped.

---

# Data Source

Each evidence

must include

source.

Example

Last 5 Matches

Last 3 Practice Sessions

Daily Readiness

Equipment

---

# Today's Training

Coach recommends

Maximum

5 drills.

---

# Drill Card

Display

Difficulty

Duration

Target Skill

Expected Result

Favorite

Start Button

---

# Start Training

Tap

↓

Open Practice

↓

Selected Drill

automatically.

---

# Alternative Drill

Player may choose

Alternative Drill.

Coach remembers

future preference.

---

# Performance Section

Display

Current Skill

Trend

Improvement

Regression

Confidence

---

# Skill Cards

Display

Position

Safety

Break

Cue Ball Control

Long Pot

Pattern

Mental

Consistency

---

# Trend

Display

↑

↓

→

Never use

numbers only.

---

# Weekly Progress

Display

Current Week

Previous Week

Improvement

Regression

---

# Monthly Progress

Display

Skill Growth

Practice Hours

Matches

Largest Run

Coach Score

---

# Recommendation History

Display

Date

Focus

Completed

Ignored

Result

---

# Recommendation Status

Generated

Accepted

Completed

Ignored

Expired

---

# Coach Feedback

After

completed practice

Coach updates

Result.

Example

Position Play

Improved

6%

---

# Equipment Advice

Display

only when needed.

Example

Replace Tip

Clean Shaft

Weight Adjustment

Otherwise

hide section.

---

# Readiness Advice

Display

Today's Energy

Today's Fatigue

Training Load

Recovery Suggestion

---

# Warning Card

Examples

Overtraining

Low Confidence

Training Plateau

Equipment Issue

Mental Fatigue

---

# Celebration Card

Examples

New Largest Run

7-day Practice Streak

Personal Best

Coach Score Increased

Skill Improved

---

# Empty State

If

insufficient data

Display

Collect More Data

Start Practice

Play Match

Complete Daily Readiness

---

# Navigation

Tap Drill

↓

Practice Screen

Tap Skill

↓

Statistics

Tap History

↓

Recommendation Detail

Tap Equipment

↓

Equipment Screen

---

# Refresh Rule

Coach Screen

refreshes automatically

after

Practice

Match

Daily Readiness

Equipment

Player Profile

---

# Performance

Open Screen

<500ms

Refresh

<1 second

Recommendation

<1 second

---

# Accessibility

Large Cards

Readable Fonts

Minimal Text

High Contrast

Single Hand Operation

---

# UX Rules

Never display

more than

one priority.

Never overwhelm

the player.

Every screen

must finish with

an action.

---

# Mandatory Rule

Coach Screen

must always answer

"What should I do today?"

within

5 seconds.

---

# Mandatory Rule

Every recommendation

must have

Start Training

button.

No dead-end information.

---

# Mandatory Rule

If player completes

today's training,

Coach must immediately

generate

the next recommendation.

Never leave

Coach Screen empty.

---

End of Part 09

# DS-003 Product Specification
## Part 10 - Statistics Engine

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Statistics Engine is responsible for calculating every statistic inside Pool OS.

Coach

Dashboard

Reports

History

Skill Engine

must never calculate statistics independently.

All calculations must come from Statistics Engine.

---

# Design Principle

Raw Data

↓

Statistics Engine

↓

Processed Metrics

↓

Consumers

Coach

Dashboard

Skill Engine

Reports

---

# Data Sources

Match

Practice

Daily Readiness

Equipment

Player

Session

---

# Update Rule

Statistics update

immediately after

every save.

Never wait

until Session finishes.

---

# Statistics Levels

Shot

↓

Rack

↓

Match

↓

Session

↓

Daily

↓

Weekly

↓

Monthly

↓

Career

---

# Shot Statistics

Total Shots

Successful Shots

Missed Shots

Accuracy %

Average Difficulty

Longest Success Streak

Current Streak

---

# Rack Statistics

Racks Played

Racks Won

Rack Win Rate

Average Balls Potted

Average Largest Run

Average Confidence

Average Errors

---

# Match Statistics

Matches Played

Matches Won

Matches Lost

Win Rate

Race To Record

Average Rack Time

Average Match Time

Comeback Wins

Clean Wins

---

# Session Statistics

Sessions

Average Duration

Practice Time

Competition Time

Break Time

Average Coach Score

---

# Practice Statistics

Practice Sessions

Completed Drills

Success Rate

Favorite Drill

Most Practiced Skill

Average Difficulty

---

# Mental Statistics

Average Confidence

Confidence Trend

Motivation Trend

Training Consistency

Fatigue Trend

---

# Equipment Statistics

Current Cue

Current Tip

Cue Usage

Tip Lifetime

Maintenance Count

Replacement Count

---

# Daily Statistics

Practice Time

Matches

Racks

Shots

Coach Score

Readiness

---

# Weekly Statistics

Total Hours

Practice Hours

Competition Hours

Win Rate

Accuracy

Largest Run

Coach Score

---

# Monthly Statistics

Skill Growth

Training Frequency

Largest Run

Best Match

Best Session

Improvement %

---

# Career Statistics

Career Matches

Career Sessions

Career Practice

Career Largest Run

Career Accuracy

Career Win Rate

Career Hours

---

# Skill Statistics

One statistic object

per skill.

Position

Safety

Break

Pattern

Long Pot

Kick

Jump

Bank

Draw

Follow

Mental

Consistency

Cue Ball

---

# Rolling Statistics

Maintain

Last 5 Matches

Last 10 Matches

Last 20 Matches

Last 30 Days

Last 90 Days

Last 365 Days

---

# Trend Calculation

Improving

Stable

Declining

Strong Improvement

Strong Decline

---

# Percentage Rules

Display

1 decimal place.

Example

74.6%

Never

74.666666%

---

# Largest Run

Career Best

Monthly Best

Weekly Best

Today's Best

Always stored separately.

---

# Coach Score History

Store

every score.

Never overwrite.

---

# Personal Best

Track

Longest Run

Highest Accuracy

Best Match

Best Session

Best Practice

Best Week

Best Month

---

# Milestones

Automatically detect

10 Matches

50 Matches

100 Matches

500 Matches

1000 Matches

100 Practice Sessions

1000 Practice Shots

---

# Records

Store

Date

Value

Context

Equipment Used

Opponent

---

# Performance

Statistics Update

<300ms

Weekly Calculation

<500ms

Monthly Calculation

<1 second

Career Calculation

<2 seconds

---

# Validation

No statistic

may become

negative.

No percentage

may exceed

100%.

---

# Data Integrity

Every statistic

must have

one source.

Never duplicate data.

Never manually edit statistics.

Statistics are always calculated.

---

# Mandatory Rule

Coach

Dashboard

Reports

must always read

Statistics Engine.

Never calculate

their own values.

---

# Mandatory Rule

Deleting

Match

Rack

Practice

must automatically

recalculate

every affected statistic.

---

# Mandatory Rule

Statistics Engine

must support

future cloud synchronization

without changing

calculation rules.

---

End of Part 10

# DS-003 Product Specification
## Part 11 - Skill Rating Engine

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Skill Rating Engine calculates the player's real ability.

It is the core engine used by

Coach

Dashboard

Training Planner

Progress Report

Statistics

Tournament Preparation

---

# Philosophy

Skill

is not

Win Rate.

Skill

is the probability

of executing

a technique correctly.

---

# Skill Sources

Match

+

Practice

+

History

↓

Skill Rating

---

# Update Rule

Every saved

Shot

Rack

Practice

updates

Skill Rating.

Never wait

until session ends.

---

# Skill Scale

Every skill

uses

0~100.

---

# Interpretation

0~20

Beginner

21~40

Developing

41~60

Intermediate

61~80

Advanced

81~100

Professional

---

# Skill Categories

Fundamental

Cue Ball

Shot Making

Position

Safety

Break

Mental

Competition

Consistency

---

# Fundamental Skills

Straight Shot

Thin Cut

Thick Cut

Long Pot

Rail Shot

Pocket Speed

---

# Cue Ball Skills

Draw

Follow

Stop Shot

Stun

Side Spin

Cue Ball Control

Speed Control

---

# Position Skills

Position Play

Pattern Play

Angle Control

Transition

End Pattern

---

# Safety Skills

Basic Safety

Advanced Safety

Safety Escape

Kick Safety

Containment

---

# Break Skills

Break Power

Break Accuracy

Break Control

Break Success

---

# Bank Skills

Bank Shot

Cross Bank

Long Bank

Double Rail

---

# Kick Skills

One Rail Kick

Two Rail Kick

Three Rail Kick

Jump Kick

---

# Jump Skills

Jump Accuracy

Jump Distance

Jump Safety

---

# Mental Skills

Confidence

Focus

Pressure Handling

Recovery

Decision Making

Patience

---

# Competition Skills

Match Control

Closing Ability

Comeback Ability

Momentum Control

---

# Consistency Skills

Consistency

Shot Repeatability

Training Discipline

---

# Skill Object

Every skill stores

Current Rating

Highest Rating

Lowest Rating

30-day Trend

90-day Trend

Confidence Level

Last Update

Evidence Count

---

# Confidence Level

Very Low

Low

Medium

High

Very High

---

# Evidence Count

Coach

must know

how much data

supports

a skill.

Example

Position Play

based on

15 shots

↓

Low Confidence

Position Play

based on

500 shots

↓

Very High Confidence

---

# Rating Update

New Rating

=

Previous Rating

+

Learning

-

Decay

---

# Learning Rule

Correct execution

increases

rating.

Incorrect execution

decreases

rating.

---

# Difficulty Weight

Easy

×

1.0

Medium

×

1.5

Hard

×

2.0

Professional

×

3.0

---

# Match Weight

Competition

has higher weight

than Practice.

Example

Practice

1.0

Match

1.5

Tournament

2.0

---

# Time Decay

Unused skills

slowly decay.

Decay starts

after

30 days.

---

# Decay Limit

Maximum decay

10%

per

90 days.

Never erase

player history.

---

# Plateau Detection

If

rating

changes

less than

2%

within

30 days

↓

Plateau.

---

# Breakthrough Detection

If

rating

improves

10%

within

7 days

↓

Breakthrough.

---

# Regression Detection

Three consecutive

negative updates

↓

Regression Alert.

---

# Skill Dependencies

Example

Cue Ball Control

affects

Position Play.

Position Play

affects

Pattern Play.

Confidence

affects

all Match skills.

---

# Composite Skills

Overall Offense

=

Shot Making

+

Cue Ball

+

Pattern

Overall Defense

=

Safety

+

Kick

+

Jump

Overall Mental

=

Confidence

+

Focus

+

Pressure

---

# Overall Rating

Player Rating

=

weighted average

of

all composite skills.

---

# Radar Chart

Radar

must always

read

Skill Engine.

Never calculate

inside UI.

---

# Skill History

Store

every change.

Never overwrite.

---

# Skill Milestones

40

50

60

70

80

90

100

Generate

achievement.

---

# Coach Usage

Coach

must always

recommend

lowest priority

high-impact skill.

Not necessarily

lowest score.

---

# Validation

No skill

may exceed

100.

No skill

may be

negative.

---

# Performance

Single Skill Update

<20ms

Complete Skill Update

<200ms

Radar Calculation

<50ms

---

# Mandatory Rule

Skill Rating

must always

be explainable.

Every change

must have

supporting evidence.

---

# Mandatory Rule

Practice

improves

Technique Skills.

Competition

improves

Competition Skills.

Do not mix

their weight equally.

---

# Mandatory Rule

Skill Engine

is the

single source of truth

for every skill value

inside Pool OS.

---

End of Part 11

# DS-003 Product Specification
## Part 12 - Dashboard Intelligence

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Dashboard is the home screen.

Dashboard is not a statistics page.

Dashboard is not a report page.

Dashboard must answer

"What should I do right now?"

within

3 seconds.

---

# Dashboard Philosophy

Information

↓

Decision

↓

Action

Never

Information

↓

Information

↓

Information

---

# Dashboard Layout

Header

↓

Today's Status

↓

Coach Priority

↓

Today's Training

↓

Today's Match

↓

Skill Snapshot

↓

Equipment

↓

Progress

↓

Recent Activity

---

# Header

Display

Player

Current Cue

Current Tip

Coach Score

Current Streak

---

# Today's Status

Display

Readiness

Training Load

Fatigue

Confidence

Mood

---

# Status Color

Green

Ready

Yellow

Moderate

Red

Recovery Required

---

# Coach Priority

Always display

ONE

highest priority.

Example

Improve Position Play

Replace Tip

Recovery Day

Tournament Tomorrow

---

# Priority Card

Contains

Title

Reason

Expected Benefit

Start Button

---

# Start Button

Navigate directly

to

Practice

Match

Equipment

Daily Readiness

depending on recommendation.

---

# Today's Training

Display

Maximum

5 drills.

Coach order only.

No manual sorting.

---

# Drill Card

Display

Name

Difficulty

Duration

Target Skill

Start

---

# Today's Match

Display only

if

Match scheduled.

Otherwise

hide section.

---

# Match Information

Opponent

Race To

Location

Estimated Time

Coach Reminder

---

# Pre-Match Reminder

Examples

Warm Up

Mental Focus

Break Practice

Equipment Check

---

# Skill Snapshot

Display

Top 6 skills.

Show

Radar

+

Trend

---

# Trend

Display

↑

↓

→

Only.

---

# Equipment Section

Display

Current Cue

Current Tip

Condition

Maintenance Status

---

# Equipment Warning

Display only

if needed.

Examples

Tip worn

Cue maintenance

Low lifespan

---

# Progress

Display

7 Days

30 Days

90 Days

365 Days

---

# Progress Metrics

Coach Score

Skill Growth

Practice Time

Largest Run

Accuracy

Consistency

---

# Recent Activity

Display

Last 10 activities.

Examples

Practice

Match

Readiness

Equipment

Coach Update

---

# Empty State

If

new player

Display

Create Player

↓

Add Cue

↓

Daily Readiness

↓

First Practice

---

# Refresh Rules

Dashboard refreshes

after

Practice

Match

Session

Equipment

Player

Readiness

Coach Update

---

# Auto Refresh

Refresh

only changed sections.

Never rebuild

entire screen.

---

# AI Cards

Dashboard may insert

temporary cards.

Examples

Today's Achievement

Recovery Needed

New Personal Best

Coach Alert

Tournament Tomorrow

Equipment Maintenance

---

# Celebration Cards

Examples

10 Practice Streak

Largest Run

New Skill Level

Coach Score +5

Consistency Improved

---

# Warning Cards

Examples

No Practice

7 Days

Skill Regression

Confidence Drop

Low Readiness

Equipment Issue

---

# Smart Ordering

Dashboard

changes

section order

depending on

player situation.

Example

Tournament Tomorrow

↓

Match Card

moves

to top.

Recovery Day

↓

Daily Readiness

moves

to top.

---

# Notification Rules

Dashboard

never interrupts.

Dashboard

suggests.

Never forces.

---

# Offline

Dashboard

must work

without internet.

---

# Performance

Open

<300ms

Refresh Section

<100ms

Coach Refresh

<500ms

---

# Validation

Dashboard

must never

contain

empty widgets.

Hide

unused sections.

---

# Mandatory Rule

Dashboard

must always end

with

one clear action.

Example

Start Practice

Start Match

Complete Readiness

Replace Tip

---

# Mandatory Rule

Dashboard

must never

show

more than

one

highest priority.

---

# Mandatory Rule

Dashboard

must adapt

to

player behavior.

Two players

with different data

must have

different dashboards.

---

End of Part 12

# DS-003 Product Specification
## Part 13 - Equipment Intelligence

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Equipment Intelligence manages

every playing equipment

and evaluates

its influence

on player performance.

Equipment

is no longer

static information.

Equipment

becomes

performance data.

---

# Philosophy

The system

does not ask

"What cue are you using?"

The system asks

"How does this cue affect your performance?"

---

# Equipment Categories

Playing Cue

Break Cue

Jump Cue

Extension

Tip

Glove

Chalk

Case

Other Accessories

---

# Cue Profile

Every cue stores

Brand

Model

Weight

Balance Point

Length

Wrap

Shaft

Joint

Joint Type

Purchase Date

Status

---

# Tip Profile

Brand

Model

Hardness

Diameter

Layer

Install Date

Maintenance Date

Replacement Date

Current Condition

Estimated Life

---

# Equipment Status

Excellent

Good

Normal

Needs Maintenance

Replace Soon

Expired

---

# Usage Tracking

Each equipment records

Matches Played

Practice Sessions

Racks Played

Estimated Hours

---

# Automatic Usage

Whenever

Practice

or

Match

starts

↓

Current equipment

usage increases automatically.

---

# Equipment History

Store

every change.

Example

Old Tip

↓

New Tip

Old Cue

↓

New Cue

---

# Equipment Timeline

Display

Purchase

Installation

Maintenance

Replacement

Damage

Repair

Retirement

---

# Maintenance Schedule

Automatically calculate

based on

usage.

---

# Example

Tip

Installed

90 days ago

↓

Played

520 racks

↓

Condition

Needs Replacement

---

# Tip Lifetime

Estimate

based on

Rack Count

Hours Played

Player Feedback

Coach Analysis

---

# Cue Performance

Track

Win Rate

Accuracy

Largest Run

Confidence

using

each cue.

---

# Tip Performance

Track

Accuracy

Cue Ball Control

Spin Quality

Consistency

before

and

after

replacement.

---

# Equipment Comparison

Compare

Cue A

↓

Cue B

using

Win Rate

Accuracy

Largest Run

Confidence

Coach Score

---

# Equipment Recommendation

Coach may recommend

Replace Tip

Clean Shaft

Replace Wrap

Change Cue

No Action

---

# Equipment Warning

Examples

Tip too old

Wrap damaged

Cue maintenance overdue

High scratch rate after tip change

---

# Equipment Influence

Coach calculates

whether

equipment

affects

performance.

---

# Example

Confidence

↓

after

new tip

↓

Coach suggests

more adaptation practice.

---

# Equipment Score

Each equipment

has

Health Score

0~100.

---

# Health Score

Calculated from

Age

Usage

Maintenance

Player Feedback

Performance Trend

---

# Equipment Compatibility

System learns

which equipment

works best

for

Practice

Competition

Break

Jump

---

# Favorite Equipment

Automatically detect

most used

equipment.

---

# Retirement

Equipment

never deleted.

Only

Archived.

History

must remain.

---

# Maintenance Reminder

Examples

Replace Tip

Clean Cue

Check Joint

Replace Glove

Buy Chalk

---

# Inventory

Display

All equipment

Owned

Archived

Retired

Loaned

Broken

---

# Search

Search by

Brand

Model

Type

Condition

Status

---

# Filters

Playing Cue

Break Cue

Jump Cue

Tips

Accessories

Archived

---

# Statistics

Display

Total Equipment

Active Equipment

Archived

Maintenance Cost

Replacement Count

Average Lifetime

---

# Cost Tracking

Store

Purchase Cost

Maintenance Cost

Replacement Cost

Total Ownership Cost

---

# Coach Integration

Coach

always checks

Equipment Health

before

making

training recommendations.

---

# Dashboard Integration

Dashboard

shows

Equipment Warning

only

when needed.

---

# Performance

Equipment update

<50ms

Equipment analysis

<200ms

Comparison

<500ms

---

# Validation

Current Playing Cue

must always exist.

Current Tip

must always exist.

Archived equipment

cannot be selected.

---

# Mandatory Rule

Equipment

must automatically

collect usage.

Never ask

user

to update

rack count manually.

---

# Mandatory Rule

Every equipment

must have

history.

Nothing

is permanently deleted.

---

# Mandatory Rule

Coach

must explain

why

equipment

is recommended

for replacement.

Never recommend

without evidence.

---

End of Part 13

# DS-003 Product Specification
## Part 14 - AI Training Planner

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

AI Training Planner automatically creates

Daily

Weekly

Monthly

Long-term

training plans.

The player

never needs

to build

their own schedule.

---

# Philosophy

Coach

does not recommend

random drills.

Coach builds

a structured roadmap.

---

# Training Levels

Today's Plan

↓

7-Day Plan

↓

30-Day Plan

↓

90-Day Plan

↓

Long-Term Development

---

# Planning Inputs

Skill Rating

Statistics

Practice History

Competition History

Daily Readiness

Equipment Status

Coach Rules

Upcoming Tournament

Training Goal

Available Time

---

# Planning Outputs

Today's Focus

Training Sequence

Estimated Duration

Expected Improvement

Recovery Recommendation

---

# Daily Plan

Contains

Warm-up

↓

Main Skill

↓

Support Skill

↓

Match Simulation

↓

Cool Down

---

# Warm-up

5~15 minutes

Purpose

Prepare body

and stroke rhythm.

---

# Main Skill

Only ONE

highest-priority skill.

Examples

Position Play

Safety

Break

Long Pot

Cue Ball Control

---

# Support Skill

One complementary skill.

Example

Position Play

↓

Cue Ball Speed

Safety

↓

Kick Shot

---

# Match Simulation

Always included

unless

Recovery Day.

---

# Cool Down

Simple drills

to finish

with confidence.

---

# 7-Day Plan

Goal

Build consistency.

Daily workload

changes automatically.

---

# Weekly Structure

Day 1

Heavy Practice

Day 2

Technique

Day 3

Match Play

Day 4

Recovery

Day 5

Pressure Training

Day 6

Competition Simulation

Day 7

Evaluation

---

# Recovery Day

AI may schedule

Recovery

instead of

Practice.

Examples

Stretching

Visualization

Mental Review

Video Analysis

---

# 30-Day Plan

Goal

Improve

one major weakness.

---

# Monthly Objectives

Increase Skill

Increase Accuracy

Increase Largest Run

Increase Coach Score

Increase Confidence

---

# Monthly Review

Every 30 days

AI evaluates

Goal

Completed

↓

Continue

or

Adjust Plan

---

# 90-Day Plan

Long-term development.

AI divides

90 days

into

three phases.

---

# Phase 1

Foundation

---

# Phase 2

Consistency

---

# Phase 3

Competition

---

# Tournament Mode

If tournament exists

within

14 days

↓

AI replaces

normal plan

with

Tournament Preparation.

---

# Tournament Preparation

Mental

Break

Safety

Pressure

Short Sessions

Equipment Check

Recovery

---

# Training Duration

AI adapts

to

available time.

---

# Example

15 minutes

↓

Warm-up

+

One Drill

---

30 minutes

↓

Warm-up

+

Two Drills

+

Review

---

60 minutes

↓

Full Session

---

120 minutes

↓

Competition Simulation

---

# Missed Training

AI never punishes.

Instead

adjusts

future schedule.

---

# Overtraining Detection

Examples

Practice

7 days

without recovery.

↓

Recovery Day.

---

# Plateau Detection

Skill

unchanged

30 days.

↓

New Drill Sequence.

---

# Adaptive Difficulty

Too Easy

↓

Increase Difficulty

Too Hard

↓

Decrease Difficulty

---

# Drill Rotation

Avoid

same drill

too frequently.

Minimum rotation

3 days

unless

critical weakness.

---

# Success Evaluation

Each completed drill

returns

Success Score.

---

# Training Score

Daily Score

Weekly Score

Monthly Score

Training Consistency

Training Completion

---

# AI Replanning

Whenever

new Match

Practice

Statistics

Skill Update

↓

Training Plan

recalculates automatically.

---

# Manual Adjustment

Player may

Skip

Pause

Swap

Extend

today's plan.

AI learns

preferences.

---

# Favorite Drills

AI records

favorite drills

but

never lets

favorites

replace

needed drills.

---

# Dashboard Integration

Dashboard

always displays

Today's Plan.

---

# Coach Integration

Coach explains

why

today's plan

was generated.

---

# Notification

Examples

Today's Training Ready

Recovery Day

Tournament Tomorrow

New Plan Generated

---

# Performance

Generate Daily Plan

<300ms

Weekly Plan

<500ms

Monthly Plan

<1 second

---

# Validation

Every plan

must include

Warm-up.

No plan

may exceed

available time.

Recovery

must exist

after overload.

---

# Mandatory Rule

AI

must optimize

improvement,

not

practice volume.

---

# Mandatory Rule

Training Plan

must adapt

after

every important event.

Never stay static.

---

# Mandatory Rule

Player

always knows

Today's Goal

before

starting practice.

---

End of Part 14

# DS-003 Product Specification
## Part 15 - Tournament Preparation Engine

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Tournament Preparation Engine prepares

the player

before

every tournament.

Coach becomes

a real tournament assistant.

---

# Philosophy

Tournament Day

is not

the day

to improve skill.

Tournament Day

is the day

to maximize performance.

---

# Tournament Lifecycle

Tournament Created

↓

Preparation Phase

↓

Competition Phase

↓

Post Tournament Review

---

# Tournament Information

Store

Tournament Name

Organizer

Location

Start Time

End Time

Game Format

Race

Dress Code

Entry Fee

Notes

---

# Tournament Types

Local

Club

Regional

National

International

Practice Tournament

---

# Supported Formats

8 Ball

9 Ball

10 Ball

Chinese Pool

Straight Pool

Snooker

Custom

---

# Timeline

T-30

↓

T-14

↓

T-7

↓

T-3

↓

T-1

↓

Tournament Day

↓

Review

---

# T-30

Long-term preparation

Skill Improvement

Training Volume

Physical Conditioning

---

# T-14

Begin Competition Phase

Increase Match Practice

Reduce Drill Variety

Mental Training

---

# T-7

Focus

Consistency

Break

Safety

Pressure

Recovery

---

# T-3

Reduce workload

Increase confidence

Equipment inspection

Video review

---

# T-1

Very light practice

Mental preparation

Sleep optimization

Equipment checklist

Travel preparation

---

# Tournament Day

Warm-up

Mental Checklist

Break Practice

Visualization

Equipment Check

---

# Warm-up Plan

10 minutes

Stroke

↓

10 minutes

Long Pot

↓

10 minutes

Cue Ball Control

↓

5 minutes

Break

---

# Mental Checklist

Confidence

Focus

Breathing

Routine

Goal

---

# Equipment Checklist

Playing Cue

Break Cue

Jump Cue

Extension

Chalk

Glove

Tip

Towel

Case

Water

---

# Equipment Verification

Coach checks

Tip Health

Cue Health

Replacement Risk

Maintenance Status

---

# Sleep Recommendation

Based on

Tournament Time

Travel

Fatigue

Readiness

---

# Nutrition Reminder

Water

Meal Timing

Avoid Alcohol

Avoid Heavy Food

---

# Match Preparation

Before every match

Coach displays

Today's Focus

Opponent Reminder

Mental Reminder

Break Reminder

---

# Between Matches

Coach evaluates

Fatigue

Confidence

Equipment

Mental State

---

# Recovery

Between matches

Stretch

Water

Food

Breathing

Visualization

---

# Emergency Mode

Examples

Broken Tip

↓

Switch Cue

Confidence Drop

↓

Mental Reset

Poor Break

↓

Short Break Drill

---

# Tournament Goals

Champion

Final

Semi Final

Quarter Final

Top 16

Experience

Practice

---

# AI Success Prediction

Estimate

Tournament Readiness

0~100

---

# Readiness Inputs

Skill

Confidence

Equipment

Fatigue

Practice

Coach Score

Recent Trend

---

# Confidence Prediction

Very Low

Low

Medium

High

Excellent

---

# Risk Detection

Low Confidence

Fatigue

Poor Sleep

Equipment Issue

Regression

Stress

---

# AI Warnings

Examples

Overtrained

Tip nearly worn out

Recovery recommended

Confidence unstable

---

# Live Notes

Player may record

Opponent

Table Condition

Cloth Speed

Pocket Size

Humidity

Lighting

---

# Tournament History

Store

Every Tournament

Forever

---

# Tournament Statistics

Matches

Win Rate

Best Finish

Average Finish

Largest Run

Break Success

Pressure Performance

---

# Post Tournament Review

Automatically generate

Strengths

Weaknesses

Mistakes

Positive Moments

Improvement Plan

---

# Coach Report

Questions answered

Why did you lose?

What improved?

What declined?

What should be trained?

---

# Dashboard Integration

Tournament Countdown

appears automatically.

---

# Coach Integration

Coach

switches

to Tournament Mode

automatically.

---

# Notification

T-14

Preparation Starts

T-7

Competition Week

T-1

Checklist Ready

Tournament Morning

Good Luck

---

# Performance

Tournament Report

<1 second

Readiness Score

<200ms

Checklist

<50ms

---

# Validation

Tournament

must never

interrupt

normal training.

Tournament Mode

ends automatically

after review.

---

# Mandatory Rule

Coach

must reduce

training volume

before tournament.

Never increase intensity

one day before competition.

---

# Mandatory Rule

Tournament Review

must generate

a new training plan

for the next cycle.

---

# Mandatory Rule

Tournament history

must never be deleted.

It is one of the most valuable datasets

for long-term player development.

---

End of Part 15

# DS-003 Product Specification
## Part 16 - Opponent Intelligence Engine

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Opponent Intelligence Engine

learns

every opponent

the player

has ever faced.

Coach prepares

a match strategy

before every game.

---

# Philosophy

Winning

is not only

about

playing well.

Winning

is also

about

understanding

your opponent.

---

# Opponent Profile

Each opponent stores

Name

Nickname

Club

City

Country

Playing Hand

Age (optional)

Notes

---

# Playing Style

Coach classifies

the opponent.

Examples

Aggressive

Defensive

Balanced

Fast

Slow

Risk Taking

Conservative

Pattern Player

Shot Maker

Safety Player

---

# Preferred Game

Store

8 Ball

9 Ball

10 Ball

Chinese Pool

Snooker

---

# Historical Record

Store

Matches Played

Wins

Losses

Win Rate

Average Race

Largest Run

Average Match Duration

---

# Match History

Every match

stores

Score

Winner

Date

Venue

Tournament

Equipment

Coach Notes

---

# Opponent Statistics

Display

Win %

Average Rack Time

Break Success

Scratch Rate

Safety Usage

Kick Usage

Jump Usage

Position Quality

---

# Weakness Detection

Coach automatically detects

Weak Break

Weak Safety

Weak Long Pot

Weak Position

Weak Mental

Weak Finish

Poor Recovery

---

# Strength Detection

Coach automatically detects

Excellent Break

Strong Safety

Excellent Pattern

Power Shot

Strong Mental

High Consistency

---

# Tactical Profile

Examples

Attacks often

Avoids safety

Uses bank shots

Rarely jumps

Slow decision making

Fast rhythm

---

# Pressure Analysis

Coach records

performance

when

Leading

Trailing

Hill-Hill

Race Finish

---

# Score Pattern

Example

Opponent

often loses

after

leading

5-2.

Coach stores

this behavior.

---

# Break Analysis

Store

Break Success

Break Win Rate

Scratch

Dry Break

Cue Ball Control

---

# Safety Analysis

Average Safety

Successful Safety

Failed Safety

Safety Frequency

---

# Shot Analysis

Most Used Shot

Least Used Shot

Weakest Shot

Best Shot

---

# Mental Analysis

Confidence

Tilt Risk

Recovery Speed

Momentum

Consistency

---

# Time Analysis

Average Shot Time

Fastest Decision

Longest Decision

Slow Under Pressure

---

# Equipment Analysis

Coach records

which cue

opponent uses.

Optional only.

---

# Match Notes

Player may record

Table Speed

Opponent Behavior

Special Situations

Mind Games

Referee Issues

Anything useful

---

# AI Pattern Recognition

Coach detects

repeated behaviors.

Example

Always attacks

after

good break.

Always plays safety

when

under pressure.

---

# Match Prediction

Coach estimates

Win Probability

before

every match.

---

# Prediction Inputs

Your Skill

Opponent Skill

Confidence

Equipment

Recent Form

Head-to-Head

Tournament Mode

---

# Game Plan

Coach generates

Before Match

Strategy.

---

# Example

Primary Goal

Avoid Long Pot Battle

Secondary Goal

Increase Safety Count

Opening Strategy

Break Soft

Pressure Strategy

Slow Down Pace

---

# During Match

(Optional Future)

Coach

does not coach

during play.

Only

between matches

or

between sessions.

---

# Rival Detection

If

same opponent

played

more than

5 matches

↓

Mark as

Rival.

---

# Learning Speed

Opponent profile

improves

after

every match.

---

# Confidence Level

Low

Medium

High

Very High

based on

number of matches.

---

# Opponent Radar

Display

Break

Safety

Attack

Mental

Position

Consistency

---

# Comparison

Compare

You

vs

Opponent

side-by-side.

---

# Head-to-Head

Display

Wins

Losses

Largest Run

Average Margin

Best Match

Worst Match

---

# Tournament Integration

Before tournament

Coach

checks

if

known opponents

exist.

---

# Dashboard Integration

Display

Next Opponent

Game Plan

only

when tournament exists.

---

# Privacy

Opponent data

belongs

to

the player.

Never shared

without permission.

---

# Performance

Opponent Analysis

<300ms

Match Prediction

<500ms

History Query

<200ms

---

# Validation

Opponent

may exist

without

full information.

Unknown values

must never

break analysis.

---

# Mandatory Rule

Coach

must explain

WHY

a strategy

is recommended.

Never output

a strategy

without evidence.

---

# Mandatory Rule

Opponent Intelligence

must learn

continuously.

Never overwrite

historical behavior.

---

# Mandatory Rule

Player

may manually

correct

Opponent Profile

if AI classification

is incorrect.

---

End of Part 16

# DS-003 Product Specification
## Part 17 - Career Development Engine

Version: 1.0

Project: Pool OS

Date: 2026-07-03

---

# Purpose

Career Development Engine

tracks

the player's

entire billiards journey.

Not

one session.

Not

one season.

The entire career.

---

# Philosophy

Statistics

show

the past.

Career Engine

predicts

the future.

---

# Career Timeline

First Day

↓

First Match

↓

First Tournament

↓

Skill Milestones

↓

Major Improvements

↓

Career Today

---

# Career Overview

Display

Career Age

Practice Hours

Matches

Tournaments

Coach Score

Current Level

Career Trend

---

# Career Levels

Beginner

↓

Developing

↓

Intermediate

↓

Advanced

↓

Competitive

↓

Elite

---

# Career Progress

Display

Career Progress Bar.

Example

Advanced

72%

↓

Competitive

---

# Long-Term Trend

Display

1 Month

3 Months

6 Months

1 Year

All Time

---

# Skill Evolution

Store

every

Skill Rating

forever.

---

# Timeline Events

Examples

Largest Run

First Tournament

Champion

Equipment Change

Coach Milestone

Skill Upgrade

Career Best

---

# Career Milestones

Examples

100 Practice Sessions

500 Hours

1000 Racks

Largest Run 20

Largest Run 30

Coach Score 80

Coach Score 90

---

# Personal Records

Display

Career High

Largest Run

Best Break

Highest Accuracy

Longest Practice Streak

Longest Win Streak

Best Tournament Finish

---

# Development Speed

Coach evaluates

Improving

Stable

Plateau

Regression

---

# Plateau Detection

Examples

No improvement

60 days.

↓

Recommend

new training strategy.

---

# Career Projection

AI predicts

future development.

---

# Examples

Continue

current pace

↓

Reach

Coach Score 90

in

4 months.

---

Continue

4 sessions/week

↓

Largest Run 30+

within

6 months.

---

Increase

practice

20%

↓

Win Rate

+6%

---

# Goal Tracking

Long-term Goals

Examples

Largest Run 30

Coach Score 90

Win Local Tournament

Play National Event

---

# Goal Progress

Every goal

has

Progress

Remaining Work

Estimated Completion

---

# Career Strength

Display

Top 5

career strengths.

---

# Career Weakness

Display

Top 5

career weaknesses.

---

# Training ROI

Calculate

Training Hours

↓

Skill Improvement

↓

Efficiency

---

# Example

100 hours

↓

Coach Score

+12

Efficiency

Excellent

---

# Inefficient Training

Detect

too much practice

with

little improvement.

---

# Burnout Detection

Detect

Overtraining

↓

Low Progress

↓

High Fatigue

↓

Recovery Required

---

# Motivation Analysis

Coach monitors

Consistency

Motivation

Drop Risk

---

# Career Summary

Automatically generate

Monthly

Quarterly

Yearly

reports.

---

# Monthly Report

Contains

Practice Summary

Match Summary

Coach Review

Skill Growth

Recommendations

---

# Annual Report

Contains

Best Performance

Most Improved Skill

Most Difficult Skill

Tournament Results

Career Highlights

Career Goals

---

# Career Awards

Examples

Iron Player

Practice Machine

Break Master

Safety Specialist

Comeback King

Consistency Award

---

# Legacy Records

Nothing

is deleted.

Career history

must remain

forever.

---

# Dashboard Integration

Display

Career Goal

only

when relevant.

---

# Coach Integration

Coach

uses

Career History

before

creating

new plans.

---

# AI Projection

Predict

1 Month

3 Months

6 Months

1 Year

---

# Confidence Level

Every prediction

shows

Confidence.

Low

Medium

High

Very High

---

# Performance

Career Report

<1 second

Projection

<500ms

Timeline

<300ms

---

# Validation

Career Engine

must work

even

if

player

has

very little data.

---

# Mandatory Rule

Career

must always

encourage

the player.

Never compare

against

other players.

Only compare

against

the player's

past self.

---

# Mandatory Rule

Predictions

must explain

why

they were generated.

Never output

numbers

without explanation.

---

# Mandatory Rule

Career Engine

must never

reset.

It is

the permanent memory

of the player.

---

End of Part 17

