# UATV1.0_06_DailyReadiness

## Module

Daily Readiness

## Priority

HIGH

### DR-001 Không có nút Lưu

**Current** - Người dùng nhập dữ liệu nhưng không có nút Lưu. - Vuốt
Back hoặc bấm Back làm thoát màn hình, dữ liệu không được lưu.

**Expected** - Có nút **Lưu** cố định. - Có nút **Hủy**. - Khi có thay
đổi mà chưa lưu, hỏi xác nhận trước khi thoát.

------------------------------------------------------------------------

### DR-002 Mất dữ liệu

**Current** - Sau khi nhập dữ liệu, quay lại Dashboard rồi mở lại thì dữ
liệu biến mất.

**Expected** - Sau khi lưu, dữ liệu phải được giữ nguyên. - Dashboard sử
dụng đúng dữ liệu vừa lưu.

------------------------------------------------------------------------

### DR-003 Điều hướng

**Current** - Vuốt Back thoát App.

**Expected** - Back chỉ đóng màn hình Daily Readiness. - Không được
thoát ứng dụng.

------------------------------------------------------------------------

### DR-004 Dashboard Sync

**Expected** - Sau khi lưu Readiness: - Dashboard cập nhật ngay. - Coach
sử dụng dữ liệu mới. - Không cần khởi động lại App.

## Acceptance Criteria

-   Có nút Lưu.
-   Có cảnh báo khi thoát chưa lưu.
-   Không mất dữ liệu.
-   Dashboard cập nhật ngay sau khi lưu.
