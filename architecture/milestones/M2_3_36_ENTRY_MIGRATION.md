# M2.3 - 36-entry Migration

**Status:** Engineering Closed; Production Activation Deferred

**Date:** 2026-07-21

**Branch:** `m2/evidence-runtime-hardening`

## Outcome

The complete 36-entry Pack v1.4 migration inventory was processed through a
deterministic mapping and candidate pipeline. No generated output was edited by
hand and the production Knowledge 0.2.1 pointer was not changed.

| Metric | Result |
| --- | ---: |
| Migration inputs | 36 |
| Reviewed inputs | 34 |
| Draft inputs | 2 |
| Eligible migration inputs | 34 |
| Quarantined migration inputs | 2 |
| New canonical IDs | 31 |
| Existing-ID merges | 3 |
| Retained canonical dependencies | 1 |
| RC target entries | 35 |
| Manual generated-output fixes | 0 |
| Direct production publications | 0 |
| Deterministic RC rebuild | PASS |
| Isolated publication pipeline | PASS |

`term.tro` and `term.cu_le` remain quarantined with
`reviewStateDraft`. `control.stop_shot`, `control.follow_shot`, and
`aim.ghost_ball` were reconciled with existing stable IDs; Ghost Ball maps to
`aiming.ghost_ball`.

`Eligible` above applies to migration inputs, not publication state. The RC has
35 target entries because it retains canonical Poor Speed Control in addition
to the reconciled migration targets. No M2.3 candidate is production-current.

## Immutable Evidence

- Migration manifest:
  `packages/billiard_knowledge/migration/m2_3/manifest.json`
- Candidate authoring: 35 Markdown files under
  `packages/billiard_knowledge/migration/m2_3/candidate_authoring/articles/`
- Entry review decisions:
  `packages/billiard_knowledge/migration/m2_3/entry_reviews.json`
- Release Candidate digest:
  `fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac`
- Candidate Pack digest:
  `22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02`
- Machine-readable report:
  `packages/billiard_knowledge/migration/m2_3/report.json`

## Preserved Invariants

- Production Knowledge remains `0.2.1` with content digest
  `da81ba18127c8298276cbdc0ac0f035bf305b73da7489f9309dca52e48a4ee29`.
- `publication/current.json` is unchanged.
- Golden Fixtures, Reference Behavior 0.6.0 Revision 2, Learning Runtime, and
  the frozen M1.5 baseline are unchanged.
- Legacy `prerequisite` relations remain semantic associations. Only
  `type: requires` participates in hard dependency gating.

## Deferred Gates

M2.3 does not authorize production activation. M2.4 must prove a clean-checkout
rebuild and must resolve these explicit limitations before Canonical Knowledge
Package v1 can be published:

- a clean clone on another machine produces the same RC Content Digest and
  equivalent Publication Record semantics, then passes Runtime Load, replay,
  frozen regression, and architecture fitness;

- all 15 migrated source records are preserved, but their status is
  `legacy_metadata_only`; none currently has a content-addressed source
  snapshot;
- four legacy learning paths were not part of the 36-entry migration and remain
  deferred;
- quarantined draft terminology requires a separate Domain review before it can
  become eligible.
