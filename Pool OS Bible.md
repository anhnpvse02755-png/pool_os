# Pool OS Bible

# KIẾN TRÚC DOMAIN

Pool OS không phải CRUD. Pool OS là Domain Driven Design. Mỗi Entity phải có trách nhiệm rõ ràng.

---

# DOMAIN MODEL

```
Player
│
├── Equipment
│
├── Daily Readiness
│
├── Session
│      │
│      ├── Match
│      │      │
│      │      ├── Match Context
│      │      │
│      │      ├── Rack
│      │      │      │
│      │      │      ├── Shot
│      │      │      │      │
│      │      │      │      ├── Shot Result
│      │      │      │      │
│      │      │      │      ├── Shot Reason
│      │      │      │      │
│      │      │      │      └── Event
│      │      │
│      │      └── Equipment Snapshot
│      │
│      └── Practice
│
├── Skill
│
├── Statistics
│
├── Coach
│
└── Training Plan
```

---

# PLAYER

Player là Aggregate Root. Player sở hữu toàn bộ dữ liệu. Không có Entity nào tồn tại nếu không thuộc Player.

---

# SESSION

Session là một buổi chơi. Một Session có thể gồm: Thi đấu, Luyện tập, Giao lưu, Thi đấu giải.

Session không quan tâm thắng thua. Session quan tâm toàn bộ trải nghiệm của buổi chơi.

Session gồm: Readiness, Warm-up, Match, Practice, Cool-down, Recovery.

---

# MATCH

Match là một trận. Ví dụ: Race 7, Race 9, Race 11.

Match luôn Snapshot: Equipment, Context, Opponent, Rule. Không được thay đổi sau này.

---

# MATCH CONTEXT

Context là điều kiện của trận. Không phải kết quả.

- Địa điểm → Quán A
- Ánh sáng → Tối
- Bàn → Diamond
- Bi → Aramith
- Đối thủ → Tấn công
- Giải → Không

Context dùng để AI hiểu: Tại sao hôm đó chơi tốt hoặc tệ.

---

# RACK

Rack chỉ quản lý một rack. Không quản lý Shot.

Rack gồm: Kết quả, Thời gian, Run Out, Break, Safety, Turning Point, Momentum.

---

# SHOT

Shot là dữ liệu quan trọng nhất. Mọi phân tích đều bắt đầu từ Shot.

## Ý định
Stop, Draw, Follow, Safety, Bank, Kick, Jump, Break, Position.

## Loại cú đánh
Pot, Safety, Escape, Combination, Carom, Plant.

## Mục tiêu
Ví dụ: Ăn bi 5 → Điều bi 6.

## Độ khó
AI Difficulty — không phải User chọn.

## Kết quả
Success, Miss, Scratch, Position Lost.

## Nguyên nhân
Too Thick, Too Thin, Wrong Power, Wrong Spin, Wrong Aim, Bridge Error, Stroke Error.

## Event
Event KHÔNG phải Shot. Event là thứ xảy ra sau Shot. Ví dụ: Scratch, Miss, Lucky, Hooked, Double Kiss, Kick.

---

# EVENT

Event chỉ là Metadata. Không chứa logic. Ví dụ: Event → Scratch → Penalty → Statistics.

Event không dùng để sinh Coach. Coach đọc Pattern.

---

# EQUIPMENT

Equipment là một Entity riêng. Không gắn trực tiếp vào Match. Match luôn dùng Snapshot.

```
Cue A → Weight 19oz → Tip Kamui M → Shaft Revo
↓
Snapshot
↓
Match
```

Nếu sau này đổi Tip → Lịch sử KHÔNG đổi.

---

# DAILY READINESS

Daily Readiness không phản ánh trận đấu. Nó phản ánh trạng thái đầu ngày.

Ví dụ: Ngủ, Ăn, Stress, Tự tin, Thể lực.

---

# MATCH FEEDBACK

Sau trận, User nhập: Đau vai, Đau tay, Mỏi mắt, Mất tập trung, Không đúng phong độ.

AI dùng để so sánh: Readiness → Match → Recovery.

---

# PLAYER STATE

Player luôn có State: Excellent, Good, Average, Poor, Collapsed.

State không lưu cố định. State được AI tính.

---

# SKILL

Skill không lưu %. Skill lưu Capability.

Ví dụ: Power 72, Accuracy 81, Safety 64, Mental 59.

Coach đọc Skill. Không đọc Statistics.

---

# STATISTICS

Statistics chỉ là Projection. Không được lưu logic. Statistics chỉ trả lời "Cái gì đã xảy ra?"

- Coach trả lời "Tại sao?"
- Training trả lời "Làm gì?"

---

# COACH

Coach không có quyền tính Statistics. Coach chỉ đọc: Statistics + Pattern + State + Context.

---

# TRAINING PLAN

Training Plan được sinh từ Coach. Không được User tạo thủ công. User chỉ chỉnh sửa.

---

# DATA FLOW

```
Shot → Statistics → Pattern → Diagnosis → Recommendation → Training → Review
```

Không có đường tắt.

---

# BUSINESS RULE

Một Recommendation luôn có: Observation → Evidence → Reason → Recommendation → Training → Review.

Ví dụ:
- Quan sát → Bạn thường miss Stop Shot.
- Bằng chứng → 31/50 lần.
- Nguyên nhân → Power Control.
- Khuyến nghị → Luyện Stop Shot.
- Review → 7 ngày sau đánh giá lại.

---

# AI KHÔNG ĐƯỢC PHÉP

- Không được Đoán.
- Không được Fake Data.
- Không được Suy luận nếu chưa đủ dữ liệu.
- Không được Khuyến nghị nếu không có Evidence.

---

# GOLDEN RULE

Pool OS chỉ có một nhiệm vụ: **Hiểu người chơi.**

Mọi module, mọi bảng, mọi màn hình, mọi API, mọi AI đều phải phục vụ mục tiêu đó. Nếu không, Feature đó phải bị loại bỏ.
