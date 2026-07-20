# UATV1.0_10_Architecture_Optimization

## Module

Architecture / Product Direction

## Priority

MEDIUM

### ARC-001 Phân tách rõ các chức năng

**Expected**

Ứng dụng được chia thành 3 nhóm chính:

1.  Learning Hub

-   Kiến thức
-   Bài tập
-   Lộ trình học

2.  Play Session

-   Thi đấu thực tế giữa 2 người hoặc đội
-   Chỉ ghi nhận dữ liệu trận đấu

3.  Coach

-   Phân tích dữ liệu
-   Đưa ra nhận xét
-   Đề xuất bài tập
-   Đề xuất kiến thức

------------------------------------------------------------------------

### ARC-002 Mục đích buổi chơi

Khi bắt đầu buổi chơi phải chọn:

-   Thi đấu để thắng
-   Thi đấu để luyện tập
-   Kết hợp

Coach phải đánh giá khác nhau theo mục đích.

------------------------------------------------------------------------

### ARC-003 Learning Hub

Learning Hub chỉ có nhiệm vụ:

-   Học kiến thức
-   Thực hiện bài tập
-   Theo lộ trình

Không ghi nhận dữ liệu thi đấu.

------------------------------------------------------------------------

### ARC-004 Play Session

Play Session chỉ dành cho:

-   Thi đấu thật
-   Race
-   Tournament
-   Challenge

Không chứa workflow bài tập.

------------------------------------------------------------------------

### ARC-005 Coach

Coach là trung tâm.

Coach sử dụng:

-   Daily Readiness
-   Play Session
-   Tournament
-   Training
-   Equipment

để phân tích người chơi.

## Acceptance Criteria

-   Không còn chức năng chồng chéo.
-   Coach là trung tâm phân tích.
-   Learning Hub và Play Session có trách nhiệm rõ ràng.
