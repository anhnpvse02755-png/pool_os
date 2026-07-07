# RFC-017 - Complete User Workflow Specification

Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

Every screen must have a complete workflow.

The application MUST NEVER leave the user without a next action.

Every button must have a destination.

Every action must update database.

Every completed workflow must refresh Dashboard.

---

# Main Navigation

Dashboard

↓

Session

↓

Statistics

↓

Equipment

↓

Player

↓

Settings

---

# Player Workflow

Dashboard

↓

Player

↓

Player List

↓

Add Player

↓

Save

↓

Refresh Player List

↓

Back

---

Edit Player

↓

Update

↓

Refresh

↓

Back

---

Delete Player

↓

Confirmation

↓

Delete

↓

Refresh

---

# Equipment Workflow

Equipment

↓

Cue List

↓

Add Cue

↓

Save

↓

Refresh

---

Edit Cue

↓

Update

↓

Refresh

---

Delete Cue

↓

Confirm

↓

Delete

↓

Refresh

---

Tip

↓

Search Brand

↓

Select

↓

Save

---

Shaft

↓

Search Brand

↓

Select

↓

Save

---

# Session Workflow

Dashboard

↓

New Session

↓

Fill Session Information

↓

Save

↓

Open Session Detail

---

Session Detail

↓

Create Match

↓

Save

↓

Open Match

---

# Match Workflow

Match Detail

↓

Start Match

↓

Rack 1

↓

Record Rack

↓

Save

↓

Rack 2

...

↓

Final Rack

↓

Match Summary

↓

Save

↓

Back To Session

---

# Rack Workflow

Rack Screen

↓

Play Rack

↓

Press

Win

or

Lose

↓

Popup Summary

↓

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

---

# End Match Workflow

Last Rack

↓

Match Result

↓

Statistics Update

↓

Coach Analysis

↓

Return Session

---

# End Session Workflow

Finish Session

↓

Session Summary

↓

Statistics Update

↓

Coach Analysis

↓

Dashboard Refresh

---

# Dashboard Workflow

Open App

↓

Readiness

↓

Dashboard Refresh

↓

Coach Card

↓

Today's Training

↓

Recent Session

---

# Coach Workflow

Dashboard

↓

Coach Card

↓

Open Coach

↓

Today's Recommendation

↓

Training Plan

↓

Start Training

---

# Statistics Workflow

Dashboard

↓

Statistics

↓

Overview

↓

Skill

↓

Trend

↓

Session History

↓

Match History

↓

Rack History

---

# Daily Readiness Workflow

Open App

↓

Daily Check

↓

Sleep

↓

Energy

↓

Stress

↓

Confidence

↓

Save

↓

Dashboard Refresh

↓

Coach Refresh

---

# Search Workflow

Equipment

↓

Brand Search

↓

Result

↓

Select

↓

Save

No static dropdown.

---

# Required Confirmation

Delete Player

Delete Cue

Delete Session

Delete Match

Delete Rack

Always ask confirmation.

---

# Dashboard Refresh Rules

Refresh after

Player Update

Equipment Update

Readiness Update

Rack Save

Match Save

Session Save

Coach Analysis

Statistics Update

---

# Empty States

No Player

↓

Create Player

No Equipment

↓

Add Cue

No Session

↓

Start Practice

No Statistics

↓

Complete First Session

---

# Error Handling

Database Error

↓

Retry

↓

Cancel

Validation Error

↓

Highlight Missing Fields

Network Error

↓

Offline Mode

---

# Loading Rules

Every Save

must show

Loading Indicator

Every Success

must show

Success Message

Every Failure

must show

Error Message

---

# Acceptance Criteria

Every button performs an action.

No dead-end screens.

No empty navigation.

Dashboard always refreshes automatically.

Coach always refreshes after Session.

Statistics always refresh after Match.

Every workflow is completed without returning to Home manually.
