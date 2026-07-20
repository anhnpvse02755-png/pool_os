# UATV1.0_03_Dashboard

## Module

Dashboard

## Priority

HIGH

## DASH-001 Quick Action hiển thị sai

### Current

-   Sau khi kết thúc toàn bộ Buổi chơi/Bài tập, Dashboard vẫn hiển thị
    Continue/Finish.
-   Có trường hợp bấm không có tác dụng.
-   Có trường hợp đã kết thúc nhưng nút vẫn còn.

### Expected

-   Quick Action chỉ hiển thị khi tồn tại đúng 01 Active Session.
-   Không còn Active Session thì ẩn hoàn toàn.

### Suggested Fix

-   Kiểm tra Active Session Provider.
-   Chỉ render khi có Active Session.
-   Finish Session phải invalidate provider và refresh Dashboard.

### Acceptance Criteria

-   Không có Active Session =\> không hiển thị Continue/Finish.
-   Finish Session =\> Dashboard cập nhật ngay.

------------------------------------------------------------------------

## DASH-002 Focus Today đánh giá sai

### Current

-   Chỉ mới có 1 trận Race to 9 và 1 rack phá thành công.
-   Coach vẫn kết luận cần cải thiện tỷ lệ phá.

### Expected

-   Nếu dữ liệu chưa đủ thì phải trả về "Dữ liệu chưa đủ để đánh giá".
-   Không được suy luận khi sample quá nhỏ.

### Acceptance Criteria

-   Sample nhỏ =\> không sinh Recommendation.

------------------------------------------------------------------------

## DASH-003 Coach Recommendation trùng Focus Today

### Expected

-   Focus Today = ưu tiên số 1.
-   Coach Recommendation = danh sách bài tập nên thực hiện.

------------------------------------------------------------------------

## DASH-004 Today Status

### Current

-   Không có nút đóng.
-   Vuốt back thoát app.
-   Dữ liệu bị mất.

### Expected

-   Có nút Đóng/Lưu.
-   Giữ dữ liệu sau khi lưu.

------------------------------------------------------------------------

## DASH-005 Current Equipment

Hiển thị đầy đủ: - Cơ đánh - Cơ phá - Cơ nhảy

------------------------------------------------------------------------

## DASH-006 Radar kỹ năng

-   Hiển thị radar trên Dashboard.
-   "Xem tất cả" mở thống kê chi tiết.

------------------------------------------------------------------------

## DASH-007 10 trận gần nhất

-   Mở trận đang diễn ra phải có nút quay lại.

------------------------------------------------------------------------

## DASH-008 Active Session

### Current

Đã kết thúc mọi Session nhưng Dashboard vẫn hiển thị Session đang diễn
ra.

### Expected

Dashboard luôn đồng bộ đúng trạng thái Active Session.
