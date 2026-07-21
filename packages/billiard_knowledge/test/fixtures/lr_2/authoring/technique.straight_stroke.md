---
schemaVersion: 1
id: technique.straight_stroke
kind: technique
knowledgeVersion: lr-2.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Straight Stroke
summary: Direct foundation for the LR-2 dependency chain.
capabilities:
  - measurable_outcome
  - mastery_policy
relations: []
payload:
  masteryCategory: advanced
  outcome:
    description: Complete the fixed straight-stroke protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.straight_stroke.lr2.v1
    drillId: LR2-STRAIGHT
    attempts: 10
    successDefinition: The cue finishes on the target line.
  drill:
    id: LR2-STRAIGHT
    title: Straight Stroke Gate
    instructions:
      - Complete exactly ten fixed-layout attempts.
  nextRecommendation:
    id: technique.stop_control
    title: Stop Control
    targetType: knowledge
---
Straight Stroke has no prerequisite and starts the LR-2 chain.
