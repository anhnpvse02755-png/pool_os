# TASK 04 — Equipment Intelligence (Quản lý cơ thông minh)

## Mục tiêu

Pool OS không chỉ quản lý danh sách cơ.

Pool OS phải hiểu:

- Người chơi đang sử dụng cơ nào.
- Cơ đó đảm nhiệm vai trò gì.
- Vai trò đó ảnh hưởng như thế nào đến hiệu suất thi đấu.
- Coach AI có đủ dữ liệu để biết người chơi nên:
  - đổi cơ,
  - luyện thêm kỹ năng,
  - hay không cần thay đổi gì.

## 1. Các loại cơ

Hệ thống hỗ trợ:

- Cơ đánh
- Cơ phá
- Cơ nhảy
- Cơ phá nhảy

Loại cơ được chọn khi tạo.

Ví dụ

- Revo 12.5 → Loại: Cơ đánh
- BK Rush → Loại: Cơ phá
- Air Rush → Loại: Cơ nhảy
- CP01 → Loại: Cơ phá nhảy

## 2. Vai trò tự động

Không cho người dùng tick vai trò. Vai trò được suy ra từ loại cơ.

- Cơ đánh → Vai trò: Đánh
- Cơ phá → Vai trò: Phá
- Cơ nhảy → Vai trò: Nhảy
- Cơ phá nhảy → Pool OS tự hiểu Vai trò: Phá + Nhảy

Không cần người dùng cấu hình.

## 3. Chỉ có một cơ đang sử dụng cho mỗi vai trò

Ví dụ

- Đánh: ✓ Revo / Maple
- Phá: ✓ CP01 / BK Rush
- Nhảy: ✓ CP01 / Air Rush

CP01 hoàn toàn có thể đồng thời là:

- Cơ phá hiện tại
- Cơ nhảy hiện tại

Đây là nghiệp vụ hợp lệ.

## 4. Snapshot theo trận đấu

Khi bắt đầu Match, Pool OS lưu snapshot:

- Playing Cue
- Break Cue
- Jump Cue

Snapshot này không thay đổi. Nếu sau này người chơi đổi cơ mặc định thì lịch sử cũ vẫn giữ nguyên.

## 5. Shot tự chọn đúng cơ

Người dùng KHÔNG chọn cơ khi nhập Shot. Pool OS tự quyết định.

- Shot Type Break → Dùng Break Cue
- Shot Type Jump → Dùng Jump Cue
- Shot Type Normal → Dùng Playing Cue

## 6. Thống kê theo vai trò

Không thống kê theo tên cơ. Thống kê theo: Tên cơ + Vai trò.

Ví dụ

- CP01 — Vai trò Phá: Break Success, Break & Run, Scratch, Power, Spread
- CP01 — Vai trò Nhảy: Jump Attempt, Jump Success, Jump Pot, Jump Miss, Jump Foul

Hai nhóm thống kê hoàn toàn độc lập.

## 7. Coach AI

Coach phải biết phân biệt:

Trường hợp 1

- Break 84% / Jump 42% → Kết luận: Không phải do cơ. Kỹ thuật Jump còn yếu.

Trường hợp 2

- Đổi sang Air Rush: Jump 42% → 69% → Coach: Hiệu suất Jump tăng mạnh. Equipment có ảnh hưởng. Có thể tiếp tục sử dụng Air Rush.

Trường hợp 3

- Đổi cơ nhưng 42% → 43% → Coach: Không có khác biệt. Không nên đầu tư thêm Equipment. Nên luyện kỹ thuật Jump.

## 8. Giá trị của Pool OS

Pool OS phải trả lời được các câu hỏi:

- Cơ nào giúp người chơi phá tốt nhất?
- Cơ nào giúp người chơi Jump tốt nhất?
- Có nên mua thêm cơ Jump riêng?
- Có nên tiếp tục dùng cơ phá nhảy?
- Vấn đề nằm ở Equipment hay Kỹ năng?

## 9. UI

Danh sách cơ phải hiển thị rõ.

Ví dụ

- Revo 12.5 [Cơ đánh] ✓ Đang dùng
- CP01 [Cơ phá nhảy] ✓ Cơ phá hiện tại ✓ Cơ nhảy hiện tại
- Air Rush [Cơ nhảy]

Không cần mở chi tiết vẫn biết ngay cơ nào đang được dùng cho từng vai trò.

## Definition of Done

- Hỗ trợ đầy đủ 4 loại cơ.
- Cơ phá nhảy tự động đảm nhiệm cả vai trò Phá và Nhảy.
- Mỗi vai trò chỉ có một cơ đang sử dụng.
- Match lưu snapshot Equipment.
- Shot tự xác định đúng cơ theo Shot Type.
- Thống kê tách riêng theo từng vai trò.
- Coach AI có thể phân biệt vấn đề do Equipment hay do kỹ năng.
- UI hiển thị rõ cơ đang dùng cho từng vai trò.
- Không làm thay đổi lịch sử khi đổi cơ mặc định sau này.
