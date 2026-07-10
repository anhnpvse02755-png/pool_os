# RFC-301 — Handoff / Bản đồ Recording Pipeline hiện tại

> Tài liệu chuẩn bị cho việc triển khai **RFC-301 (Recording Pipeline rebuild, P0, APPROVED)**.
> Soạn 2026-07-10 sau khi đọc toàn bộ tài liệu `.docx` gốc + `.md` triển khai + **code Dart thực tế**.
> Đọc kèm: `RFC-301` (bản user cung cấp), `Pool_OS_Workflow_Specification_v1.0.md`, `Pool_OS_Development_Rules_v1.0.md`.

## Toolchain đã xác nhận
- Flutter 3.24.0 / Dart 3.5.0 tại `D:\flutter\bin`.
- App tại `app/`, schema Drift hiện tại **v10** (`lib/features/player/data/database/app_database.dart:16`).
- DoD RFC-301: `flutter analyze` = 0 errors + `flutter test` pass + APK build + UAT pass.

## Kết luận 1 dòng
Pipeline `Session → Match → Rack → Shot → Event` đứt gãy. Gốc rễ: các màn recording mở bằng `const ShotRecordingScreen()` / `const EventRecordingScreen()` **không truyền ID**, tầng dưới lách bằng fallback `?? 0` → **orphan (rackId=0, shotId=0)**; và **Event gần như không bao giờ persist** vì điều kiện `shotId != null` luôn false.

## Schema (thực tế, đã đọc code)
- **Shots.rackId**: `integer().references(Racks,#id)` — NOT NULL + FK (dòng ~473).
- **Events.shotId**: `integer().references(Shots,#id)` — NOT NULL + FK (dòng ~487). Event chỉ gắn Shot, không tham chiếu Rack/Match/Session.
- **Racks**: các field FIX-003 (ballsPotted, largestRun, easyMissCount...) KHÔNG có cột thật → bị nhồi vào cột `notes` dạng JSON blob `'__RACK_DATA__'+jsonEncode(...)`.
- `PRAGMA foreign_keys = ON` có bật, nhưng bị vô hiệu trên thực tế do ghi giá trị `0`.

## Chuỗi bug (theo thứ tự nguyên nhân gốc)
1. `lib/features/shot/presentation/shot_recording_screen.dart:34` — `rackId: widget.rackId ?? 0`.
2. `lib/features/session/presentation/session_screen.dart:540-554` + `lib/features/match/presentation/match_detail_screen.dart:1430-1444` — push `const ShotRecordingScreen()` / `const EventRecordingScreen()` KHÔNG truyền id.
3. `lib/features/shot/presentation/shot_provider.dart:150-211` — guard `if (rackId != null)` cho phép 0; thêm shot vào memory bất kể persist; **vứt id auto-increment** từ `createShot` → Event không lấy được shotId thật.
4. `lib/features/event/presentation/event_provider.dart:121` — `if (eventRecord.shotId != null)` gần như luôn false → Event chỉ ở memory.
5. `lib/features/event/data/repositories/event_repository.dart:34` — `shotId: event.shotId ?? 0` → orphan Event.
6. `lib/features/shot/data/repositories/shot_repository.dart:34` — ghi thẳng `rackId`, không validate.
7. `lib/features/rack/data/repositories/rack_repository.dart:33-57,141-207` — JSON blob workaround.
8. `session_provider.finishSession` (dòng ~134-148) — chỉ set `finishedAt`, KHÔNG generate/persist summary, KHÔNG flush memory → shot/event chưa persist mất tại đây.
9. Không repository nào dùng `_db.transaction(...)` → không atomic.
10. `getActiveSession` dùng `getSingleOrNull` → crash nếu >1 session active (không giới hạn 1 active).

## Đối chiếu 7 Business Rule RFC-301
| Rule | Trạng thái |
|---|---|
| Shot phải có rackId hợp lệ | ❌ (`?? 0`) |
| Event phải có shotId hợp lệ | ❌ NẶNG (không persist / `?? 0`) |
| Persist ngay, không giữ memory | ❌ (memory-first, vứt id) |
| Repository là tầng persist duy nhất | ⚠️ (provider sạch, nhưng Rack dùng JSON blob) |
| Transaction-safe | ❌ (không có transaction) |
| Không orphan | ❌ (chủ động sinh orphan) |
| Liên kết id thật xuyên tầng | ❌ (id createShot bị bỏ) |

## File cần động khi rebuild (thứ tự đề xuất)
1. `shot_recording_screen.dart:34` — bỏ `?? 0`, bắt buộc rackId.
2. `session_screen.dart:540-554` + `match_detail_screen.dart:1430-1444` — truyền id khi push.
3. `event_provider.dart:121` + `event_repository.dart:34` — bỏ `?? 0`, validate reject.
4. `shot_provider.dart:150-211` — persist trước, dùng id trả về, memory sau; trả shotId cho event recorder.
5. `rack_repository.dart` — bỏ JSON blob → cột thật (schema **v11** + migration).
6. Bọc `_db.transaction(...)` cho chuỗi Rack→Shot→Event.
7. `lib/app/router/app_router.dart` + `lib/app/router.dart` — hợp nhất, thêm route có tham số cho recording/summary, bỏ mix Navigator.push/context.go.

## File CHƯA đọc kỹ — đọc trước khi sửa để tránh sót
- `lib/app/router.dart` (router thứ hai — nghi trùng lặp; Dashboard `context.go('/match/:id')` mà route này không có ở app_router.dart).
- `lib/features/rack/presentation/rack_provider.dart`.
- `lib/features/session/presentation/session_summary_screen.dart` (logic generate summary).
- `lib/features/shot/data/repositories/practice_repository.dart` (nhánh Practice tách rời; PracticeShots.sessionId nullable).

## Ràng buộc RFC-301 (nhắc lại)
- CHỈ sửa Recording Pipeline. KHÔNG đụng Coach / Statistics calc / Dashboard / Equipment / Readiness / Theme / Localization / Settings / AI.
- Match: hỗ trợ mọi race (3/5/7/9/11/13/15/21/custom); winner `playerScore >= raceTo`.
- Deliverables khi báo cáo: Root Cause · Files Modified · Flow Before · Flow After · DB Changes · Migration · Acceptance Checklist · flutter analyze · flutter test · APK Build.
- Sau khi duyệt → Recording Pipeline LOCKED.
