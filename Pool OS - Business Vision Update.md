# Pool OS - Business Vision Update
Version: 1.0
Status: Product Vision
Owner: Product Owner

---

# Triết lý mới

Pool OS không phải ứng dụng ghi điểm.

Pool OS là hệ điều hành giúp người chơi hiểu chính mình.

Mục tiêu cuối cùng không phải lưu dữ liệu.

Mục tiêu cuối cùng là trả lời:

"Tại sao hôm nay mình đánh tốt?"
"Tại sao hôm nay mình đánh tệ?"
"Làm gì để đánh tốt hơn?"

AI phải tìm được nguyên nhân.

---

# AI không chỉ phân tích kỹ thuật

Đa số ứng dụng billiards hiện nay chỉ phân tích:

- thắng
- thua
- break
- run out
- foul

Pool OS phải phân tích cả con người.

AI cần hiểu:

- thể trạng
- tâm lý
- khả năng làm nóng
- độ bền
- khả năng duy trì phong độ
- khả năng chịu áp lực

---

# Mô hình hiệu suất

Performance

=

Kỹ thuật
×

Thể trạng
×

Tâm lý
×

Độ làm nóng
×

Độ bền
×

Thiết bị

Không được đánh giá người chơi chỉ bằng Win Rate.

---

# Các nhóm dữ liệu AI

## 1. Kỹ thuật

Đã có

- Shot
- Event
- Rack
- Match
- Session
- Statistics

---

## 2. Thể trạng trước khi chơi

Đã có

Daily Readiness

Ví dụ

- ngủ
- mệt
- đau vai
- đau tay
- tinh thần

Đây là trạng thái trước khi bắt đầu.

---

## 3. Thể trạng sau khi chơi (NEW)

Sau khi kết thúc Session.

Pool OS hỏi:

Hiện tại bạn cảm thấy:

- Tay còn khỏe
- Hơi mỏi
- Rất mỏi

Vai

- Bình thường
- Mỏi
- Đau

Mắt

- Bình thường
- Mỏi

Tinh thần

- Bình thường
- Mất tập trung

Mức tiêu hao

- thấp
- trung bình
- cao

Không hỏi trong lúc thi đấu.

Chỉ hỏi sau Session.

---

## 4. Khả năng làm nóng (NEW)

Đây là chỉ số cực kỳ quan trọng với cơ thủ nghiệp dư.

Một số người:

- đánh rất tệ 3 rack đầu
- sau đó đánh cực hay

Một số người:

- vào là đánh tốt ngay

AI phải học được điều này.

Pool OS sẽ tính:

Warm-up Index

Ví dụ

Rack 1

Accuracy
Safety
Position

↓

Rack 2

↓

Rack 3

↓

Rack 4

↓

Rack 5

Nếu hiệu suất tăng dần

→ người chơi cần thời gian làm nóng.

Nếu ngay Rack đầu đã đạt đỉnh

→ người chơi vào phong độ nhanh.

---

# Warm-up Recommendation

AI có thể đưa lời khuyên:

"Bạn thường đạt phong độ sau Rack 4."

Khuyến nghị:

- khởi động 20 phút
- đánh 3 rack trước khi thi đấu

Hoặc

"Bạn vào phong độ rất nhanh."

Không cần warm-up quá lâu.

---

## 5. Độ bền (Endurance)

AI phải biết:

Người chơi đánh tốt trong bao lâu.

Ví dụ

Accuracy

Rack

1

2

3

4

5

6

7

8

9

10

11

12

Nếu từ Rack 8 trở đi giảm mạnh

AI biết:

Fatigue Threshold = Rack 8

Hoặc

Time Threshold = 2 giờ

---

# Endurance Recommendation

Ví dụ

"Bạn bắt đầu giảm hiệu suất sau khoảng 2 giờ."

Khuyến nghị:

- nghỉ 5 phút
- uống nước
- kéo giãn vai

---

## 6. Thiết bị

Mỗi Match phải lưu:

- Cue chơi
- Cue phá
- Tip
- Shaft

AI sẽ tìm:

Thiết bị nào giúp người chơi đánh tốt nhất.

---

## 7. Điều kiện thi đấu

Session cần lưu:

- thi đấu
- luyện tập

Địa điểm

- CLB

Bàn

- 9ft
- 10ft

Ánh sáng

(nếu sau này có)

---

## 8. Đối thủ

Nếu là Match.

Lưu:

- đối thủ
- trình độ
- handicap

AI sẽ biết:

Người chơi đánh tốt hơn khi gặp:

- đối thủ mạnh
- đối thủ yếu
- ngang trình

---

## 9. Tâm lý

Sau Match.

Pool OS hỏi:

Bạn có bị:

- run
- nóng vội
- mất bình tĩnh
- quá tự tin

Không hỏi nhiều.

Chỉ 1~2 câu.

---

# Nguyên tắc AI

AI KHÔNG chỉ nhìn Shot.

AI luôn nhìn toàn bộ bối cảnh.

Performance
=
Skill
+
Condition
+
Warm-up
+
Endurance
+
Equipment
+
Psychology

---

# Giá trị khác biệt

Pool OS không chỉ trả lời:

"Bạn đánh như thế nào."

Pool OS phải trả lời:

"Tại sao bạn đánh như vậy."

Và

"Làm gì để lần sau đánh tốt hơn."

Đây là giá trị cốt lõi của Pool OS.
