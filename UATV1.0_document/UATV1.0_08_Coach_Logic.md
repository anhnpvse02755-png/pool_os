# UATV1.0_08_Coach_Logic

## Module

Coach

## Priority

HIGH

### COACH-001 Trọng tâm hôm nay

**Current** - Coach khuyến nghị cải thiện tỷ lệ phá dù dữ liệu chỉ có 1
rack phá thành công. - Có dấu hiệu suy luận sai hoặc thiếu dữ liệu.

**Expected** - Chỉ kết luận khi dữ liệu đủ tin cậy. - Hiển thị mức
**Coach Data Confidence**. - Nếu dữ liệu chưa đủ phải nói rõ "chưa đủ dữ
liệu".

------------------------------------------------------------------------

### COACH-002 Gợi ý huấn luyện viên

**Current** - Nội dung gần như trùng với Trọng tâm hôm nay.

**Expected** - Trọng tâm hôm nay = 1 ưu tiên quan trọng nhất. - Gợi ý
huấn luyện viên = danh sách bài tập, kiến thức và lộ trình nên thực
hiện.

------------------------------------------------------------------------

### COACH-003 Không bịa dữ liệu

**Expected** - Mọi nhận xét phải dựa trên dữ liệu thật. - Không suy luận
nếu chưa đủ dữ liệu.

------------------------------------------------------------------------

### COACH-004 Mục đích buổi chơi

Coach phải đánh giá theo mục đích: - Thi đấu để thắng. - Thi đấu để
luyện tập. - Thi đấu kết hợp.

Không dùng cùng một tiêu chí cho mọi buổi chơi.

## Acceptance Criteria

-   Coach không đưa nhận xét sai khi dữ liệu ít.
-   Có Coach Data Confidence.
-   Trọng tâm và Gợi ý khác vai trò.
-   Mọi nhận xét truy vết được tới dữ liệu.
