# UATV1.0_09_PRODUCT_DIRECTION_POST_UAT

# Mục tiêu

Đây KHÔNG phải tài liệu sửa lỗi.

Đây là định hướng phát triển sản phẩm sau khi UAT V1.

Sau khi toàn bộ bug P0/P1 đã được xử lý, Coach sẽ chuyển sang giai đoạn tối ưu
UX và Product.

---

# 1. Dashboard chỉ là nơi tổng hợp

Dashboard chỉ nên trả lời 4 câu hỏi:

- Hôm nay nên làm gì?
- Tôi đang tiến bộ hay thụt lùi?
- Tôi có buổi chơi nào đang diễn ra?
- Coach muốn tôi tập gì tiếp theo?

Dashboard KHÔNG hiển thị toàn bộ dữ liệu. Dữ liệu chi tiết nằm trong màn hình
riêng.

---

# 2. Rút gọn Tab

Ứng dụng chỉ còn 4 tab:

1. Dashboard
2. Thi đấu
3. Tập luyện
4. Coach

## Dashboard

Trang tổng hợp. Không nhập dữ liệu và không cấu hình.

## Thi đấu

Bao gồm Match, Tournament, History và Review. Toàn bộ dữ liệu thi đấu nằm tại
đây.

## Tập luyện

Bao gồm Learning Hub, Knowledge, Drill, Ghost Match và Progress. Toàn bộ hoạt
động luyện tập nằm tại đây.

## Coach

Bao gồm Coach Report, Skill, Recommendation, Memory, Learning Path, Mastery và
Roadmap.

---

# 3. Statistics không còn là Tab

Statistics là Dashboard Detail:

Dashboard → Skill Radar → View All → Statistics.

---

# 4. Equipment không cần một Tab

Equipment được quản lý theo luồng:

Profile → Current Equipment → Edit.

Coach vẫn sử dụng dữ liệu Equipment.

---

# 5. Learning Hub

Training Center trở thành Learning Hub. Đây không chỉ là nơi chứa bài tập mà là
nơi học theo vòng lặp:

Knowledge → Start Training → Drill → Review → Next Lesson.

Người dùng đi theo Learning Path, không đọc kiến thức xong rồi tự tìm bài tập.

---

# 6. Mở rộng Knowledge

Knowledge đào tạo từ Beginner → Intermediate → Advanced → Professional.

## Người mới

- Cách đứng
- Cầu tay
- Cầm cơ
- Điểm chết
- Đánh thẳng
- Đánh nhẹ
- Ít spin

## Cue Ball Control

- Stop
- Follow
- Draw
- Stun
- Spin

## Position Play

- Đi 3 bi
- Đi 5 bi
- Pattern

## Safety

- Chắn bi
- Điều bi cái
- Escape

## Break

- Break cơ bản
- Break mạnh
- Break chiến thuật

## Mental

- Routine
- Tập trung
- Thi đấu
- Kiểm soát cảm xúc

## Equipment

- Tip
- Shaft
- Cue
- Chalk

## Common Mistakes

- Lifting Head
- Steering
- Grip
- Stroke
- Spin sai

---

# 7. Five-Layer Knowledge Architecture

Pool OS sử dụng hệ thống kiến thức 5 tầng để phục vụ mọi đối tượng người chơi.

## Layer 1 — Do It

Chỉ cần làm theo, không cần hiểu. Ví dụ: đầu cơ thấp hơn tâm bi khoảng một đầu
cơ, đánh lực vừa, bi cái sẽ đứng. Đây là tầng dành cho đa số người chơi phong
trào.

## Layer 2 — Understand

Giải thích tại sao, ví dụ vì sao đầu cơ thấp hơn tâm mới tạo Stop Shot và vì sao
Follow nhiều hay ít.

## Layer 3 — Principle

Giải thích bằng vật lý cơ bản: ma sát, động lượng, spin, collision, góc phản xạ,
hiệu ứng lăn và trượt.

## Layer 4 — Physics & Mathematics

Bao gồm Vector, Conservation of Momentum, Angular Momentum, Throw, Deflection,
Squirt, Swerve và Friction Model. Tầng này dành cho người nghiên cứu kỹ thuật
hoặc HLV.

## Layer 5 — Engine & Simulation

Bao gồm thuật toán mô phỏng vật lý, Ball Collision Engine, Cue Ball Prediction,
Shot Solver, AI Search, Pattern Evaluation và Table Analysis.

Pool OS sử dụng tầng này làm nền cho AI Coach, AI Shot Analysis, AI Table
Analysis và Future Billiard Engine. Người dùng thông thường không cần đọc tầng
này; Coach AI sử dụng nó để tạo lời khuyên chính xác hơn.

---

# 8. Coach Philosophy

Coach không ưu tiên nâng trần. Coach ưu tiên nâng sàn.

Mục tiêu:

- Giảm số cú đánh tệ.
- Giảm ngày phong độ thấp.
- Tăng độ ổn định.
- Đưa người chơi về phiên bản tốt nhất thường xuyên.

Chỉ khi nền tảng đủ, Coach mới đề xuất kỹ thuật khó.

---

# 9. Match Objective

Match Objective là dữ liệu bắt buộc đối với Coach:

- Win: Coach ưu tiên thắng.
- Training: Coach ưu tiên kỹ thuật.
- Mixed: Coach cân bằng.

Coach luôn giải thích đang đánh giá theo Objective nào.

---

# 10. Match Review tương lai

Đây là hướng dài hạn, không triển khai trong Phase 1.

Người chơi quay video cú đánh lỗi. Coach AI phân tích chọn bi, lực, spin, điểm
chết, stroke và cue-ball path. Chỉ phân tích cú lỗi thay vì cả trận để giảm tài
nguyên.

---

# 11. AI Table Analysis

Đây là định hướng rất dài hạn:

Phá bi → Chụp ảnh bàn → Coach AI → Đề xuất đường chạy, pattern, safety, cue ball
và độ khó.

Kết quả có thể cá nhân hóa theo phong cách người chơi. Người thích Draw được ưu
tiên Draw; người đánh ít Spin được ưu tiên Natural Angle.

---

# 12. Tầm nhìn sản phẩm

Pool OS không chỉ là phần mềm ghi điểm. Mục tiêu cuối cùng là một HLV Bida AI.

Người chơi học, tập, thi đấu, được phân tích và được hướng dẫn trong một ứng
dụng. Coach biết người chơi mạnh gì, yếu gì, phong cách nào, tâm lý ra sao, nên
tập gì hôm nay và nên bỏ gì hôm nay.

Mục tiêu là giúp người chơi tiến bộ nhanh hơn so với tự học hoặc xem các video
rời rạc trên Internet.

---

# 13. Trạng thái triển khai

## Triển khai trong batch này

- [x] Bottom navigation còn đúng 4 tab.
- [x] Statistics chuyển thành Dashboard Detail.
- [x] Equipment chuyển vào Profile và không còn chiếm tab.
- [x] Dashboard rút gọn theo bốn câu hỏi sản phẩm.
- [x] Thi đấu tập hợp Match, Tournament, History và Review.
- [x] Training Center đổi tên hiển thị thành Learning Hub.
- [x] Knowledge → Start Training → Drill → Next Lesson dùng chung workflow.
- [x] Match Objective tiếp tục là dữ liệu bắt buộc của Coach.
- [x] Five-Layer Knowledge tiếp tục dùng schema Knowledge hiện tại.

## Không triển khai trong Phase 1

- [ ] Mở rộng toàn bộ corpus Knowledge từ Beginner đến Professional.
- [ ] Coach Memory, Mastery và Roadmap hoàn chỉnh.
- [ ] Video Match Review bằng AI.
- [ ] AI Table Analysis.
- [ ] Billiard Engine, Shot Solver và AI Search.

Các mục dài hạn chỉ được chuyển thành đầu việc khi P0/P1 đã qua Android UAT và
có tiêu chí dữ liệu, độ tin cậy, chi phí và fallback UX rõ ràng.
