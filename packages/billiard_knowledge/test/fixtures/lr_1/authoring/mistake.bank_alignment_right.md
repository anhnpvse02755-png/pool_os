---
schemaVersion: 1
id: mistake.bank_alignment_right
kind: mistake
knowledgeVersion: lr-1.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Bank Alignment Right
summary: The bank repeatedly misses to the right.
capabilities:
  - correction_policy
relations:
  - technique.bank_shot
payload:
  masteryCategory: advanced
  resolutionPolicy:
    type: consecutive_clean
    requiredConsecutiveClean: 3
  symptom: The object ball repeatedly misses right of the target pocket.
  correction: Recheck the cushion contact point before changing speed.
  causes:
    - The selected cushion contact point is too deep.
---
This second equal-score correction proves stable semantic-ID ranking.
