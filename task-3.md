# TASK 03 — Coach Intelligence v1

## Mục tiêu

Biến Huấn luyện viên từ một màn hình hiển thị thống kê thành một HLV AI thực sự.

Coach không chỉ nói "cần tập Stop Shot" mà phải giải thích vì sao, dựa trên dữ liệu nào, và nên làm gì tiếp theo.

## Yêu cầu

- Đọc Product Bible và toàn bộ tài liệu hiện có.
- Không tạo kiến trúc mới nếu có thể mở rộng kiến trúc hiện tại.
- Tận dụng dữ liệu đã có từ:
  - Player State
  - Session
  - Match
  - Rack
  - Shot
- Không dùng dữ liệu giả (fake data).

## Coach phải trả lời được 4 câu hỏi

### 1. Hôm nay bạn đánh như thế nào?

Ví dụ:

- Phong độ tốt.
- Phong độ giảm sau rack 8.
- Khả năng điều bi giảm ở cuối buổi.
- Tỷ lệ xử lý bi khó ổn định.

### 2. Vì sao lại như vậy?

Coach phải chỉ rõ dữ liệu.

Ví dụ:

- Tỷ lệ Stop Shot thành công giảm từ 82% xuống 54%.
- Miss chủ yếu do lực.
- Sai nhiều ở cú đánh có ép phê.
- Sau 70 phút thi đấu tỷ lệ lỗi tăng.

Không được trả lời chung chung.

### 3. Bạn nên làm gì?

Coach đưa tối đa 3 khuyến nghị.

Ví dụ:

- Tập Stop Shot.
- Tập kiểm soát lực.
- Nghỉ giữa các set.
- Khởi động thêm trước trận.

### 4. Vì sao Coach lại khuyên như vậy?

Mỗi khuyến nghị đều phải có phần giải thích.

Ví dụ:

Tôi khuyên bạn tập Stop Shot vì trong 5 buổi gần nhất:

- 31% lỗi đến từ Stop Shot.
- Đây là loại cú đánh có tỷ lệ thất bại cao nhất.
- Nếu cải thiện kỹ năng này, bạn có thể tăng khoảng 8–12% tỷ lệ thắng.

## UI / UX

Claude tự thiết kế.

Yêu cầu:

- dễ đọc
- không quá nhiều chữ
- ưu tiên dạng Card
- người chơi mở Coach là hiểu ngay hôm nay mình cần cải thiện điều gì

## Definition of Done

- Coach sử dụng dữ liệu thật.
- Không còn khuyến nghị chung chung.
- Mỗi khuyến nghị đều có:
  - Lý do
  - Dữ liệu
  - Hướng cải thiện
- Không dùng fake data.
- flutter analyze sạch.
- flutter test pass.
- Build APK thành công.
- Commit Task 03.
