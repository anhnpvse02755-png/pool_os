# Pool OS Product Owner Context Sync Specification

Status: Accepted; Implementation Authorized

Date: 2026-07-25

## Objective

GitHub is the authoritative source for Product Owner context shared between the
home and office machines. A new PO task must be able to recover the current
product decision, active workflow state and one exact next action without
depending on chat history or a local Codex task.

This mechanism synchronizes Product planning and review context only. It does
not transfer uncommitted Engineering work and does not relax the rule that Code
must not commit or push implementation before Product Owner acceptance.

## Operating Invariants

- At most one PO location is active at a time.
- PO context is checkpointed at every workflow transition and before changing
  machines.
- Roadmap and FEATURE specifications remain the authoritative product
  contracts.
- `PO_HANDOFF.md` is the single source of truth for current workflow state.
- `MEMORY.md` contains only durable accepted decisions.
- `memory/YYYY-MM-DD.md` records dated decisions, ideas and unresolved issues.
- Chat and task identifiers are communication handles, not sources of truth.
- `engineering_location` prevents a second Code task from being started for the
  same FEATURE.
- A PO receiving a handoff executes only `next_action`; it does not infer a new
  workflow.

## Required Repository Artifacts

Engineering must add or update only these documentation and contributor-policy
surfaces for this milestone:

- `architecture/product/PO_BOOTSTRAP.md`
- `architecture/product/PO_HANDOFF.md`
- `memory/2026-07-25.md`
- `AGENTS.md`
- `MEMORY.md`, only if an additional durable implementation decision is needed

No Dart, schema, generated, test or runtime file may change.

### PO Bootstrap

`PO_BOOTSTRAP.md` must instruct any new PO task to:

1. Read `AGENTS.md` and the bootstrap document.
2. Read `PO_HANDOFF.md`, the authoritative roadmap, the active FEATURE and the
   relevant leading section of `MEMORY.md`.
3. Verify branch, upstream and full HEAD against the handoff.
4. Run `bunx memory-search --sync` when available, while treating failure or
   absence of the semantic index as non-blocking and falling back to `rg` over
   tracked Markdown.
5. Verify the lease and claim it through the documented commit/push procedure.
6. Perform only the exact `next_action` after a valid claim.

The bootstrap must explain the PO/Code workflow and the limits of cross-machine
visibility for uncommitted Code work.

### Contributor Role Routing

Root `AGENTS.md` must preserve all existing architecture rules and add these
role-specific requirements:

- A task assigned the Product Owner role reads Bootstrap, Handoff, Roadmap,
  active FEATURE and MEMORY before acting.
- PO plans, records authoritative documents, authorizes Engineering, reviews
  Engineering Reports and authorizes closure. PO does not implement Dart,
  schema or tests and does not repeat adequate Engineering verification.
- A task assigned the Code/Engineering role implements only the current written
  authorization, reports evidence before commit/push and never expands the
  roadmap or opens the next FEATURE by inference.
- Chat or task history cannot override tracked product contracts.

### Daily Memory

`memory/2026-07-25.md` must record the accepted context-sync decision, current
FEATURE_004 workflow state, the outstanding Engineering action and any
unresolved coordination constraints. It must not duplicate the full roadmap or
store secrets, credentials, personal data or private chat content.

## Handoff Schema

`PO_HANDOFF.md` must begin with valid YAML front matter using this schema:

```yaml
schema_version: 1
updated_at_utc: <ISO-8601-UTC>
active_po: home | office | none
handoff_to: home | office | none
branch: product/guided-learning-pilot
baseline_commit: <full-sha>
active_feature: FEATURE_004
workflow_state: planning | accepted | engineering | review | changes_requested | closure_authorized | closed
engineering_location: home | office | none
engineering_status: idle | authorized | implementing | report_ready | awaiting_changes | complete
engineering_report: <path-or-none>
last_po_decision: <short-decision>
next_action: <one-exact-action>
```

The human-readable body must identify:

- authoritative roadmap and active specification;
- most recent outgoing authorization to Code;
- most recent Engineering Report or explicitly `none`;
- changes requested by PO or explicitly `none`;
- unresolved questions or explicitly `none`;
- prohibited scope;
- whether uncommitted Code WIP is known to exist and where;
- exact conditions under which the next PO may act.

The initial handoff must be derived from repository and Code-task evidence, not
from the expected baseline alone. At specification time the verified repository
state is:

- branch `product/guided-learning-pilot`;
- HEAD and upstream
  `b736404c58b5ebf70082384ef782f616c73123a2`;
- clean worktree;
- active FEATURE `FEATURE_004`;
- specification Accepted and Implementation Authorized;
- Code task idle with no Engineering Report and no observed FEATURE_004 WIP.

Therefore the initial Engineering state is `authorized`, not `implementing`.
The initial location is `home`, because the authorization was issued from the
home workspace. The exact next action is for the existing home Code task to
implement FEATURE_004 and return an Engineering Report without commit or push.
FEATURE_005 and all later features remain prohibited.

## Checkpoint And Transfer Procedure

Before leaving the active PO machine:

1. Verify branch, upstream, full HEAD and `git status`.
2. Do not stage any file being changed by Engineering.
3. Update Handoff, the daily memory and durable MEMORY only when applicable.
4. Set `active_po: none` and `handoff_to` to the destination.
5. Stage only the intended PO files.
6. Commit with `chore(po): hand off <feature> to <machine>`.
7. Push and verify local HEAD equals the remote tracking HEAD.
8. Make no further Product decision on the source machine.

On the destination machine:

```powershell
git fetch origin
git switch product/guided-learning-pilot
git pull --ff-only
```

The receiving PO then bootstraps from tracked documents, verifies the branch and
HEAD, changes `active_po` to its location, sets `handoff_to: none`, commits and
pushes the claim. It may execute `next_action` only after the remote confirms
that claim.

If fast-forward pull fails, the recorded handoff belongs to another machine, or
the commit does not match, the PO must stop and report the discrepancy. Product
decisions must never be auto-merged.

## Engineering Coordination

- Every outgoing authorization and incoming Engineering Report is summarized in
  Handoff at the matching workflow transition.
- Only the Code task at `engineering_location` may continue the active FEATURE.
- The other PO may continue synced planning and document review but cannot
  inspect uncommitted Code WIP on the first machine.
- Implementation review occurs on the machine holding WIP or after an accepted
  closure commit/push.
- Transferring Code WIP requires a separate explicit policy. This specification
  does not authorize temporary commits, patches, stashes or pushes of
  unaccepted implementation.

## Security And Data Rules

The tracked context must never contain API keys, access tokens, account
credentials, personal data, private chat transcripts or proprietary source
content. Handoff uses concise decision and evidence summaries with repository
paths where needed.

The local semantic-memory database remains ignored and disposable. Tracked
Markdown is sufficient to reconstruct PO context.

## Acceptance Evidence

Engineering must return evidence that:

1. A second clean checkout can recover active FEATURE, last decision,
   Engineering location/status and exact next action using tracked documents.
2. Root role routing prevents PO implementation and unauthorized Code scope
   expansion.
3. The initial Handoff YAML parses and every enum value is valid.
4. A checkpoint can stage only PO files while unrelated Code WIP remains
   unstaged.
5. Both home-to-office and office-to-home instructions use `--ff-only`.
6. Missing `memory-search` or `.memory.sqlite` does not block bootstrap.
7. Lease rules prevent two active POs and duplicate Code tasks.
8. A secret-pattern scan finds no credential or personal-data material in the
   new documents.
9. `git diff --check` is clean.
10. No Dart, schema, generated, test or runtime file changed.

Engineering must report results to Product Owner without committing or pushing.
Product Owner review is required before repository closure.

## Out Of Scope

- FEATURE_004 implementation changes.
- FEATURE_005 or later product work.
- Transfer or synchronization of uncommitted Code WIP.
- Cloud databases, account identity, multi-user editing or concurrent PO work.
- Runtime automation that locks GitHub or Codex tasks.
- Secrets management or backup of private chat history.

