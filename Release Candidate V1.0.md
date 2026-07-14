# Pool OS
# Phase RC-01
# Release Candidate Preparation
# (Sau Task 15)

---

# Mục tiêu

Sau khi hoàn thành Task 15, KHÔNG phát triển thêm tính năng mới.

Toàn bộ dự án chuyển sang giai đoạn ổn định sản phẩm để tạo bản Release Candidate đầu tiên.

Mục tiêu của Phase này là:

> Đưa Pool OS từ "nhiều chức năng" trở thành "một sản phẩm đủ ổn định để đội dự án và người chơi trải nghiệm thực tế."

Đây KHÔNG phải là Phase phát triển tính năng.

Đây là Phase hoàn thiện sản phẩm.

---

# Nguyên tắc

Không thêm module mới.

Không thay đổi Product Vision.

Không mở rộng Database nếu không thật sự cần.

Không refactor lớn.

Chỉ sửa:

- bug
- UX
- hiệu năng
- logic
- tính nhất quán

để chuẩn bị Release.

---

# Mục tiêu của Claude

Claude đóng vai trò Senior Product Engineer.

Không chỉ kiểm tra code.

Claude phải review toàn bộ sản phẩm dưới góc nhìn:

- người chơi Pool
- Product Owner
- UX Designer
- Software Architect

và đưa Pool OS về trạng thái Release Candidate.

---

# PHASE 1
# Functional Review

Kiểm tra toàn bộ chức năng.

Không được bỏ sót.

Ví dụ:

Player

Equipment

Readiness

Match

Ghost

Training Center

Statistics

Coach

Dashboard

Settings

...

Kiểm tra:

- có màn hình nào chưa hoàn chỉnh

- có nút nào không hoạt động

- có menu nào không dùng

- có chức năng nào bị orphan

- có luồng nào bị đứt

---

# PHASE 2
# User Flow Review

Kiểm tra toàn bộ hành trình người dùng.

Ví dụ

Người chơi mới.

↓

Tạo Profile

↓

Thêm cơ

↓

Readiness

↓

Đánh Match

↓

Coach

↓

Training

↓

Ghost

↓

Statistics

↓

Equipment

↓

...

Người chơi không nên bị "bí".

Nếu cần nhiều hơn 2 lần suy nghĩ:

"Tôi phải bấm ở đâu?"

=> UX chưa đạt.

---

# PHASE 3
# Coach Review

Coach là trung tâm của sản phẩm.

Kiểm tra Coach với nhiều trường hợp.

Ví dụ

Không có dữ liệu.

Chỉ có Training.

Chỉ có Match.

Chỉ có Ghost.

Training rất tốt nhưng Match kém.

Match tốt nhưng Training ít.

Không có Equipment.

Không có Readiness.

Coach luôn phải:

- phân tích đúng

- giải thích đúng

- không kết luận quá mức

- chỉ rõ dữ liệu còn thiếu

- đưa Next Action phù hợp

---

# PHASE 4
# Statistics Review

Kiểm tra:

- thống kê sai

- thống kê trùng

- thống kê không có giá trị

- biểu đồ khó hiểu

- số liệu không khớp

Mục tiêu:

Người chơi mở Statistics phải hiểu ngay.

Không cần đọc hướng dẫn.

---

# PHASE 5
# Equipment Review

Kiểm tra toàn bộ logic:

Cue

Break

Jump

Break Jump

Snapshot

Cue History

Equipment Intelligence

Cue Recommendation

Tip

...

Đảm bảo:

Không có dữ liệu sai.

Không có snapshot sai.

Không mất dữ liệu khi đổi cơ.

---

# PHASE 6
# Training Center Review

Kiểm tra:

Drill

Level

Progress

Video

GIF

History

Coach Recommendation

Navigation

Đảm bảo:

Training Center hoạt động độc lập.

Coach chỉ dẫn người chơi đến đúng bài tập.

---

# PHASE 7
# Database Review

Kiểm tra:

Migration

Table

Column

Index

Repository

Foreign Key

Dead Table

Dead Column

Unused Model

Không thay đổi schema nếu không cần.

Chỉ dọn dẹp khi an toàn.

---

# PHASE 8
# Code Quality Review

Kiểm tra:

Dead Code

Duplicate Code

Unused Widget

Unused Provider

Unused Repository

Naming

Folder Structure

Dependency

Logic

Mục tiêu:

Code sạch.

Dễ bảo trì.

---

# PHASE 9
# Performance Review

Kiểm tra:

Dashboard

Coach

Statistics

Training

Equipment

Match

Ghost

Provider

Database Query

Render

Animation

Không tối ưu vi mô.

Chỉ xử lý các vấn đề ảnh hưởng trải nghiệm.

---

# PHASE 10
# UI / UX Review

Kiểm tra:

Spacing

Typography

Icon

Color

Consistency

Button

Dialog

Bottom Sheet

Navigation

Dark Mode

Tablet

Landscape (nếu hỗ trợ)

Mục tiêu:

Ứng dụng thống nhất.

Không có cảm giác "vá".

---

# PHASE 11
# Release Review

Kiểm tra:

Version

Build

APK

Crash

Permission

Database Upgrade

First Launch

Update từ version cũ

Không được có crash blocker.

---

# UAT Checklist

Sau khi hoàn thành RC.

Tạo checklist cho người dùng.

Ví dụ

□ Tạo Player

□ Thêm cơ

□ Đặt cơ mặc định

□ Ghi Readiness

□ Đánh Match

□ Đánh Ghost

□ Xem Coach

□ Làm Drill

□ Xem Statistics

□ Xem Equipment

□ Đổi cơ

□ Xem Dashboard

□ Khởi động lại App

□ Kiểm tra dữ liệu

Nếu người dùng hoàn thành toàn bộ checklist mà KHÔNG cần hỏi cách sử dụng.

UX được coi là đạt.

---

# Definition of Done

Claude chỉ được coi là hoàn thành Phase RC khi:

✓ flutter analyze sạch

✓ flutter test pass

✓ build APK thành công

✓ không còn crash blocker

✓ không còn orphan feature

✓ Coach hoạt động đúng

✓ UX mạch lạc

✓ hoàn thành UAT Checklist

✓ tạo báo cáo Release Review

---

# Kết quả cuối cùng

Sau Phase này, Pool OS phải đạt trạng thái:

Release Candidate 1.0

Đủ ổn định để:

- Team IT sử dụng

- Người chơi Pool trải nghiệm

- Thu thập phản hồi thực tế

Chỉ sau khi hoàn thành UAT và tổng hợp phản hồi thực tế mới bắt đầu phát triển Task 16 và các tính năng tiếp theo.
