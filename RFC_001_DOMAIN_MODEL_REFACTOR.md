# FILE: RFC_001_DOMAIN_MODEL_REFACTOR.md

# POOL OS

Request For Change

RFC-001

Domain Model Refactor

Version 2.0

Status

APPROVED

---

# PURPOSE

This RFC updates the Pool OS domain model before Sprint 1 implementation.

The previous design was missing one important business object:

Match

This RFC also simplifies the database by moving many specialized fields into the Event system.

---

# WHY

Real practice sessions rarely contain only one match.

Example

Saturday Practice

↓

Warm Up

↓

Race To 5

↓

Race To 7

↓

Ghost Challenge

↓

Break Practice

↓

Long Pot Drill

All of these belong to ONE Session.

Therefore Session must become a container.

---

# NEW DOMAIN MODEL

Old

Player

↓

Session

↓

Rack

↓

Shot

↓

Event

New

Player

↓

Equipment

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

Statistics

are generated from Events.

Coach AI

reads Statistics.

---

# SESSION

Session is only a container.

Session stores

id

date

location

sessionType

duration

equipment

trainingGoal

notes

weather (optional)

table

cloth

balls

No statistics should be stored inside Session.

---

# MATCH

Create new entity

Match

Fields

id

sessionId

matchNumber

gameType

raceTo

opponent

partner

teamMode

winner

result

startTime

endTime

matchObjective

notes

Examples

Race To 5

Race To 7

Ghost Challenge

Challenge Match

League Match

Tournament Match

Practice Match

---

# RACK

Rack no longer belongs to Session.

Rack belongs to Match.

Old

Session

↓

Rack

New

Match

↓

Rack

---

# SHOT

Shot should remain lightweight.

Allowed fields

id

rackId

shotNumber

shotType

difficulty

result

positionQuality

decision

confidence

playerNote

createdAt

Forbidden

longPot

thinCut

sideSpin

draw

follow

railCut

bankShot

kickShot

jumpShot

strokeHitch

gripPressure

headLift

These belong to Events.

---

# POSITION

Do NOT create Position table.

Do NOT create

distanceError

angleError

speedError

These values are impossible to record manually.

Position remains

Perfect

Good

Playable

Recovery

Bad

Future AI Vision may calculate precise errors.

---

# STROKE

Do NOT create Stroke table.

Stroke problems become Events.

Examples

Stroke Hitch

Grip Tight

Grip Loose

Head Lift

Steering

Bridge Unstable

Follow Through Short

---

# EVENT SYSTEM

Event becomes the core of Pool OS.

Every Shot

contains

0..N Events.

Event fields

id

shotId

category

type

severity

confidence

metadataJson

createdAt

---

# EVENT CATEGORY

Stroke

Position

Decision

Pattern

Break

Mental

Equipment

Training

Environment

Special

---

# EVENT EXAMPLES

Category

Stroke

Type

Stroke Hitch

---

Category

Position

Type

Natural Route

---

Category

Decision

Type

Attack

---

Category

Mental

Type

Pressure Shot

---

Category

Training

Type

No Side Spin

---

Category

Equipment

Type

House Cue

---

# WHY EVENTS?

Because Events are infinitely extensible.

Adding

Rail First

Kick

Bank

Jump

Curve

Power Draw

No database migration is required.

Only add new Event Types.

---

# SESSION EXAMPLE

Player

↓

Saturday Practice

(Session)

↓

Warm Up

(Match)

↓

Rack 1

↓

Shots

↓

Events

↓

Race To 5

(Match)

↓

Rack 1

↓

Shots

↓

Events

↓

Ghost Challenge

(Match)

↓

Rack 1

↓

Shots

↓

Events

---

# DATABASE CHANGES

Create

Match

table.

Change

Rack.sessionId

↓

Rack.matchId

Do NOT modify

Shot

except adding difficulty if missing.

Extend Event

category

severity

confidence

metadataJson

---

# COACH AI IMPACT

No changes required.

Coach AI reads Statistics.

Statistics are still generated from Events.

Only the hierarchy changes.

---

# MIGRATION

Existing Sessions

↓

Create one default Match

↓

Move all existing Racks

↓

Update foreign keys

No user data should be lost.

---

# IMPLEMENTATION PRIORITY

Priority

Critical

This RFC must be completed

before

continuing Sprint 1.

---

# ACCEPTANCE CRITERIA

✓ Match entity exists.

✓ Rack belongs to Match.

✓ Session acts as container.

✓ Shot remains lightweight.

✓ Event becomes extensible.

✓ No Stroke table.

✓ No Position table.

✓ Existing data migrates successfully.

---

# END OF FILE
