# Pool OS Product Owner Bootstrap

This procedure reconstructs Product Owner context from tracked repository
documents. It applies to a new PO task on either the home or office machine.
Chat history, task identifiers, `.memory.sqlite`, and uncommitted work on another
machine are not sources of truth.

## 1. Establish A Safe Checkout

Start at the Pool OS repository root. Read `AGENTS.md` and this document before
making a Product decision. Check the worktree first:

```powershell
git status --short --branch
```

If the worktree is not clean, stop. Do not merge, stash, discard, stage, or move
unrelated work merely to bootstrap PO context.

For a home-to-office transfer, run on the office checkout:

```powershell
git fetch origin
git switch product/guided-learning-pilot
git pull --ff-only origin product/guided-learning-pilot
```

For an office-to-home transfer, run the same fail-closed sequence on the home
checkout:

```powershell
git fetch origin
git switch product/guided-learning-pilot
git pull --ff-only origin product/guided-learning-pilot
```

If switching or fast-forwarding fails, stop and report the discrepancy. Never
merge Product context automatically.

## 2. Recover Authoritative Context

Read these tracked documents in order:

1. `AGENTS.md` and this Bootstrap.
2. `architecture/product/PO_HANDOFF.md`.
3. The authoritative Roadmap named by the Handoff.
4. The active FEATURE specification named by the Handoff.
5. The leading `MEMORY.md` sections for PO Context Sync, the Roadmap, and the
   active FEATURE.
6. The current dated file under `memory/` when it exists.

The Roadmap and FEATURE specification are the product contracts. Handoff is the
single source of truth for current workflow state, location leases, the last PO
decision, and one exact next action. Durable `MEMORY.md` decisions provide
context but do not replace those contracts.

## 3. Verify Repository Identity

Run these checks after the fast-forward pull:

```powershell
$poBranch = (git branch --show-current).Trim()
$poUpstream = (git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}').Trim()
$poHead = (git rev-parse HEAD).Trim()
$poUpstreamHead = (git rev-parse '@{upstream}').Trim()

if ($poBranch -ne 'product/guided-learning-pilot') {
  throw "Unexpected branch: $poBranch"
}
if ($poUpstream -ne 'origin/product/guided-learning-pilot') {
  throw "Unexpected upstream: $poUpstream"
}
if ($poHead -ne $poUpstreamHead) {
  throw "Local HEAD does not equal remote-tracking HEAD"
}

git cat-file -e "${poHead}:architecture/product/PO_HANDOFF.md"
if ($LASTEXITCODE -ne 0) {
  throw 'PO_HANDOFF.md is not tracked at HEAD'
}

$poBaselineMatch = Select-String `
  -Path 'architecture/product/PO_HANDOFF.md' `
  -Pattern '^baseline_commit: ([0-9a-f]{40})$'
if ($poBaselineMatch.Matches.Count -ne 1) {
  throw 'Handoff must contain one full baseline_commit SHA'
}
$poBaseline = $poBaselineMatch.Matches[0].Groups[1].Value

git cat-file -e "${poBaseline}^{commit}"
if ($LASTEXITCODE -ne 0) {
  throw 'baseline_commit is not an available commit'
}
git merge-base --is-ancestor $poBaseline $poHead
if ($LASTEXITCODE -ne 0) {
  throw 'baseline_commit is not an ancestor of checked-out HEAD'
}
```

`baseline_commit` is the full HEAD immediately before the checkpoint or claim
commit was authored. It is expected to precede checked-out HEAD; never require
post-checkpoint HEAD to equal `baseline_commit`.

Audit every commit and changed path after that baseline:

```powershell
git log --format=fuller --decorate "$poBaseline..$poHead"
git rev-list --merges "$poBaseline..$poHead"
git diff --name-status "$poBaseline..$poHead"
```

Compare the complete output with the outgoing authorization and expected PO
checkpoint/claim scope recorded in Handoff. Stop if a commit is unexpected, a
merge appears, any path exceeds that scope, or any identity/ancestry check
fails. Do not shorten a SHA when comparing it. The worktree must remain clean.

## 4. Use Semantic Memory Only As An Optional Index

When `bunx` and `memory-search` are available, attempt the index refresh:

```powershell
bunx memory-search --sync
```

Absence or failure is non-blocking. `.memory.sqlite` is local, ignored, and
disposable. Fall back to tracked Markdown and use `rg` to locate relevant
decisions:

```powershell
$poTrackedMarkdown = git ls-files '*.md'
rg -n -i -- 'PO Context Sync|FEATURE_004|next_action|engineering_status' $poTrackedMarkdown
```

Bootstrap is complete from tracked Markdown alone; semantic search results
cannot override a tracked contract.

## 5. Validate And Claim The PO Lease

There may be at most one active PO:

- If `active_po` is this machine and `handoff_to` is `none`, this machine already
  owns the lease.
- If `active_po` is `none` and `handoff_to` is this machine, this machine may
  claim the lease.
- If `active_po` names the other machine, `handoff_to` names the other machine,
  or the values conflict, stop. Do not make a Product decision.

To claim an incoming lease, first capture the verified pre-claim HEAD. Update
only Handoff and the dated memory needed for the claim: set `baseline_commit`
to that pre-claim HEAD, set `active_po` to this machine, set `handoff_to: none`,
refresh `updated_at_utc`, and preserve the exact workflow state and
`next_action`. Then stage and inspect only those PO files:

```powershell
$poPreClaimHead = (git rev-parse HEAD).Trim()
# Edit baseline_commit to $poPreClaimHead and claim the PO lease.
$poRecordedBaseline = (Select-String `
  -Path 'architecture/product/PO_HANDOFF.md' `
  -Pattern '^baseline_commit: ([0-9a-f]{40})$'
).Matches[0].Groups[1].Value
if ($poRecordedBaseline -ne $poPreClaimHead) {
  throw 'Claim Handoff does not record the exact pre-claim HEAD'
}
git add -- architecture/product/PO_HANDOFF.md memory/YYYY-MM-DD.md
git diff --cached --name-only
git diff --cached --check
git commit -m "chore(po): claim FEATURE_004 on <machine>"
git push origin product/guided-learning-pilot
git fetch origin
$poClaimHead = (git rev-parse HEAD).Trim()
$poRemoteHead = (git rev-parse '@{upstream}').Trim()
if ($poClaimHead -ne $poRemoteHead) {
  throw 'Claim HEAD does not equal remote-tracking HEAD'
}
git merge-base --is-ancestor $poPreClaimHead $poClaimHead
if ($LASTEXITCODE -ne 0) {
  throw 'Pre-claim baseline is not an ancestor of claim HEAD'
}
git cat-file -e "${poClaimHead}:architecture/product/PO_HANDOFF.md"
if ($LASTEXITCODE -ne 0) {
  throw 'Claimed Handoff is not tracked at claim HEAD'
}
git log --format=fuller "$poPreClaimHead..$poClaimHead"
git diff --name-status "$poPreClaimHead..$poClaimHead"
```

The claim commit and paths must match the intended claim scope before the
receiving PO executes `next_action`. Unrelated Code WIP must remain unstaged.
Add `MEMORY.md` only when a genuinely new durable accepted decision is required.

## 6. Enforce The Engineering Lease

`engineering_location` is exclusive. When it is `home` or `office`, only the
existing Code task at that location may continue the active FEATURE. Do not
start a duplicate Code task. An `authorized` status does not mean
`implementing`; change it only from live Code-task evidence and checkpoint the
matching workflow transition.

The persistent Engineering role is the task named `Code Pool OS`. PO sends all
specification audits, implementation authorizations, changes requested and
closure authorizations to that task and reads its reports directly. A completed
turn is not a reason to stop the Product workflow: PO must continue the same
task, or fork it only when the app cannot continue the ended conversation, then
retain the title and Engineering lease. The user is not a message relay between
PO and Code.

The operating sequence is:

```text
PO plan -> tracked specification -> exact Code authorization
-> Engineering Report -> PO review -> closure authorization
```

PO does not implement Dart, schema, generated output, or tests. Code does not
expand scope, open a later FEATURE, commit, or push before explicit PO
authorization. Execute only the literal `next_action` after a valid PO claim.
When one transition completes, PO immediately checkpoints the resulting state
and issues the next authorized action without waiting for a user prompt. Pause
only for a genuine Product decision or authority boundary.

## 7. Transfer Or Stop

Before transferring PO ownership, verify branch, upstream, full HEAD, and
status. Record that verified pre-transfer HEAD as `baseline_commit`; update
Handoff and dated memory; set `active_po: none` and `handoff_to` to the
destination; stage only intended PO files; commit with
`chore(po): hand off <feature> to <machine>`; push; and verify local HEAD equals
the remote-tracking HEAD. Verify the recorded baseline is an ancestor of the
new HEAD, the Handoff is tracked at the new HEAD, and every post-baseline commit
and path matches the transfer scope. The source PO makes no further Product
decision after release.

Use the same capture and verification pattern as a claim:

```powershell
$poPreTransferHead = (git rev-parse HEAD).Trim()
# Edit baseline_commit to $poPreTransferHead and release the PO lease.
$poRecordedBaseline = (Select-String `
  -Path 'architecture/product/PO_HANDOFF.md' `
  -Pattern '^baseline_commit: ([0-9a-f]{40})$'
).Matches[0].Groups[1].Value
if ($poRecordedBaseline -ne $poPreTransferHead) {
  throw 'Transfer Handoff does not record the exact pre-transfer HEAD'
}
git add -- architecture/product/PO_HANDOFF.md memory/YYYY-MM-DD.md
git diff --cached --name-only
git diff --cached --check
git commit -m "chore(po): hand off <feature> to <machine>"
git push origin product/guided-learning-pilot
git fetch origin
$poTransferHead = (git rev-parse HEAD).Trim()
$poRemoteHead = (git rev-parse '@{upstream}').Trim()
if ($poTransferHead -ne $poRemoteHead) {
  throw 'Transfer HEAD does not equal remote-tracking HEAD'
}
git merge-base --is-ancestor $poPreTransferHead $poTransferHead
if ($LASTEXITCODE -ne 0) {
  throw 'Pre-transfer baseline is not an ancestor of transfer HEAD'
}
git cat-file -e "${poTransferHead}:architecture/product/PO_HANDOFF.md"
if ($LASTEXITCODE -ne 0) {
  throw 'Transferred Handoff is not tracked at transfer HEAD'
}
git log --format=fuller "$poPreTransferHead..$poTransferHead"
git diff --name-status "$poPreTransferHead..$poTransferHead"
```

This process transfers tracked PO context only. Uncommitted Code work is visible
only in its local worktree and must not be represented as transferred. Moving
such WIP requires a separate explicit policy; temporary commits, patches,
stashes, or pushes are not authorized here.

Never record credentials, access tokens, personal data, private chat content,
or proprietary source material in Handoff or memory files.
