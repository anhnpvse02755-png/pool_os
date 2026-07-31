---
name: roadmap-v3-beta-wave-model
description: Roadmap V3 Beta — single-lifecycle per Epic; PO 2026-07-31; engineering internal Wave Model allowed but never creates intermediate closures
metadata:
  type: project
---

Pool OS v3 Beta standardizes the per-Epic lifecycle to:

  Implementation
  ↓
  ONE Engineering Report
  ↓
  ONE Full Regression
  ↓
  ONE PO Review
  ↓
  Merge
  ↓
  Close EPIC

EPIC may internally organize work in Engineering Waves (e.g. EPIC 05:
Wave 1 Core Knowledge / Wave 2 Content / Wave 3 User Layer), but the
EPIC lifecycle remains a single linear flow. No intermediate merges,
no partial regressions, no PO Close between Waves.

**Why:** PO 2026-07-31 directive. Roadmap V3 Beta explicitly reduces
the number of test+package cycles compared to the legacy Feature
model.

**How to apply:** When bootstrapping a new Epic, plan internal Wave
sequencing for engineering control, but produce exactly one
Engineering Report (`EPIC_<NN>_ENGINEERING_REPORT.md`), one
`flutter test` regression per Epic, one PO close per Epic.

Related: [[capability-pattern]], [[epic-05-close]]
