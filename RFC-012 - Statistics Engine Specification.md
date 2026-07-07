# RFC-012 - Statistics Engine Specification

Version: 1.0

Status: REQUIRED

Priority: P0

---

# Objective

Statistics Engine is responsible for converting raw Session data into meaningful performance metrics.

Coach AI MUST ONLY read Statistics.

Coach AI MUST NEVER read raw Session data directly.

---

# Data Flow

Player

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

↓

Statistics Engine

↓

Coach Engine

---

# Statistics Categories

1. Overall Performance

2. Break Performance

3. Potting Performance

4. Position Play

5. Safety

6. Cue Ball Control

7. Mental

8. Equipment

9. Trend

10. Training

---

# Overall Performance

Matches Played

Matches Won

Matches Lost

Rack Won

Rack Lost

Win Rate

Average Match Duration

Average Rack Duration

Average Balls Per Rack

Longest Run

Current Winning Streak

Longest Winning Streak

---

# Break Performance

Break Attempts

Successful Break

Dry Break

Scratch On Break

Break Success %

Average Balls After Break

Break And Run

Golden Break

Power Break %

Control Break %

---

# Potting Performance

Balls Potted

Pot Success %

Long Pot Success %

Thin Cut Success %

Straight Shot %

Rail Shot %

Combination Success %

Bank Success %

Kick Success %

Jump Success %

---

# Position Play

Position Success %

Good Position

Bad Position

Too Long

Too Short

Wrong Angle

Lost Shape

Average Position Rating

---

# Cue Ball Control

Cue Ball Accuracy

Scratch Rate

Draw Success

Follow Success

Stop Shot Success

Spin Accuracy

Speed Control

---

# Safety

Safety Attempts

Successful Safety

Failed Safety

Safety Success %

Safety Escape %

Kick Escape %

---

# Mental

Confidence Average

Pressure Win %

Hill-Hill Win %

Hill-Hill Lose %

Focus Rating

Rush Events

Tilt Events

Recovery After Miss

---

# Equipment

Current Cue

Current Shaft

Current Tip

Equipment Usage Time

Performance By Tip

Performance By Shaft

Performance By Cue

Equipment Change Impact

---

# Trend Statistics

Last 3 Sessions

Last 5 Sessions

Last 10 Sessions

30 Days

90 Days

Lifetime

Every statistic must include trend

Improving

Stable

Declining

---

# Skill Radar

Radar contains

Break

Shot Making

Position

Safety

Cue Ball Control

Mental

Consistency

Each Skill

0 ~ 100

---

# Consistency Score

Formula based on

Position

Potting

Mental

Break

Scratch

Foul

Output

0 ~ 100

---

# Readiness Statistics

Average Sleep

Average Energy

Average Stress

Average Recovery

Training Load

Recovery Score

Readiness Trend

---

# Session Statistics

For every Session generate

Duration

Total Matches

Total Racks

Win %

Average Balls

Biggest Strength

Biggest Weakness

Coach Summary

---

# Match Statistics

For every Match

Rack Timeline

Momentum

Longest Run

Key Mistake

Turning Point

Pressure Performance

---

# Rack Statistics

Every Rack stores

Balls

Mistake

Strength

Confidence

Pressure

Events

---

# Player Statistics

Lifetime

Weekly

Monthly

Yearly

Best Session

Worst Session

Current Trend

Potential Improvement

---

# Dashboard Statistics

Today's Readiness

Current Focus

Skill Radar

Weekly Hours

Last Session

Coach Recommendation

Current Equipment

Training Progress

---

# Required Output

Every Statistic MUST provide

Current Value

Trend

Target

History

Example

Position Accuracy

Current

61%

Trend

+4%

Target

75%

History

58

59

61

61

63

---

# Rule

Statistics MUST update immediately after

Rack Save

Match Save

Session Save

---

# Acceptance Criteria

✓ Every Session generates statistics.

✓ Every Match generates statistics.

✓ Every Rack contributes to statistics.

✓ Statistics support Coach Engine.

✓ Dashboard uses Statistics only.

✓ No hardcoded values.

✓ Every statistic supports trend analysis.

✓ Every statistic supports historical comparison.
