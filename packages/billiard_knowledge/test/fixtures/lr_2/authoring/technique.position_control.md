---
schemaVersion: 1
id: technique.position_control
kind: technique
knowledgeVersion: lr-2.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Position Control
summary: Requires both Stop Control and Follow Control directly.
capabilities:
  - measurable_outcome
  - mastery_policy
relations:
  - type: requires
    targetId: technique.stop_control
  - type: requires
    targetId: technique.follow_control
payload:
  masteryCategory: advanced
  outcome:
    description: Complete the fixed position-control protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.position_control.lr2.v1
    drillId: LR2-POSITION
    attempts: 10
    successDefinition: The cue ball finishes in the target position area.
  drill:
    id: LR2-POSITION
    title: Position Control Gate
    instructions:
      - Complete exactly ten fixed-layout attempts.
  nextRecommendation:
    id: status.position_control_complete
    title: Position Control Complete
    targetType: placeholder
---
Multiple direct requires use implicit ALL semantics without an expression.
