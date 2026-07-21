# Pool OS Project Memory

## Official State (2026-07-21)

- M1 - Executable Architecture: Closed.
- M1.5 - Integrated Baseline: Closed. Tag: `v0.6.0-M1.5`.
- M2 - Runtime Hardening & Deterministic Publication: In Progress.
- Evidence Runtime Hardening: Closed.
- Compiler & Publication Hardening: Closed.
- Knowledge Generalization: In Progress.
  - M2.1 Scale Conformance: Closed at `716c23a`.
  - M2.2 Production Dependency Validation: Closed at `0809c83`.
  - M2.3 36-entry Migration: Closed at `cc54024`.
  - M2.4 Clean-checkout Rebuild & Publication Proof: Not Started; this is the
    next capability.
- Learning Runtime Generalization: Not Started.
- Canonical Knowledge Package v1: Not Published.
- M3 - AI Platform: Not Started.

Active branch: `m2/evidence-runtime-hardening`.

## Locked Invariants

- Reference Behavior 0.6.0 Revision 2 and current Golden Fixtures are
  regression invariants.
- Hardening work must introduce zero new architecture debt and must include
  failure-path tests.
- Candidate Artifact -> Review -> Publication Record -> Atomic Current Pointer
  Commit -> Published Package.
- `Published` and `Current` are distinct. Published packages remain immutable
  for replay, rollback, and audit; `current` only selects the runtime package.
- Entry candidates end as `Eligible` or `Quarantined(reason)`.
- Quarantine cascades through dependency edges, not across unrelated entries.
- RC Content Digest includes RC schema version, compiler version, canonical
  entries, and the resolved dependency graph.
- Each resolved edge binds `entryId`, `dependencyId`, and
  `resolvedDependencyContentDigest`.
- Reviewer, review time, publication metadata, and runtime timestamps do not
  participate in RC Content Digest.
- Hard dependencies are projected only from typed Knowledge relations with
  `type: requires`. Legacy string relations remain associations; there is no
  separately authored dependency graph.
- Dependency validation applies only to relations that the schema defines as
  dependencies (`type: requires`). Other relations remain semantic
  associations and do not participate in dependency publication gating.
- Dependency validation rejects dangling, self, duplicate, and cyclic hard
  dependencies. Isolated entries remain valid under the current schema.
- A valid dependency whose target is not Eligible is quarantined as
  `dependencyUnavailable`.
- One `knowledgeVersion` maps to one RC Content Digest. Persistence-level
  uniqueness in the publication store remains future M2 work.
- Do not branch on Knowledge IDs, add policy/kind/capability, change runtime,
  migrate the 36 entries, or publish Canonical Knowledge Package v1 outside
  the explicitly authorized capability.

## Latest Verification

M2.2 verification at commit `0809c83`:

- M2.2 conformance: 8/8.
- App tests: 207/207.
- Knowledge package tests: 51/51.
- Compiler conformance: 5/5.
- Golden vertical slice: 14/14.
- Frozen regression: 28 files unchanged.
- Architecture Fitness: 133 existing / 0 new.
- Analyzer baseline: 62 app info + 4 package info; no errors or warnings.
- Production Knowledge 0.2.1 compiler drift, Publication Check, and Runtime
  Load: PASS.
- Production corpus, runtime, Golden Fixtures, and Reference Behavior were not
  changed by M2.2.

## M2.3 Readiness Review (2026-07-21)

This section records the pre-implementation review. M2.3 subsequently closed at
`cc54024`; the observed risks below became explicit migration outcomes rather
than being hidden or coerced.

The migration input at `packages/billiard_knowledge/assets/pack_v1.json`
contains 36 entries, 4 learning paths, and 15 sources. It is not yet canonical
authoring and must remain a read-only migration input.

Observed inventory:

- 34 entries are `reviewed`; `term.tro` and `term.cu_le` are still `draft`.
- The input has 8 kinds: 12 Technique, 7 Concept, 4 Terminology, 5 Rule,
  4 Strategy, 2 Common Mistake, 1 Equipment, and 1 Mental.
- The executable runtime currently supports only Technique, Mistake, and
  Concept. Scale conformance used synthetic entries and does not prove that all
  production shapes can compile.
- `control.stop_shot` and `control.follow_shot` collide with existing canonical
  IDs. They must be reconciled as revisions, not added as duplicate entries.
- `aim.ghost_ball` is a semantic collision with canonical
  `aiming.ghost_ball`; the stable-ID mapping requires explicit review.
- Legacy `commonMistake` does not match the current `mistake` contract.
- Current Technique payloads require Outcome, Measurement, Drill, mastery
  category, and next recommendation. Most legacy Technique entries do not
  satisfy that contract and must not be coerced into another kind.
- Current compiler output does not yet preserve the full source/provenance and
  entry revision fields required for bulk migration.

### Authorized next batch: M2.3A Migration Inventory and ID Mapping

M2.3A is a dry-run/governance batch, not a publication batch. It must:

1. Produce a deterministic mapping row for every one of the 36 inputs.
2. Classify each row as `merge_existing`, `migrate_candidate`, or
   `quarantine` with a stable reason code.
3. Record the target semantic ID, target kind, source IDs, review state, and
   relation interpretation without changing the source pack.
4. Quarantine the two draft terminology entries unless Domain Review changes
   their review state.
5. Keep Knowledge 0.2.1, the production current pointer, runtime behavior,
   Golden Fixtures, and Reference Behavior unchanged.

### Conditional pilot: M2.3B Concept Migration

After the mapping is reviewed, migrate the 7 reviewed Concept inputs as the
first compiler-backed pilot:

- `fundamental.alignment.visual`
- `aim.ghost_ball` -> reviewed target `aiming.ghost_ball`
- `aim.cut_angle`
- `physics.throw.awareness`
- `control.tangent_line`
- `physics.squirt`
- `physics.swerve`

This pilot adds 6 new canonical IDs and revises one existing canonical entry.
It must stop at Candidate/Entry Review/Eligible-or-Quarantined/immutable RC.
It must not publish or move `publication/current.json`; activation remains an
M2.4 concern.

M2.3B exit gates:

- stable-ID mapping approved;
- source provenance and entry revision survive compilation;
- typed relation meaning is preserved without inventing hard dependencies;
- deterministic compiler and RC digests pass reorder/rebuild checks;
- every candidate has a scoped review decision or quarantine reason;
- production 0.2.1 drift, Golden Fixtures, Reference Behavior, and frozen M1.5
  baseline remain unchanged;
- architecture fitness reports zero new violations.

M2.3 remains one 36-entry migration capability despite the internal A/B batch
sequence. Its completion report must include:

- total migration inputs: 36;
- published/eligible count and quarantined count;
- quarantine reason-code breakdown;
- manual generated-output fixes: 0;
- direct publications or publication bypasses: 0;
- deterministic RC rebuild: PASS;
- publication pipeline check: PASS without activating the production current
  pointer before the separately authorized M2.4 proof.

Focused verification on the remote M2 HEAD `58a46ef` passed 21/21 tests across
M2.1 scale conformance, M2.2 dependency validation, and compiler conformance.
This proves the hardening baseline, not production-shape migration readiness.

## M2.3 Completion (2026-07-21)

M2.3 engineering migration is Closed at `cc54024`.

- 36 Pack v1.4 inputs received deterministic dispositions.
- 31 inputs became new canonical candidates.
- 3 inputs merged into existing stable IDs: Stop Shot, Follow Shot, and Ghost
  Ball (`aim.ghost_ball` -> `aiming.ghost_ball`).
- `term.tro` and `term.cu_le` remain quarantined with `reviewStateDraft`.
- The candidate release contains 35 eligible target entries: the 34 reviewed
  migration inputs after ID reconciliation plus retained canonical Poor Speed
  Control.
- Release Candidate digest:
  `fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac`.
- Candidate Pack digest:
  `22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02`.
- Deterministic rebuild and isolated publication pipeline: PASS.
- Manual generated-output fixes: 0. Direct production publications: 0.
- Production Knowledge remains 0.2.1; production current, runtime behavior,
  Golden Fixtures, Reference Behavior, and frozen M1.5 files are unchanged.

Verification at `cc54024`:

- App tests: 207/207.
- Knowledge package tests: 58/58.
- M2.3 conformance: 6/6.
- Compiler drift: PASS.
- Production Publication Check and Runtime Load: PASS on Windows after
  canonical newline verification was added.
- Frozen regression: 28 files unchanged.
- Architecture Fitness: 133 existing / 0 new.
- Analyzer baseline: 62 app info + 4 package info; no errors or warnings.

M2.4 remains blocked from production activation until it explicitly handles:

- clean-checkout rebuild on the second machine;
- 15 source records that currently have `legacy_metadata_only` rather than
  content-addressed source snapshots;
- four deferred learning paths;
- the two quarantined draft terminology entries, unless they remain excluded
  by an approved publication decision.

## Cross-machine Continuation Rule

Before continuing on either machine:

1. Fetch origin and tags.
2. Read this file from the active remote branch, then read `AGENTS.md` and
   `ARCHITECTURE_CONSTITUTION.md`.
3. Compare local HEAD and worktree status with the active remote branch before
   editing.
4. At the end of a completed capability or review decision, update this file,
   commit the evidence, and push the active branch so the other machine can
   continue from GitHub.
5. Never overwrite or discard a dirty worktree to synchronize machines; stash
   or isolate it first and record the recovery reference.

## Continue On Another Machine

```powershell
git fetch origin --prune --tags
git switch m2/evidence-runtime-hardening
git pull --ff-only origin m2/evidence-runtime-hardening
```

Before starting M2.4, read `AGENTS.md`, `ARCHITECTURE_CONSTITUTION.md`, and this
file. M2.4 must reproduce the M2.3 digests from a clean checkout, resolve or
explicitly gate the remaining source/path/quarantine limitations, and prove
publication without bypassing review or silently changing production current.
