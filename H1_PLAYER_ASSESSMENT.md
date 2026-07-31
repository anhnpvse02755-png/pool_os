# H1 — Player Assessment & Personalized Learning Journey

Status: Design Draft
Author: Engineering
Date: 2026-07-31
Source: PO Product Direction

---

## §1 — Concept

Player Assessment is the **trigger mechanism** for the entire Pool OS ecosystem.

Without it:
- A new user opens the app and sees no personalized path
- Knowledge exists but has no context
- AI Coach has no player data to analyze
- Statistics has no baseline
- The entire ecosystem is dormant

With it:
- User completes 2-3 min conversation
- AI determines real level (Beginner → K → I → H → G → F)
- AI generates personalized Learning Path immediately
- All 6 EPICs activate with player context
- Ecosystem delivers value from the first launch

**This is H1's Deliverable 0 — the gateway to all other H1 work.**

---

## §2 — User Flow

```
First Launch / New Player
  ↓
Onboarding: Explain Ranking System
  ↓
Player Assessment (15-20 questions)
  ↓
AI Assessment Result
  ├── Estimated Level: K (with confidence: 82%)
  ├── Explain Why: {reasons}
  └── Recommended Learning Path
  ↓
Personalized Dashboard
  ├── My Learning Path (auto-generated)
  ├── AI Coach (with player context)
  ├── Training (with personalized drills)
  └── Statistics (baseline established)
  ↓
Continuous Reassessment
  ├── Every 100 racks
  ├── Every 20 training sessions
  └── Or: player requests reassessment
```

---

## §3 — Assessment Questions Data Model

```dart
class AssessmentQuestion {
  final String id;
  final String questionEn;
  final String questionVi;
  final QuestionCategory category; // background | skills | performance | goal
  final QuestionType type;       // multipleChoice | binary | scale
  final List<AnswerOption> options;
  final String? helpTextEn;
  final String? helpTextVi;
}

class AnswerOption {
  final String value;       // e.g., "never", "10h", "100h"
  final int score;          // used to calculate level
  final String labelEn;
  final String labelVi;
  final String? followUpQuestionId; // conditional branching
}

enum QuestionCategory {
  background,   // Part 1 — have you played, how often, tournaments
  skills,       // Part 2 — Open Bridge, Stop Shot, Draw, Bank, Safety
  performance,  // Part 3 — balls run, why do you lose
  goal,         // Part 4 — what do you want to achieve
}
```

### Sample Questions (from PO direction)

#### Part 1 — Background (3 questions)

| ID | Question | Options |
|---|---|---|
| Q1 | Have you played Pool before? | Never / Under 10 hours / Under 100 hours / Over 100 hours |
| Q2 | How often do you play? | Never / Occasionally / Weekends / Weekly / Daily |
| Q3 | Have you joined a tournament? | No / Yes |

#### Part 2 — Skills (8 questions)

| ID | Question | Options |
|---|---|---|
| Q4 | Do you know Open Bridge? | No / Yes |
| Q5 | Do you know Closed Bridge? | No / Yes |
| Q6 | Do you know Rail Bridge? | No / Yes |
| Q7 | Do you know Stop Shot? | No / Yes |
| Q8 | Do you know Follow Shot? | No / Yes |
| Q9 | Do you know Draw Shot? | No / Yes |
| Q10 | Do you know Bank Shot? | No / Yes |
| Q11 | Do you know Safety? | No / Yes |
| Q12 | Do you know Pattern Play? | No / Yes |

#### Part 3 — Performance (2 questions)

| ID | Question | Options |
|---|---|---|
| Q13 | How many balls can you typically run? | 1 / 2 / 3 / 5 / 5+ |
| Q14 | Why do you usually lose? | Aim / Position / Psychology / Stroke / Don't know |

#### Part 4 — Goal (1 question)

| ID | Question | Options |
|---|---|---|
| Q15 | What is your goal? | Learn to play / Play well / Beat friends / Join tournaments / Reach G / Reach F |

**Total: 15 questions (within PO's 15-20 range)**

---

## §4 — Assessment Result Model

```dart
class AssessmentResult {
  final String playerId;
  final PlayerLevel estimatedLevel;
  final int confidencePercent;  // 0-100
  final List<String> reasons;   // e.g., "✓ Knows the rules", "✓ Can pot 2 balls"
  final List<String> gaps;     // e.g., "✗ No position play", "✗ No safety knowledge"
  final LearningPath initialPath;
  final DateTime assessedAt;
  final AssessmentVersion version;
}

enum PlayerLevel {
  beginner,  // Never played
  k,        // Played but no fundamentals
  i,        // Rank I
  h,        // Rank H
  g,        // Rank G
  f,        // Rank F+
}

class LearningPath {
  final String id;
  final String title;
  final PlayerLevel targetLevel;
  final List<LearningPhase> phases;
  // ... existing LearningPath model from EPIC 05
}
```

### Result Example

```
Estimated Level: K
Confidence: 82%

Why K:
✓ Knows how to hold the cue
✓ Knows basic rules
✓ Can pot 1-2 balls occasionally
✗ No position play
✗ No Stop Shot
✗ No Draw Shot
✗ No Safety knowledge

Recommended Starting Point: K Level Learning Path
Lessons: Bridge Fundamentals → Grip → Stance → Stroke → Straight Shot → Stop Shot → Follow Shot
```

---

## §5 — AI Assessment Logic

### Scoring Algorithm

```dart
int calculateScore(List<AnswerResponse> answers) {
  int score = 0;
  for (final answer in answers) {
    score += answer.selectedOption.score;
  }
  return score;
}

PlayerLevel determineLevel(int score, List<String> skillsAnswered) {
  // Score ranges (calibrated with PO)
  if (score < 10) return PlayerLevel.beginner;
  if (score < 20 && skillsAnswered.length < 3) return PlayerLevel.k;
  if (score < 25 && skillsAnswered.length < 5) return PlayerLevel.k;
  if (score < 30 && skillsAnswered.length < 7) return PlayerLevel.i;
  if (score < 40) return PlayerLevel.h;
  if (score < 50) return PlayerLevel.g;
  return PlayerLevel.f;
}

int calculateConfidence(List<AnswerResponse> answers) {
  // Higher confidence when:
  // - Clear patterns in answers (all skills "yes" or all "no")
  // - Performance data consistent with skill level
  // - Goal is realistic for stated level
  int confidence = 60;
  if (_answersAreConsistent(answers)) confidence += 20;
  if (_performanceMatchesSkills(answers)) confidence += 15;
  if (_goalMatchesLevel(answers)) confidence += 5;
  return confidence.clamp(0, 100);
}
```

### AI Coach Integration

The actual level determination + reasoning is done by AI Coach (EPIC 06).
This is NOT a separate AI — it uses the existing Coach infrastructure.

```dart
class AssessmentContext {
  final String playerId;
  final List<AnswerResponse> answers;
  final DateTime assessedAt;
}

// AI Coach receives this and returns AssessmentResult
Future<AssessmentResult> runPlayerAssessment(AssessmentContext context) {
  // 1. Score answers
  // 2. Determine level with reasoning
  // 3. Identify gaps
  // 4. Generate personalized Learning Path
  // 5. Return AssessmentResult
}
```

---

## §6 — Auto-Generated Learning Path

### Path Generation Algorithm

```dart
LearningPath generatePath(PlayerLevel level, List<String> gaps) {
  // 1. Start from level's base path (from learning_paths.json)
  // 2. Filter out items the player already knows
  // 3. Prioritize gaps identified in assessment
  // 4. Add prerequisites
  // 5. Return personalized path
}

class PersonalizedPhase {
  final int order;
  final String lessonId;
  final String title;
  final bool completed;     // false for new players
  final bool locked;        // true until prerequisites met
  final String? drillRef;   // linked drill from H1 data
  final String? videoRef;   // linked video with chapter markers
}
```

### Example: K Level Path

```
My Learning Path — K Level

Phase 1: Foundation (start here)
├── Lesson: Bridge Fundamentals          [drill: BRIDGE001]
├── Lesson: Grip & Stance               [drill: GRIP001]
├── Lesson: Basic Stroke                [drill: STROKE001]
└── Lesson: Straight Shot                [drill: STRAIGHT001]

Phase 2: First Shots
├── Lesson: Stop Shot                   [drill: STOP001]       ← GAP identified
├── Lesson: Follow Shot                 [drill: FOLLOW001]    ← GAP identified
└── Lesson: Cut Shot Introduction       [drill: CUT001]

Phase 3: Control
├── Lesson: Speed Control               [drill: SPEED001]
├── Lesson: Cue Ball Position           [drill: POS001]
└── Lesson: Natural Angle               [drill: ANGLE001]

Locked: I Level content (complete K first)
```

---

## §7 — Re-assessment Trigger

### Automatic Triggers

```dart
class ReassessmentTrigger {
  final TriggerType type;
  final int threshold;
  final DateTime? lastAssessment;

  static const racksTrigger = 100;      // every 100 racks played
  static const sessionsTrigger = 20;    // every 20 training sessions
}

// In Statistics Engine (EPIC 02)
Future<void> checkReassessmentTrigger(String playerId) async {
  final stats = await statisticsEngine.getPlayerStats(playerId);
  if (stats.totalRacks >= 100) {
    await _promptReassessment(playerId, reason: '100 racks completed');
  }
  if (stats.trainingSessions >= 20) {
    await _promptReassessment(playerId, reason: '20 sessions completed');
  }
}
```

### Reassessment UI

```
┌─────────────────────────────────────────┐
│  Congratulations!                        │
│                                         │
│  Based on your recent performance,       │
│  AI recommends reassessing your level.   │
│                                         │
│  Your last assessment: K (82% confidence)│
│  Racks played: 127                      │
│  Training sessions: 24                   │
│                                         │
│  [Take Reassessment]  [Maybe Later]      │
└─────────────────────────────────────────┘
```

### Reassessment Result Example

```
Congratulations!

AI has analyzed your last 100 racks and 20 training sessions.

Improvements detected:
✓ Stop Shot accuracy: 45% → 72%
✓ Position play: emerging
✓ Pattern recognition: improving

Recommendation: Promote from K → I

Your new Learning Path:
├── I Level content unlocked
├── Focus: Position Play & Draw Shot
└── Drills adjusted to I Level
```

---

## §8 — Integration with Existing Systems

### Data Flow

```
┌──────────────────────────────────────────────────────┐
│                  PLAYER ASSESSMENT                     │
└──────────────────────┬───────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   ┌─────────┐   ┌──────────┐   ┌──────────┐
   │Knowledge│   │AI Coach  │   │Training  │
   │  (H1)   │   │ (EPIC 06)│   │ (EPIC 03)│
   └────┬────┘   └─────┬────┘   └────┬────┘
        │               │              │
        └───────────────┼──────────────┘
                        ▼
               ┌─────────────────┐
               │  Statistics     │
               │   (EPIC 02)     │
               └────────┬────────┘
                        │
              ┌─────────┴─────────┐
              ▼                   ▼
         Re-assessment        Dashboard
           Trigger            (personalized)
```

### No New Data Ownership

- Assessment questions: stored in app assets (read-only)
- Assessment results: owned by Player/Statistics (EPIC 02)
- Learning paths: owned by Knowledge (EPIC 05)
- Drills: owned by Training (EPIC 03)
- AI reasoning: owned by AI Coach (EPIC 06)

**Assessment orchestrates — it doesn't own data.**

---

## §9 — Engineering Scope

### What Engineering Builds

| Component | Scope |
|---|---|
| `assessment_questions.json` | Data file with 15 questions |
| `assessment_question_model.dart` | Dart model for questions |
| `assessment_result_model.dart` | Dart model for results |
| `assessment_service.dart` | Orchestrator (calls AI Coach) |
| `assessment_ui.dart` | Onboarding screens (Flutter) |
| `reassessment_trigger.dart` | Auto-trigger logic |
| `reassessment_ui.dart` | Reassessment prompt screens |

### What Uses Existing Systems

| Integration | Existing System |
|---|---|
| Level determination | AI Coach (EPIC 06) |
| Learning path generation | Knowledge Learning Paths (EPIC 05) |
| Drill references | Training System (EPIC 03) |
| Rack counting | Statistics Engine (EPIC 02) |
| Session counting | Training System (EPIC 03) |

### Schema Changes Needed

1. **Add `chapterMarkers` to VideoEntry** (H1 Knowledge gap)
2. **Extend `difficulty` to 6 levels** (H1 Knowledge gap)
3. **Player profile**: add `assessmentResultId`, `currentLevel`, `lastAssessedAt`

---

## §10 — First Launch UX

### Screen 1: Welcome

```
┌─────────────────────────────────────────┐
│                                         │
│           🎱  Welcome to PoolOS          │
│                                         │
│   Before we start, let's understand      │
│   your experience level so we can      │
│   create a personalized learning path    │
│   just for you.                          │
│                                         │
│   This takes about 2-3 minutes.          │
│   It's not a test — just a chat!       │
│                                         │
│   [Start Assessment]                     │
│                                         │
└─────────────────────────────────────────┘
```

### Screen 2: Ranking Explanation

```
┌─────────────────────────────────────────┐
│  How PoolOS Rankings Work                │
│                                         │
│  PoolOS uses a simple reference scale:  │
│                                         │
│  Beginner                               │
│       ↓                                 │
│       K  (beginner, some experience)    │
│       ↓                                 │
│       I  (Rank I)                       │
│       ↓                                 │
│       H  (Rank H)                       │
│       ↓                                 │
│       G  (Rank G)                       │
│       ↓                                 │
│       F  (Rank F+)                      │
│                                         │
│  This is NOT a national or club        │
│  standard. It's just for reference.    │
│  You can adjust it later.              │
│                                         │
│   [I Understand]                        │
│                                         │
└─────────────────────────────────────────┘
```

### Screen 3: Questions (scrollable)

```
┌─────────────────────────────────────────┐
│  Question 3 of 15                       │
│  ████████░░░░░░░░░░░  20%             │
│                                         │
│  Have you joined a tournament before?    │
│                                         │
│  ○ No                                   │
│  ○ Yes                                  │
│                                         │
│  [← Back]                [Next →]        │
│                                         │
└─────────────────────────────────────────┘
```

### Screen 4: Results

```
┌─────────────────────────────────────────┐
│                                         │
│     🎯  Your Level: K                   │
│                                         │
│     Confidence: 82%                      │
│                                         │
│  ─────────────────────────────────────   │
│                                         │
│  Why K:                                  │
│  ✓ Knows how to hold the cue           │
│  ✓ Knows basic rules                   │
│  ✓ Can pot 1-2 balls occasionally      │
│  ✗ No position play                     │
│  ✗ No Stop Shot                         │
│  ✗ No Draw Shot                         │
│  ✗ No Safety knowledge                  │
│                                         │
│  ─────────────────────────────────────   │
│                                         │
│  Your Learning Path is ready!            │
│                                         │
│  [View My Learning Path →]               │
│                                         │
└─────────────────────────────────────────┘
```

---

## §11 — Deliverables (H1 — Priority 0)

Since Assessment is the gateway to all H1 value:

| # | Deliverable | Priority | Status |
|---|---|---|---|
| 0 | Player Assessment (onboarding + 15 questions) | **HIGHEST** | Pending PO approval |
| 1 | Level System Restructure (Beginner→K→I→H→G→F) | HIGH | Pending (blocks Assessment) |
| 2 | Video chapterMarkers (schema change) | HIGH | Pending |
| 3 | Learning Path Quality Audit | MEDIUM | Pending |
| 4 | Relationship Audit (broken links, duplicates) | MEDIUM | Pending |
| 5 | Re-assessment Trigger (100 racks / 20 sessions) | HIGH | After Assessment |
| 6 | Search Quality Audit | LOW | Pending |

---

## §12 — Decision Required from PO

1. **Assessment → AI Coach or Rule-based?**
   - Option A: AI Coach generates reasoning (requires AI integration now)
   - Option B: Rule-based scoring + AI Coach explains (faster to implement)

2. **15 questions or adjust?**
   - Current draft: 15 questions
   - PO's examples suggest this is the right count

3. **Start with K→I→H or full Beginner→F?**
   - H1 Beta likely focuses on K→I→H (primary user segment)
   - Full Beginner→F for later

---

*Design draft by Engineering 2026-07-31. PO Review pending.*
