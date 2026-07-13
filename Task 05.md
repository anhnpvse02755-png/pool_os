# TASK 05 — Hồ sơ người chơi (Player Profile)

## Mục tiêu

Pool OS phải hiểu người đang chơi là ai. Không chỉ là tên. Mà là một cơ thủ có:
trình độ, phong cách, mục tiêu, kinh nghiệm, thiết bị, quá trình phát triển.

Player Profile sẽ là trung tâm để AI cá nhân hóa mọi phân tích sau này.

## Những gì cần có

### 1. Thông tin cơ bản
- Tên
- Ảnh đại diện
- Tuổi
- Giới tính (nếu muốn)
- Tay thuận
- CLB/Khu vực (tùy chọn)

### 2. Hồ sơ cơ thủ
- Hạng hiện tại (H, G, F...)
- Mục tiêu
- Game chính (9 Ball / 10 Ball / 8 Ball)

### 3. Phong cách thi đấu
Người chơi có thể chọn nhiều: An toàn, Tấn công, Đánh nhanh, Đánh chắc, Kiểm soát, Phá mạnh.

Coach sẽ dùng để đối chiếu sau này. Ví dụ: người chơi tự đánh giá "đánh chắc" nhưng dữ liệu cho thấy miss nhiều, force shot nhiều, safety ít → Coach sẽ phát hiện sự khác biệt.

### 4. Mục tiêu luyện tập
Ví dụ: Lên hạng G, Ổn định lực phá, Điều bi, Jump, Safety, Thi đấu giải.
Coach sẽ ưu tiên khuyến nghị theo mục tiêu.

### 5. Kinh nghiệm
- Bắt đầu chơi bao lâu
- Đã thi đấu giải chưa
- Bao nhiêu giờ / tuần

### 6. Thiết bị
Không chỉnh Equipment ở đây. Chỉ hiển thị Cơ đánh / Cơ phá / Cơ nhảy đang dùng. Bấm vào sẽ mở màn Equipment.

### 7. Thành tích
Ví dụ: Best Run, Break & Run, Golden Break, Win streak, Tổng số Match. Đây là dữ liệu chỉ đọc.

### 8. Timeline
Người chơi nhìn thấy hành trình. Ví dụ: 02/2026 Bắt đầu chơi → 04/2026 Lên hạng H → 06/2026 Best Run 5 → 08/2026 Break & Run đầu tiên.

### 9. Giá trị của Player Profile
Đây không phải màn hình cài đặt. Đây là "hồ sơ sự nghiệp". Sau này AI sẽ trả lời: Bạn chơi được 18 tháng. Bạn đã tăng từ H lên G. Break tốt hơn 32%. Nhưng Jump gần như không cải thiện.

## Không làm trong Task này
- Không sửa Coach.
- Không sửa Statistics.
- Không thêm AI.
- Không thêm Equipment mới.
- Chỉ xây dựng Player Profile làm nền tảng.

## Definition of Done
- Có màn hình Player Profile hoàn chỉnh.
- Có thể chỉnh sửa hồ sơ.
- Hiển thị thiết bị đang dùng.
- Hiển thị thành tích.
- Hiển thị Timeline phát triển.
- Dữ liệu được lưu bền vững.
- UI đủ đẹp để người chơi có cảm giác đây là "hồ sơ cơ thủ", không phải màn hình Settings.
