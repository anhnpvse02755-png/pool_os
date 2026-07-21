---
schemaVersion: 1
id: technique.stop_control
kind: technique
knowledgeVersion: lr-4.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Stop Control
summary: Independent LR-4 prerequisite.
capabilities: [measurable_outcome, mastery_policy]
relations: []
payload:
  masteryCategory: advanced
  outcome:
    description: Complete the stop-control protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.stop_control.lr4.v1
    drillId: LR4-STOP
    attempts: 10
    successDefinition: Stop in the target area.
  drill:
    id: LR4-STOP
    title: Stop Control Gate
    instructions: [Complete ten fixed attempts.]
  nextRecommendation:
    id: technique.position_control
    title: Position Control
    targetType: knowledge
---
Stop Control is an independent leaf of the LR-4 expression.
