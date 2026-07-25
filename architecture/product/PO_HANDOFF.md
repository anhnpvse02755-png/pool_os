---
schema_version: 1
updated_at_utc: 2026-07-25T09:28:00Z
active_po: home
handoff_to: none
branch: product/guided-learning-pilot
baseline_commit: 45d2f89cc08e88cf991ea8b7fd86ace06b4fd8e8
active_feature: FEATURE_005
workflow_state: planning
engineering_location: home
engineering_status: authorized
engineering_report: none
last_po_decision: "Final audit correction preserves signed raw Player IDs for attribution and validates positivity only at canonical adaptation."
next_action: "existing home Code task verifies the signed-ID correction in one final read-only FEATURE_005 specification audit."
---

# Product Owner Handoff

## Authoritative Product Contracts

- Roadmap: `architecture/product/POOL_OS_GUIDED_LEARNING_EQUIPMENT_AI_ROADMAP.md`
- Most recently closed specification:
  `architecture/product/features/FEATURE_004_ATOMIC_ACTIVE_PLAYER_LIFECYCLE.md`
- Active FEATURE_005 draft:
  `architecture/product/features/FEATURE_005_PLAYER_PROFILE_COMPATIBILITY_PROVENANCE.md`.
- Durable decisions: leading PO Context Sync, Roadmap, and FEATURE_004 sections
  of `MEMORY.md`.

## Live Evidence At This Checkpoint

FEATURE_004 closed at `c9ebde09e3754eb1ba0d4804b0afc97c8ac599d9` with exactly
the accepted 15-file implementation/test allowlist. Local HEAD and
`origin/product/guided-learning-pilot` matched and the worktree was clean. No
tag, PR, merge, stash or FEATURE_005 implementation was created.

The draft was derived from accepted E3 gaps E3-G01/E3-G03, the legacy Player
row/model, foundation `PlayerProfile`, and `PlayerProfileContract`. It introduces
no implementation or schema change.

`baseline_commit` is the full clean HEAD immediately before this specification
checkpoint is authored. It is an ancestor of the future checkpoint commit, not
the SHA of the commit containing this Handoff.

## Authorization And Report State

- FEATURE_004: Accepted and Closed.
- FEATURE_004 closure commit:
  `c9ebde09e3754eb1ba0d4804b0afc97c8ac599d9`.
- FEATURE_004 evidence: lifecycle/migration/handoff `16/16`, final lifecycle
  `10/10`, FEATURE_001-003/Player `48/48`, compatibility `12/12`, full app
  `1234/1234`, Knowledge `75/75`, Freeze `76/76`, Architecture Fitness
  `133 existing / 0 new`, analyzer zero errors/warnings, formatter and diff
  checks clean.
- FEATURE_005 specification audit: Changes Requested; Product Owner revised the
  draft without expanding roadmap scope.
- FEATURE_005 specification re-audit: Changes Requested; audit is complete.
- FEATURE_005 final specification re-audit authorization: active at `home`.
- FEATURE_005 implementation authorization: `none`.
- Engineering Report for FEATURE_005: `none`.
- Changes requested: final audit found raw assessment could not represent
  persisted ID 0/-1; corrected to signed raw ID with positive canonical gate.
- Unresolved product questions: `none`.

## Baseline And Receiving Audit

After `git pull --ff-only`, a receiver must verify local HEAD equals
`origin/product/guided-learning-pilot`, this Handoff is tracked at HEAD, and
`baseline_commit` is an ancestor of HEAD. Inspect every commit and changed path
in `baseline_commit..HEAD`; never require post-checkpoint HEAD to equal
`baseline_commit`.

For this specification checkpoint, post-baseline history may change only:

- `architecture/product/PO_HANDOFF.md`;
- `memory/2026-07-25.md`;
- `MEMORY.md`;
- `architecture/product/features/FEATURE_005_PLAYER_PROFILE_COMPATIBILITY_PROVENANCE.md`.

Any unexpected commit, merge or path requires a stop and report.

## Lease And Action Conditions

The Product Owner lease belongs to `home`; no handoff is pending. An office PO
must not act until home releases the lease through a committed/pushed handoff
and office claims it through `PO_BOOTSTRAP.md`.

The Engineering lease belongs to the existing home Code task for final read-only
specification re-audit only. No implementation is authorized.

The user returned and selected the recommended canonical-plus-raw dual-digest
policy. The shutdown guard is paused and the workflow resumed from the tracked
checkpoint without lost WIP.

## Prohibited Scope

Do not implement FEATURE_005, transfer unrelated WIP, or alter the accepted
Roadmap. Engineering may read and report on the draft only. No Dart, schema,
generated, test or runtime change is authorized.
