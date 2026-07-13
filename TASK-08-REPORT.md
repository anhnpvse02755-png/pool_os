# Task 08 — Player Endurance Intelligence · Report

**Status:** IMPLEMENTED — PENDING UAT
**Ngày:** 2026-07-13
**Scope:** Chỉ đọc (read-side). Không đụng RFC-301 / Recording Pipeline / các Task đã LOCKED.

---

## 1. Mục tiêu đã đạt

Pool OS giờ trả lời được, hoàn toàn từ dữ liệu đã ghi (không nhập thêm, không schema mới):

- Người chơi giữ phong độ được bao lâu → **Endurance score 0-100**.
- Khi nào bắt đầu xuống → **rack decline onset trung bình**.
- Xuống do kỹ thuật hay thể lực → **DeclineCause** (technical / physical / mixed / unknown).
- Race nào phù hợp → **recommendedRaceTo** (chỉ đưa ra khi có tín hiệu decline thật).
- Nhìn vài giây là hiểu → **thẻ tóm tắt + đường cong phong độ** (LineChart).

Khi chưa đủ dữ liệu: hiển thị **"Chưa đủ dữ liệu để đánh giá."** — không suy đoán, không số giả.

---

## 2. Nguyên tắc thiết kế (bám spec)

| Yêu cầu spec | Cách thực hiện |
|---|---|
| Không ngưỡng cố định | Baseline học từ **personal peak** của mỗi người + biên độ decline lấy từ **độ lệch chuẩn** của chính trận đó (`0.5·std`, floor 6). Beginner và pro đều so với chính mình. |
| Không dữ liệu giả | Mọi số truy về Rack/Shot/Match thật. Thiếu dữ liệu → `EnduranceProfile.insufficient`. |
| Không nhập thêm | Chỉ đọc dữ liệu Task 06 đã có. |
| Tự học theo thời gian | Cần ≥3 trận đủ dài (≥6 rack) mới kết luận; càng nhiều trận càng chuẩn. |
| Không phá LOCKED | Feature mới độc lập, **tái sử dụng** `PlayerStateAnalyzer.rackQuality()` thay vì sửa nó. |

---

## 3. Files

**Mới (feature `endurance`):**

| File | Vai trò |
|---|---|
| `app/lib/features/endurance/domain/endurance_analyzer.dart` | Pure-Dart analyzer: học đường cong thể lực, quy nguyên nhân, gợi ý race. Không Flutter/DB. |
| `app/lib/features/endurance/presentation/endurance_provider.dart` | 2 `FutureProvider`: profile + đường cong rack quality trận gần nhất. Đọc DB qua repo có sẵn. |
| `app/lib/features/endurance/presentation/widgets/endurance_card.dart` | Thẻ tóm tắt glanceable, tôn trọng "not enough data". |
| `app/lib/features/endurance/presentation/endurance_screen.dart` | Màn hình đầy đủ: thẻ + LineChart đường cong phong độ. |
| `app/test/task_08_endurance_test.dart` | 10 unit test (pure-domain). |

**Sửa (tối thiểu, chỉ nối dây):**

| File | Thay đổi |
|---|---|
| `app/lib/app/router/app_router.dart` | Thêm route `/endurance`. |
| `app/lib/features/player/presentation/player_screen.dart` | Thêm EnduranceCard (tap → `/endurance`). |
| `app/lib/shared/localization/app_localizations.dart` | 14 key `endurance_*` cho cả `en` và `vi`. |

Không sửa Drift schema (giữ nguyên version 16). Không sửa AI/Coach/Statistics calculations.

---

## 4. Thuật toán tóm tắt

1. **rackQuality(rack)** — tái dùng nguyên từ Player State (nguồn sự thật duy nhất về "rack tốt").
2. **personalPeak** — trung bình cửa sổ 1/3 tốt nhất của mỗi trận → mức trần đã học.
3. **declineOnset(match)** — rack đầu tiên mà trung bình phần còn lại tụt dưới form đầu trận quá biên độ **học từ std của trận đó**.
4. **cause** — đếm miss reason ở các rack sau onset: aim/position/english/bad_decision = kỹ thuật; speed/kick/rush/nerves = thể lực/tâm lý. Chỉ gọi tên nguyên nhân khi ≥60% nghiêng hẳn một phía, còn lại là *mixed*; không có tín hiệu = *unknown* (không đoán).
5. **enduranceScore** — 100 nếu không bao giờ tụt; trừ điểm theo tần suất tụt và độ sâu tụt (chuẩn hoá theo personalPeak).
6. **recommendedRaceTo** — làm tròn xuống giá trị race phổ biến (3/5/7/9/11/13/15) ngay dưới onset; steady → null.

---

## 5. Definition of Done

| Tiêu chí | Kết quả |
|---|---|
| `flutter analyze` | **0 error, 0 warning** — 58 info (đều là mục cũ ở file khác, không phát sinh từ Task 08). |
| `flutter test` (Task 08) | **10/10 pass.** |
| `flutter test` (toàn bộ) | 52 pass, 1 fail = `widget_test.dart` smoke test — **đã xác nhận fail sẵn trên baseline** (harness test thiếu init DB), không do Task 08. |
| APK build | Xem mục 7 — cần fix toolchain (không liên quan code Task 08). |
| Commit riêng | Sẽ commit sau khi APK xanh. |

---

## 7. Ghi chú build APK — toolchain drift (KHÔNG do Task 08)

APK build fail ở bước Gradle plugin-application, **trước khi Dart được biên dịch** — nên không liên quan code Task 08 (analyze sạch, test pass).

**Root cause:** Flutter 3.44.6 (cài ~2026-07-08) nâng AGP tối thiểu lên **8.6.0**, nhưng `app/android/settings.gradle` vẫn pin **8.1.0**:

```
Your project's Android Gradle Plugin version (8.1.0) is lower than
Flutter's minimum supported version of Android Gradle Plugin version 8.6.0.
```

(Cảnh báo "newDsl" trong Flutter Fix box là gây nhiễu — lỗi thật ở dòng version check phía trên.)

**Fix:** bump AGP `8.1.0 → 8.6.0` trong `settings.gradle`. An toàn: Gradle wrapper đã là 8.10.2 (hỗ trợ AGP 8.6+), Kotlin 1.9.24 tương thích. Đây là sửa hạ tầng build, tách bạch với feature Task 08.

---

## 6. Regression risk: THẤP

- Toàn bộ read-side, không ghi DB, không đổi schema/migration.
- Không sửa Recording Pipeline, Coach, Statistics, hay bất kỳ Task LOCKED nào.
- Điểm chạm duy nhất vào code cũ: 3 lần nối dây (route, 1 card trên Player screen, key l10n) — đều additive.
