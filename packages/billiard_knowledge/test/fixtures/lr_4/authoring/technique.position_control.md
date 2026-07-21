---
schemaVersion: 1
id: technique.position_control
kind: technique
knowledgeVersion: lr-4.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Position Control
summary: Requires an explicit nested allOf expression.
capabilities: [measurable_outcome, mastery_policy]
relations: []
unlock:
  allOf:
    - technique.stop_control
    - allOf:
        - technique.follow_control
        - technique.straight_stroke
payload:
  masteryCategory: advanced
  outcome:
    description: Complete the position-control protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.position_control.lr4.v1
    drillId: LR4-POSITION
    attempts: 10
    successDefinition: Finish in the target position area.
  drill:
    id: LR4-POSITION
    title: Position Control Gate
    instructions: [Complete ten fixed attempts.]
  nextRecommendation:
    id: status.position_control_complete
    title: Position Control Complete
    targetType: placeholder
---
Position Control proves the explicit AND-only Unlock Expression Contract.
