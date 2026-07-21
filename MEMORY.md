# Pool OS Project Memory

## Official State (2026-07-21)

- M1 - Executable Architecture: Closed.
- M1.5 - Integrated Baseline: Closed. Tag: `v0.6.0-M1.5`.
- M2 - Runtime Hardening & Deterministic Publication: Closed.
- Evidence Runtime Hardening: Closed.
- Compiler & Publication Hardening: Closed.
- Knowledge Generalization (Compiler & Publication scope): Closed.
  - M2.1 Scale Conformance: Closed at `716c23a`.
  - M2.2 Production Dependency Validation: Closed at `0809c83`.
  - M2.3 36-entry Migration: Closed at `cc54024`.
  - M2.4 Reproducibility Proof: Closed; executable gate added at `b1f3316`,
    fresh-clone proof passed at `bbc1d67`.
- Learning Runtime Generalization: Closed.
  - LR-1 Policy Dispatch and Deterministic Ranking: Engineering Closed at
    `75dbec2`; Product Review Accepted and capability Closed.
  - LR-2 Dependency-aware Learning Decisions: Engineering Closed at
    `3c50e12`; Product Review Accepted and capability Closed.
  - LR-3 Policy-driven Availability and Recommendation Pipeline: Engineering
    Closed at `35a5457`; Product Review Accepted and capability Closed.
  - LR-4 Unlock Expression Contract: Engineering Closed at `eaf635b`; Product
    Review Accepted and capability Closed. Only `allOf`/AND is implemented.
- Canonical Knowledge Package v1: Closed.
  - LR-5 Canonical Knowledge Package v1 Publication: Engineering Closed at
    `77c5412`; Product Review Accepted and capability Closed.
  - Product Owner approved the executable scope: deterministic Package
    Manifest v1 is separate from the audit-oriented Publication Record.
  - Manifest is the runtime entry point: Manifest -> Compatibility -> Artifact
    -> Runtime Load. Direct package.json runtime load is not the LR-5 canonical
    path.
  - Compatibility declares versioned required runtime contracts, not generic
    capabilities, and enforces a minimum runtime version.
  - LR-5 ends at Published Candidate Package, Not Current. It must not update
    the production current pointer.
  - Product Owner resolved the reference direction: Publication Record ->
    Manifest Digest. Manifest never contains Publication Record digest and
    runtime never reads Publication Record.
  - LR-5 Accepted and Closed. Manifest `7e65f849`,
    Candidate Pack `419b2bc0`, RC `69d71e22`, isolated Publication Record
    `69224e17`; Knowledge package 75/75, app 222/222, architecture 133/0.
- M2 Final Validation: Engineering Complete at `689ba7e`; Product Review
  Accepted and M2 Closed. Corrected fresh-clone gate passed compiler, publication, Manifest
  compatibility/runtime load, replay, package 75/75, app 222/222, architecture
  133/0, governance linkage, and no unexpected content drift.
- M3 - AI Platform: Open.
  - M3.1 Player Model Foundation: Accepted and Closed; implementation at
    `261988a`. Versioned Profile, State, Progress Snapshot, and Coach Input
    contracts now run through a deterministic projector from Learning Runtime
    snapshots. No LLM, new recommendation, or M2 runtime semantic change was
    introduced.
  - M3.2 Experience Projection Foundation: Accepted and Closed; implementation
    at `2722e0d`. Deterministic timeline, session summary, and
    Experience Snapshot projections consume Learning Runtime and Player Model
    outputs without raw Evidence access, persistence, scoring, recommendation,
    or AI.
  - M3.3 Coach Context Foundation: Engineering Complete at `8f6b98a`; Product
    Review Pending. The version-bound deterministic AI input contract combines
    Profile, Progress, and Experience without Evidence/Runtime access,
    inference, recommendation, persistence, or AI.

Active branch: `m2/evidence-runtime-hardening`.

## Locked Invariants

- Reference Behavior 0.6.0 Revision 2 and current Golden Fixtures are
  regression invariants.
- Player Model and Experience Snapshot are rebuildable projections, never
  sources of truth. Evidence remains factual input and Learning Runtime remains
  the versioned interpretation boundary.
- Coach Context is the API boundary for future AI consumers. AI must not bypass
  it to read Evidence, Event Log, Learning Runtime, or internal projection
  implementations.
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

M3.3 verification at implementation commit `8f6b98a`:

- Coach Context Contract v1 contains Profile, Progress, and Experience only.
- Version binding covers all three contract versions plus Knowledge version and
  digest; the complete deterministic payload participates in Context digest.
- Player mismatch, stale Player Progress binding, and Knowledge mismatch fail
  loudly.
- The builder imports projections/contracts only and has no Evidence, Event
  Log, persistence, Flutter, recommendation, planning, or AI dependency.
- Focused Coach Context tests: 6/6; app tests: 242/242; Knowledge package tests:
  75/75; Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues. Constitution, Reference Behavior, Golden
  Fixtures, production Knowledge/publication, and M2 digests are unchanged.

M3.3 milestone:
`architecture/milestones/M3_3_COACH_CONTEXT_FOUNDATION.md`.

M3.2 verification at implementation commit `2722e0d`:

- Experience Event Contract v1 records derived Learning Decision timeline
  items; it is not a canonical Evidence event or source of truth.
- Timeline ordering is canonical by UTC occurrence time and stable event ID.
- Session Summary covers its timeline events exactly and introduces no score or
  inference.
- Experience Snapshot binds the timeline to Player Progress and Knowledge
  identities with a deterministic SHA-256 digest.
- Empty, duplicate, mixed-Knowledge, incomplete-summary, and cross-player paths
  fail loudly.
- Focused Experience tests: 7/7; app tests: 236/236; Knowledge package tests:
  75/75; Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues. Constitution, Reference Behavior, Golden
  Fixtures, production Knowledge/publication, and M2 digests are unchanged.

M3.2 milestone:
`architecture/milestones/M3_2_EXPERIENCE_PROJECTION_FOUNDATION.md`.

M3.1 verification at implementation commit `261988a`:

- Player Model is an Intelligence capability and its projector is an
  application service.
- Player Profile and Progress Snapshot are UI-independent versioned contracts.
- Coach Input contains Player Model contracts and never raw Evidence records.
- Snapshot JSON and SHA-256 digest are deterministic across input ordering.
- Empty, duplicate, mixed-Knowledge, and player-ID mismatch cases fail loudly.
- Focused Player Model tests: 7/7; app tests: 229/229; Knowledge package tests:
  75/75; Architecture Fitness: 133 existing / 0 new.
- Focused analyzer: no issues. Existing full analyzer baselines remain app 62
  info and package 4 info + 1 warning.
- Constitution, Reference Behavior, Golden Fixtures, production Knowledge,
  publication artifacts, and M2 digests remain unchanged.

M3.1 milestone:
`architecture/milestones/M3_1_PLAYER_MODEL_FOUNDATION.md`.

LR-4 verification at implementation commit `eaf635b`:

- Additive `unlock.allOf` authoring compiles to a canonical nested AND tree.
- Expression leaves populate the existing hard dependency graph and RC digest;
  compiler rejects cycles before runtime.
- Runtime trace identifies failed dependency leaves and failed `allOf` nodes
  using structured node IDs; no prose is embedded.
- OR, NOT, empty allOf, and mixed `requires` plus `unlock` declarations fail
  loudly. Existing typed `requires` remains backward compatible.
- LR-4 compiler conformance: 5/5; runtime conformance: 3/3.
- LR-4 RC digest:
  `69d71e22e2f47d85060cc5bd03a1e5af0fd34b6e3e1bbb82f0764648971b71f6`.
- LR-4 Candidate Pack digest:
  `419b2bc04c402726d9b4b382523e83a83a23467e1c4c83dcc8b1cac05080dc38`.
- Knowledge package tests: 72/72; app tests: 222/222.
- Architecture Fitness: 133 existing / 0 new.
- Production compiler, M2.3 migration, M2.4 reproducibility, LR-2 fixture,
  Golden, and replay regression: PASS with prior identities unchanged.
- Publication, Evidence, Reference Behavior, Constitution, production
  Knowledge 0.2.1, and current are unchanged.

LR-4 milestone:
`architecture/milestones/LR_4_UNLOCK_EXPRESSION_CONTRACT.md`.

LR-3 verification at implementation commit `35a5457`:

- Technique decisions execute explicit Availability -> Mastery ->
  Recommendation -> Correction -> Decision stages.
- Availability returns typed state and blockers without creating
  Recommendation candidates.
- Mastery returns assessment and structured reasons without creating
  Recommendation candidates.
- Recommendation consumes resolved Availability and Mastery; it does not
  evaluate dependency evidence itself.
- Correction resolution has no Mastery or Recommendation input.
- LR-3 stage conformance: 4/4; focused LR-1/LR-2/Golden regression: 26/26.
- App tests: 219/219; Knowledge package baseline: 67/67.
- Architecture Fitness: 133 existing / 0 new.
- Analyzer: no errors or warnings; existing app info baseline remains 62.
- Production compiler drift, M2.3 migration, and M2.4 reproducibility: PASS;
  all prior RC and Candidate Pack digests are unchanged.
- Compiler, Publication, Evidence, Golden Fixtures, Reference Behavior,
  Constitution, production Knowledge 0.2.1, and current are unchanged.

LR-3 milestone:
`architecture/milestones/LR_3_POLICY_DRIVEN_DECISION_PIPELINE.md`.

LR-2 verification at implementation commit `3c50e12`:

- Executable Knowledge preserves typed `requires` relations in an optional,
  additive `dependencies` field; semantic `relations` remain unchanged.
- Learning decisions gate the current Technique on direct dependencies using
  implicit ALL semantics, with no recursive or transitive traversal.
- Structured `PREREQUISITE_UNSATISFIED` and `PREREQUISITE_SATISFIED` reasons
  carry dependency ID, measurement evidence, and policy version.
- Compiler/publication remains the primary dependency graph gate; runtime
  defensively rejects dangling and cyclic executable graphs.
- LR-2 RC digest:
  `ee09ca62a354fb6cf8c3754f72dac105e2e1d46f087a7a349145e8794cfe189b`.
- LR-2 Candidate Pack digest:
  `531a7e6d5066fc1dca33aaca10b6080648dfdc70dfd2b1278bd3d3959a6dcc82`.
- LR-2 fixture tests: 4/4; LR-2 app behavior tests: 4/4.
- Knowledge package tests: 67/67.
- App tests, including accepted Golden/replay behavior: 215/215.
- Architecture Fitness: 133 existing / 0 new.
- Production Knowledge/current, M2.3/M2.4 identities, Golden Fixtures,
  Reference Behavior, Evidence contracts, Publication records, and
  Constitution are unchanged.

LR-2 milestone:
`architecture/milestones/LR_2_DEPENDENCY_AWARE_LEARNING_DECISIONS.md`.

LR-1 verification at implementation commit `75dbec2`:

- Generic Learning Runtime dispatch resolves payload kind plus versioned
  policy; no Knowledge-ID branch.
- Third Technique proof passed Markdown -> compile -> scoped review -> RC ->
  isolated candidate publication -> runtime load.
- LR-1 RC digest:
  `f9b7d6f5fd280d183e2f973fab9e46c43f4a8c3d614bdb8f16ff671e629bdc8d`.
- LR-1 Candidate Pack digest:
  `4d4faab782d90d389cfc1d49e6b9703f47fdbc26a04e354b5346842e463e4060`.
- Existing `advanced` policy: 15/20 remains below threshold; 16/20 achieves
  Mastery and changes the recommendation.
- Evidence isolation across two Techniques and two Mistakes: PASS.
- Equal-score ranking uses policy score then stable semantic ID and is stable
  across pack order: PASS.
- Unsupported kind, missing capability, unknown ID, and probabilistic policy
  fail with `ExecutableKnowledgeException`: PASS.
- Knowledge package tests: 63/63.
- App tests, including accepted Golden/replay behavior: 211/211.
- Architecture Fitness: 133 existing / 0 new.
- Production Knowledge/current, Golden Fixtures, Reference Behavior,
  Constitution, and M2.3/M2.4 identities are unchanged.

LR-1 milestone:
`architecture/milestones/LR_1_POLICY_DISPATCH_DETERMINISTIC_RANKING.md`.

M2.4 fresh-clone verification at commit `bbc1d67`:

- Clone source: GitHub branch `m2/evidence-runtime-hardening`.
- RC Content Digest reproduced exactly:
  `fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac`.
- Candidate Pack Digest reproduced exactly:
  `22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02`.
- Publication schema, provenance linkage, review scope, and semantics:
  equivalent.
- Candidate Runtime Load and production Knowledge 0.2.1 Runtime Load: PASS.
- Knowledge package tests: 61/61.
- App tests, including replay/restart coverage: 207/207.
- Architecture Fitness: 133 existing / 0 new.
- Production current pointer unchanged; no activation or production publish.
- Different-machine/user/locale proof remains Extended Evidence and was not
  required for M2.4 closure.

M2.4 machine-readable evidence is stored at
`architecture/milestones/m2_4/proof_record.json`.

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
- Migration input candidates: 36. Eligible migration inputs: 34. Quarantined
  migration inputs: 2.
- The RC contains 35 target entries because the 34 reviewed inputs are
  reconciled with stable IDs and canonical Poor Speed Control is retained.
  `Eligible` does not mean `Published`, and no M2.3 candidate is
  production-current.
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

Canonical Knowledge Package v1 remains blocked from production activation
until later publication work explicitly handles:

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

Before continuing Learning Runtime Generalization, read `AGENTS.md`,
`ARCHITECTURE_CONSTITUTION.md`, and this file. M2.4 closed reproducibility only;
do not treat its isolated publication proof as authorization to move production
current or publish Canonical Knowledge Package v1. LR-1 is engineering-complete
and Product Accepted. Do not reopen LR-1 without a regression or governance
decision. LR-2 Dependency-aware Learning Decisions is the next batch and must
receive its own executable scope before implementation.
