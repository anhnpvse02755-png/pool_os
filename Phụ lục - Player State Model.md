# Phụ lục - Hiểu về trạng thái người chơi (Player State Model)

## Triết lý

Pool OS không chỉ phân tích kỹ thuật đánh bi.

Một người chơi có thể đánh không tốt không phải vì kỹ thuật kém, mà vì:

- chưa nóng người
- chưa vào tay
- mệt sau thời gian dài thi đấu
- mất tập trung
- áp lực tâm lý
- thiếu tự tin
- bị ảnh hưởng bởi đối thủ

Vì vậy AI Coach phải hiểu được **trạng thái của người chơi theo thời gian**, không chỉ nhìn vào kết quả thắng thua.

---

# 1. Sẵn sàng hàng ngày (Baseline)

Đây là trạng thái trước khi người chơi bắt đầu bất kỳ buổi chơi nào.

Ví dụ:

- ngủ bao nhiêu giờ
- mức năng lượng
- tinh thần
- đau mỏi
- stress
- mức tập trung

Đây được coi là "điểm xuất phát".

Ví dụ:

Hôm nay người chơi có Readiness = 92

=> AI hiểu đây là một ngày thể trạng rất tốt.

Readiness KHÔNG thay đổi trong suốt ngày hôm đó.

---

# 2. Trạng thái trước trận đấu

Trước khi bắt đầu mỗi trận đấu (Match), AI nên hỏi nhanh người chơi một số câu.

Ví dụ:

- Đã khởi động kỹ chưa?
- Đã đánh làm nóng chưa?
- Tay đã vào cảm giác chưa?

Không cần quá nhiều câu hỏi.

Chỉ cần biết:

- Đã sẵn sàng thi đấu chưa?

Điều này hoàn toàn khác với Readiness.

Ví dụ:

Readiness = 95

Nhưng:

- vừa đến quán
- chưa đánh quả nào

=> Người chơi vẫn chưa "vào tay".

---

# 3. Chỉ số "Vào tay"

Đây là một trong những chỉ số quan trọng nhất với người chơi nghiệp dư.

Khái niệm:

Người chơi cần một khoảng thời gian để:

- nhớ cơ
- lấy cảm giác
- làm quen tốc độ bàn
- làm quen băng
- làm quen bi
- ổn định lực

Trong vài rack đầu:

- dễ hụt bi
- dễ non lực
- dễ quá lực
- dễ run

Sau đó phong độ mới tăng lên.

AI cần học được:

Ví dụ:

Người A

- Rack 1-3 đánh rất tệ
- Rack 4 trở đi đánh rất tốt

=> AI kết luận:

"Bạn cần khoảng 3 rack để vào tay."

Lần sau AI sẽ khuyên:

"Hãy đánh warm-up khoảng 15 phút hoặc chơi vài rack khởi động trước khi vào trận chính."

Đây là khả năng học theo lịch sử, không phải người chơi nhập tay.

---

# 4. Thể lực khi thi đấu

Readiness chỉ phản ánh đầu ngày.

Trong quá trình thi đấu, thể lực sẽ thay đổi.

Ví dụ:

Người A

Rack 1-5

- phong độ rất tốt

Rack 6-10

- bắt đầu giảm

Rack 11-15

- giảm rõ rệt

AI kết luận:

Người chơi duy trì phong độ khoảng:

- 5 rack
- hoặc 60 phút

Sau mốc đó:

- độ chính xác giảm
- lỗi tăng
- quyết định kém hơn

Một người khác có thể duy trì:

- 15 rack
- hoặc 4 giờ

=> Đây là chỉ số cá nhân.

AI phải học theo lịch sử.

---

# 5. Thể lực sau trận

Sau khi kết thúc Match hoặc Session, AI nên hỏi nhanh.

Ví dụ:

"Mức mệt hiện tại?"

Có thể chọn:

- Không mệt
- Hơi mệt
- Mệt
- Rất mệt

Thông tin này dùng để:

- học sức bền
- phân tích thời gian thi đấu tối ưu
- lập kế hoạch luyện tập

---

# 6. Quan hệ giữa các trạng thái

Readiness
↓

Trước trận

↓

Vào tay

↓

Thi đấu

↓

Thể lực giảm dần

↓

Kết thúc trận

↓

Đánh giá mức mệt

AI phải hiểu đây là một chuỗi liên tục.

Không được coi đây là các dữ liệu độc lập.

---

# 7. Nguyên tắc phân tích của AI

AI không được kết luận:

"Bạn đánh kém."

AI phải tìm nguyên nhân.

Ví dụ:

- chưa vào tay
- chưa khởi động
- thể lực giảm
- thiếu tập trung
- áp lực
- kỹ thuật

Nếu nguyên nhân không phải kỹ thuật thì KHÔNG được đề xuất bài tập kỹ thuật.

Ví dụ:

Nếu phát hiện:

- Rack đầu đánh kém
- Rack sau đánh rất tốt

AI phải kết luận:

"Bạn cần cải thiện quá trình khởi động."

KHÔNG phải:

"Hãy luyện Stop Shot."

---

# 8. Thứ tự ưu tiên khi AI phân tích

AI luôn phân tích theo thứ tự:

1. Thể trạng (Readiness)
2. Trạng thái trước trận
3. Chỉ số vào tay
4. Thể lực trong trận
5. Tâm lý
6. Kỹ thuật
7. Chiến thuật

Chỉ khi các yếu tố trên bình thường thì mới kết luận lỗi đến từ kỹ thuật.

---

# 9. Nguyên tắc phát triển

Các trạng thái trên phải được lưu riêng thành dữ liệu lịch sử.

Không được ghi đè.

Không được suy luận bằng dữ liệu giả.

Mọi kết luận của AI phải chỉ ra:

- nguyên nhân
- bằng chứng
- dữ liệu sử dụng

Không được đưa ra khuyến nghị nếu chưa đủ dữ liệu lịch sử.
