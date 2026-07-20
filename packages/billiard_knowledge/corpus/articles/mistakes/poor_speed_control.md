---
schemaVersion: 1
id: mistake.poor_speed_control
kind: mistake
knowledgeVersion: 0.2.1
publishedAt: 2026-07-20T00:00:00.000Z
reviewState: verified
title: Kiểm soát tốc độ chưa ổn định
summary: Tốc độ không phù hợp làm bi cái đi quá hoặc chưa tới vùng dừng.
capabilities:
  - correction_policy
relations:
  - control.stop_shot
  - control.follow_shot
payload:
  masteryCategory: foundation
  resolutionPolicy:
    type: consecutive_clean
    requiredConsecutiveClean: 3
  symptom: Bi cái thường xuyên đi quá hoặc dừng trước vùng mục tiêu.
  correction: Giảm biên độ backswing, giữ nhịp ra cơ đều và luyện cùng một khoảng cách.
  causes:
    - Thay đổi lực đột ngột giữa các lần đánh.
    - Backswing không ổn định.
---
Poor Speed Control là một lỗi quan sát được, không phải điểm Mastery. Coach dùng correction này như một phương án hỗ trợ khi outcome của kỹ thuật liên quan chưa đạt.
