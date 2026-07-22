# M20.4 Platform Cross-Domain Semantic Stabilization Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define governance for preserving canonical meaning across accepted cross-domain
platform flows. M20.4 is planning only. It introduces no runtime contract,
implementation, production code, Flutter/UI, Product, infrastructure, tooling,
ADR, freeze or generated protected-artifact change.

## Authority And Accepted Inputs

Constitution v1.4.0, accepted M20.0-M20.3 and M19 Foundation Freeze remain
authoritative/protected. M20.1 supplies candidate/scope, M20.2 public boundaries
and M20.3 compatible version determinations. Each domain remains sole owner of
its semantic truth. Architecture/Platform owns composition governance, Quality
verifies evidence and Product Owner accepts.

## Semantic Convergence Model

An immutable semantic-convergence entry binds candidate/schema version,
composed-flow and claim IDs, source/consumer domains, public contract/boundary
and compatible-version identities, source semantic invariant IDs, canonical
term/value/unit/state/failure/provenance meanings, permitted projection or
presentation variation, Evidence/Decision Trace references, owners, conflicts,
validity, recovery, predecessor/successor and deterministic digest.

Convergence records agreement that composed public meanings remain consistent.
It cannot create a Platform-owned domain model, merge distinct concepts, infer
equivalence from shared names/shapes, rewrite source truth or normalize away
uncertainty and provenance.

## Canonical Meaning Preservation Across Domains

| Semantic boundary | Meaning that must remain owned/preserved | Forbidden reinterpretation |
|---|---|---|
| Knowledge -> Intelligence | published instructional concept/dependency identity | compiler/runtime inference as authoring truth |
| Evidence -> Intelligence | attributable fact/event/projection | inference or decision recast as fact |
| Intelligence -> Experience | decision, trace and read-model meaning | UI-derived mastery or recommendation policy |
| Intelligence -> Simulation | request, result, uncertainty and model identity | physics result recast as player/strategy truth |
| Simulation -> Experience | versioned scenario/result projection | UI presentation treated as simulation evidence |
| AI session -> provider | bounded IDs/digests/capability request | provider output treated as deterministic source truth |
| AI response -> Experience | accepted structured response/provenance | prose or generation treated as verified decision |
| Domain -> persistence | aggregate identity and public repository semantics | storage schema/client as domain model |
| Domain -> operations | status/evidence/failure identity | telemetry or deployment state as semantic authority |
| Cross-domain Decision Trace | cited facts, rules, alternatives and decision | explanation without structured grounding |

Units, enumerations, state transitions, null/unknown semantics, ordering,
precision, uncertainty, provenance and failure classes remain contract/version
bound. Presentation and transport may vary only without changing meaning.

## Ownership Of Semantic Truth

| Truth or decision | Accountable owner |
|---|---|
| Knowledge concepts and dependencies | Knowledge author/publisher |
| Evidence facts and event meaning | Evidence/source owner |
| Intelligence inference, mastery and decision policy | Intelligence owner |
| Simulation physics/result uncertainty | Simulation owner |
| Experience presentation and commands | Experience owner |
| AI boundary contracts and accepted output status | AI contract owner; source owners retain facts |
| Public contract meaning/version | Producer/consumer contract owners |
| Persistence/transport/provider mechanism | Infrastructure owner, never semantic owner |
| Composed-flow convergence entry | Architecture plus all affected semantic owners |
| Independent verification and acceptance | Quality/Product Owner |

An assembler or consumer cannot approve a source-owned meaning. Agreement adds
composition evidence, not transferred authority.

## Semantic Conflict Resolution Governance

Conflicts are immutable candidate-bound findings classified as `naming`,
`identity`, `definition`, `unit`, `state`, `ordering`, `precision`, `unknown`,
`provenance`, `ownership`, `version` or `failureSemantic`. Each binds affected
entry/claims, source statements, owners, severity to correctness (not score),
evidence, permitted resolution path, validity and digest.

Resolution order is deterministic: verify identity/version; consult normative
authority; obtain each source-owner decision; preserve distinct concepts when
meanings differ; version any approved change; update compatibility/evidence;
independently verify; append a superseding determination. Platform arbitration,
majority vote, provider behavior or implementation convenience cannot redefine
domain truth. Unresolved conflicts block the composed claim.

## Evidence Requirements

Each evidence reference binds exact candidate, flow/entry, source semantic IDs,
contracts/versions, canonical input/output/failure and provenance digests,
positive equivalence or negative conflict case, source/custodian, owner
decisions, rule/tool version, reviewer, validity/retention and digest. Required
cases cover equivalent meaning, permitted presentation variation, same-name
different-meaning, unit/state/version mismatch, unknown/uncertainty preservation,
source-owner disagreement and deterministic replay.

Evidence is immutable or superseding. A projection, report, AI/provider output
or implementation observation cannot replace source truth or self-review.

## Semantic Determinations

| Determination | Meaning | Gate effect |
|---|---|---|
| `stableEquivalent` | Exact canonical meaning preserved | Eligible |
| `stableVariant` | Declared presentation/mechanism variation preserves meaning | Eligible |
| `distinctPreserved` | Similar concepts remain explicitly non-equivalent | Eligible for declared separation |
| `conflictOpen` | Owner-approved resolution is incomplete | Blocked |
| `sourceDrift` | A source identity/version/meaning changed | Blocked |
| `ownershipConflict` | Semantic authority is missing or disputed | Blocked |
| `invalid` | Mixed, duplicate, malformed or nondeterministic entry | Blocked |

Only the first three can satisfy their exact declared claims. No score, fallback
or partial equivalence compensates for a blocked state.

## Rollback, Repair And Supersession

Rollback selects a verified compatible last-known-good semantic entry without
editing source, conflicts, evidence or audit. Repair occurs at the accountable
source or as a versioned composition update under separate authority.
Supersession links immutable predecessor/successor, changed meanings, owner
decisions, compatibility impact, evidence and rerun gates.

## Fail-Closed Governance

Reject on wrong predecessor/root, private boundary, mixed/stale semantic or
version identity, missing owner, inferred equivalence, lost units/unknown/
uncertainty/provenance, Evidence/Intelligence confusion, conflicting source
decisions, unsupported compatibility, incomplete evidence, unsafe rollback or
nondeterministic ordering. Technical success, shared schema, name equality,
provider output, score or deadline cannot establish semantic convergence.

## Product Owner Implementation Acceptance Gates

Future implementation requires separately authorized exact scope/files,
accepted predecessors, complete flow/semantic/owner inventory, current M20.3
compatibility, positive/negative evidence, resolved conflicts, recovery and
supersession, protected regressions, Architecture Fitness 0 new, clean diff and
explicit PO acceptance. M20.4 grants planning authority only.

## Definition Of Done

- Immutable semantic convergence and canonical preservation are defined.
- Ten semantic boundaries and ten truth owners are explicit.
- Twelve conflict classes, seven determinations and resolution order are defined.
- Evidence, rollback/repair/supersession and fail-closed gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, runtime contract, Product, ADR, tooling or freeze change.

## Engineering Evidence

- Planning defines ten boundaries, ten owners, twelve conflict classes and seven determinations.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
