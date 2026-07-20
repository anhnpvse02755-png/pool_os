# RFC-303 — Competition State Model
Version: 1.0
Status: Approved
Priority: High

---

# Mục tiêu

Pool OS không chỉ đánh giá kỹ năng của người chơi.

Pool OS phải hiểu:

- Người chơi đang ở trạng thái thể lực nào.
- Người chơi vào form nhanh hay chậm.
- Người chơi duy trì phong độ được bao lâu.
- Khi nào người chơi bắt đầu xuống sức.
- Vì sao người chơi thắng hoặc thua.

AI Coach phải nhìn được toàn bộ quá trình này.

---

# 1. Readiness KHÔNG đại diện cho thể trạng trong suốt buổi chơi

Readiness chỉ phản ánh trạng thái trước khi bắt đầu.

Ví dụ

09:00

Người chơi đánh giá

Energy = 90
Focus = 85
Stress = 20

=> Đây chỉ là trạng thái trước buổi chơi.

Sau 3 tiếng thi đấu

Readiness ban đầu không còn đúng.

Pool OS phải hiểu rằng:

Thể trạng luôn thay đổi theo thời gian.

---

# 2. Thêm khái niệm Competition State

Competition State phản ánh trạng thái của người chơi trong quá trình thi đấu.

Nó khác hoàn toàn Readiness.

Readiness

=

Trước buổi chơi

Competition State

=

Trong buổi chơi

---

# 3. Competition State được cập nhật sau mỗi Match

Không hỏi sau mỗi Shot.

Không hỏi sau mỗi Rack.

Sau mỗi Match hoặc sau một khoảng thời gian đủ dài.

Ví dụ

Sau Match

App hỏi

Hiện tại bạn cảm thấy thế nào?

Người chơi chọn

- Tay bắt đầu mỏi
- Vai mỏi
- Mắt mỏi
- Tập trung giảm
- Căng thẳng tăng
- Vẫn sung sức

Có thể chọn nhiều.

---

# 4. Các chỉ số cần lưu

## Physical Fatigue

0-100

Đánh giá mệt thể lực.

---

## Arm Fatigue

0-100

Mỏi tay.

---

## Shoulder Fatigue

0-100

Mỏi vai.

---

## Eye Fatigue

0-100

Mỏi mắt.

---

## Focus

0-100

Khả năng tập trung hiện tại.

---

## Confidence

0-100

Độ tự tin.

---

## Mental Pressure

0-100

Áp lực thi đấu.

---

## Rhythm

0-100

Cảm giác cơ.

Ví dụ

"Vào cơ rất ngọt"

hoặc

"Đánh không còn cảm giác."

---

# 5. Phân tích khả năng duy trì phong độ

AI không chỉ biết người chơi mạnh.

AI phải biết

Người chơi mạnh được BAO LÂU.

Ví dụ

Player A

Rack 1-5

Performance

92

Rack 6-10

88

Rack 11-15

84

Rack 16-20

79

=> Người chơi xuống phong độ từ Rack 12.

AI ghi nhận

Endurance tốt.

Nhưng cần tăng khả năng duy trì sau Rack 10.

---

Player B

Rack 1-5

88

Rack 6-20

87

=> Người chơi duy trì phong độ rất ổn.

---

Đây là một kỹ năng hoàn toàn khác Accuracy.

---

# 6. Chỉ số Endurance

Pool OS sinh thêm chỉ số

Endurance

0-100

Được tính từ

- số Rack
- thời gian thi đấu
- Performance theo thời gian
- Competition State

Ví dụ

Endurance

92

AI

Bạn gần như giữ nguyên chất lượng trong suốt buổi chơi.

---

Endurance

45

AI

Sau khoảng 90 phút bạn bắt đầu xuống rõ rệt.

---

# 7. Khái niệm Warm-up Curve

Đây là hành vi rất phổ biến ở người chơi nghiệp dư.

Không phải ai cũng vào bàn là đánh tốt.

Nhiều người cần vài Rack để "nóng máy".

Pool OS phải theo dõi điều này.

---

Ví dụ

Performance

Rack 1

60

Rack 2

65

Rack 3

71

Rack 4

79

Rack 5

87

Rack 6

90

Rack 7

91

AI kết luận

Bạn là người vào form chậm.

Bạn cần khoảng 5 Rack để đạt phong độ cao nhất.

---

Người khác

Rack 1

90

Rack 2

91

Rack 3

89

Rack 4

90

=> Warm-up rất nhanh.

---

# 8. Chỉ số Warm-up Speed

Sinh thêm chỉ số

Warm-up Speed

0-100

Ví dụ

95

Vào form ngay.

40

Cần nhiều thời gian để đạt cảm giác.

---

# 9. Coach sử dụng dữ liệu này

Ví dụ

AI nói

Bạn thường mất khoảng 4 Rack để đạt phong độ.

Nếu thi đấu Race 5, khả năng bị dẫn trước rất cao.

Khuyến nghị

Khởi động ít nhất 15 phút trước trận.

Hoặc

Đánh vài Rack khởi động trước khi thi đấu chính thức.

---

Hoặc

Bạn duy trì phong độ rất tốt trong 3 giờ đầu.

Sau đó Focus giảm nhanh.

Khuyến nghị

Nghỉ 10 phút sau mỗi 2 giờ.

---

# 10. Điều này KHÔNG ảnh hưởng Readiness

Readiness

=

Đầu ngày.

Competition State

=

Trong buổi chơi.

Hai mô hình hoàn toàn khác nhau.

AI sử dụng cả hai.

Readiness

để dự đoán.

Competition State

để xác nhận.

Sau nhiều tháng,

AI sẽ học được

- Readiness bao nhiêu thì người chơi giữ phong độ tốt.
- Readiness thấp nhưng vẫn đánh tốt.
- Người chơi nào xuống sức nhanh.
- Người chơi nào cần nhiều thời gian khởi động.
- Người chơi nào càng đánh càng hay.

Đây là nền tảng để AI Coach cá nhân hóa theo đúng từng người chơi.
