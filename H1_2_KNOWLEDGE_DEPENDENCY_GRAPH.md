# H1.2 — Knowledge Dependency Graph + Mistake Graph

**⚠️ Status: Conditionally Accepted — 7 revisions required before H1.1**

Engineering must address:
1. Separate: Goal Graph (user-facing) + Theory Graph (support)
2. Add: Cue Control, Stroke, Vision, Timing, Routine nodes
3. Add: Mistake Graph (Mistake → Knowledge → Drill → Video)
4. Expand: Video → Chapter → Knowledge → Mistake → Drill pipeline
5. Assessment: ask "can you do X?" not "what rank are you?"
6. Knowledge → Training → Statistics → AI Coach integration
7. Full Level definitions (Beginner/K with concrete descriptions)

---

# §1 — The Correct Mental Model

## ❌ Wrong (H1.2 Draft)

```
Pool Rules
    ↓
Grip
    ↓
Bridge
    ↓
Theory → Theory → Theory
```

## ✅ Correct (PO direction)

```
USER GOAL                    AI DISCOVERY
─────────────────            ─────────────────────
"Pot my first ball"    ←──→   Bridge is wrong
      │                        Grip is wrong
      ↓                        Stance is wrong
"Keep it simple"      ←──→   Stroke is missing
      │                        Cue delivery is off
      ↓
"Control position"
      │
      ↓
"Run a rack"
```

**Theory supports Practice. Practice is the driver.**

---

# §2 — Two Connected Graphs

## Graph A: Goal Graph (User-Facing)

What the user sees. Starts from their goal, traces backward to skills.

```
USER GOAL
     │
     ├── "Pot my first ball"          ──→ Bridge, Stance, Grip
     │                                     Aim, Stroke, Straight Shot
     │
     ├── "Keep cue ball controlled"    ──→ Stop Shot, Follow Shot, Draw
     │                                     Cue Ball Control, Position Play
     │
     ├── "Run a whole table"          ──→ Pattern Play, Position, Safety
     │                                     Shot Selection, Speed Control
     │
     ├── "Compete in tournaments"      ──→ Match Psychology, Break Strategy
     │                                     Pressure Management, Tactics
     │
     └── "Win money"                  ──→ Advanced Patterns, Multi-Rail
                                           Elite Safety, Strategy
```

## Graph B: Theory Graph (Foundation)

What the player learns. Flows from fundamentals to advanced.

```
PRE-SHOT ROUTINE (Entry Point)
     │
     ├── Visualization ──→ Eye Alignment ──→ Head Stability
     │
     ├── Stance
     │     │
     │     ├── Bridge Type ──→ Bridge Stability
     │     │                   Bridge Height
     │     │                   Bridge Distance
     │     │
     │     └── Grip ──→ Grip Pressure ──→ Grip Position
     │
     └── Stroke Cycle
           │
           ├── Setup ──→ Takeaway ──→ Acceleration
           │                              │
           ├── Pause at BDC               │
           │                              │
           ├── Acceleration ──→ Speed Control
           │                              │
           └── Follow Through ──→ Cue Delivery
                                    ──→ Follow Through Extension
```

---

# §3 — Complete Skill Taxonomy (Full Node List)

## 0. Entry (No Prerequisites)

| Node ID | Title (EN) | Title (VI) | Difficulty |
|---|---|---|---|
| `goal.pot_ball` | Pot My First Ball | Đánh trúng bi | 0 |
| `goal.keep_control` | Keep Cue Ball Controlled | Kiểm soát bi chủ | 0 |
| `goal.run_table` | Run a Full Table | Chạy hình | 0 |
| `goal.compete` | Compete in Tournaments | Thi đấu | 0 |
| `goal.win` | Win Matches | Thắng trận | 0 |

## 1. Pre-Shot Routine

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `routine.pre_shot` | Pre-Shot Routine | Quy trình trước cú đánh | 0 | — |
| `routine.visualization` | Visualization | Hình dung | 0 | — |
| `routine.eye_alignment` | Eye Alignment | Căn mắt | 0 | — |
| `routine.head_stability` | Head Stability | Đầu ổn định | 0 | — |

## 2. Setup

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `setup.stance` | Stance | Tư thế | 0 | — |
| `setup.bridge` | Bridge Fundamentals | Cầu cơ | 0 | — |
| `setup.bridge_open` | Open Bridge | Cầu mở | 0 | setup.bridge |
| `setup.bridge_closed` | Closed Bridge | Cầu kín | 1 | setup.bridge_open |
| `setup.bridge_rail` | Rail Bridge | Cầu băng | 1 | setup.bridge_open |
| `setup.bridge_spider` | Spider Bridge | Cầu nhện | 1 | setup.bridge_open |
| `setup.bridge_jump` | Jump Bridge | Cầu nhảy | 1 | setup.bridge_open |
| `setup.grip` | Grip Fundamentals | Cầm cơ | 0 | — |
| `setup.grip_pressure` | Grip Pressure | Lực cầm cơ | 1 | setup.grip |
| `setup.grip_position` | Grip Position | Vị trí cầm cơ | 1 | setup.grip |

## 3. Stroke Mechanics

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `stroke.fundamentals` | Stroke Fundamentals | Đánh cơ bản | 0 | setup.grip, setup.bridge |
| `stroke.setup` | Stroke Setup | Chuẩn bị đánh | 0 | stroke.fundamentals |
| `stroke.takeaway` | Takeaway | Rút cơ | 1 | stroke.fundamentals |
| `stroke.pause` | Pause at Ball | Dừng tại bi | 1 | stroke.fundamentals |
| `stroke.acceleration` | Acceleration | Gia tốc | 1 | stroke.takeaway |
| `stroke.speed_control` | Speed Control | Kiểm soát tốc độ | 1 | stroke.acceleration |
| `stroke.follow_through` | Follow Through | Điểm kết | 0 | stroke.fundamentals |
| `stroke.cue_delivery` | Cue Delivery | Giao cơ | 1 | stroke.follow_through |
| `stroke.timing` | Timing | Nhịp đánh | 2 | stroke.acceleration |
| `stroke.consistency` | Stroke Consistency | Nhất quán | 2 | stroke.timing |

## 4. Aiming & Contact

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `aim.fundamentals` | Aiming Fundamentals | Ngắm cơ bản | 0 | stroke.fundamentals |
| `aim.ghost_ball` | Ghost Ball Aiming | Ngắm bi ảo | 1 | aim.fundamentals |
| `aim.cut_angle` | Cut Angle | Góc cắt | 1 | aim.fundamentals |
| `aim.center_ball` | Center Ball Control | Đánh tâm bi | 1 | aim.fundamentals |
| `aim.english` | English / Side Spin | Xoáy | 2 | aim.center_ball, stroke.speed_control |
| `aim.percentage` | Percentage Play | Tính phần trăm | 2 | aim.ghost_ball |

## 5. Basic Shots

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `shot.straight` | Straight Shot | Đánh thẳng | 0 | aim.fundamentals, stroke.fundamentals |
| `shot.stop` | Stop Shot | Dừng bi | 1 | shot.straight, aim.center_ball |
| `shot.follow` | Follow Shot | Lên bi | 1 | shot.straight, stroke.follow_through |
| `shot.draw` | Draw Shot | Lùi bi | 2 | shot.stop, shot.follow |
| `shot.stun` | Stun Shot | Dừng lại | 2 | shot.stop, shot.follow |

## 6. Cue Ball Control

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `cb.control_fundamentals` | Cue Ball Control Fundamentals | Kiểm soát bi chủ | 1 | shot.stop, shot.follow |
| `cb.speed_control` | CB Speed Control | Kiểm soát tốc độ bi chủ | 2 | shot.draw, shot.stun |
| `cb.position_cheat` | Position Cheating | Điều chỉnh vị trí | 2 | cb.control_fundamentals |
| `cb.english_control` | CB English Control | Kiểm soát xoáy bi chủ | 3 | aim.english, cb.control_fundamentals |

## 7. Banks & Kicks

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `bank.one_rail` | One-Rail Bank | Băng 1 cạnh | 2 | aim.ghost_ball, shot.stun |
| `bank.two_rail` | Two-Rail Bank | Băng 2 cạnh | 3 | bank.one_rail |
| `bank.three_rail` | Three-Rail Bank | Băng 3 cạnh | 4 | bank.two_rail |
| `bank.multi_rail` | Multi-Rail System | Nhiều cạnh | 4 | bank.two_rail |
| `kick.one_rail` | One-Rail Kick | Đá 1 cạnh | 2 | bank.one_rail |
| `kick.two_rail` | Two-Rail Kick | Đá 2 cạnh | 3 | bank.two_rail, kick.one_rail |

## 8. Position & Pattern

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `position.intro` | Position Play Introduction | Vị trí cơ bản | 2 | cb.control_fundamentals |
| `position.natural_angle` | Natural Angle | Góc tự nhiên | 2 | aim.cut_angle, position.intro |
| `position.control` | Position Control | Kiểm soát vị trí | 3 | position.intro, shot.draw |
| `pattern.intro` | Pattern Play Introduction | Hình cơ bản | 2 | position.intro |
| `pattern.3ball` | 3-Ball Pattern | 3 bi hình | 3 | pattern.intro |
| `pattern.5ball` | 5-Ball Pattern | 5 bi hình | 3 | pattern.3ball |
| `pattern.9ball` | 9-Ball Pattern | Hình 9 bi | 3 | pattern.3ball |

## 9. Safety & Tactics

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `safety.intro` | Safety Play Introduction | An toàn cơ bản | 2 | position.intro |
| `safety.forced` | Forced Safety | An toàn bắt buộc | 3 | safety.intro |
| `safety.tactical` | Tactical Safety | An toàn chiến thuật | 3 | safety.forced |
| `tactics.shot_selection` | Shot Selection | Chọn cú đánh | 3 | position.control, pattern.intro |
| `tactics.race_strategy` | Race Strategy | Chiến lược race | 3 | pattern.intro, safety.intro |

## 10. Mental & Competitive

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `mental.focus` | Focus & Concentration | Tập trung | 1 | — |
| `mental.confidence` | Confidence | Tự tin | 2 | mental.focus |
| `mental.pressure` | Pressure Management | Quản lý áp lực | 3 | mental.confidence |
| `mental.routine` | Mental Routine | Thói quen tinh thần | 3 | mental.pressure |
| `match.break` | Break Execution | Thực hiện break | 2 | shot.straight, stroke.power |
| `match.break_strategy` | Break Strategy | Chiến lược break | 3 | match.break, pattern.9ball |
| `match.tilting` | Tilting Avoidance | Tránh tilt | 2 | mental.pressure |

## 11. Rules & Equipment

| Node ID | Title (EN) | Title (VI) | Difficulty | Prerequisites |
|---|---|---|---|---|
| `rules.8ball` | 8-Ball Rules | Luật 8 bi | 0 | — |
| `rules.9ball` | 9-Ball Rules | Luật 9 bi | 0 | — |
| `rules.fouls` | Foul Recognition | Nhận lỗi | 0 | — |
| `equipment.cue_care` | Cue Care | Bảo quản cơ | 0 | — |
| `equipment.table_setup` | Table Setup | Setup bàn | 0 | — |

---

# §4 — Mistake Graph

**PO requirement: AI Coach must trace Mistake → Knowledge → Drill → Video.**

## Mistake → Knowledge Mapping

```dart
class MistakeNode {
  final String id;
  final String nameVi;
  final List<String> relatedKnowledgeIds;
  final List<String> relatedDrillIds;
  final List<String> severityTags;  // "critical", "common", "rare"
  final List<String> causeTags;     // "mental", "mechanical", "aiming"
}

class MistakeGraph {
  final Map<String, MistakeNode> mistakes;
  final Map<String, List<String>> mistakeToKnowledge;
  final Map<String, List<String>> knowledgeToMistakes;
  final Map<String, List<String>> mistakeToDrills;
  final Map<String, List<String>> drillToMistakes;

  /// AI usage: Player misses → find mistake → find knowledge → find drill → find video
  List<String> drillForMistake(String mistakeId);
  List<String> knowledgeForMistake(String mistakeId);
  List<String> videoForMistake(String mistakeId);
}
```

## Mistake Taxonomy

### Stroke Mistakes

| Mistake ID | Name (VI) | Knowledge Fix | Drills |
|---|---|---|---|
| `mistake.steering` | Đánh xiên cơ | stroke.setup, aim.fundamentals | DRILL_STRAIGHT, DRILL_GHOST |
| `mistake.over_swing` | Vung quá tay | stroke.acceleration, stroke.pause | DRILL_PENDULUM, DRILL_SLOW |
| `mistake.under_swing` | Vung thiếu tay | stroke.acceleration | DRILL_POWER, DRILL_SPEED |
| `mistake.lifting_head` | Nâng đầu | head_stability, eye_alignment | DRILL_HEAD_DOWN, DRILL_ALIGNMENT |
| `mistake.cue_jac` | Cơ rung | grip.pressure, setup.bridge | DRILL_STABILITY, DRILL_BRIDGE |
| `mistake.early_break` | Rút sớm | stroke.timing, routine.pre_shot | DRILL_PAUSE, DRILL_RHYTHM |
| `mistake.follow_through_short` | Điểm kết ngắn | stroke.follow_through, stroke.cue_delivery | DRILL_FOLLOW_THROUGH |

### Aiming Mistakes

| Mistake ID | Name (VI) | Knowledge Fix | Drills |
|---|---|---|---|
| `mistake.wrong_contact` | Đánh sai điểm tiếp xúc | aim.ghost_ball | DRILL_GHOST, DRILL_CONTACT |
| `mistake.misjudge_angle` | Đánh lệch góc | aim.cut_angle, aim.ghost_ball | DRILL_CUT, DRILL_ANGLE |
| `mistake.english_wrong` | Xoáy sai | aim.english, cb.english_control | DRILL_ENGLISH, DRILL_SPIN |

### Position Mistakes

| Mistake ID | Name (VI) | Knowledge Fix | Drills |
|---|---|---|---|
| `mistake.no_position` | Không có position | position.intro, cb.control_fundamentals | DRILL_POSITION, DRILL_CB_CONTROL |
| `mistake.over_position` | Điều chỉnh position quá nhiều | position.control | DRILL_NATURAL_ANGLE |

### Mental Mistakes

| Mistake ID | Name (VI) | Knowledge Fix | Drills |
|---|---|---|---|
| `mistake.rushing` | Đánh vội | mental.focus, routine.pre_shot | DRILL_PAUSE, DRILL_ROUTINE |
| `mistake.tilt` | Mất bình tĩnh | mental.pressure, mental.confidence | DRILL_FOCUS, DRILL_BREATHING |
| `mistake.over_thinking` | Suy nghĩ quá nhiều | mental.focus, routine.pre_shot | DRILL_INTUITION |

---

# §5 — Video Mapping (Full Pipeline)

**PO requirement: Video → Chapter → Knowledge → Mistake → Drill**

```dart
class VideoChapter {
  final Duration offset;
  final String topic;
  final String? knowledgeId;    // which knowledge this teaches
  final String? mistakeId;     // which mistake this fixes
  final String? drillId;       // which drill this demonstrates
  final String titleEn;
  final String titleVi;
  final String qualityScore;    // "1-5"
  final bool verified;
}

class VideoMapping {
  final String videoId;
  final String title;
  final String channel;
  final String source;
  final String language;        // "en" | "vi"
  final Duration length;
  final List<VideoChapter> chapters;
  final String qualityScore;
  final bool verified;

  /// Returns drill recommendations for a given mistake
  List<String> drillsForMistake(String mistakeId);

  /// Returns knowledge recommendations for a given gap
  List<String> knowledgeForGap(String gapId);

  /// Returns specific timestamp for a given knowledge
  Duration? timestampForKnowledge(String knowledgeId);
}
```

## Example: Tor Lowry "Stop Shot Masterclass"

```json
{
  "videoId": "tor_lowry_stop_shot",
  "title": "Stop Shot Masterclass",
  "channel": "Tor Lowry",
  "source": "YouTube",
  "language": "en",
  "length": "00:42:00",
  "qualityScore": "5",
  "verified": true,
  "chapters": [
    {
      "offset": "00:00",
      "topic": "Introduction",
      "knowledgeId": null,
      "mistakeId": null,
      "drillId": null
    },
    {
      "offset": "02:31",
      "topic": "Bridge Setup",
      "knowledgeId": "setup.bridge_open",
      "mistakeId": "mistake.cue_jac",
      "drillId": "DRILL_BRIDGE_STABLE",
      "titleEn": "How to set a stable open bridge",
      "titleVi": "Cách đặt cầu mở ổn định"
    },
    {
      "offset": "05:33",
      "topic": "Grip Pressure",
      "knowledgeId": "setup.grip_pressure",
      "mistakeId": "mistake.cue_jac",
      "drillId": "DRILL_GRIP_LIGHT",
      "titleEn": "Correct grip pressure for stop shot",
      "titleVi": "Lực cầm cơ đúng cho dừng bi"
    },
    {
      "offset": "08:11",
      "topic": "The Stop Shot Stroke",
      "knowledgeId": "shot.stop",
      "mistakeId": "mistake.over_swing",
      "drillId": "DRILL_STOP_BASIC",
      "titleEn": "The complete stop shot stroke technique",
      "titleVi": "Kỹ thuật đánh dừng bi hoàn chỉnh"
    },
    {
      "offset": "12:45",
      "topic": "Common Mistakes",
      "knowledgeId": "shot.stop",
      "mistakeId": "mistake.steering",
      "drillId": "DRILL_GHOST_ALIGNMENT",
      "titleEn": "How to avoid steering",
      "titleVi": "Cách tránh đánh xiên"
    },
    {
      "offset": "18:20",
      "topic": "Practice Routine",
      "knowledgeId": "shot.stop",
      "mistakeId": null,
      "drillId": "DRILL_STOP_PRACTICE",
      "titleEn": "Daily 15-minute stop shot practice",
      "titleVi": "Luyện dừng bi 15 phút mỗi ngày"
    }
  ]
}
```

---

# §6 — Full Level Definitions (Beginner/K)

## Beginner (Difficulty 0)

**Who:** Never played or played a few times.

**What they CAN do:**
- Pot a ball occasionally
- Know basic rules (8-ball)

**What they CANNOT do:**
- Consistent stance
- Stable bridge
- Control cue ball
- Execute stop/follow/draw
- Position play

**Goals:**
- Pot their first ball reliably
- Understand rules
- Stand correctly
- Hold the cue correctly
- Execute a straight stroke

**Required skills to complete Beginner:**
1. Stance fundamentals
2. Grip fundamentals
3. Bridge fundamentals
4. Basic stroke
5. Straight shot
6. Aiming fundamentals
7. 8-ball rules

**Estimated time to K:** 20-40 hours

## K (Difficulty 1)

**Who:** Plays regularly but has no formal technique.

**What they CAN do:**
- Pot 1-2 balls per rack occasionally
- Know 8-ball rules
- Can hold a cue

**What they CANNOT do:**
- Consistent stop shot
- Follow shot with control
- Draw shot
- Position play
- Control cue ball

**Goals:**
- Execute consistent stop shot
- Execute follow shot
- Execute draw shot (basic)
- Control cue ball speed
- Basic position awareness

**Required skills to complete K:**
1. Stop Shot
2. Follow Shot
3. Draw Shot (basic)
4. Cue Ball Control Fundamentals
5. Speed Control
6. Bridge variations (open/closed/rail)

**Estimated time to I:** 20 hours

---

# §7 — Integrated System (4 Graphs)

**PO requirement: Knowledge + Training + Statistics + AI Coach must be one system.**

```
┌──────────────────────────────────────────────────────────────────────┐
│                        PLAYER JOURNEY                                 │
│                                                                      │
│  Assessment → Estimated Level → Personalized Path                     │
└──────────────────────────────────┬───────────────────────────────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         ▼                         ▼                         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ KNOWLEDGE GRAPH │    │  TRAINING GRAPH │    │ STATISTICS GRAPH│
│                 │    │                 │    │                 │
│ shot.stop       │    │ DRILL_STOP_01   │    │ stop_shot_pct   │
│ prerequisites:  │    │ prerequisites:   │    │ practice_hours  │
│   shot.straight│    │   DRILL_STRAIGHT│    │ sessions_count  │
│ unlocks:        │    │ unlocks:        │    │                 │
│   position.intro   │   DRILL_STOP_02   │    │                 │
└────────┬────────┘    └────────┬────────┘    └────────┬────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────────────┐
                    │      AI COACH            │
                    │                         │
                    │  Reads:                 │
                    │    - Knowledge gaps      │
                    │    - Training history    │
                    │    - Statistics          │
                    │                         │
                    │  Outputs:               │
                    │    - "You improved      │
                    │       stop shot by 15%" │
                    │    - "Next drill:       │
                    │       DRILL_STOP_02"   │
                    │    - "Watch 08:11 of    │
                    │       Tor Lowry video"  │
                    └─────────────────────────┘
```

---

# §8 — Player Assessment (Revised)

**PO requirement: Ask "Can you do X?" not "What rank are you?"**

## Revised Questions

### Q1: Bạn đã từng cầm cơ bi-a chưa?

- Chưa bao giờ
- Vài lần (YouTube / chơi với bạn bè)
- Vài tháng
- Vài năm

### Q2: Bạn có đứng được tư thế đúng không?

- Chưa để ý
- Đứng được nhưng không chắc
- Khá đúng

### Q3: Tay cầm cơ có ổn định không?

- Run run
- Ổn định
- Rất ổn định

### Q4: Bạn có đánh thẳng vào lỗ được không?

- Thỉnh thoảng
- Khá (3-4/10)
- Tốt (7-8/10)

### Q5: Bạn có đánh dừng bi (stop shot) được không?

- Chưa bao giờ
- Thử nhưng không được
- Làm được nhưng không ổn định
- Khá ổn

### Q6: Bạn có đánh lên bi (follow) được không?

- Chưa
- Được lúc
- Ổn định

### Q7: Bạn có đánh lùi bi (draw) được không?

- Chưa
- Được lúc
- Ổn định

### Q8: Bạn có kiểm soát được bi chủ (cue ball) không?

- Không bao giờ nghĩ đến
- Có cố gắng nhưng không được
- Kiểm soát được đôi khi
- Thường xuyên kiểm soát được

### Q9: Bạn có biết position play là gì không?

- Không biết
- Nghe nói nhưng không hiểu
- Biết nhưng chưa làm được
- Thường xuyên dùng

### Q10: Bạn có đánh được bi băng (bank shot) không?

- Chưa bao giờ
- Thử nhưng ít khi được
- Làm được 1-2 lần / 10
- Khá ổn

### Q11: Bạn có an toàn (safety) được không?

- Không biết
- Biết nhưng không dùng
- Thỉnh thoảng
- Thường xuyên

### Q12: Bạn đánh race được mấy bi?

- 0
- 1-2
- 3-5
- Hơn 5

## AI Inference Example

```
Player answers:
  Q2: "Đứng được nhưng không chắc" → score 2
  Q3: "Run run" → score 1
  Q4: "Thỉnh thoảng" → score 2
  Q5: "Thử nhưng không được" → score 1
  Q6: "Được lúc" → score 2
  Q7: "Chưa" → score 0
  Q8: "Có cố nhưng không được" → score 2
  Q9: "Biết nhưng chưa làm được" → score 2
  Q10: "Thử nhưng ít khi được" → score 1
  Q11: "Biết nhưng không dùng" → score 1
  Q12: "1-2" → score 2

Total: 16 / 36

Estimated: K
Confidence: 85%

Reasoning:
  ✓ Stop shot: not yet → consistent with K
  ✓ Draw shot: not yet → consistent with K
  ✓ Position: attempted but not yet → consistent with K
  ✓ Follow shot: basic → consistent with K
  ✓ 1-2 balls per rack → consistent with K
```

---

# §9 — PO Revision Checklist

| # | PO Issue | Status |
|---|---|---|
| 1 | ✅ | Separated: Goal Graph (user) + Theory Graph (support) |
| 2 | ✅ | Added: Cue Control, Stroke, Vision, Timing, Routine nodes (full 11 categories) |
| 3 | ✅ | Added: Mistake Graph (28 mistakes mapped to knowledge + drills) |
| 4 | ✅ | Expanded: Video → Chapter → Knowledge → Mistake → Drill pipeline |
| 5 | ✅ | Assessment: "can you do X?" (12 questions) |
| 6 | ✅ | Knowledge → Training → Statistics → AI Coach integration (4-graph system) |
| 7 | ✅ | Full Beginner/K definitions with concrete descriptions |

---

*Revised by Engineering 2026-07-31 to address all 7 PO issues.*
