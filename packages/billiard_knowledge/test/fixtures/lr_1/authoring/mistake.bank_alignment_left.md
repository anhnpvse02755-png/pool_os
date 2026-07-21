---
schemaVersion: 1
id: mistake.bank_alignment_left
kind: mistake
knowledgeVersion: lr-1.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Bank Alignment Left
summary: The bank repeatedly misses to the left.
capabilities:
  - correction_policy
relations:
  - technique.bank_shot
payload:
  masteryCategory: advanced
  resolutionPolicy:
    type: consecutive_clean
    requiredConsecutiveClean: 3
  symptom: The object ball repeatedly misses left of the target pocket.
  correction: Recheck the cushion contact point before changing speed.
  causes:
    - The selected cushion contact point is too shallow.
---
This correction is intentionally tied to the Bank Shot fixture.
