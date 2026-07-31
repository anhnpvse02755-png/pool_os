---
name: excluded-engineering-wip
description: Pool OS master baseline excludes unmerged work-in-progress from EPIC 03; never pulled into a downstream Epic's regression
metadata:
  type: reference
---

File: `app/test/features/training_system/training_system_polish_test.dart`
(16 tests, references unmerged classes like `ProgramSession`,
`TrainingProgramHierarchy`, `ProgramDay`, `ProgramWeek`).

Status: NOT in the official master baseline. Lives only in the
EPIC_03 worktree as untracked. Adding it to a downstream Epic's
regression would require merging EPIC 03 WIP — explicitly rejected
by PO 2026-07-31 (Option 2: "Engineering neither modified nor removed
those tests"; do not merge WIP from another Epic).

**Why:** Avoids scope creep across EPICs. Keeps each Epic responsible
only for its own official-baseline regression.

**How to apply:** When starting a new Epic on master, do NOT copy this
file forward. Document it in the new Epic's Engineering Report under
"Excluded engineering artifacts" only if the new Epic's audit trail
needs to surface why a regression delta exists; otherwise omit.

Related: [[epic-05-close]], [[roadmap-v3-beta-wave-model]]
