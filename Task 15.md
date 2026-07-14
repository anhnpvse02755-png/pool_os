# Pool OS — Task 15
# Coach Intelligence V2
# Product Vision Update

## Context

Task 1 → Task 14 đã hoàn thành.

Pool OS hiện đã có:

- Match Recording
- Ghost
- Statistics
- Equipment Intelligence
- Readiness
- Warm-up Intelligence
- Endurance Intelligence
- Player Profile
- Match Context
- Training Center
...

Từ Task 15 trở đi, trọng tâm của sản phẩm thay đổi.

Không còn phát triển từng module riêng lẻ.

Bắt đầu phát triển "Coach".

---

# Product Goal

Pool OS KHÔNG phải là ứng dụng ghi điểm.

Pool OS KHÔNG phải là ứng dụng thống kê.

Pool OS là một HLV cá nhân (Personal Pool Coach).

Mục tiêu lớn nhất của sản phẩm là:

Giúp người chơi biết

- Tôi đang ở trình độ nào?
- Tôi đang yếu ở đâu?
- Vì sao tôi yếu?
- Tôi cần làm gì tiếp theo để nâng trình độ?

Coach là nơi duy nhất trả lời các câu hỏi này.

---

# Architecture Principle

Không thay đổi kiến trúc hiện tại.

Không tạo module mới.

Không đổi tên màn hình.

Không thay đổi Navigation.

Training Center vẫn là Training Center.

Equipment vẫn là Equipment.

Statistics vẫn là Statistics.

Match vẫn là Match.

Ghost vẫn là Ghost.

Mỗi module vẫn giữ nguyên nhiệm vụ của mình.

Coach không thay thế các module.

Coach chỉ sử dụng dữ liệu từ các module.

---

# Coach Principle

Coach là trung tâm giá trị của Pool OS.

Coach không lưu dữ liệu.

Coach không sửa dữ liệu.

Coach chỉ

- đọc dữ liệu
- phân tích
- giải thích
- hướng dẫn người chơi

---

# Data Principle

Coach không bắt buộc phải có đầy đủ dữ liệu.

Coach phải luôn làm việc với dữ liệu hiện có.

Ví dụ

Chỉ có dữ liệu Training

↓

Coach vẫn đưa ra nhận xét.

Ví dụ

"Stop Shot của bạn rất tốt trong môi trường luyện tập."

Sau đó Coach phải giải thích

"Tôi chưa có dữ liệu thi đấu.

Bạn nên chơi thêm Match hoặc Ghost để tôi đánh giá chính xác hơn."

---

# Data Confidence

Coach phải hiểu độ tin cậy của kết luận.

Coach phải biết

- dữ liệu nào đang có
- dữ liệu nào đang thiếu
- dữ liệu nào mâu thuẫn

Ví dụ

Training

95%

Match

61%

↓

Coach không được nói

"Stop Shot tốt."

Coach phải nói

"Kỹ thuật Stop Shot rất tốt trong luyện tập.

Hiệu quả giảm khi thi đấu.

Bạn nên luyện khả năng áp dụng dưới áp lực."

---

# UX Principle

Người dùng không cần đọc hướng dẫn sử dụng.

Người dùng không cần tự suy nghĩ

"Tôi phải làm gì tiếp?"

Coach phải luôn hướng dẫn.

Ví dụ

"Bạn chưa có đủ dữ liệu Jump."

↓

Coach phải đưa Action

[Luyện Jump]

↓

Đi đến Training Center.

---

Ví dụ

"Bạn chưa ghi Readiness hôm nay."

↓

[Cập nhật Readiness]

↓

Đi đúng màn hình.

---

Ví dụ

"Bạn cần thêm dữ liệu Match."

↓

[Tạo Match]

↓

Đi đúng màn hình.

---

# Coach Insight

Mỗi Insight phải gồm

1.

Nhận xét.

2.

Nguyên nhân.

3.

Bằng chứng.

4.

Độ tin cậy.

5.

Hành động tiếp theo.

Không được chỉ hiển thị Recommendation.

Coach phải giải thích để người chơi hiểu.

---

# Navigation Principle

Coach trở thành người dẫn đường của toàn bộ ứng dụng.

Coach không chỉ phân tích.

Coach còn dẫn người dùng đến đúng chức năng.

Người dùng gần như không cần phải tự tìm menu.

---

# Functional Principle

Training Center

vẫn là nơi học.

Equipment

vẫn là nơi quản lý cơ.

Statistics

vẫn là nơi xem thống kê.

Match

vẫn là nơi ghi trận đấu.

Coach không thay thế bất kỳ module nào.

Coach chỉ kết nối tất cả các module.

---

# Claude Task

Dựa trên toàn bộ hệ thống hiện tại.

Không phá kiến trúc.

Không tạo lại ứng dụng.

Không viết lại module.

Hãy nâng cấp Coach trở thành trung tâm của Pool OS.

Mọi đề xuất UI/UX đều phải hướng tới mục tiêu:

"Người chơi chỉ cần mở Pool OS và làm theo Coach."

Nếu có nhiều phương án thiết kế,

hãy chọn phương án có UX đơn giản nhất,

ít thao tác nhất,

và phù hợp với người chơi nghiệp dư.

Pool OS không cố gắng trở thành ứng dụng có nhiều chức năng nhất.

Pool OS phải trở thành ứng dụng giúp người chơi tiến bộ nhanh nhất.
