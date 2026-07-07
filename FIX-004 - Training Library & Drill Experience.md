# FIX-004 - Training Library & Drill Experience

Version: 1.0

Priority: P1

Status: Ready

Reference

RFC-010

RFC-011

RFC-020

---

# Objective

Redesign the Drill Library.

Current implementation is difficult to browse.

Users cannot quickly find suitable drills.

This FIX improves only Drill Library UX.

Do NOT modify Coach Engine.

Do NOT modify Statistics.

---

# Current Problems

Current Drill Library

↓

One long list

↓

Filter

↓

Still difficult to browse

---

# Required Structure

The library shall be divided by

Skill Level

instead of displaying one long list.

---

# Skill Levels

Beginner

Intermediate

Advanced

Professional

Coach Custom

---

# Beginner

Typical drills

- Straight Pot
- Stop Shot
- Half Ball
- Full Ball
- Follow
- Draw
- Basic Position
- Center Ball

---

# Intermediate

- Thin Cut
- Thick Cut
- Long Pot
- Stun
- Two Rail Position
- One Rail Position
- Safety Basic
- Bank Shot

---

# Advanced

- Jump
- Kick
- Multi Rail
- Cue Ball Route
- Pattern Play
- Pressure Drill
- Cluster Break
- Safety Exchange

---

# Professional

- Ghost Challenge
- Match Simulation
- Race Drill
- Pressure Finish
- Break Control
- Tactical Drill

---

# Coach Custom

Coach generated drills.

These drills are dynamic.

Never hardcoded.

---

# Search

Add search box.

Search by

- Name

- Skill

- Category

- Difficulty

---

# Filter

Allow multiple filters

Skill Level

Difficulty

Shot Type

Target Skill

Estimated Time

Equipment Needed

---

# Drill Card

Each drill card must display

Name

Difficulty

Skill Level

Target Skill

Estimated Time

Completion %

Recommended By Coach (optional)

---

# Drill Detail

Each drill must include

Title

Description

Purpose

Table Layout

Ball Setup

Execution Steps

Success Criteria

Recommended Repetitions

Difficulty

Common Mistakes

Expected Improvement

Related Skills

---

# Drill Difficulty

Display

1

2

3

4

5

Stars

---

# Drill Status

Not Started

In Progress

Completed

Mastered

---

# Drill Recommendation

Coach recommendation

↓

Open drill directly.

User must not search again.

---

# Favorite

Allow

Favorite Drill

Recent Drill

Most Used Drill

---

# Sorting

Newest

Alphabetical

Difficulty

Coach Recommended

Recently Used

Most Practiced

---

# Vietnamese

Entire Drill Library

must use

Vietnamese with proper accents.

No English.

---

# Constraints

Do NOT redesign Dashboard.

Do NOT redesign Coach.

Do NOT redesign Statistics.

Modify only Drill Library.

---

# Acceptance Criteria

✓ Drill Library divided by Skill Level.

✓ Search available.

✓ Multiple filters.

✓ Drill Detail complete.

✓ Coach can open recommended drill directly.

✓ Favorite supported.

✓ Recently Used supported.

✓ Vietnamese only.

✓ No regression.