# POOL OS MASTER SPEC V2
## Product Vision & Development Roadmap
Version: 2.0
Status: Product Blueprint
Owner: Product Team

---

# MỤC TIÊU

Pool OS KHÔNG phải ứng dụng ghi điểm.

Pool OS là **AI Pool Training Platform**.

Mục tiêu cuối cùng:

> Thu thập dữ liệu → Phân tích → Hiểu người chơi → Sinh chương trình luyện tập → Theo dõi tiến bộ → Nâng trình.

Toàn bộ kiến trúc của hệ thống phải xoay quanh vòng lặp này.

```
Collect
    ↓
Analyze
    ↓
Understand
    ↓
Recommend
    ↓
Train
    ↓
Improve
    ↓
Collect...
```

---

# TRIẾT LÝ THIẾT KẾ

## Không làm Statistics App

Không xây app chỉ để hiển thị:

- Win Rate
- Break Rate
- Safety %

đó chỉ là dữ liệu.

Người chơi cần biết

> Tại sao mình như vậy?

và

> Làm sao để cải thiện?

---

## AI Coach là trung tâm

Mọi dữ liệu đều phục vụ AI Coach.

Không có dữ liệu nào được thu thập nếu nó không giúp:

- hiểu người chơi
- tìm nguyên nhân
- đưa lời khuyên

---

## Không Fake Data

Nếu chưa đủ dữ liệu:

Hiển thị

```
Chưa đủ dữ liệu
```

KHÔNG hiển thị

```
Stop Shot 0%
Safety 0%
Mental 50%
```

---

# KIẾN TRÚC TỔNG THỂ

Pool OS gồm 10 Epic.

---

# EPIC 1 — PLAYER PROFILE

Lưu toàn bộ thông tin người chơi.

### Hồ sơ

- Họ tên
- Avatar
- Rank
- Tay thuận
- Tuổi
- Giới tính

### Phong cách

- Tấn công
- Phòng thủ
- Điều bi
- Mạo hiểm
- Chắc chắn

### Mục tiêu

- Rank mong muốn
- Giải đấu
- Thời gian

---

# EPIC 2 — EQUIPMENT INTELLIGENCE

Quản lý toàn bộ cơ.

- Cơ đánh
- Cơ phá
- Đầu cơ
- Ngọn
- Chuôi
- Trọng lượng
- Tip
- Shaft
- Balance

Mỗi Match phải Snapshot Equipment. KHÔNG được thay đổi lịch sử.

---

# EPIC 3 — SESSION CONTEXT

Đây là dữ liệu quan trọng nhất. Một buổi chơi không chỉ gồm Shot. Một buổi chơi còn có Context. Context gồm 5 Phase.

## Phase 1 — Daily Readiness

Đã có.

## Phase 2 — Before Match

- Khởi động chưa
- Đánh thử bao lâu
- Tự tin
- Mục tiêu

## Phase 3 — During Match

Theo dõi: Fatigue, Focus, Shoulder, Hand, Vision.

## Phase 4 — After Match

- Có hài lòng?
- Đúng phong độ?
- Sai chiến thuật?
- Sai tâm lý?

## Phase 5 — Recovery

- Đau tay
- Đau vai
- Mỏi mắt
- Cần nghỉ

---

# EPIC 4 — RECORDING ENGINE

Pipeline chuẩn

```
Session → Match → Rack → Shot → Result → Reason → Event
```

KHÔNG được để

```
Shot → Event
```

## Shot

Một Shot phải có:

### Ý định

Stop, Draw, Follow, Safety, Kick, Bank, Jump, Position.

### Mục tiêu

Ví dụ: Stop để ăn bi 2.

### Độ khó

Dễ / Trung bình / Khó.

### Kết quả

Thành công / Thất bại.

### Nguyên nhân

Đánh dày, Thiếu lực, Sai ép phê, Sai ngắm.

### Event

Scratch, Miss, Kick, Double Kiss, Cue Ball Control, Position Lost.

---

# EPIC 5 — PERFORMANCE ANALYTICS

Không chỉ thống kê. Phải tìm Pattern.

```
LLLLWWWW  → Warm-up chậm.
WWWWLLLL  → Thể lực giảm.
WWLLWWLL  → Phong độ không ổn định.
```

---

# EPIC 6 — AI LEARNING ENGINE

Đây là bộ não. Không đọc Win Rate. Không đọc 0%. Không đọc Fake Data. AI học Pattern.

```
41 lần Stop Shot → 31 lần đánh dày → Kết luận: Sai cảm giác lực.
15 lần Draw → 13 lần thiếu ép phê → Khuyến nghị: Luyện Draw.
```

---

# EPIC 7 — AI COACH

Coach KHÔNG đọc Statistics. Coach đọc:

```
Pattern → Diagnosis → Evidence → Recommendation → Training
```

Ví dụ

```
Quan sát: Bạn thường thua 4 rack đầu.
Nguyên nhân: Khởi động chậm.
Bằng chứng: 12/15 trận.
Khuyến nghị: Khởi động 15 phút.
```

---

# EPIC 8 — TRAINING GENERATOR

Sinh bài tập tự động.

```
Stop Shot → Level 1 → Level 2 → Level 3
```

---

# EPIC 9 — PLAYER GROWTH

Theo dõi tiến bộ.

```
30 ngày → Stop Shot 45% → 63%
Đã luyện 17 ngày liên tục
Break +12%
```

---

# EPIC 10 — FUTURE

- Cloud
- Community
- League
- Tournament
- Multiplayer

---

# SUBSYSTEM MỚI

## Warm-up Model

Warm-up Time, Warm-up Speed, First Rack, Confidence, Optimal Warm-up.

## Fatigue Model

Tay, Vai, Lưng, Mắt, Tập trung, Thể lực.

## Psychology Model

Tự tin, Áp lực, Dẫn trước, Bị gỡ, Chung kết, Hill-Hill.

## Momentum Model

Chuỗi thắng, Chuỗi thua, Lật kèo, Mất phong độ.

## Opponent Model

Đối thủ nào: Khó thắng, Khó chịu, Thích phòng thủ, Đánh nhanh, Đánh chậm.

## Equipment Intelligence

AI học: Cơ nào → Đánh tốt. Tip nào → Control tốt. Ngọn nào → Break mạnh.

---

# PRODUCT LOOP

```
Thu thập → Phân tích → Hiểu → Khuyến nghị → Luyện tập → Tiến bộ → Thu thập
```

---

# NGUYÊN TẮC PHÁT TRIỂN

Không phát triển theo Bug. Không phát triển theo UI. Không phát triển theo Screen. Phát triển theo Product Loop.

Mỗi Feature phải trả lời được:

1. Thu thập dữ liệu gì?
2. Giúp AI hiểu gì?
3. Sinh ra giá trị gì?
4. Giúp người chơi tiến bộ như thế nào?

Nếu không trả lời được 4 câu hỏi trên → KHÔNG phát triển Feature đó.

---

# ĐỊNH HƯỚNG

Pool OS không cạnh tranh bằng: UI, Animation, Dashboard.

Pool OS cạnh tranh bằng:

**Khả năng hiểu người chơi tốt hơn chính người chơi.**

Đó là giá trị cốt lõi của sản phẩm.

---

# KIẾN TRÚC AI COACH

## AI Coach KHÔNG PHẢI CHATBOT

AI Coach không trả lời câu hỏi. AI Coach là một hệ thống chuyên gia (Expert System).

Mục tiêu: Hiểu người chơi. Không phải hiểu trận đấu.

## Luồng xử lý

```
Raw Data → Feature Extraction → Pattern Detection → Diagnosis → Evidence → Recommendation → Training Plan → Follow-up
```

## 1. Raw Data

Player → Session → Match → Rack → Shot → Reason → Event → Equipment → Readiness → Match Context → After Match.

## 2. Feature Extraction

- `Stop Shot / Miss / Too Thick` → Feature: **Power Control**
- `Scratch 3 lần` → Feature: **Cue Ball Control**
- `Miss Bank` → Feature: **Bank Accuracy**

## 3. Pattern Detection

- `Stop Shot → Miss → Too Thick → 18 lần` → Pattern: **Over Hit**
- `Rack 1 Lose, 2 Lose, 3 Lose, 4 Win, 5 Win` → Pattern: **Warm-up Slow**
- `Rack 10 → Miss nhiều → Fatigue tăng` → Pattern: **Endurance Issue**

## 4. Diagnosis

Pattern → Nguyên nhân.

- `Warm-up Slow` → Diagnosis: **Chưa vào cơ.**
- `Draw Shot → Miss → Power` → Diagnosis: **Điều khiển lực chưa ổn.**

## 5. Evidence

Mọi kết luận PHẢI có bằng chứng.

- "Bạn khởi động chậm." → Evidence: 12 trận gần nhất, 10 trận thua rack đầu.
- "Bạn giảm phong độ sau 8 rack." → Evidence: Accuracy Rack 1-8 = 76%, Rack 9-15 = 61%.

## 6. Recommendation

Recommendation KHÔNG được chung chung.

- Sai: "Luyện Stop Shot."
- Đúng: "Trong 30 cú Stop Shot gần nhất, 19 cú đánh quá dày. Bạn nên luyện Stop Shot Distance 40 cm, 50 lần."

## 7. Training Plan

Coach phải tự sinh giáo án. Ví dụ: Ngày 1 Stop Shot, Ngày 2 Cue Ball Control, Ngày 3 Safety.

## 8. Follow-up

Sau khi luyện, AI phải hỏi "Bạn đã luyện chưa?" → Nếu Có → So sánh Trước / Sau.

---

# HỆ THỐNG ĐÁNH GIÁ NGƯỜI CHƠI

Không dùng Rank H, G, F... AI tự xây dựng **Player DNA**.

## Technical DNA
Power, Accuracy, Position, Safety, Bank, Kick, Jump, Break.

## Tactical DNA
Shot Selection, Safety Decision, Risk Control, Pattern Play.

## Physical DNA
Warm-up, Endurance, Recovery, Stability.

## Mental DNA
Confidence, Pressure, Momentum, Focus, Tilt.

## Equipment DNA
Cue, Tip, Shaft, Weight, Balance.

---

# PLAYER STATE MODEL

Người chơi không cố định. Player luôn ở một trạng thái: Excellent, Good, Normal, Bad, Collapse. AI phải xác định Player đang ở State nào.

## State Transition

```
Excellent → (Fatigue) → Good → (Pressure) → Normal → (Tilt) → Bad
```

AI phải phát hiện State thay đổi khi nào.

---

# MOMENTUM ENGINE

Momentum KHÔNG phải Win/Lose. Momentum là xu hướng.

- `LLLL WWWW` → Momentum tăng.
- `WWWW LLLL` → Momentum giảm.
- `WLWLWL` → Momentum không ổn định.

---

# FATIGUE ENGINE

Fatigue gồm nhiều loại, mỗi loại đánh giá riêng — KHÔNG gộp thành một chỉ số.

- **Physical**: Tay, Vai, Lưng
- **Mental**: Stress, Focus
- **Vision**: Mỏi mắt, Quan sát
- **Decision**: Ra quyết định

---

# WARM-UP ENGINE

Warm-up không chỉ là có khởi động hay không. Bao gồm: Warm-up Time, Warm-up Speed, First Rack Accuracy, Time to Peak, Optimal Warm-up.

Ví dụ: AI học "Player A Peak sau 4 rack" → Khuyến nghị "Khởi động 15 phút trước giải."

---

# TRIẾT LÝ THU THẬP DỮ LIỆU

Pool OS không cố gắng ghi thật nhiều dữ liệu. Pool OS chỉ ghi "Dữ liệu tạo ra giá trị."

- Không hỏi "Bạn vui không?" nếu AI không dùng.
- Nếu "Đau vai" giúp AI giải thích "Accuracy giảm" → Bắt buộc phải thu.

---

# NGUYÊN TẮC UX

Người chơi không được cảm thấy "Mình đang nhập dữ liệu." Mà phải cảm thấy "Mình đang ghi lại trận đấu."

Input càng ít càng tốt. AI suy luận càng nhiều càng tốt.

---

# ĐỊNH HƯỚNG PHÁT TRIỂN

4 giai đoạn:

1. **Recording** — Thu thập đúng.
2. **Analytics** — Hiểu đúng.
3. **Coach** — Dạy đúng.
4. **AI Training Platform** — Đồng hành cùng người chơi nhiều năm.

---

# TẦM NHÌN CUỐI CÙNG

Pool OS không phải ứng dụng ghi điểm. Pool OS không phải ứng dụng thống kê. Pool OS không phải chatbot AI.

Pool OS là một hệ thống có khả năng học cách bạn chơi bi-a, hiểu điểm mạnh, điểm yếu, thể trạng, tâm lý, thiết bị và quá trình tiến bộ của bạn để trở thành một huấn luyện viên cá nhân, giúp bạn nâng cao trình độ theo thời gian bằng dữ liệu thực tế của chính bạn.
