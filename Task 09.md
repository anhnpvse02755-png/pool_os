# Pool OS — Task 09

## Training Center (Trung tâm luyện tập)

---

## 1. Mục tiêu

Pool OS hiện quản lý: Người chơi · Trận đấu · Shot · Event · Equipment · Match
Context · Warm-up · Endurance. **Chưa quản lý việc luyện tập.**

Task 09 xây dựng toàn bộ hệ thống Training. Sau task này người chơi có thể:

- tạo / chọn bài tập (drill)
- chạy một buổi luyện tập (training session) và ghi Đạt / Miss
- tạo bài tập riêng (custom drill)
- xem tiến độ (progress) theo thời gian

Đây là chức năng **nền tảng, KHÔNG phải AI**. Chỉ nhập tay + hiển thị dữ liệu.

---

## 2. Bối cảnh code hiện có (ĐỌC TRƯỚC KHI SỬA)

- `features/drill/` đã có **`DrillLibrary` (21 bài tập hardcoded)** + models `Drill`,
  `DrillCategory` (17 category). Task 09 **tái dùng** thư viện này, không viết lại.
- `features/training/` hiện là *giáo án nhiều tuần* (training programs), **100%
  in-memory**. Task 09 **KHÔNG đụng** feature này (spec: "Không sinh giáo án").
- Có 2 bảng orphan `DrillSessions`, `TrainingProgramProgress` — chưa được wire.
  Task 09 **không dùng** chúng để tránh nhầm lẫn semantics; tạo bảng mới rõ ràng.
- Recording Pipeline (RFC-301/302) là **LOCKED**. Training Center là luồng ghi
  tay riêng, **KHÔNG chạm** vào Session/Match/Rack/Shot/Event của recording.

Feature mới: `features/training_center/` — self-contained.

---

## 3. Phạm vi

### Phần 1 — Drill Library
Thư viện bài tập theo Category (tái dùng `DrillLibrary` + `DrillCategory`).
Ví dụ category: Stop Shot, Follow, Draw, Long Pot, Cut, Position, Break, Jump,
Safety, Kick... (đã có sẵn 17 category trong `DrillCategory`).

### Phần 2 — Training Session
Một buổi luyện tập. Chọn drill → đặt mục tiêu số lần (vd 100) → ghi Đạt / Miss →
Lưu. **Nhiều drill trong một session.** Mỗi drill run lưu attempts + successes.

### Phần 3 — Custom Drill
Người chơi tạo bài tập riêng: Tên · Mục tiêu (số lần) · Điều kiện thành công (tự
định nghĩa, text tự do) · Category. Custom drill lưu DB, dùng lại được.

### Phần 4 — Progress
Theo dõi tiến bộ: với mỗi drill / category, so sánh success rate kỳ trước vs hiện
tại (vd Long Pot: tháng trước 58% → hiện tại 71%). **Chỉ hiển thị dữ liệu, không AI.**

### Phần 5 — Favorite Drill
Đánh dấu yêu thích → hiển thị đầu danh sách.

### Phần 6 — Recent Drill
Hiển thị 5 bài tập luyện gần nhất.

### Phần 7 — UI / UX (Claude tự thiết kế)
`Training Center` → danh sách Category → danh sách Drill → Training Session →
Progress. Điểm vào: route `/training-center`, card ở Player/Dashboard.

---

## 4. Thiết kế dữ liệu (Drift, schema v17)

3 bảng mới, additive, tạo bằng `m.createTable` (mirror `_migrateToV16`):

- **CustomDrills** — bài tập do người chơi tạo (Phần 3).
  `id, name, category, targetReps, successCriteria(nullable), createdAt`.
- **TrainingSessions** — một buổi luyện (Phần 2).
  `id, playerId(nullable), startedAt, completedAt(nullable), notes(nullable)`.
- **DrillRuns** — một drill được chạy trong một session (Đạt/Miss).
  `id, sessionId, drillCode(nullable), customDrillId(nullable), drillName,
  category, targetReps, attempts, successes, createdAt`.
- **DrillFavorites** — đánh dấu yêu thích (Phần 5).
  `id, drillKey (code hoặc "custom:<id>"), createdAt`.

`successRate = successes / attempts`. Progress đọc lịch sử `DrillRuns` theo
`category`/`drillKey`, chia mốc thời gian, tính rate trước/sau. Recent = 5
`DrillRuns` mới nhất. Không FK cứng (soft refs) để xoá không cascade lịch sử.

---

## 5. Kiến trúc
`Presentation → Riverpod Provider → Repository → Drift`. Không bypass repository.
`features/training_center/{data/repositories, domain/models, presentation/{providers,widgets,screens}}`.

---

## 6. Không làm
Không sinh giáo án · Không AI Coach · Không Recommendation · Không sửa Statistics ·
Không sửa Recording Pipeline · Không đụng feature `training/` cũ.

---

## 7. Definition of Done
- Training Center hoàn chỉnh (Library, Custom Drill, Session, Progress, Favorite, Recent).
- `flutter analyze` = 0 errors.
- `flutter test` pass (unit test cho repository + progress logic).
- APK build thành công.
- Commit riêng Task 09.
