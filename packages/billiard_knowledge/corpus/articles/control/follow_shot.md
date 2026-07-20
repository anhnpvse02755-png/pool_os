---
schemaVersion: 1
id: control.follow_shot
kind: technique
knowledgeVersion: 0.2.1
publishedAt: 2026-07-20T00:00:00.000Z
reviewState: verified
title: Follow Shot
summary: Làm bi cái tiếp tục lăn về phía trước sau khi chạm bi mục tiêu.
capabilities:
  - measurable_outcome
  - mastery_policy
relations:
  - control.stop_shot
  - mistake.poor_speed_control
payload:
  masteryCategory: foundation
  outcome:
    description: Bi cái đi tiếp từ 30 đến 50 cm theo đường mục tiêu sau va chạm.
    successRadiusCm: 20
    requiredSuccesses: 23
    requiredAttempts: 25
  measurement:
    id: measurement.follow_shot.v1
    drillId: B002-FOLLOW
    attempts: 25
    successDefinition: Bi cái đi tiếp và dừng trong vùng mục tiêu 30 đến 50 cm.
  drill:
    id: B002-FOLLOW
    title: Follow Shot Control
    instructions:
      - Đặt bi cái và bi mục tiêu thẳng hàng.
      - Đánh phía trên tâm bi cái với nhịp ra cơ đều.
      - Ghi đạt khi bi cái đi tiếp và dừng trong vùng 30 đến 50 cm.
  nextRecommendation:
    id: next.position_control.placeholder
    title: Position Control đã sẵn sàng
    targetType: placeholder
    blockedByActiveCorrectionCategory: foundation
---
Follow Shot dùng topspin còn lại tại thời điểm va chạm để đưa bi cái tiếp tục đi tới. Drill này đo vùng dừng thay vì chỉ kiểm tra bi cái có lăn về trước hay không. Position Control chỉ mở khi không còn Foundation correction hoạt động.
