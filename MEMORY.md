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
  - M2.3 36-entry Migration: Not Started; this is the next capability.
  - M2.4 Clean-checkout Rebuild & Publication Proof: Not Started.
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

## Continue On Another Machine

```powershell
git fetch origin --prune --tags
git switch m2/evidence-runtime-hardening
git pull --ff-only origin m2/evidence-runtime-hardening
```

Before starting M2.3, read `AGENTS.md`, `ARCHITECTURE_CONSTITUTION.md`, and this
file. M2.3 must migrate the 36 reviewed entries through the compiler, dependency
validator, entry review, Eligible/Quarantined evaluation, and immutable RC
pipeline without bypass or direct publication.
