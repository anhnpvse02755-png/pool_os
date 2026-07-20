# Pool OS

# Task 12

## Data Center

---

## Mục tiêu

Pool OS lưu trữ toàn bộ hành trình của người chơi.

Dữ liệu này có giá trị rất lớn.

Task 12 xây dựng hệ thống quản lý dữ liệu.

Mục tiêu:

- Người chơi không bao giờ sợ mất dữ liệu.
- Có thể chuyển sang máy khác.
- Có thể backup.
- Có thể restore.
- Có thể export để phân tích.

Task này KHÔNG có AI.

---

# Phần 1

## Backup

Cho phép tạo Backup toàn bộ dữ liệu.

Bao gồm

- Player

- Equipment

- Match

- Session

- Rack

- Shot

- Event

- Training

- Goal

- Timeline

- Statistics

- Match Context

- Warm-up

- Endurance

...

Claude tự quyết định format.

---

# Phần 2

## Restore

Restore từ file Backup.

Yêu cầu

Không tạo dữ liệu trùng.

Có kiểm tra version.

Có cảnh báo trước khi ghi đè.

---

# Phần 3

## Export

Cho phép Export

- Excel

- CSV

- JSON

Tùy từng module.

Ví dụ

Export Match History

Export Training

Export Statistics

Export Equipment

...

---

# Phần 4

## Import

Cho phép Import dữ liệu.

Có kiểm tra

- Version

- Duplicate

- Integrity

Không phá dữ liệu hiện có.

---

# Phần 5

## Database Information

Hiển thị

- Version

- Kích thước Database

- Số Player

- Số Match

- Số Rack

- Số Shot

- Số Training

- Dung lượng ảnh (nếu có)

...

---

# Phần 6

## Maintenance

Cho phép

- Dọn dữ liệu tạm

- Rebuild Statistics

- Verify Integrity

- Repair Database

- Compact Database

Không xóa dữ liệu người dùng.

---

# Phần 7

## Multi Device Ready

Chuẩn bị kiến trúc cho

Cloud Sync

Task này KHÔNG cần đồng bộ.

Chỉ cần thiết kế để sau này dễ mở rộng.

---

# UI

Một màn hình

Data Center

Bao gồm

- Backup

- Restore

- Export

- Import

- Database Info

- Maintenance

---

# Không làm

Không AI.

Không Cloud Sync.

Không sửa Recording Pipeline.

Không sửa Statistics Engine.

---

# Coding Rules

Claude tự quyết định

- Database

- Repository

- Provider

- Widget

- Export Format

Miễn

Không phá các Task đã LOCKED.

---

# Definition of Done

Có Backup.

Có Restore.

Có Export.

Có Import.

Có Database Information.

Có Maintenance.

flutter analyze sạch.

flutter test pass.

APK build.

Commit riêng Task 12.
