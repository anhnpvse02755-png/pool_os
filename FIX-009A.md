# FIX-009A
Version: 1.0
Priority: P1
Module: Statistics Repository

---

## IMPORTANT

Follow

CURSOR_DEVELOPMENT_RULES.md

Especially

Rule 4
Rule 5
Rule 8
Rule 10
Rule 17 (Scope Guard)

---

# PURPOSE

This FIX exists ONLY to expose detailed statistics data from Repository
to Presentation.

DO NOT change:

- Statistics Engine
- Coach Engine
- Database
- Drift
- Migration
- Business Rules
- Dashboard
- Session Logic
- Match Logic

---

# BACKGROUND

FIX-008C completed Statistics Presentation.

Presentation now supports drill-down UI.

However,

StatisticsRepository currently does not expose enough raw data for those
detail screens.

This FIX ONLY completes Repository data exposure.

---

# ROOT CAUSE

Current StatisticsRepository mainly returns aggregated values.

Presentation requires detailed datasets such as:

- Match history
- Rack history
- Shot statistics
- Error statistics
- Break statistics
- Position play statistics

These datasets already exist in database.

Repository simply does not expose them.

---

# OBJECTIVE

Expand Statistics Repository APIs.

Expose existing data.

Do NOT calculate new values.

Do NOT modify existing formulas.

Presentation performs visualization only.

---

# BUG-001

Win Rate Detail

Repository shall expose:

- Total matches
- Won matches
- Lost matches
- Match list
- Match date
- Opponent
- Match type
- Final score

No new calculations.

---

# BUG-002

Rack Detail

Repository shall expose:

- Rack history
- Rack winner
- Balls run
- Largest run
- Confidence
- Biggest mistake
- Biggest strength

These fields already exist.

Only expose them.

---

# BUG-003

Shot Statistics

Repository shall expose raw shot records.

Include:

- Shot type
- Difficulty
- Success
- Miss
- Position quality
- Cue ball control
- Safety result

No aggregation.

---

# BUG-004

Error Statistics

Repository shall expose

raw error events.

Include:

- Scratch
- Miss easy ball
- Position error
- Safety error
- Kick error
- Jump error
- Other recorded errors

---

# BUG-005

Break Statistics

Repository shall expose

raw break information.

Include:

- Break success
- Scratch
- Dry break
- Balls pocketed
- Spread score (if available)

---

# BUG-006

Repository API

Presentation should never query Drift directly.

Flow must remain:

Database

↓

Repository

↓

Provider

↓

Presentation

Do not bypass Repository.

---

# BUG-007

Performance

Avoid duplicate queries.

If multiple screens require same dataset,

reuse Repository methods.

Do not duplicate SQL.

---

# ACCEPTANCE

Repository exposes all required datasets.

Presentation uses Repository only.

No SQL inside Presentation.

No changes to

Statistics Engine.

No changes to

Coach Engine.

No database migration.

No Drift modification.

No regression.

flutter analyze

0 errors.

---

# REPORT

Report ONLY

1.

Root Cause

2.

Repository Methods Added

3.

Files Modified

4.

Performance Impact

5.

Regression Risk

6.

Flutter Analyze

7.

Remaining Limitations

If detailed statistics require new Business Logic,

STOP.

Do NOT implement.

Recommend

RFC

instead.