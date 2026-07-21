# M2.4 - Reproducibility Proof

**Status:** Engineering Closed; Production Activation Not Authorized

**Date:** 2026-07-21

**Verified source commit:** `bbc1d67a60049fb3de12a8746e32491ea8153211`

**Branch:** `m2/evidence-runtime-hardening`

## Outcome

A fresh clone from GitHub reproduced the M2.3 release candidate and candidate
pack identities, verified equivalent publication semantics in an isolated
store, loaded both the generalized candidate and current production package,
replayed the accepted learning behavior through the full app suite, and passed
Architecture Fitness.

| Gate | Result |
| --- | --- |
| Fresh clone from GitHub | PASS |
| M2.3 artifact drift check | PASS |
| RC Content Digest identical | PASS |
| Candidate Pack Digest identical | PASS |
| Publication semantics equivalent | PASS |
| Candidate Runtime Load | PASS |
| Production 0.2.1 Runtime Load | PASS |
| Replay and frozen regression | PASS |
| Knowledge package tests | 61/61 |
| App tests | 207/207 |
| Architecture Fitness | 133 existing / 0 new |
| Production current unchanged | PASS |
| Production activation | NOT PERFORMED |

The exact reproduced identities are:

- RC Content Digest:
  `fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac`
- Candidate Pack Digest:
  `22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02`
- Production current pointer file digest:
  `0e757d4af0eca29fd085ab0c0c5b806415b63dd651bd3000ab23023eb158c8ba`

Publication Record identity was intentionally not used as the reproducibility
gate. The proof compared schema version, compiler and Knowledge versions,
candidate identity, artifact path semantics, RC provenance linkage, review
outcome, and review scope. Reviewer, timestamp, audit metadata, and record
digest remain outside this equivalence rule.

## Executable Evidence

- Proof verifier:
  `packages/billiard_knowledge/tool/knowledge_reproducibility_proof.dart`
- Failure-path conformance:
  `packages/billiard_knowledge/test/knowledge_reproducibility_proof_test.dart`
- Fresh-clone gate runner:
  `scripts/run_m2_4_reproducibility_proof.ps1`
- Machine-readable run record:
  `architecture/milestones/m2_4/proof_record.json`

The runner rejects RC, Candidate Pack, current-pointer, publication-semantic,
source/corpus, and other repository content drift. Architecture Fitness is
allowed to refresh only its generated `build/architecture/health.json`
projection. Windows CRLF stat noise in generated plugin registrants is not
treated as content drift.

## Scope Boundary

M2.4 proves deterministic rebuild and publication semantics. It does not
authorize production activation or claim Canonical Knowledge Package v1 is
publishable.

The following remain publication blockers owned by later work:

- 15 sources remain `legacy_metadata_only` without content-addressed source
  snapshots;
- four legacy learning paths remain deferred;
- `term.tro` and `term.cu_le` remain quarantined drafts;
- production current remains Knowledge `0.2.1`.

Different-machine, different-user, locale, and timezone verification remains
Extended Evidence, not an M2.4 closure gate.

## Roadmap Transition

With the official M2.4 gate satisfied:

- M2.4 Reproducibility Proof: Closed.
- Knowledge Generalization: Closed within the proven compiler/migration scope.
- Learning Runtime Generalization: In Progress as the next capability.
- Canonical Knowledge Package v1: Not Published.
