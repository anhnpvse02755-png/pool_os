# POOL OS
# Phase 2 - Feature Development
# Product Owner Master Specification

Version: 2.0

---

# IMPORTANT

Stop treating Pool OS as a Flutter application.

Treat it as a complete AI Pool Training Operating System.

You are no longer fixing bugs.

You are implementing the product.

Bug fixing is only allowed when it blocks a feature.

Priority:

Business
→ UX
→ Performance
→ Bug

NOT

Bug
→ Bug
→ Bug

---

# PRODUCT GOAL

Pool OS must become the most complete training platform for amateur pool players.

The application must answer one question:

"Why did I lose?"

and

"What should I train tomorrow?"

Everything else only exists to support these two answers.

---

# PRODUCT LOOP

Every feature must belong to this loop.

Player

↓

Daily Readiness

↓

Session

↓

Practice
or
Match

↓

Rack

↓

Shot

↓

Result

↓

Statistics

↓

Coach

↓

Training Plan

↓

Player Improvement

↓

repeat forever

Nothing outside this loop should exist.

---

# CURRENT STATUS

Recording Pipeline — DONE

Session — DONE

Match — DONE

Statistics — PARTIAL

Coach — PARTIAL

Dashboard — PARTIAL

Practice — VERY BASIC

Training Program — MISSING

Player Profile — MISSING

Skill Analysis — PARTIAL

Equipment Intelligence — MISSING

Fatigue Analysis — MISSING

Mental Analysis — MISSING

Warmup Analysis — MISSING

Learning System — MISSING

---

##################################################
PHASE 2
##################################################

The following features MUST be implemented.

Do NOT skip.

---

# FEATURE 1 — PLAYER PROFILE

Create a complete player profile. The profile is no longer only name + avatar. It becomes the player's identity.

Include: Name, Avatar, Playing hand, Height, Age, Years playing, Current rank, Target rank, Preferred game, Break style, Playing style, Attack %, Safety %, Favorite cue, Favorite tip, Bridge length, Eye dominance, Coach, Club, Playing frequency, Average hours per week, Average matches per week, Goals, Weaknesses, Strengths, Training history, Achievement timeline, Progress timeline, Milestones.

---

# FEATURE 2 — PLAYER TIMELINE

Create a timeline. Every important event is stored.

Examples: Started Pool, Changed cue, Changed tip, Won tournament, Reached rank G, Changed coach, Personal best, Highest run, Best win streak, Training streak.

All timeline events can be reviewed.

---

# FEATURE 3 — COMPLETE SESSION

A Session is no longer only Match. A session contains:

Arrival time, Warmup, Practice, Match, Cooldown, Notes, Mood, Energy, Hydration, Food, Sleep, Fatigue after session, Lessons learned, Session score, Coach review.

---

# FEATURE 4 — PRE MATCH

Before every match ask:

How nervous are you, Confidence, Focus, Body condition, Shoulder, Arm, Back, Eyes, Legs, Mental pressure, Expected opponent level, Expected race, Expected duration.

This becomes Match Context.

---

# FEATURE 5 — POST MATCH

After every match ask:

How tired are you, Shoulder fatigue, Arm fatigue, Eye fatigue, Mental fatigue, Lost focus?, Lost confidence?, Satisfied?, Most difficult rack?, What caused defeat?, Player comments, Coach comments.

This data must be stored.

---

# FEATURE 6 — WARMUP ANALYSIS

Track: Warmup duration, Warmup drills, Warmup score, Warmup confidence.

Then compare Warmup → Performance. Find relationships.

Example: Player warmup <10 minutes → First 3 racks win rate only 28% → Recommend: increase warmup to 20 minutes.

---

# FEATURE 7 — FIRST RACK EFFECT

Detect: Player usually starts badly.

Track Rack 1, Rack 2, Rack 3, Rack 4, ... Compare.

Example: Rack 1 accuracy, Rack 5 accuracy, Rack 10 accuracy.

Coach must know: Player needs 3 racks to enter rhythm.

---

# FEATURE 8 — MUSCLE MEMORY

Track how quickly player reaches stable performance.

Metrics: First successful stop shot, First successful draw, First successful follow, First successful break, Average stabilization rack, Average stabilization time.

Display: Muscle Memory Curve.

---

# FEATURE 9 — FATIGUE MODEL

Build fatigue model.

Inputs: Duration, Shots, Breaks, Movement, Heart estimation, Mental pressure, Temperature, Hydration.

Outputs: Fatigue curve, Coach recommendations.

---

# FEATURE 10 — ENDURANCE

Measure performance after: 30 minutes, 60 minutes, 90 minutes, 120 minutes, 180 minutes, 240 minutes.

Coach determines: Short match player / Long match player.

---

# FEATURE 11 — MENTAL MODEL

Track: Confidence, Tilt, Recovery, Pressure, Momentum, Comeback ability, Hill-hill ability, Leading ability, Trailing ability.

---

# FEATURE 12 — SHOT LEARNING

Every Shot must produce: Success, Failure, Reason, Difficulty, Confidence.

Then classify: Needs training, Stable, Mastered.

---

# FEATURE 13 — EVENT SYSTEM

Events must NOT be entered separately. Events belong to a Shot.

Workflow: Shot → Result → Reason → Event → Learning.

No standalone Event screen.

---

# FEATURE 14 — SMART COACH

Coach no longer displays statistics. Coach must explain.

Example:

You lost because:
- Stop shot unstable
- Warmup too short
- Shoulder fatigue

Evidence:
- 14 misses
- 82% happened after 70 minutes
- First successful stop shot appeared only at rack 5

Recommendation:
- Warmup 20 minutes
- Train Stop Shot 200 reps
- Maximum match length 2 hours

---

# FEATURE 15 — TRAINING PLAN

Generate automatically: Daily, Weekly, Monthly.

Based on: Weakness, Fatigue, Goals, Recent matches, Progress.

---

# FEATURE 16 — SKILL TREE

Replace radar. Build a Skill Tree:

Stop Shot, Draw, Follow, Bank, Kick, Jump, Safety, Position, Break, Mental, Physical, Decision, Visualization.

Every skill: Level, XP, Progress, Coach target.

---

# FEATURE 17 — PLAYER IMPROVEMENT

Every month generate a Monthly report.

Include: Improvement, Regression, Best session, Worst session, Best drill, Worst drill, Strength, Weakness, Next month focus.

---

# UX REQUIREMENTS

The application must become enjoyable. Testing should feel like using a premium sports app.

Avoid: Large forms, Long scrolling, Duplicate screens.

Instead: Cards, Progress, Timeline, Expandable sections, Animations, Charts, Coach cards, Insights, Achievements.

---

# IMPORTANT

Never create fake statistics. Never invent values.

Every recommendation must include: Evidence, Reason, Data source, Training solution, Expected improvement.

---

# FINAL GOAL

By the end of Phase 2, Pool OS should feel like:

Strava + Chess.com + Whoop + Garmin + AI Coach — for Pool players.
