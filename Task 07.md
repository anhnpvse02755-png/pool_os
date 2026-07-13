# TASK 07 — Warm-up Intelligence & Phong độ theo thời gian

## Mục tiêu

Pool OS phải học được:
- Người chơi cần bao lâu để vào phong độ.
- Người chơi duy trì phong độ được bao lâu.

Đây không phải dữ liệu người chơi nhập. Đây là AI tự học từ hàng trăm Rack.

## Mục tiêu phân tích

Pool OS phải trả lời được:

### 1. Người chơi nóng máy sau bao nhiêu rack?

Ví dụ:
- Rack 1 → độ chính xác 48%
- Rack 2 → 61%
- Rack 3 → 72%
- Rack 4 → 81%
- Rack 5 → 84%

Coach kết luận: "Bạn thường cần khoảng 4 rack để đạt phong độ tốt nhất."

### 2. Phong độ giảm từ khi nào?

Ví dụ:
- Rack 1-8 → Ổn định
- Rack 9-12 → Giảm nhẹ
- Rack 13+ → Giảm mạnh

Coach: "Sau khoảng 12 rack bạn bắt đầu mất độ chính xác."

### 3. Thời gian

Ngoài số rack, Pool OS cũng học theo thời lượng: 30 phút → 1 giờ → 2 giờ → 3 giờ.
Có người đánh tốt trong 2 giờ. Có người chỉ tốt trong 45 phút.

## Nguồn dữ liệu

Không hỏi thêm người chơi. Sử dụng:
- Thời gian Match
- Thời gian Shot
- Rack, kết quả Rack
- Miss, Easy Miss
- Break, Safety, Position
- Dữ liệu Context của Task 06

AI phải tự phát hiện. Ví dụ: 20 trận, AI thấy 16 trận đều tăng mạnh sau Rack 3 → Kết luận Warm-up trung bình = 3 Rack. Không dùng ngưỡng cứng, mà tự học.

## Mô hình phân tích

- Giai đoạn 1 — Cold Zone (ví dụ Rack 1-2)
- Giai đoạn 2 — Warm-up (Rack 3-5)
- Giai đoạn 3 — Peak (Rack 6-10)
- Giai đoạn 4 — Fatigue (Rack 11+)

AI tự xác định, không hard-code.

## Hiển thị

Không dùng bảng. Dùng biểu đồ vùng / đường cong:

```
Cold      ██████
Warm-up   ██████████
Peak      ██████████████
Fatigue   █████
```

Hoặc timeline theo Rack:

```
Rack       1 2 3 4 5 6 7 8 9 10 11 12
Phong độ   ▁▂▃▄▅▆▇██▇▆▅
```

## Coach phải trả lời

Ví dụ:
- "Bạn thường bỏ lỡ nhiều trong 3 rack đầu."
- "Sau rack thứ 4 bạn ổn định."
- "Sau rack thứ 12 độ chính xác giảm."

## Kết hợp Task 06

Nếu Task 06 lưu "Đã khởi động đầy đủ", AI sẽ so sánh:
- Có khởi động → Peak từ Rack 2
- Không khởi động → Peak từ Rack 5

Coach: "Khởi động giúp bạn vào phong độ sớm hơn khoảng 3 rack."

## Kết hợp Equipment

Ví dụ:
- Cơ A → Warm-up nhanh
- Cơ B → Warm-up chậm

AI sẽ phát hiện.

## Không làm trong Task này
- Không sinh giáo án.
- Không tạo Drill.
- Không sửa Statistics.
- Không sửa Equipment.
- Không thay đổi Recording Pipeline.

## Definition of Done
- AI tự xác định Cold → Warm-up → Peak → Fatigue.
- Không sử dụng ngưỡng cố định.
- Hiển thị đường cong phong độ theo Rack và Thời gian.
- Coach có thể giải thích: khi nào vào phong độ, khi nào bắt đầu giảm, ảnh hưởng của khởi động (Task 06), ảnh hưởng của thời lượng thi đấu.
- Chỉ sử dụng dữ liệu thực, không sinh dữ liệu giả.
