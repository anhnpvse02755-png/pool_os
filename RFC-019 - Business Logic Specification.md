# RFC-019 - Business Logic Specification

Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

This document defines all business logic.

Cursor MUST NOT invent business logic.

Every user action must follow this document.

---

# Session Lifecycle

Draft

↓

Started

↓

In Progress

↓

Completed

↓

Archived

Only Completed Sessions generate final statistics.

---

# Match Lifecycle

Created

↓

Started

↓

Playing

↓

Finished

↓

Saved

Statistics update only after Match Finished.

---

# Rack Lifecycle

Created

↓

Playing

↓

Finished

↓

Saved

↓

Statistics Updated

↓

Coach Updated

---

# Rack Save Logic

When Rack is saved

System MUST

Save Rack

↓

Save Events

↓

Update Match Statistics

↓

Update Session Statistics

↓

Update Player Statistics

↓

Refresh Dashboard

↓

Refresh Coach

---

# Match Finish Logic

When Match ends

System MUST

Calculate Winner

↓

Generate Match Summary

↓

Update Statistics

↓

Generate Coach Analysis

↓

Save Timeline

---

# Session Finish Logic

When Session ends

System MUST

Generate Session Summary

↓

Update Lifetime Statistics

↓

Generate Coach Report

↓

Refresh Dashboard

---

# Daily Readiness Logic

User opens app

↓

Check today's readiness

↓

Save

↓

Update Readiness Score

↓

Coach recalculates today's training

---

# Equipment Logic

When Tip changes

↓

Reset Tip Usage Hours

↓

Start Equipment Tracking

↓

Compare Performance

---

When Shaft changes

↓

Save Equipment History

↓

Track Performance Difference

---

# Statistics Logic

Statistics update

Immediately

after

Rack Save

Match Finish

Session Finish

Equipment Change

Readiness Update

Never wait until app restart.

---

# Coach Logic

Coach runs after

Session Finished

Match Finished

Readiness Updated

Coach MUST NOT run

every screen refresh.

---

# Dashboard Logic

Dashboard refreshes after

Statistics Update

Coach Update

Equipment Update

Readiness Update

Player Update

---

# Event Logic

Every Event belongs to

One Rack

One Match

One Session

Events never exist independently.

---

# Timeline Logic

Every Session contains Timeline.

Timeline stores

Rack

↓

Events

↓

Summary

↓

Coach Notes

Timeline must be viewable later.

---

# History Logic

Player History stores

Sessions

Matches

Racks

Equipment

Training

Readiness

Coach Reports

---

# Notification Logic

Coach Recommendation Ready

↓

Training Reminder

↓

Recovery Reminder

↓

Equipment Reminder

↓

Weekly Summary

---

# Delete Rules

Delete Rack

↓

Recalculate Match

↓

Recalculate Session

↓

Recalculate Player

↓

Refresh Dashboard

Delete Match

↓

Recalculate Session

↓

Refresh Dashboard

Delete Session

↓

Recalculate Lifetime Statistics

↓

Refresh Dashboard

---

# Edit Rules

Editing historical data

must trigger

complete recalculation

for affected statistics.

---

# Offline Logic

All actions work offline.

Synchronization occurs automatically

when internet becomes available.

No data loss.

---

# Acceptance Criteria

Every action has defined business logic.

No hidden calculations.

No undefined workflows.

Statistics always remain consistent.

Coach always receives latest data.

Dashboard always reflects current state.
