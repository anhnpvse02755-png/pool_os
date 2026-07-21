---
schemaVersion: 1
id: technique.follow_control
kind: technique
knowledgeVersion: lr-4.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Follow Control
summary: Independent LR-4 prerequisite.
capabilities: [measurable_outcome, mastery_policy]
relations: []
payload:
  masteryCategory: advanced
  outcome:
    description: Complete the follow-control protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.follow_control.lr4.v1
    drillId: LR4-FOLLOW
    attempts: 10
    successDefinition: Finish in the target follow area.
  drill:
    id: LR4-FOLLOW
    title: Follow Control Gate
    instructions: [Complete ten fixed attempts.]
  nextRecommendation:
    id: technique.position_control
    title: Position Control
    targetType: knowledge
---
Follow Control is an independent leaf of the LR-4 expression.
