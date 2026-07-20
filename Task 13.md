# Pool OS

# Task 13

## Tournament & League Management

---

## Mục tiêu

Pool OS không chỉ quản lý Match.

Pool OS phải quản lý cả giải đấu.

Task 13 xây dựng toàn bộ hệ thống Tournament.

Không có AI.

---

# Phần 1

## Tournament

Người chơi có thể tạo giải đấu.

Ví dụ

- Club Weekly

- Race To G

- Company Cup

- Team League

...

Thông tin

- Tên giải

- Địa điểm

- Ngày bắt đầu

- Ngày kết thúc

- Ghi chú

---

# Phần 2

## Tournament Type

Hỗ trợ

- Single Elimination

- Double Elimination

- Round Robin

- League

Claude tự thiết kế kiến trúc.

---

# Phần 3

## Participants

Quản lý người tham gia.

Có thể

- Chọn Player có sẵn

- Thêm khách

- Seed

---

# Phần 4

## Bracket

Hiển thị

Bracket

↓

Người thắng

↓

Người thua

↓

Tự động cập nhật.

---

# Phần 5

## Match Integration

Match trong Tournament

vẫn sử dụng

Recording Pipeline hiện tại.

Không tạo Recording mới.

Một Match chỉ cần biết

TournamentID.

---

# Phần 6

## Standing

Hiển thị

- Thắng

- Thua

- Rack thắng

- Rack thua

- Điểm

- Xếp hạng

---

# Phần 7

## Statistics

Theo Tournament.

Ví dụ

Break %

Stop Shot %

Safety %

...

Không sửa Statistics Engine.

Chỉ filter theo Tournament.

---

# Phần 8

## History

Lưu lịch sử

Giải đã tham gia.

Giải đã vô địch.

Hạng đạt được.

---

# Phần 9

## UI

Tournament

↓

Bracket

↓

Standing

↓

Matches

↓

Statistics

↓

History

Claude tự thiết kế.

---

# Không làm

Không AI.

Không Coach.

Không Recommendation.

Không thay đổi Recording Pipeline.

Không thay đổi Statistics Engine.

---

# Coding Rules

Claude được quyền quyết định

- Database

- Repository

- Provider

- Widget

- Navigation

Miễn

Không phá các Task đã LOCKED.

---

# Definition of Done

Có Tournament.

Có Bracket.

Có Standing.

Có Match Integration.

Có Tournament Statistics.

Có Tournament History.

flutter analyze sạch.

flutter test pass.

APK build.

Commit riêng Task 13.
