---
schemaVersion: 1
id: technique.stop_control
kind: technique
knowledgeVersion: lr-2.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Stop Control
summary: Available only when Straight Stroke is mastered.
capabilities:
  - measurable_outcome
  - mastery_policy
relations:
  - type: requires
    targetId: technique.straight_stroke
payload:
  masteryCategory: advanced
  outcome:
    description: Complete the fixed stop-control protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.stop_control.lr2.v1
    drillId: LR2-STOP
    attempts: 10
    successDefinition: The cue ball stops in the target area.
  drill:
    id: LR2-STOP
    title: Stop Control Gate
    instructions:
      - Complete exactly ten fixed-layout attempts.
  nextRecommendation:
    id: technique.follow_control
    title: Follow Control
    targetType: knowledge
---
Stop Control demonstrates one direct prerequisite.
