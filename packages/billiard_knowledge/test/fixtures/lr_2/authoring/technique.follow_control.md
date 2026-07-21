---
schemaVersion: 1
id: technique.follow_control
kind: technique
knowledgeVersion: lr-2.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Follow Control
summary: Available only when Stop Control is mastered.
capabilities:
  - measurable_outcome
  - mastery_policy
relations:
  - type: requires
    targetId: technique.stop_control
payload:
  masteryCategory: advanced
  outcome:
    description: Complete the fixed follow-control protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.follow_control.lr2.v1
    drillId: LR2-FOLLOW
    attempts: 10
    successDefinition: The cue ball enters the target follow area.
  drill:
    id: LR2-FOLLOW
    title: Follow Control Gate
    instructions:
      - Complete exactly ten fixed-layout attempts.
  nextRecommendation:
    id: technique.position_control
    title: Position Control
    targetType: knowledge
---
Follow Control demonstrates direct-only dependency evaluation.
