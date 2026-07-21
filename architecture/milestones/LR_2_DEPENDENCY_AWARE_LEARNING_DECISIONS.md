# LR-2 - Dependency-aware Learning Decisions

**Status:** Engineering Closed; Product Review Pending

**Date:** 2026-07-21

**Implementation commit:** `3c50e129ffe6b5665da1e26aa1466e84aebae914`

**Branch:** `m2/evidence-runtime-hardening`

## Outcome

The executable Knowledge contract now preserves typed `requires` relations as
direct learning dependencies. The Learning Runtime gates the Technique being
evaluated on those direct dependencies and emits structured prerequisite
reasons without branching on Knowledge IDs.

| Gate | Result |
| --- | --- |
| Optional additive executable `dependencies` field | PASS |
| Direct dependency gating | PASS |
| Multiple direct dependencies use implicit ALL | PASS |
| Direct-only evaluation; no transitive traversal | PASS |
| `PREREQUISITE_UNSATISFIED` structured reason | PASS |
| `PREREQUISITE_SATISFIED` structured reason | PASS |
| No Knowledge-ID special case | PASS |
| Runtime defensive dangling/cycle rejection | PASS |
| LR-2 fixture and source-order determinism | 4/4 |
| LR-2 app behavior | 4/4 |
| Knowledge package tests | 67/67 |
| App tests | 215/215 |
| Architecture Fitness | 133 existing / 0 new |

The LR-2 fixture identities are:

- RC Content Digest:
  `ee09ca62a354fb6cf8c3754f72dac105e2e1d46f087a7a349145e8794cfe189b`
- Candidate Pack Digest:
  `531a7e6d5066fc1dca33aaca10b6080648dfdc70dfd2b1278bd3d3959a6dcc82`

## Semantics

- `relations` remain semantic associations.
- Only typed `requires` relations populate executable `dependencies`.
- Every direct dependency must be mastered before the current Technique is
  available.
- Multiple direct dependencies use implicit ALL semantics. This is not an
  Unlock Expression Contract.
- Runtime evaluates only the dependencies declared directly by the current
  Technique. It does not perform recursive traversal or transitive closure.
- Compiler/publication validation remains the primary dangling, self,
  duplicate, and cycle gate. Runtime validation is defensive.
- Decision reasons contain `dependencyId`, measurement evidence, and policy
  version; no explanation prose is embedded in Intelligence output.

## Preserved Invariants

- Production Knowledge remains `0.2.1` and current is unchanged.
- M2.3 RC digest remains
  `fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac`.
- M2.3 Candidate Pack digest remains
  `22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02`.
- Golden Fixtures, Reference Behavior 0.6.0 Revision 2, Evidence contracts,
  Publication records, and the Constitution are unchanged.

## Scope Boundary

LR-2 does not introduce recursive prerequisites, dependency expressions,
probabilistic mastery, attempt-level Evidence, dynamic policy discovery, or
production activation. Product acceptance is not inferred from passing tests.
