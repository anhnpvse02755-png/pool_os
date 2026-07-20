# DEBUG-001
Version: 1.0
Priority: P0
Mode: DEBUG ONLY

==================================================

THIS IS NOT A FIX.

DO NOT MODIFY ANY CODE.

DO NOT REFACTOR.

DO NOT OPTIMIZE.

DO NOT BUILD APK.

YOUR ONLY JOB IS TO DEBUG.

==================================================

The latest Release Candidate still contains critical workflow failures.

Before implementing ANY fix, you must investigate the real root cause.

==================================================

RULES

1.

Reproduce every reported bug.

2.

Find the exact exception.

3.

Capture the complete stack trace.

4.

Locate the FIRST file where the exception originates.

NOT

where the crash appears.

5.

Determine whether multiple bugs share the same root cause.

6.

Do NOT assume.

Do NOT guess.

Every root cause must be supported by evidence.

7.

If the root cause cannot be proven,

report

UNKNOWN

Do NOT fabricate a solution.

==================================================

UAT BUGS

BUG-001

Dashboard

Crash

Null check operator used on a null value.

--------------------------------------------------

BUG-002

Session

Race only supports

5

7

Need investigation.

--------------------------------------------------

BUG-003

Match

Press Win

Press Lose

Grey screen.

--------------------------------------------------

BUG-004

Session Screen

Still shows

Win

Lose

Add Shot

Add Event

Drill

Need to determine why previous fixes did not take effect.

--------------------------------------------------

BUG-005

Add Shot

Add Event

No Save

No Auto Save

Investigate data flow.

--------------------------------------------------

BUG-006

Drill

Grey screen.

--------------------------------------------------

BUG-007

Equipment

Active Cue

Tick icon missing.

Determine whether

UI

Provider

or

Repository.

--------------------------------------------------

BUG-008

Coach

Grey screen.

Back exits app.

--------------------------------------------------

BUG-009

Statistics

Grey screen.

Back exits app.

==================================================

OUTPUT

Generate only

DEBUG_REPORT.md

For EACH bug provide

--------------------------------------------------

1.

Bug ID

2.

Can reproduce?

YES / NO

3.

Exception

4.

Stack Trace

5.

First failing file

6.

Failing line

7.

Root Cause

8.

Evidence

9.

Affected modules

10.

Estimated Fix Scope

--------------------------------------------------

After all bugs,

create

ROOT CAUSE GROUPING

Example

Root Cause A

Causes

BUG-003

BUG-006

BUG-008

BUG-009

Root Cause B

Causes

BUG-001

Root Cause C

Causes

BUG-007

==================================================

IMPORTANT

If four bugs are caused by one root cause,

DO NOT propose four fixes.

Propose one fix.

==================================================

DO NOT

Fix code.

Generate APK.

Refactor.

Implement anything.

Only debug.

Wait for my approval.