---
schemaVersion: 1
id: technique.bank_shot
kind: technique
knowledgeVersion: lr-1.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Bank Shot
summary: Control a one-cushion bank with an advanced deterministic protocol.
capabilities:
  - measurable_outcome
  - mastery_policy
relations:
  - mistake.bank_alignment_left
  - mistake.bank_alignment_right
  - concept.bank_geometry
payload:
  masteryCategory: advanced
  outcome:
    description: Pocket the bank shot under the defined setup.
    successRadiusCm: 10
    requiredSuccesses: 16
    requiredAttempts: 20
  measurement:
    id: measurement.bank_shot.lr1.v1
    drillId: LR1-BANK
    attempts: 20
    successDefinition: The object ball is pocketed from the fixed bank setup.
  drill:
    id: LR1-BANK
    title: Fixed One-Cushion Bank
    instructions:
      - Use the fixed LR-1 bank layout.
      - Complete exactly twenty attempts.
  nextRecommendation:
    id: status.bank_shot_complete
    title: Bank Shot Complete
    targetType: placeholder
---
This fixture proves that an advanced Technique uses the same compiled learning
pipeline without a Knowledge-ID branch.
