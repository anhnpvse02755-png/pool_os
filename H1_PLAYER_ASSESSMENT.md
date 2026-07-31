# H1 — Player Journey & Personalized Learning

**⚠️ Status: Conditionally Accepted — 8 revisions required before H1.1**

Full design below. Revision checklist tracked in §11.

---

# §0 — The Correct Mental Model

## ❌ Wrong (current design)

```
Welcome
    ↓
15 questions
    ↓
"You are K"
```

## ✅ Correct (PO direction)

```
Welcome
    ↓
What will PoolOS do for me?
    ↓
How does PoolOS ranking work?
    ↓
Let me discover my level
    ↓
My personalized learning path
    ↓
Dashboard
```

**Assessment is ONE step in the Player Journey, not the whole journey.**

The 3-minute goal: user must feel the app understands them and has a plan for them.

---

# §1 — Player Journey Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    SCREEN 1: WELCOME                        │
│                                                              │
│   🎱  Chào mừng đến với PoolOS                              │
│                                                              │
│   Trước khi bắt đầu, hãy để PoolOS hiểu bạn.             │
│   Chúng tôi sẽ tạo một lộ trình học riêng cho bạn.        │
│                                                              │
│   Mất khoảng 2-3 phút.                                      │
│                                                              │
│                          [Bắt đầu →]                         │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               SCREEN 2: WHAT WILL I GET?                     │
│                                                              │
│   PoolOS sẽ giúp bạn:                                       │
│                                                              │
│   ✓  Xác định trình độ hiện tại của bạn                     │
│                                                              │
│   ✓  Tạo giáo trình học riêng phù hợp với bạn              │
│                                                              │
│   ✓  AI phân tích lối chơi và đưa ra gợi ý cải thiện        │
│                                                              │
│   ✓  Theo dõi tiến bộ qua từng trận đấu                     │
│                                                              │
│   ✓  Đề xuất video và bài tập phù hợp trình độ               │
│                                                              │
│   ✓  Luyện tập mỗi ngày với kế hoạch rõ ràng               │
│                                                              │
│                          [Tiếp tục →]                        │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│          SCREEN 3: HOW DOES RANKING WORK?                   │
│                                                              │
│   PoolOS sử dụng hệ thống phân hạng nội bộ:               │
│                                                              │
│   Beginner  ─  Chưa từng chơi                               │
│        ↓                                                     │
│        K  ─  Biết chơi nhưng chưa có kỹ thuật               │
│        ↓                                                     │
│        I  ─  Có kỹ thuật cơ bản                            │
│        ↓                                                     │
│        H  ─  Người chơi phong trào                          │
│        ↓                                                     │
│        G  ─  Phong trào khá                                 │
│        ↓                                                     │
│        F  ─  Phong trào mạnh                                │
│                                                              │
│   Đây chỉ là thang tham chiếu của PoolOS.                   │
│   Có thể khác với hệ thống ở CLB hoặc quốc gia của bạn.   │
│   Bạn có thể điều chỉnh sau.                                │
│                                                              │
│                          [Tôi hiểu →]                        │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               SCREEN 4: LET'S DISCOVER YOUR LEVEL            │
│                                                              │
│   Trả lời một vài câu hỏi để PoolOS hiểu bạn.             │
│   Không phải bài thi — không có đáp án đúng.                │
│                                                              │
│   Câu 1/12                                                  │
│                                                              │
│   Bạn đã từng chơi Pool chưa?                              │
│                                                              │
│   ○  Chưa bao giờ                                           │
│   ○  Đánh vài lần (xem YouTube / chơi với bạn bè)         │
│   ○  Chơi thường xuyên (hàng tuần hoặc hơn)                │
│                                                              │
│   [← Quay lại]                    [Tiếp →]                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼ ... (12 questions total)
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    SCREEN 5: YOUR LEVEL                     │
│                                                              │
│   🎯  Trình độ của bạn: K                                   │
│                                                              │
│   Confidence: 82%                                           │
│                                                              │
│   ───────────────────────────────────────────────────────   │
│                                                              │
│   PoolOS nhận thấy bạn:                                     │
│                                                              │
│   ✓  Đã biết cách cầm cơ                                   │
│   ✓  Hiểu luật cơ bản                                      │
│   ✓  Đánh được 1-2 bi trong vài trận                       │
│                                                              │
│   ✗  Chưa có kỹ thuật vị trí (position play)                │
│   ✗  Chưa biết Stop Shot                                   │
│   ✗  Chưa kiểm soát được tốc độ                             │
│                                                              │
│   ───────────────────────────────────────────────────────   │
│                                                              │
│   Chỉ cần khoảng 20 giờ luyện tập là bạn có thể đạt I.   │
│   Lộ trình học của bạn đã sẵn sàng.                        │
│                                                              │
│                   [Xem lộ trình của tôi →]                   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               SCREEN 6: MY LEARNING PATH                    │
│                                                              │
│   Lộ trình của bạn — K Level                               │
│                                                              │
│   ┌─ Grip ─────────────────────────────────────────────┐   │
│   │  ✓ Đã hoàn thành                                   │   │
│   └─────────────────────────────────────────────────────┘   │
│                          ↓                                  │
│   ┌─ Bridge ───────────────────────────────────────────┐   │
│   │  ○ Open Bridge                              [Học →] │   │
│   │  ○ Closed Bridge                             [Học →] │   │
│   │  ○ Rail Bridge                              [Học →] │   │
│   └─────────────────────────────────────────────────────┘   │
│                          ↓                                  │
│   ┌─ Kỹ thuật cơ bản ────────────────────────────────┐   │
│   │  ○ Stroke                                [Khoá 🔒]  │   │
│   │  ○ Stop Shot                              [Khoá 🔒]  │   │
│   │  ○ Follow Shot                            [Khoá 🔒]  │   │
│   └─────────────────────────────────────────────────────┘   │
│                          ↓                                  │
│   ┌─ I Level ────────────────────────────────────────┐   │
│   │  🔒 Khoá (hoàn thành K trước)                    │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   [Vào Dashboard →]                                         │
└─────────────────────────────────────────────────────────────┘
```

---

# §2 — The 12 Questions (Beginner Language)

**PO requirement: No jargon. Questions must be answerable by someone who has never played.**

## Part 1 — Background (3 questions)

### Q1: Bạn đã từng chơi Pool chưa?

| Option | Score | Mapping |
|---|---|---|
| Chưa bao giờ | 0 | → Beginner |
| Đánh vài lần (YouTube / bạn bè) | 3 | → Beginner/K |
| Chơi thường xuyên (hàng tuần) | 7 | → K/I |
| Chơi hàng ngày | 10 | → I/H |

### Q2: Khi đánh, bạn thường thua vì?

| Option | Score | Mapping |
|---|---|---|
| Không biết lý do | 0 | → Beginner |
| Aim (ngắm không trúng) | 2 | → K |
| Vị trí (không đến được chỗ mình muốn) | 3 | → K/I |
| Tâm lý (run/áp lực) | 2 | → H/G |
| Tốc độ (đánh nhanh quá / chậm quá) | 2 | → K |

### Q3: Bạn có thể tập trung bao lâu mỗi ngày?

| Option | Score | Note |
|---|---|---|
| 15 phút | 1 | |
| 30 phút | 3 | |
| 1 giờ | 5 | |
| 2 giờ hoặc hơn | 7 | |

## Part 2 — Equipment & Setup (2 questions)

### Q4: Bạn biết cách đặt tay cầm cơ (bridge) không?

| Option | Score | Knowledge ID |
|---|---|---|
| Không biết | 0 | bridge.fundamentals |
| Biết một chút | 2 | bridge.open |
| Thành thạo | 5 | bridge.closed |

### Q5: Tay cầm cơ của bạn đã ổn định chưa?

| Option | Score | Knowledge ID |
|---|---|---|
| Chưa bao giờ để ý | 0 | stroke.fundamentals |
| Đôi khi run | 2 | stroke.fundamentals |
| Khá ổn định | 4 | stroke.fundamentals |

## Part 3 — Shots (5 questions)

### Q6: Bạn có thể đánh thẳng vào lỗ (straight shot) không?

| Option | Score | Knowledge ID |
|---|---|---|
| Chưa bao giờ | 0 | shot.straight |
| Thỉnh thoảng được | 2 | shot.straight |
| Khá ổn (5/10) | 4 | aim.fundamentals |
| Rất ổn (8-9/10) | 6 | aim.ghost_ball |

### Q7: Bạn có biết "dừng bi" (stop shot) không?

| Option | Score | Knowledge ID |
|---|---|---|
| Không biết là gì | 0 | shot.stop |
| Biết nhưng chưa làm được | 2 | shot.stop |
| Làm được nhưng không ổn định | 4 | shot.stop |
| Khá ổn | 6 | shot.stop |

### Q8: Bạn có biết "lên bi" (follow shot) không?

| Option | Score | Knowledge ID |
|---|---|---|
| Không biết | 0 | shot.follow |
| Biết nhưng chưa làm được | 2 | shot.follow |
| Làm được | 4 | shot.follow |

### Q9: Bạn có biết "lùi bi" (draw shot) không?

| Option | Score | Knowledge ID |
|---|---|---|
| Không biết | 0 | shot.draw |
| Biết nhưng chưa làm được | 2 | shot.draw |
| Làm được nhưng không ổn định | 4 | shot.draw |
| Khá ổn | 6 | shot.draw |

### Q10: Bạn có đánh được bi băng (bank shot) chưa?

| Option | Score | Knowledge ID |
|---|---|---|
| Chưa bao giờ | 0 | bank.intro |
| Thử nhưng ít khi được | 2 | bank.intro |
| Làm được 1-2 lần / 10 | 4 | bank.one_rail |
| Khá ổn | 6 | bank.one_rail |

## Part 4 — Position & Tactics (2 questions)

### Q11: Bạn có nghĩ về vị trí bi chủ (cue ball position) sau mỗi cú đánh không?

| Option | Score | Knowledge ID |
|---|---|---|
| Chưa bao giờ nghĩ đến | 0 | position.intro |
| Có nghĩ nhưng không kiểm soát được | 2 | position.intro |
| Cố gắng kiểm soát và làm được đôi khi | 4 | position.intro |
| Thường xuyên kiểm soát được | 6 | position.intro |

### Q12: Bạn có biết "an toàn" (safety) trong Pool là gì không?

| Option | Score | Knowledge ID |
|---|---|---|
| Không biết | 0 | safety.intro |
| Biết nhưng chưa áp dụng | 2 | safety.intro |
| Thỉnh thoảng dùng | 4 | safety.intro |

---

# §3 — Confidence Calibration

**PO requirement: Detect over-estimation and reduce confidence.**

### The Over-estimation Problem

A player who says "I know Draw" + "I know Follow" + "I know Safety" but only runs 1 ball is **likely over-estimating**.

### Calibration Rules

```dart
class ConfidenceCalibrator {
  /// Calculate confidence based on answer consistency
  int calibrate({
    required int rawScore,
    required List<Answer> answers,
  }) {
    int confidence = 60; // base

    // Rule 1: Skill claims vs. performance (Q6 vs Q7-Q10)
    final performanceScore = _sum(answers[5..10]); // Q6-Q12
    final claimedSkills = _count(answers[3..5], selected: true); // Q4-Q5

    if (performanceScore < 5 && claimedSkills >= 3) {
      confidence -= 20; // "I know everything" but can't run balls → over-estimation
    }

    // Rule 2: Hours played vs. skills claimed
    final hoursPlayed = _hoursFrom(answers[0]); // Q1
    if (hoursPlayed < 5 && rawScore > 15) {
      confidence -= 15; // Less than 5 hours but high score → over-estimation
    }

    // Rule 3: Position vs. basic shots
    final positionScore = answers[10].score;
    final basicShotScore = answers[5].score + answers[6].score;
    if (positionScore > basicShotScore) {
      confidence -= 10; // Position better than basic shots → inconsistent
    }

    // Rule 4: Frequency alignment
    final frequency = answers[2].score; // Q3
    if (frequency <= 1 && rawScore > 10) {
      confidence -= 10; // Only 15 min/day but high score → unlikely
    }

    return confidence.clamp(50, 99);
  }
}
```

### Example: Over-estimating Player

```
Q1: "Chơi thường xuyên" → score 7
Q4: "Biết bridge" → score 5
Q5: "Khá ổn định" → score 4
Q6: "Thỉnh thoảng được" → score 2
Q7: "Biết nhưng chưa làm được" → score 2
Q8: "Biết nhưng chưa làm được" → score 2

Raw score: 22 → suggests I level
But: basic shots (Q6-Q10) = low (2+2+2+0 = 6)
Confidence: 60 - 20 (over-claim) - 15 (hours vs score) = 25%
```

**Result: "You are K with 25% confidence. Your answers suggest you may have seen these techniques but can't execute them yet. Let's start with fundamentals."**

---

# §4 — Motivation: Post-Assessment Result

**PO requirement: Show time to next level, not just "You are K."**

### Result Screen Model

```dart
class AssessmentResult {
  final PlayerLevel level;
  final int confidencePercent;
  final List<String> strengths;     // what player already knows
  final List<String> gaps;         // what player doesn't know
  final int estimatedHoursToNextLevel;
  final String motivationalMessage;
  final LearningPath initialPath;
  final List<KnowledgeNode> nextThreeItems;
}
```

### Example: K Level Result

```
Trình độ của bạn: K

Confidence: 82%

─── Bạn đã có ───
✓ Biết cách cầm cơ
✓ Hiểu luật cơ bản
✓ Đánh được 1-2 bi trong vài trận

─── Cần cải thiện ───
✗ Stop Shot (dừng bi)
✗ Follow Shot (lên bi)
✗ Position Play (kiểm soát vị trí)
✗ Speed Control (kiểm soát tốc độ)

─── Tin tốt ───
Chỉ cần khoảng 20 giờ luyện tập là bạn có thể đạt I.
Mỗi ngày 30 phút = khoảng 6 tuần.

─── Lộ trình của bạn đã sẵn sàng ───

[Học ngay →]
```

---

# §5 — Knowledge Graph Learning Path (Not Linear)

**PO requirement: Graph, not a straight list.**

The learning path is a DAG (directed acyclic graph), not a list:

```
Grip (completed)
    │
    ├── Open Bridge ──────────┐
    │        │                │
    │        ├── Closed Bridge ──┤
    │        │                │
    │        └── Rail Bridge ──┘
    │
    └── Stance (independent)
             │
             └── Stroke ────────────────┐
                      │                │
                      ├── Straight Shot ──→ Aiming ──→ Ghost Ball
                      │                │
                      ├── Stop Shot ◄───┘
                      │                │
                      ├── Follow Shot   │
                      │                │
                      └── Draw Shot ◄──┘
```

### How the Graph Generates a Path

```dart
class LearningPathGenerator {
  /// Generate personalized path based on player profile
  List<LearningNode> generate({
    required PlayerLevel level,
    required Set<String> completedSkills,
    required List<String> priorityGaps,
  }) {
    // 1. Get all nodes at current level
    final candidates = graph.nodesAtLevel(level);

    // 2. Filter: only items whose parents are completed
    final ready = candidates.where((n) {
      return n.prerequisites.every((p) => completedSkills.contains(p));
    }).toList();

    // 3. Sort: priority gaps first, then by prerequisite depth
    ready.sort((a, b) {
      final aGap = priorityGaps.contains(a.id) ? 0 : 1;
      final bGap = priorityGaps.contains(b.id) ? 0 : 1;
      if (aGap != bGap) return aGap.compareTo(bGap);
      return a.depth.compareTo(b.depth);
    });

    // 4. Return next 5-7 items as the "current phase"
    return ready.take(7).toList();
  }
}
```

### UI: Graph View

```
┌─────────────────────────────────────────────────────┐
│              Lộ trình của bạn — K Level             │
│                                                     │
│  Grip ──────────── ✓ Đã hoàn thành                 │
│    │                                               │
│    ├── Open Bridge ─ ○ Sẵn sàng học                │
│    │     │                                          │
│    │     ├── Closed Bridge ─ ○ Có thể học          │
│    │     │                                          │
│    │     └── Rail Bridge ─ ○ Có thể học             │
│    │                                               │
│    └── Stance ─────── ✓ Đã hoàn thành               │
│              │                                        │
│              ▼                                        │
│         Stroke ──── ○ Sẵn sàng học                   │
│              │                                        │
│    ┌─────────┼─────────┐                            │
│    ▼         ▼         ▼                            │
│ Stop Shot  Follow    Draw ──────── ○ Đang khoá     │
│    │         │         │                (cần Stop+Follow trước)  │
│    └─────────┴─────────┘                            │
│              │                                        │
│              ▼                                        │
│         Position ──── ○ Đang khoá                   │
│                                                     │
│  [Xem đầy đủ →]                                    │
└─────────────────────────────────────────────────────┘
```

---

# §6 — Video Mapping (Full Pipeline)

**PO requirement: Video → Chapter → Timestamp → Knowledge → Drill → Mistake**

### VideoReference Model

```dart
class VideoChapter {
  final Duration offset;
  final String topic;           // maps to knowledge.skillId
  final String titleEn;
  final String titleVi;
  final String? drillRef;       // linked drill code
  final String? mistakeRef;     // linked mistake code
  final String descriptionEn;
  final String descriptionVi;
}

class VideoReference {
  final String videoId;
  final String channel;
  final Duration startOffset;
  final Duration endOffset;
  final String reason;           // why this segment is relevant
  final String knowledgeId;      // which knowledge this maps to
}
```

### Full Pipeline Example

```
Tor Lowry — Stop Shot Masterclass

├── 00:00 — 02:30  Introduction
│              topic: "introduction"
│
├── 02:31 — 05:15  Grip for Stop Shot
│              topic: "grip"
│              knowledgeId: "grip.fundamentals"
│              drillRef: "GRIP_BASIC"
│
├── 05:16 — 09:42  The Stop Shot Technique
│              topic: "stop_shot_technique"
│              knowledgeId: "shot.stop"
│              drillRef: "STOP_BASIC"
│              mistakeRef: "steering"
│
├── 09:43 — 13:20  Common Mistakes
│              topic: "common_mistakes"
│              mistakeRefs: ["over_swing", "no_cue_ball_control"]
│
└── 13:21 — 15:00  Practice Routine
              topic: "practice"
              knowledgeId: "shot.stop"
              drillRef: "STOP_PRACTICE"
```

### AI Coach Usage

When AI sees the player is struggling with "steering":

```dart
// AI finds relevant video segment
final video = knowledgeGraph.findVideo(
  knowledgeId: "shot.stop",
  mistakeTag: "steering",
);

// AI references specific timestamp
final reference = "Watch 09:43 of Tor Lowry's Stop Shot video — "
    "he explains exactly how to fix steering. "
    "The drill at 13:21 will help you practice.";

// This is specific, actionable, and contextual
```

---

# §7 — Assessment Questions → Knowledge Mapping

**PO requirement: Assessment questions map to specific knowledge items.**

```dart
class AssessmentQuestion {
  final String id;
  final String questionVi;
  final List<AnswerOption> options;
  final List<String> knowledgeIds; // knowledge this question probes
}

class AnswerOption {
  final String labelVi;
  final int score;
  final List<String> demonstratedSkills; // skills this answer shows
  final List<String> missingSkills;       // skills this answer suggests are missing
}
```

### Q7 Mapping: "Bạn có biết 'dừng bi' (stop shot) không?"

```dart
AssessmentQuestion(
  id: "Q7",
  questionVi: "Bạn có biết 'dừng bi' (stop shot) không?",
  knowledgeIds: ["shot.stop"],
  options: [
    AnswerOption(
      labelVi: "Không biết",
      score: 0,
      demonstratedSkills: [],
      missingSkills: ["shot.stop"],
    ),
    AnswerOption(
      labelVi: "Biết nhưng chưa làm được",
      score: 2,
      demonstratedSkills: [],
      missingSkills: ["shot.stop"],
      // Knows what it is but can't execute
    ),
    AnswerOption(
      labelVi: "Làm được nhưng không ổn định",
      score: 4,
      demonstratedSkills: ["shot.stop"],
      missingSkills: [],
      // Has basic competency, needs practice
    ),
    AnswerOption(
      labelVi: "Khá ổn",
      score: 6,
      demonstratedSkills: ["shot.stop", "speed.control"],
      missingSkills: [],
    ),
  ],
)
```

---

# §8 — Data Model (Revised)

```dart
// ── Player Journey State ──
class PlayerJourneyState {
  final String playerId;
  final JourneyStep currentStep;  // welcome | whatWillIGet | ranking | assessment | result | path
  final AssessmentAnswers? answers;
  final AssessmentResult? result;
  final LearningPath? generatedPath;
  final DateTime? startedAt;
  final DateTime? completedAt;
}

// ── Assessment Result ──
class AssessmentResult {
  final PlayerLevel level;
  final int confidencePercent;
  final List<String> strengths;       // what player already knows
  final List<String> gaps;             // what player needs to learn
  final int estimatedHoursToNextLevel;
  final String motivationalMessage;
  final LearningPath initialPath;
  final List<KnowledgeNode> nextThreeItems;
}

// ── Player Level ──
enum PlayerLevel {
  beginner,  // Never played
  k,         // Played but no fundamentals
  i,         // Rank I
  h,         // Rank H
  g,         // Rank G
  f,         // Rank F+
}

// ── Level Descriptions (for UI) ──
const levelDescriptions = {
  PlayerLevel.beginner: LevelDescription(
    nameVi: "Beginner",
    descriptionVi: "Chưa từng chơi hoặc mới chơi vài lần",
    hoursToNext: 40,
    color: Colors.grey,
  ),
  PlayerLevel.k: LevelDescription(
    nameVi: "K",
    descriptionVi: "Biết chơi nhưng chưa có kỹ thuật",
    hoursToNext: 20,
    color: Colors.green,
  ),
  PlayerLevel.i: LevelDescription(
    nameVi: "I",
    descriptionVi: "Có kỹ thuật cơ bản, đánh được 2-3 bi",
    hoursToNext: 30,
    color: Colors.blue,
  ),
  PlayerLevel.h: LevelDescription(
    nameVi: "H",
    descriptionVi: "Người chơi phong trào, có chiến thuật",
    hoursToNext: 50,
    color: Colors.orange,
  ),
  PlayerLevel.g: LevelDescription(
    nameVi: "G",
    descriptionVi: "Phong trào khá, có thể thắng giải nhỏ",
    hoursToNext: 80,
    color: Colors.purple,
  ),
  PlayerLevel.f: LevelDescription(
    nameVi: "F",
    descriptionVi: "Phong trào mạnh, cạnh tranh được ở giải lớn",
    hoursToNext: null, // Elite
    color: Colors.red,
  ),
};
```

---

# §9 — Integration with Existing Systems

### Assessment is the Gateway

```
Player Journey
    │
    ├── reads: Learning Paths (H1.3)
    ├── writes: PlayerProfile (currentLevel, assessedAt)
    │
    ▼
Dashboard
    │
    ├── AI Coach → reads player level + gaps
    ├── Training → reads personalized path + drills
    ├── Knowledge → filters by player level
    └── Statistics → baseline for reassessment
```

### Re-assessment Triggers (after H1.2)

- Every 100 racks played
- Every 20 training sessions
- Or: player requests reassessment anytime

---

# §10 — Engineering Scope

| Component | Status | Notes |
|---|---|---|
| Assessment questions data model | ✅ Ready | 12 questions, beginner language |
| Assessment result model | ✅ Ready | Includes motivation + hours to next |
| Confidence calibrator | ✅ Ready | Over-estimation detection |
| Learning path generator | ✅ Ready | Graph-based, not linear |
| Video mapping | ✅ Ready | Video → Chapter → Timestamp → Knowledge → Drill → Mistake |
| Player Journey UI screens | ⏳ Pending H1.1 | 6 screens: Welcome → What → Ranking → Assessment → Result → Path |
| Re-assessment trigger | ⏳ Pending H1.1 | 100 racks / 20 sessions |
| Integration with EPIC 02/03/05/06 | ⏳ Pending H1.1 | Connect to existing systems |

---

# §11 — PO Revision Checklist

| # | PO Requirement | Status |
|---|---|---|
| 1 | ✅ | Rename "Assessment" → "Player Journey" |
| 2 | ✅ | Add "What will I get?" screen |
| 3 | ✅ | Complete Ranking explanation (Beginner→K→I→H→G→F with descriptions) |
| 4 | ✅ | Rewrite ALL 12 questions in beginner-friendly language |
| 5 | ✅ | Add Confidence Calibration (over-estimation detection) |
| 6 | ✅ | Learning Path = Knowledge Graph (not straight list) |
| 7 | ✅ | Video Mapping: Video → Chapter → Timestamp → Knowledge → Drill → Mistake |
| 8 | ✅ | Motivation: time to next level + personalized goal |

---

*Design revised by Engineering 2026-07-31 to address all 8 PO requirements.*
