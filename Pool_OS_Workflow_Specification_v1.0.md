# Pool OS Workflow Specification v1.0

## Status

**LOCKED** -- This document is the authoritative workflow specification
for Pool OS.

## Purpose

Pool OS is a player development system, not merely a scorekeeping
application.

All future implementations must follow this workflow. If existing code
conflicts with this specification, the code must be updated to match the
specification. AI assistants (Cursor, Claude, Gemini, etc.) must **not**
invent or redesign workflows.

------------------------------------------------------------------------

# Core Data Flow

``` text
Session
  └── Match / Practice / Drill
        └── Rack
              └── Shot
                    └── Event
                          └── Statistics
                                └── Coach
```

Every module exists to improve player performance.

------------------------------------------------------------------------

# Session

## Session List

Display only:

-   Recent sessions
-   Date
-   Type
-   Duration
-   Summary

Do **not** display:

-   Shot controls
-   Event controls
-   Win/Lose buttons
-   Drill controls

Those belong only inside detail screens.

## Create Session

User presses **+**

Choose:

-   Practice
-   Match
-   Drill

Only after choosing is a session created.

------------------------------------------------------------------------

# Practice Workflow

``` text
Create Practice
→ Practice Detail
→ Record Rack
→ Record Shot
→ Record Event
→ Finish Practice
→ Summary
→ Back to Session
```

Practice never has opponent or race.

------------------------------------------------------------------------

# Match Workflow

``` text
Create Match
→ Enter Opponent
→ Enter Race
→ Start Match
→ Match Detail
```

Match Detail contains:

-   Win Rack
-   Lose Rack
-   Add Shot
-   Add Event

Race must be configurable (3,5,7,9,11,13,15 or custom).

Finishing a match does **not** finish the session.

Workflow:

``` text
Finish Match
→ Summary
→ Return to Match Detail
→ Continue editing if required
→ Finish Session later
```

------------------------------------------------------------------------

# Drill Workflow

``` text
Session
→ Drill Library
→ Search / Filter
→ Select Drill
→ Configure repetitions
→ Start
→ Record Hit/Miss/Event
→ Finish
→ Summary
→ Back Session
```

Drill Library must never disappear unexpectedly.

------------------------------------------------------------------------

# Shot Rules

-   Every Shot belongs to one Rack.
-   No standalone Shot.
-   Auto-save immediately after recording.

------------------------------------------------------------------------

# Event Rules

-   Every Event belongs to one Shot.
-   No standalone Event.
-   Auto-save immediately after recording.

------------------------------------------------------------------------

# Equipment

Exactly one active cue for each type:

-   Playing
-   Break
-   Jump
-   Break+Jump

Active cues must show a visible indicator directly on the list.

------------------------------------------------------------------------

# Daily Readiness

Workflow:

``` text
Dashboard
→ Daily Readiness
→ Sleep
→ Fatigue
→ Focus
→ Stress
→ Save
→ Dashboard
```

Never crash if data is empty.

------------------------------------------------------------------------

# Dashboard

Dashboard is read-only.

Displays:

-   Daily Readiness
-   Latest Session
-   Coach Summary
-   Quick Statistics

No data entry.

------------------------------------------------------------------------

# Statistics

Read-only.

Never create, edit or delete data.

If no data exists, display a friendly empty state instead of crashing.

------------------------------------------------------------------------

# Coach

Coach consumes Statistics only.

Outputs:

-   Focus
-   Recommendation
-   Weakness
-   Improvement

------------------------------------------------------------------------

# Database Relationship

``` text
Session
→ Match
→ Rack
→ Shot
→ Event
```

One-to-many relationship at every level.

------------------------------------------------------------------------

# Development Rules

AI Developer MUST NOT:

-   redesign workflow
-   invent navigation
-   change business rules

AI Developer MUST:

-   implement this specification
-   preserve workflow consistency
-   keep changes within approved scope

------------------------------------------------------------------------

# Acceptance Criteria

A fix is complete only if all three are true:

1.  `flutter analyze` returns 0 errors.
2.  APK builds successfully.
3.  UAT passes against this workflow specification.

Passing static analysis alone is **not** sufficient.
