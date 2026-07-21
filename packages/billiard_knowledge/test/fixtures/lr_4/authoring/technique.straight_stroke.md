---
schemaVersion: 1
id: technique.straight_stroke
kind: technique
knowledgeVersion: lr-4.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Straight Stroke
summary: Independent LR-4 prerequisite.
capabilities: [measurable_outcome, mastery_policy]
relations: []
payload:
  masteryCategory: advanced
  outcome:
    description: Complete the straight-stroke protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.straight_stroke.lr4.v1
    drillId: LR4-STRAIGHT
    attempts: 10
    successDefinition: Finish on the target line.
  drill:
    id: LR4-STRAIGHT
    title: Straight Stroke Gate
    instructions: [Complete ten fixed attempts.]
  nextRecommendation:
    id: technique.position_control
    title: Position Control
    targetType: knowledge
---
Straight Stroke is an independent leaf of the LR-4 expression.
