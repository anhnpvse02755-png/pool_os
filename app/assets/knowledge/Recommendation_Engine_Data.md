# Pool OS Recommendation Engine Data

## Overview

This document describes the recommendation metadata for the Pool OS Knowledge Base.

**Version:** 1.0.0  
**Last Updated:** 2026-07-17  
**Total Items:** 500  
**Estimated Reading Hours:** 150  
**Estimated Practice Hours:** 2000  

---

## Metadata Fields

### For Each Knowledge Item

| Field | Description | Values |
|-------|-------------|--------|
| `whoShouldLearn` | Target audience description | Text |
| `requiredLevel` | Minimum skill level needed | I, H, G, F, E, D, C, B, A |
| `recommendedNextTopic` | Best topic to learn after this | Skill ID |
| `commonFollowUpTopics` | Related topics often studied next | Array of Skill IDs |
| `estimatedReadingTime` | Time to read and understand | quickRead (3min), standardRead (5min), detailedRead (8min), comprehensiveRead (12min) |
| `estimatedPracticeTime` | Time to achieve basic proficiency | introduction (30min), basic (60min), intermediate (120min), advanced (240min), mastery (480min) |
| `importanceScore` | How critical this skill is | 0-100 |
| `popularityScore` | How commonly studied | 0-100 |
| `tags` | Categorization tags | Array of strings |

---

## Reading Time Estimates

| Type | Minutes | Description |
|------|---------|-------------|
| quickRead | 3 | Brief concept overview |
| standardRead | 5 | Normal topic coverage |
| detailedRead | 8 | In-depth with examples |
| comprehensiveRead | 12 | Complete with all details |

---

## Practice Time Estimates

| Type | Minutes | Description |
|------|---------|-------------|
| introduction | 30 | Basic understanding |
| basic | 60 | Can perform with supervision |
| intermediate | 120 | Can perform independently |
| advanced | 240 | Consistent performance |
| mastery | 480 | Automatic execution |

---

## Player Levels

| Level | Name | Description |
|-------|------|-------------|
| I | Beginner | No prior experience |
| H | Novice | Knows rules and basic shots |
| G | Intermediate | Can run balls, basic position |
| F | Club Player | Consistent, competitive |
| E | Advanced | Strong all-around game |
| D | Semi-Pro | Tournament competitive |
| C | Professional | Regional winner |
| B | Expert | National level |
| A | Master | World-class |

---

## Sample Recommendations

### Stroke Fundamentals

```json
{
  "whoShouldLearn": "Everyone - this is the foundation of all pool skills",
  "requiredLevel": "I",
  "readingTime": "standardRead",
  "practiceTime": "intermediate",
  "importanceScore": 100,
  "popularityScore": 95,
  "recommendedNextTopic": "stroke.straight_stroke",
  "commonFollowUpTopics": [
    "stroke.pendulum_stroke",
    "stroke.stability",
    "stroke.follow_through"
  ],
  "tags": ["fundamentals", "stroke", "critical", "everyone"]
}
```

### Bank Shot Mastery

```json
{
  "whoShouldLearn": "Elite players mastering all bank types",
  "requiredLevel": "E",
  "readingTime": "detailedRead",
  "practiceTime": "mastery",
  "importanceScore": 92,
  "popularityScore": 55,
  "recommendedNextTopic": "match_strategy.safety_battle",
  "commonFollowUpTopics": [
    "kick.kick_mastery",
    "match_strategy.fundamentals"
  ],
  "tags": ["bank", "mastery", "elite"]
}
```

---

## Importance vs Popularity Matrix

```
HIGH IMPORTANCE (80-100)
         │
    100  │  ★Fundamentals
         │  ★Position Planning
    90   │  ★Cue Ball Control
         │  ★Speed Control
    85   │  ★Match Strategy
         │  ★Safety Battle
    80   │  ○English
         │  ○Stability
         │
         └───────────────────────────
         50    70    90    100
              POPULARITY
         │
         │    HIGH POPULARITY (80-100)
    95   │  ★Stroke Fundamentals
         │  ★Center Ball
         │  ★Bridge Fundamentals
    90   │  ★Draw/Follow
         │  ★Ghost Ball
    85   │  ★Stance
         │  ★Run Out
    80   │  ★Grip
         │  ★Speed Control
         │
    70   │  ○Half Ball
         │  ○One Rail Bank
    60   │  ○Diamond Kick
         │  ○Massé
    50   │  ○Gap Analysis
         │  ○Mastery
         │
         └───────────────────────────
         50    70    90    100
              POPULARITY
```

**Legend:**
- ★ = High importance + High popularity (Study first)
- ○ = Lower importance or lower popularity

---

## Learning Path Recommendations

### Beginner (Level I-H)

1. **stroke.fundamentals** - 100 importance, 95 popularity
2. **bridge.fundamentals** - 92 importance, 88 popularity
3. **grip.fundamentals** - 88 importance, 85 popularity
4. **aim.fundamentals** - 98 importance, 92 popularity
5. **stance.fundamentals** - 90 importance, 85 popularity

### Intermediate (Level G-F)

1. **cue_ball.fundamentals** - 95 importance, 90 popularity
2. **pattern.position_planning** - 90 importance, 82 popularity
3. **stroke.speed_control** - 92 importance, 88 popularity
4. **aim.cue_ball_path** - 90 importance, 82 popularity
5. **safety.fundamentals** - 85 importance, 80 popularity

### Advanced (Level F-E)

1. **cue_ball.english** - 92 importance, 82 popularity
2. **aim.shot_selection** - 92 importance, 78 popularity
3. **match_strategy.fundamentals** - 88 importance, 78 popularity
4. **pattern.run_out** - 92 importance, 85 popularity
5. **cue_ball.multi_dimensional** - 90 importance, 75 popularity

### Elite (Level E-D)

1. **cue_ball.cue_ball_mastery** - 98 importance, 60 popularity
2. **stroke.mechanics_mastery** - 95 importance, 60 popularity
3. **aim.aiming_mastery** - 95 importance, 55 popularity
4. **pattern.mastery** - 95 importance, 58 popularity
5. **match_strategy.match_strategy_mastery** - 95 importance, 55 popularity
6. **mental.mastery** - 95 importance, 55 popularity
7. **gap_analysis.gap_analysis_mastery** - 88 importance, 48 popularity

---

## Category Statistics

| Category | Items | Avg Importance | Avg Popularity |
|----------|-------|----------------|----------------|
| stroke | 13 | 87 | 76 |
| aim | 13 | 88 | 76 |
| bridge | 27 | 76 | 68 |
| stance | 20 | 77 | 68 |
| cue_ball | 7 | 93 | 78 |
| bank | 8 | 84 | 67 |
| kick | 6 | 82 | 64 |
| jump | 5 | 79 | 61 |
| table_reading | 6 | 83 | 67 |
| safety | 5 | 85 | 71 |
| pattern | 5 | 91 | 76 |
| match_strategy | 8 | 89 | 73 |
| gap_analysis | 9 | 81 | 63 |
| mental | 4 | 89 | 72 |
| grip | 1 | 88 | 85 |

---

## Common Follow-up Topic Patterns

### Fundamentals → Technique

| After Learning | Common Next Topics |
|---------------|-------------------|
| stroke.fundamentals | stroke.straight_stroke, bridge.fundamentals |
| aim.fundamentals | aim.ghost_ball, aim.center_ball |
| bridge.fundamentals | bridge.open_bridge, bridge.closed_bridge |
| stance.fundamentals | stance.foot_position, stance.balance |

### Basic → Advanced

| After Learning | Common Next Topics |
|---------------|-------------------|
| cue_ball.stop_ball | cue_ball.draw, cue_ball.follow |
| cue_ball.draw | cue_ball.follow, cue_ball.english |
| bank.one_rail_bank | bank.two_rail_bank, bank.speed_bank |
| kick.one_rail_kick | kick.two_rail_kick, safety.kick_safety |

### Technique → Mastery

| After Learning | Common Next Topics |
|---------------|-------------------|
| stroke.accuracy | stroke.mechanics_mastery |
| cue_ball.english | cue_ball.multi_dimensional |
| aim.shot_selection | aim.percentage_play |
| safety.safety_battle | safety.mastery |

---

## Time Estimates Summary

### By Level

| Level | Avg Reading (min) | Avg Practice (min) | Total Hours |
|-------|-------------------|---------------------|-------------|
| I | 4 | 45 | 0.8 |
| H | 4 | 60 | 1.1 |
| G | 5 | 120 | 2.1 |
| F | 5.5 | 180 | 3.1 |
| E | 6 | 300 | 5.1 |
| D | 7 | 400 | 6.8 |
| C | 8 | 480 | 8.1 |

### By Category

| Category | Avg Reading (min) | Avg Practice (min) |
|----------|-------------------|-------------------|
| stroke | 5.5 | 250 |
| aim | 5.5 | 240 |
| cue_ball | 6 | 280 |
| bank | 5 | 240 |
| kick | 5 | 240 |
| jump | 5 | 240 |
| safety | 5 | 200 |
| pattern | 6 | 300 |
| match_strategy | 6 | 260 |
| gap_analysis | 5.5 | 200 |
| mental | 5.5 | 300 |

---

## Recommendation Engine Usage

### For New Users

1. Start with fundamentals (level I-H)
2. Prioritize high importance + high popularity
3. Follow recommended next topics
4. Practice until intermediate level before moving on

### For Intermediate Users

1. Identify weak areas
2. Focus on medium importance items not yet learned
3. Fill gaps before advancing
4. Track progress with gap_analysis tools

### For Advanced Users

1. Focus on high importance, lower popularity items
2. Practice mastery-level skills
3. Use gap_analysis for targeted improvement
4. Mentally rehearse skills not physically practiced

### For Elite Users

1. Complete remaining advanced skills
2. Focus on mastery and integration
3. Use gap_analysis for fine-tuning
4. Develop personal style with learned techniques

---

*Generated: 2026-07-17*
*Pool OS Knowledge Base v1.0*
