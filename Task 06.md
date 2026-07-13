# TASK 06 — Bối cảnh trận đấu (Match Context & Player State)

## Mục tiêu

Pool OS không chỉ biết đã xảy ra chuyện gì. Mà phải biết người chơi bước vào trận đấu trong trạng thái nào và kết thúc trận đấu trong trạng thái nào. Đây là nền tảng cho toàn bộ AI sau này.

## Nguyên tắc

Không hỏi trong lúc đang thi đấu. Mọi thông tin đều nhập: Trước Match, Sau Match — không làm gián đoạn việc ghi Rack / Shot.

## PHẦN 1 — Trước trận đấu

**A. Mục đích:** Luyện tập / Thi đấu / Giải đấu / Giao lưu

**B. Đối thủ (đánh giá chủ quan):** Chơi một mình / Bạn bè / Đối thủ mạnh / Đối thủ ngang trình / Đối thủ yếu

**C. Điều kiện thi đấu:** Bàn quen / Bàn lạ / Phòng quen / Phòng lạ / Ánh sáng tốt / Bình thường / Kém

**D. Mức độ khởi động:** Chưa khởi động / Khởi động nhẹ / Khởi động đầy đủ / Đã đánh nóng trước trận

**E. Mục tiêu trận đấu:** Luyện Stop Shot / Luyện Position / Luyện Break / Chỉ muốn thắng / Chơi giải

## PHẦN 2 — Sau trận đấu (phần quan trọng)

**A. Mức độ mệt:** Không mệt / Mệt nhẹ / Mệt / Rất mệt

**B. Mệt ở đâu (chọn nhiều):** Tay / Vai / Cổ tay / Lưng / Mắt / Thể lực

**C. Tinh thần:** Rất tự tin / Ổn / Bình thường / Thiếu tự tin / Áp lực

**D. Đánh giá bản thân:** phong độ ★★★★★ → ★☆☆☆☆

**E. Điều gì ảnh hưởng nhiều nhất?:** Break kém / Điều bi / Miss bi dễ / Tâm lý / Mệt / Đối thủ quá mạnh / Không quen bàn / Khác...

## PHẦN 3 — AI KHÔNG PHÂN TÍCH NGAY

Task này chỉ lưu dữ liệu. Không sửa Coach. Không sửa Statistics. Không tạo Insight. Chỉ tạo nguồn dữ liệu.

## PHẦN 4 — Giá trị sau này

Sau vài chục Match, Pool OS sẽ tự biết (ví dụ): "Bạn thường đánh tốt hơn khi đã khởi động, bàn quen, không quá 2 giờ, thể lực còn tốt." Hoặc "73% trận bạn đánh kém đều xuất hiện khi không warm-up, mắt mỏi, vai mỏi." Đây là nền cho Warm-up Intelligence và Fatigue Intelligence ở các task sau.

## Không làm trong Task này
- Không sửa Coach.
- Không sửa Statistics.
- Không sửa Skill Tree.
- Không sửa Equipment.
- Không thêm AI.

## Definition of Done
- Có màn hình nhập Trước trận đấu.
- Có màn hình nhập Sau trận đấu.
- Dữ liệu lưu bền vững theo từng Match.
- Người chơi chỉ mất khoảng 15–20 giây để hoàn thành mỗi màn nhập.
- Toàn bộ dữ liệu sẵn sàng cho các Task 07–12 sử dụng.
