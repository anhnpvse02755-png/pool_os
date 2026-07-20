# Recommendation Service Specification

## Overview

**Document Date:** 2026-07-17  
**Component:** Recommendation Service  
**Type:** Rule-based Algorithm (No AI)  
**Status:** Algorithm Design Only

---

## Purpose

The Recommendation Service provides contextual recommendations based on:
- Current knowledge item being viewed
- Player's current skill level
- Training goals
- Historical progress

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Recommendation System                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                     INPUTS                                        │   │
│   │  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐  │   │
│   │  │  Current Item    │ │  Player Profile  │ │  Training Goal  │  │   │
│   │  │  (KnowledgeItem) │ │  (level, skills) │ │  (objective)    │  │   │
│   │  └──────────────────┘ └──────────────────┘ └──────────────────┘  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │              RECOMMENDATION ENGINE                                  │   │
│   │                                                                  │   │
│   │   ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │   │
│   │   │  Graph Walker   │  │  Priority Calc  │  │  Rule Matcher  │  │   │
│   │   │                 │  │                 │  │                │  │   │
│   │   │  • Prereqs     │  │  • Score calc   │  │  • Level match │  │   │
│   │   │  • Dependents  │  │  • Weight apply │  │  • Goal align  │  │   │
│   │   │  • Related     │  │  • Sort         │  │  • Prereq sat │  │   │
│   │   └─────────────────┘  └─────────────────┘  └────────────────┘  │   │
│   │                                                                  │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                              │                                           │
│                              ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                     OUTPUTS                                       │   │
│   │  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐  │   │
│   │  │  Related Items  │ │  Recommended      │ │  Next Skills     │  │   │
│   │  │  (ranked)       │ │  Drills (ranked)  │ │  (ranked)        │  │   │
│   │  └──────────────────┘ └──────────────────┘ └──────────────────┘  │   │
│   │  ┌──────────────────────────────────────────────────────────────┐ │   │
│   │  │  Learning Paths (ranked)                                    │ │   │
│   │  └──────────────────────────────────────────────────────────────┘ │   │
│   └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Input Models

### Current Knowledge Item

```dart
class CurrentContext {
  final KnowledgeItem? currentItem;
  final KnowledgeType? currentType;
  final KnowledgeDifficulty? currentDifficulty;
  final String? currentCategory;
}
```

### Player Profile

```dart
class PlayerProfile {
  final String id;
  final String currentLevel;              // H, G, F, E, D, C, B, A, Pro
  final Set<String> strengthAreas;        // Categories player is good at
  final Set<String> weaknessAreas;        // Categories player needs work
  final Set<String> completedItems;       // Already learned knowledge IDs
  final Set<String> completedDrills;      // Already practiced drill codes
  final int practiceHoursPerWeek;
  final String preferredGameType;         // 8-ball, 9-ball, 10-ball, straight
  final Set<String> goals;               // What player wants to improve
}
```

### Training Goal

```dart
enum TrainingGoal {
  // Primary goals
  improveAccuracy,       // Get better at pocketing balls
  improvePosition,       // Get better at cue ball control
  improveBreak,          // Improve break effectiveness
  improveSafety,         // Better defensive play
  learnNewShot,          // Master a specific technique
  fixCommonMistakes,     // Address specific weaknesses
  
  // Contextual goals
  prepareForTournament,   // General tournament prep
  warmUp,                 // Quick warm-up routine
  coolDown,              // End of session
  assessWeaknesses,       // Find areas to improve
  
  // Level-specific goals
  advanceToNextLevel,     // Level up
  maintainSkill,           // Keep current level
  masterFundamentals,      // Beginner to intermediate
}

class GoalContext {
  final TrainingGoal primaryGoal;
  final List<TrainingGoal> secondaryGoals;
  final Duration? timeBudget;            // How long for this session
  final bool isUrgent;                   // Time-sensitive
}
```

---

## Output Models

### Recommendation

```dart
enum RecommendationType {
  relatedKnowledge,
  recommendedDrill,
  nextSkill,
  learningPath,
}

class Recommendation {
  final String id;
  final RecommendationType type;
  
  // What to recommend
  final dynamic item;              // KnowledgeItem, Drill, LearningPath
  final String title;
  final String titleVi;
  
  // Priority
  final double priority;           // 0.0 - 1.0
  final int priorityRank;         // 1, 2, 3, ...
  
  // Reasoning
  final String reason;
  final List<String> reasonFactors;
  
  // Context
  final double estimatedGain;      // Skill improvement estimate
  final int estimatedMinutes;      // Time to complete
  final bool isRequired;          // Prerequisite (can't skip)
}
```

### Recommendation Set

```dart
class RecommendationSet {
  final List<Recommendation> relatedKnowledge;
  final List<Recommendation> recommendedDrills;
  final List<Recommendation> nextSkills;
  final List<Recommendation> learningPaths;
  
  final String contextSummary;
  final Duration totalEstimatedTime;
}
```

---

## Algorithm

### Priority Calculation

```
Priority Score = Base Score × Context Multipliers × Prerequisite Modifier
```

#### Base Score (0-100)

| Factor | Score | Description |
|--------|-------|-------------|
| Relevance to current item | 0-30 | Graph distance from current |
| Player level match | 0-25 | Difficulty matches player |
| Goal alignment | 0-20 | Matches training goal |
| Weakness address | 0-15 | Addresses player weakness |
| Freshness | 0-10 | Not recently completed |

#### Context Multipliers

| Context | Multiplier | Reason |
|---------|------------|--------|
| Vietnamese content available | ×1.2 | Better user understanding |
| Drill has video | ×1.15 | Easier to learn |
| Item is popular | ×1.1 | Proven effective |
| Quick completion possible | ×1.1 | Time efficient |

#### Prerequisite Modifier

| Status | Modifier | Reason |
|--------|----------|--------|
| Prerequisite satisfied | ×1.0 | Ready to learn |
| Partial prerequisites | ×0.7 | Some gaps remain |
| Missing prerequisites | ×0.3 | Needs other items first |
| Is prerequisite | ×1.5 | Required for current goal |

---

### Rule Set

#### Rule 1: Current Item Context

When viewing a knowledge item:

```
IF current_item exists:
  1. Get prerequisites → Recommend (if not completed)
  2. Get related items → Score by graph distance
  3. Get next recommended → High priority
  4. Get drills for current item → Primary drill recommendations
  5. Get learning path containing item → Show path context
```

#### Rule 2: Level-Based Recommendations

```
IF player_level == "H" (Beginner):
  → Prioritize: fundamentals, stance, grip, basic shots
  → Avoid: complex english, advanced position play
  
IF player_level == "G" (Intermediate):
  → Prioritize: position play, basic english, pattern play
  → Avoid: pro-level safety play
  
IF player_level == "F" (Advanced):
  → Prioritize: advanced english, safety, complex patterns
  → Include: beginner review for bad habits
```

#### Rule 3: Goal-Based Recommendations

| Goal | Priority 1 | Priority 2 | Priority 3 |
|------|------------|-----------|-----------|
| `improve_accuracy` | Aim fundamentals | Basic drills | Common mistakes |
| `improve_position` | Cue ball control | Position play | Pattern reading |
| `improve_break` | Break technique | Break drills | Table analysis |
| `improve_safety` | Safety basics | Safety drills | Legal shot rules |
| `learn_new_shot` | Target technique | Related drills | Common errors |
| `fix_mistakes` | Mistake article | Correction drills | Prevention tips |

#### Rule 4: Weakness-Based Recommendations

```
IF weakness_areas contains category:
  → Add +15 to items in that category
  → Add +10 to drills for that category
  → Include mistake articles for that area
```

#### Rule 5: Prerequisite Chain

```
FOR each item in recommendations:
  1. Check prerequisites
  2. IF prerequisites not completed:
     → Add prerequisite items to list (high priority)
     → Mark current item as "requires_prereqs"
  3. Sort so prerequisites appear first
```

#### Rule 6: Drill Selection

```
FOR each drill in candidate_drills:
  1. Check difficulty match to player level
  2. Check if already completed (reduce priority)
  3. Check if drill practices current weakness
  4. Calculate priority score
  5. Sort by score descending
```

---

## Detailed Algorithm Steps

### Step 1: Collect Candidates

```dart
List<dynamic> collectCandidates(
  CurrentContext context,
  PlayerProfile profile,
) {
  final candidates = <dynamic>[];
  
  // From current item context
  if (context.currentItem != null) {
    candidates.addAll(_getPrerequisites(context.currentItem));
    candidates.addAll(_getRelatedItems(context.currentItem));
    candidates.addAll(_getDrillsFor(context.currentItem));
    candidates.addAll(_getLearningPaths(context.currentItem));
  }
  
  // From weakness areas
  for (final weakness in profile.weaknessAreas) {
    candidates.addAll(_getItemsByCategory(weakness));
    candidates.addAll(_getDrillsByCategory(weakness));
  }
  
  // From goal alignment
  candidates.addAll(_getItemsForGoal(profile.goals));
  
  return candidates.toSet().toList();
}
```

### Step 2: Calculate Base Priority

```dart
double calculateBasePriority(
  dynamic candidate,
  CurrentContext context,
  PlayerProfile profile,
  GoalContext goal,
) {
  double score = 50; // Start at middle
  
  // Factor 1: Current item relevance (0-30)
  if (context.currentItem != null) {
    final distance = _getGraphDistance(context.currentItem, candidate);
    score += _distanceToScore(distance);
  }
  
  // Factor 2: Level match (0-25)
  final difficulty = _getDifficulty(candidate);
  score += _levelMatchScore(profile.currentLevel, difficulty);
  
  // Factor 3: Goal alignment (0-20)
  score += _goalAlignmentScore(candidate, goal);
  
  // Factor 4: Weakness address (0-15)
  if (_addressesWeakness(candidate, profile.weaknessAreas)) {
    score += 15;
  }
  
  // Factor 5: Freshness (0-10)
  if (candidate is KnowledgeItem) {
    if (!profile.completedItems.contains(candidate.id)) {
      score += 10;
    }
  }
  
  return score.clamp(0, 100);
}

double _distanceToScore(int distance) {
  switch (distance) {
    case 0: return 30; // Same item
    case 1: return 25; // Direct relationship
    case 2: return 15; // Related
    case 3: return 5;  // Distant
    default: return 0; // Unrelated
  }
}

double _levelMatchScore(String playerLevel, KnowledgeDifficulty difficulty) {
  final expected = _levelToDifficulty(playerLevel);
  
  if (difficulty == expected) return 25;
  if (difficulty == expected - 1) return 15; // Easier
  if (difficulty == expected + 1) return 20; // Slightly harder
  return 5; // Wrong level
}

KnowledgeDifficulty _levelToDifficulty(String level) {
  switch (level) {
    case 'I': case 'H': return KnowledgeDifficulty.beginner;
    case 'G': case 'F': return KnowledgeDifficulty.intermediate;
    case 'E': case 'D': return KnowledgeDifficulty.advanced;
    default: return KnowledgeDifficulty.professional;
  }
}
```

### Step 3: Apply Context Multipliers

```dart
double applyMultipliers(
  double baseScore,
  dynamic candidate,
  CurrentContext context,
  PlayerProfile profile,
) {
  double score = baseScore;
  
  // Vietnamese content
  if (_hasVietnameseContent(candidate)) {
    score *= 1.2;
  }
  
  // Has media
  if (_hasMedia(candidate)) {
    score *= 1.15;
  }
  
  // Time efficient
  final minutes = _getEstimatedMinutes(candidate);
  if (minutes <= 15) {
    score *= 1.1;
  }
  
  // Already completed (penalize)
  if (_isCompleted(candidate, profile)) {
    score *= 0.3;
  }
  
  return score;
}

bool _hasVietnameseContent(dynamic candidate) {
  if (candidate is KnowledgeItem) {
    return candidate.titleVi.isNotEmpty;
  }
  return false;
}

bool _hasMedia(dynamic candidate) {
  if (candidate is KnowledgeItem) {
    return candidate.media.hasAny;
  }
  if (candidate is Drill) {
    return true; // Drills assumed to have video
  }
  return false;
}
```

### Step 4: Check Prerequisite Status

```dart
PrerequisiteStatus checkPrerequisites(
  KnowledgeItem item,
  PlayerProfile profile,
) {
  if (item.prerequisites.isEmpty) {
    return PrerequisiteStatus.satisfied;
  }
  
  int satisfiedCount = 0;
  for (final prereqId in item.prerequisites) {
    if (profile.completedItems.contains(prereqId)) {
      satisfiedCount++;
    }
  }
  
  final total = item.prerequisites.length;
  final ratio = satisfiedCount / total;
  
  if (ratio == 1.0) return PrerequisiteStatus.satisfied;
  if (ratio >= 0.5) return PrerequisiteStatus.partial;
  return PrerequisiteStatus.missing;
}

double getPrerequisiteModifier(PrerequisiteStatus status) {
  switch (status) {
    case PrerequisiteStatus.satisfied: return 1.0;
    case PrerequisiteStatus.partial: return 0.7;
    case PrerequisiteStatus.missing: return 0.3;
  }
}
```

### Step 5: Build Final Recommendations

```dart
RecommendationSet buildRecommendations(
  CurrentContext context,
  PlayerProfile profile,
  GoalContext goal,
) {
  final candidates = collectCandidates(context, profile, goal);
  final recommendations = <Recommendation>[];
  
  for (final candidate in candidates) {
    final baseScore = calculateBasePriority(candidate, context, profile, goal);
    final multipliedScore = applyMultipliers(baseScore, candidate, context, profile);
    
    PrerequisiteStatus prereqStatus = PrerequisiteStatus.satisfied;
    if (candidate is KnowledgeItem) {
      prereqStatus = checkPrerequisites(candidate, profile);
    }
    
    final finalScore = multipliedScore * getPrerequisiteModifier(prereqStatus);
    
    recommendations.add(Recommendation(
      id: _getId(candidate),
      type: _getType(candidate),
      item: candidate,
      title: _getTitle(candidate),
      titleVi: _getTitleVi(candidate),
      priority: finalScore,
      reason: _generateReason(candidate, context, profile, goal),
      reasonFactors: _getReasonFactors(candidate, context, profile, goal),
      estimatedGain: _estimateGain(candidate, profile),
      estimatedMinutes: _getEstimatedMinutes(candidate),
      isRequired: prereqStatus == PrerequisiteStatus.missing,
    ));
  }
  
  // Sort by priority
  recommendations.sort((a, b) => b.priority.compareTo(a.priority));
  
  // Assign ranks
  for (int i = 0; i < recommendations.length; i++) {
    recommendations[i].priorityRank = i + 1;
  }
  
  // Group by type
  return _groupByType(recommendations);
}
```

---

## Recommendation Generation Examples

### Example 1: Viewing "Draw Shot"

**Context:**
- Current item: `shot.draw.fundamentals`
- Player level: G (Intermediate)
- Goal: `improve_position`
- Weaknesses: `cue_ball_control`

**Recommendations:**

| Type | Title | Priority | Reason |
|------|-------|----------|--------|
| Related | Stop Shot | 95 | Prerequisite, positions together |
| Related | Follow Shot | 88 | Related technique |
| Drill | Draw Shot Practice | 92 | Matches goal, addresses weakness |
| Drill | Cue Ball Control Drills | 87 | Weakness area |
| Next | English Basics | 75 | Next in progression |
| Path | Position Mastery Path | 70 | Contains this skill |

### Example 2: Beginner with Weakness in Aiming

**Context:**
- Player level: H (Beginner)
- Weaknesses: `aim`
- Goal: `improve_accuracy`

**Recommendations:**

| Type | Title | Priority | Reason |
|------|-------|----------|--------|
| Related | Aiming Fundamentals | 98 | Directly addresses weakness |
| Drill | Center Ball Practice | 95 | Beginner appropriate |
| Related | Stance Basics | 85 | Prerequisite for aiming |
| Drill | Basic Aim Practice | 90 | Beginner drills |
| Path | Complete Beginner Path | 80 | Includes aiming fundamentals |

### Example 3: Tournament Preparation

**Context:**
- Player level: F (Advanced)
- Goal: `prepareForTournament`

**Recommendations:**

| Type | Title | Priority | Reason |
|------|-------|----------|--------|
| Related | Legal Shot Rules | 95 | Tournament critical |
| Drill | Safety Practice | 90 | Tournament strategy |
| Related | Break Tactics | 88 | Tournament start |
| Drill | Advanced Position Drills | 85 | Tournament prep |
| Path | Tournament Ready Path | 82 | Comprehensive prep |

---

## Service Interface

```dart
/// Recommendation service interface.
/// Uses rule-based algorithm, no AI.
abstract class RecommendationService {
  /// Get complete recommendation set
  Future<RecommendationSet> getRecommendations({
    required PlayerProfile profile,
    required GoalContext goal,
    KnowledgeItem? currentItem,
  });
  
  /// Get related knowledge only
  Future<List<Recommendation>> getRelatedKnowledge({
    required KnowledgeItem current,
    required PlayerProfile profile,
  });
  
  /// Get recommended drills
  Future<List<Recommendation>> getRecommendedDrills({
    required KnowledgeItem? current,
    required PlayerProfile profile,
    required GoalContext goal,
  });
  
  /// Get next skills to learn
  Future<List<Recommendation>> getNextSkills({
    required KnowledgeItem current,
    required PlayerProfile profile,
  });
  
  /// Get learning paths
  Future<List<Recommendation>> getLearningPaths({
    required PlayerProfile profile,
    required GoalContext goal,
  });
  
  /// Get single recommendation for quick action
  Future<Recommendation?> getTopRecommendation({
    required PlayerProfile profile,
    required GoalContext goal,
    required RecommendationType type,
  });
}
```

---

## Implementation Notes

### Caching

- Player profile: Refresh on app launch or profile change
- Recommendations: Generate on-demand, cache for session
- Graph traversal: Memoize prerequisite chains

### Performance

- Graph distance: BFS with max depth 3
- Candidate collection: Limit to 50 items
- Priority calculation: Parallel where possible

### Testing

- Rule coverage: Test each rule in isolation
- Edge cases: Empty profile, missing prerequisites
- Priority consistency: Verify ranking is stable

---

## Future Enhancements

| Feature | Priority | Status |
|---------|----------|--------|
| Spaced repetition | HIGH | Future |
| Time-of-day patterns | MEDIUM | Future |
| Streak-based boosts | MEDIUM | Future |
| Social recommendations | LOW | Future |
| ML-based ranking | LOW | Future (optional) |

---

*Generated: 2026-07-17*
*Recommendation Service Specification v1.0*
