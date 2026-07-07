# Pool OS Development Rules
Version: 1.0

Project: Pool OS

This document is mandatory.

Cursor must follow ALL rules below.

---

# Rule 1

UAT is the highest priority.

If

RFC

DS

Specification

or

Cursor's own opinion

conflicts with

UAT,

UAT always wins.

Never argue against UAT.

Never override UAT.

---

# Rule 2

Do NOT redesign workflow.

Workflow may ONLY be changed if the UAT explicitly requests a workflow change.

Otherwise,

keep existing workflow.

Only fix bugs.

Only improve UI.

Only improve UX.

Only improve performance.

---

# Rule 3

Do NOT invent features.

If the specification does not request a feature,

do not create it.

---

# Rule 4

Never refactor unrelated code.

Modify ONLY files required by the current FIX.

Do not optimize unrelated modules.

Do not clean architecture.

Do not rename classes unless required.

---

# Rule 5

One FIX = One module.

Example

FIX-008A

Session

↓

ONLY Session files.

Do not modify

Equipment

Coach

Statistics

unless absolutely required.

---

# Rule 6

Never change navigation

unless

UAT explicitly requests it.

---

# Rule 7

Never change business logic

unless

UAT explicitly requests it.

---

# Rule 8

When fixing a bug,

find the root cause first.

Never patch symptoms.

Always explain

Root Cause

↓

Solution

↓

Files Modified

↓

Regression Risk

---

# Rule 9

Every report must contain

1.

Root Cause

2.

Files Modified

3.

What Changed

4.

What Was NOT Changed

5.

Regression Risk

6.

Flutter Analyze Result

Do not generate long marketing-style reports.

Keep reports technical.

---

# Rule 10

Never declare

"Completed"

unless

the requested feature

has actually been implemented.

If partially completed,

state

PARTIAL.

---

# Rule 11

If implementation cannot be completed,

report the blocker immediately.

Never fake completion.

---

# Rule 12

Minimize user input.

Pool OS is designed to

collect maximum useful data

while requiring

minimum manual input.

Whenever multiple UI designs are possible,

choose the one that reduces user interaction.

---

# Rule 13

UI/UX improvements

are allowed

only if

they do not change workflow.

Examples

Allowed

✓ better layout

✓ better spacing

✓ faster interaction

✓ better icons

✓ clearer labels

Not allowed

✗ changing navigation flow

✗ moving business process

✗ adding new confirmation steps

✗ removing required steps

unless requested by UAT.

---

# Rule 14

Every FIX

must preserve

backward compatibility.

Never break

existing workflows

that already pass UAT.

---

# Rule 15

Always think

Product First.

Do not implement

because it is easier.

Implement

because it provides

the best experience

for the Pool player.

---

# Rule 16

If a UAT report contains multiple issues,

fix them exactly as requested.

Do not redesign other modules.

Do not optimize unrelated areas.

Focus only on the reported issues.

---

# Rule 17

If a workflow redesign is requested,

modify ONLY that workflow.

Do not redesign any other workflow.

---

# Rule 18

Always preserve data compatibility.

Never introduce database changes

unless required.

If a migration is required,

create the next sequential migration only.

---

# Rule 19

Code quality priority

1. Correctness

2. Stability

3. User Experience

4. Performance

5. Code Elegance

Never sacrifice correctness

for cleaner code.

---

# Rule 20

Goal

Pool OS

must become

a stable,

professional,

daily-use application.

Stability is always more important

than adding new features.

# Rule 21

Never assume

that a reported bug

has already been fixed.

Every UAT issue

must be verified

against the current source code.

Do not rely on previous reports.

Always inspect the implementation first.

Only then

apply the fix.