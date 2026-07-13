# Pool OS

# Task 08

## Player Endurance Intelligence

Sau khi hoàn thành Warm-up Intelligence (Task 07), Pool OS đã biết:

- Người chơi cần bao lâu để vào phong độ.

Task 08 sẽ giúp Pool OS hiểu:

- Người chơi duy trì phong độ được bao lâu.
- Khi nào bắt đầu giảm phong độ.
- Giảm phong độ do kỹ thuật hay do thể lực.
- Race nào phù hợp với người chơi.
- Khi nào nên nghỉ.
- Khi nào nên kết thúc buổi tập.

---

## Product Goal

Pool OS phải có khả năng học từ lịch sử thi đấu để xây dựng "đường cong thể lực" riêng của từng người chơi.

Không sử dụng ngưỡng cố định.

Không dùng dữ liệu giả.

Không yêu cầu người chơi nhập thêm dữ liệu ngoài những gì đã có ở Task 06.

Hệ thống phải tự học theo thời gian.

---

## Pool OS cần trả lời được

- Người chơi đánh tốt nhất trong khoảng thời gian nào?

- Sau bao lâu thì bắt đầu xuống phong độ?

- Sau bao nhiêu rack thì xác suất miss tăng?

- Khi nào nên nghỉ giữa trận?

- Race nào phù hợp nhất với trình độ và thể lực hiện tại?

- Thể lực có phải nguyên nhân chính khiến phong độ giảm không?

---

## Input

Claude được phép sử dụng toàn bộ dữ liệu hiện có của Pool OS.

Bao gồm nhưng không giới hạn:

- Session
- Match
- Match Context
- Daily Readiness
- Warm-up Intelligence
- Rack
- Shot
- Event
- Equipment Snapshot

Claude tự quyết định dữ liệu nào cần dùng.

---

## UI

Claude tự thiết kế.

Yêu cầu:

- Đơn giản
- Dễ hiểu
- Không biến Pool OS thành phần mềm thống kê.

Người chơi chỉ cần nhìn vài giây là hiểu.

---

## AI

Không dùng AI sinh dữ liệu.

Mọi kết luận phải dựa trên dữ liệu thực.

Nếu chưa đủ dữ liệu phải hiển thị:

"Chưa đủ dữ liệu để đánh giá."

Không được suy đoán.

---

## Coding Rules

Claude được toàn quyền quyết định:

- Architecture
- Database
- Provider
- Service
- Widget
- Repository

Miễn:

- Không phá RFC-301
- Không phá Recording Pipeline
- Không sửa các Task đã LOCKED.

---

## Definition of Done

Claude tự đánh giá DoD.

Tối thiểu phải có:

- flutter analyze sạch.
- flutter test pass.
- APK build.
- Commit riêng cho Task 08.
- Report kết quả.
