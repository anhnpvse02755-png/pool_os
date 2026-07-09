# Pool OS
# IMPLEMENTATION SPECIFICATION
# FIX-010
# Author: Technical Lead
# Status: APPROVED
# Priority: P0
# Scope: LIMITED

======================================================
OBJECTIVE
======================================================

Implement ONLY the approved fixes below.

Do NOT redesign.

Do NOT refactor.

Do NOT optimize.

Do NOT modify any workflow.

Do NOT modify any architecture.

Do NOT touch unrelated modules.

======================================================
APPROVED FIXES
======================================================

------------------------------------------------------
FIX-010A
Session State Synchronization
------------------------------------------------------

Problem

After a Session ends, Session Screen still displays:

- Win
- Lose
- Add Shot
- Add Event
- Drill

This violates Pool OS workflow.

Expected Behaviour

Session Screen

↓

Session List

↓

Session Detail

↓

Match Detail

↓

ONLY Match Detail contains:

- Win
- Lose
- Shot
- Event

Implementation

Synchronize activeMatch correctly.

When there is no active match:

activeMatch MUST become null.

Allowed files

session_provider.dart

Acceptance

Session finished

↓

Return to Session Screen

↓

No Match actions visible.

======================================================

FIX-010B
Shot / Event Persistence
======================================================

Problem

Recorded Shot/Event disappears after restart.

Expected Behaviour

Every recorded Shot/Event

↓

Immediately persisted

↓

Database

↓

Visible after restart.

Implementation

Persist through existing Repository.

Do NOT redesign Repository.

Do NOT redesign Database.

Allowed files

shot_provider.dart

event_provider.dart

Acceptance

Create Shot

↓

Restart App

↓

Shot still exists.

======================================================

FIX-010C
Equipment Active Cue Indicator
======================================================

Problem

User cannot identify:

Active Playing Cue

Active Break Cue

without opening menu.

Expected Behaviour

Equipment List shows

✓ Playing Cue

✓ Break Cue

directly.

Implementation

Visible icon only.

No workflow changes.

Allowed files

equipment_screen.dart

Acceptance

Switch cue

↓

Indicator moves correctly.

======================================================

FIX-010D
Dashboard todayFocus
======================================================

Problem

Dashboard may crash while rebuilding.

Expected Behaviour

Dashboard never crashes.

If todayFocus is null

↓

Display empty state.

Implementation

Safe null handling only.

Do NOT modify Coach.

Do NOT modify Statistics.

Allowed files

dashboard_screen.dart

Acceptance

Fresh database

↓

Dashboard opens successfully.

======================================================
FILES NOT ALLOWED
======================================================

DO NOT MODIFY

Coach

Statistics

Repository Architecture

Database Schema

Drift

GoRouter

Riverpod Architecture

Localization

Theme

Skill Engine

Statistics Engine

Session Workflow

======================================================
IMPLEMENTATION RULES
======================================================

NO

Architecture changes

NO

Project-wide refactor

NO

Global replacement

NO

Changing business rules

NO

Fixing unrelated bugs

======================================================
AFTER IMPLEMENTATION
======================================================

Run

flutter analyze

Expected

0 Errors

Build

DEBUG APK ONLY

DO NOT BUILD RELEASE APK.

======================================================
OUTPUT
======================================================

Provide

FIX-010_REPORT.md

including

1.

Files modified

2.

Reason each file changed

3.

Acceptance checklist

4.

Regression Risk

5.

flutter analyze result

6.

Known remaining bugs

STOP.

Wait for UAT.

DO NOT start FIX-011.