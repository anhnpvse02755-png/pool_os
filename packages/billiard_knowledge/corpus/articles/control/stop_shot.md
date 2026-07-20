---
schemaVersion: 1
id: control.stop_shot
kind: technique
knowledgeVersion: 0.2.1
publishedAt: 2026-07-20T00:00:00.000Z
reviewState: verified
title: Stop Shot
summary: Dừng bi cái gần điểm va chạm sau một cú đánh thẳng.
capabilities:
  - measurable_outcome
  - mastery_policy
relations:
  - aiming.ghost_ball
  - mistake.poor_speed_control
  - control.follow_shot
payload:
  masteryCategory: foundation
  outcome:
    description: Giữ bi cái trong bán kính 20 cm sau va chạm.
    successRadiusCm: 20
    requiredSuccesses: 23
    requiredAttempts: 25
  measurement:
    id: measurement.stop_shot.b002.v1
    drillId: B002
    attempts: 25
    successDefinition: Bi cái dừng trong bán kính 20 cm sau va chạm.
  drill:
    id: B002
    title: Cue Ball Stop
    instructions:
      - Đặt bi cái và bi mục tiêu thẳng hàng, cách nhau khoảng 90 cm.
      - Đánh vào tâm bi cái với tốc độ vừa đủ đưa bi mục tiêu vào lỗ.
      - Ghi đạt khi bi cái dừng trong bán kính 20 cm sau va chạm.
  nextRecommendation:
    id: control.follow_shot
    title: Follow Shot
    targetType: knowledge
---
Stop Shot là nền tảng của kiểm soát bi cái. Giữ đường cơ thẳng, chạm đúng tâm bi cái và điều chỉnh tốc độ cho tới khi bi cái mất chuyển động ngay sau va chạm.

Mỗi lượt gồm 25 lần đánh. Kết quả 20/25 trở lên mở khóa đề xuất tiếp theo; 19/25 vẫn tiếp tục luyện Stop Shot.
