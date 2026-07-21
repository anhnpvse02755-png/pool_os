---
schemaVersion: 1
id: technique.kick_shot
kind: technique
knowledgeVersion: lr-1.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Kick Shot
summary: Independent advanced Technique used to prove Evidence isolation.
capabilities:
  - measurable_outcome
  - mastery_policy
relations:
  - concept.bank_geometry
payload:
  masteryCategory: advanced
  outcome:
    description: Contact the target ball from the fixed kick-shot setup.
    successRadiusCm: 10
    requiredSuccesses: 16
    requiredAttempts: 20
  measurement:
    id: measurement.kick_shot.lr1.v1
    drillId: LR1-KICK
    attempts: 20
    successDefinition: The cue ball contacts the target from the fixed setup.
  drill:
    id: LR1-KICK
    title: Fixed One-Cushion Kick
    instructions:
      - Use the fixed LR-1 kick layout.
      - Complete exactly twenty attempts.
  nextRecommendation:
    id: status.kick_shot_complete
    title: Kick Shot Complete
    targetType: placeholder
---
Kick Shot must not inherit Bank Shot evidence even though both use the same
advanced mastery policy.
