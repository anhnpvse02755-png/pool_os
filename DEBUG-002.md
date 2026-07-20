# DEBUG-002
Version: 1.0
Priority: P0
Mode: RUNTIME DEBUG ONLY

==================================================

THIS IS NOT A FIX.

DO NOT MODIFY ANY SOURCE CODE.

DO NOT REFACTOR.

DO NOT OPTIMIZE.

DO NOT BUILD RELEASE APK.

==================================================

OBJECTIVE

Run the application in DEBUG mode.

Investigate runtime failures.

Collect REAL runtime evidence.

NOT static code review.

NOT assumptions.

==================================================

FORBIDDEN WORDS

Do NOT use:

- Likely
- Maybe
- Probably
- Possibly
- Seems
- Could be
- Might be
- Requires verification

If you cannot prove the root cause,

write

UNKNOWN

==================================================

RUN THE APPLICATION

flutter clean

flutter pub get

flutter run

==================================================

REPRODUCE EVERY BUG

BUG-001

Dashboard

Crash

Null check operator used on a null value

--------------------------------------------------

BUG-002

Session

Race selection

--------------------------------------------------

BUG-003

Match

Win

Lose

Grey Screen

--------------------------------------------------

BUG-004

Session Screen

Wrong buttons still visible

--------------------------------------------------

BUG-005

Shot

Event

Not saved

--------------------------------------------------

BUG-006

Drill

Grey Screen

--------------------------------------------------

BUG-007

Equipment

Active Cue Tick

--------------------------------------------------

BUG-008

Coach

Grey Screen

--------------------------------------------------

BUG-009

Statistics

Grey Screen

==================================================

FOR EACH BUG

You MUST provide

1.

Can reproduce

YES

NO

2.

Exact operation

Example

Dashboard

↓

Open Session

↓

Press Match

↓

Win

↓

Crash

3.

Exact Exception

Copy exactly.

4.

Complete Stack Trace

5.

First project file in stack trace.

6.

Exact line number.

7.

Root Cause.

Must be supported by stack trace.

8.

Affected modules.

9.

Recommended Fix Location.

==================================================

IF THE BUG CANNOT BE REPRODUCED

Write

NOT REPRODUCED

Do NOT guess.

==================================================

OUTPUT

Generate only

DEBUG_RUNTIME_REPORT.md

No code changes.

No APK.

No fixes.

==================================================

STOP.

Wait for my approval.