# M19.3 Platform Compatibility Validation Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define deterministic compatibility validation for M19 candidates and surfaces.
M19.3 is planning only. It adds no runtime contract, implementation, Flutter,
infrastructure, deployment, CI/CD, monitoring, tooling, Product, ADR or frozen
change.

## Authority And Inputs

Constitution v1.4.0, M18 Freeze and accepted M19.0-M19.2 identity/surface
governance remain protected. Contract owners own compatibility semantics;
Architecture owns evaluation governance; Quality verifies; PO accepts.

## Compatibility Validation Model

One immutable evaluation binds candidate/scope/freeze, source and target
surfaces, producer/consumer and contract versions, capabilities, Knowledge and
rule identities, boundary direction, canonical inputs, expected failure and
degradation semantics, evidence, owners, validity, lineage and digest.

The matrix evaluates each declared producer-consumer-capability combination.
Passing one row or direction cannot imply another.

## Compatibility Identity And Version Lineage

Compatibility identity includes semantic contract ID, major/minor/patch,
producer/consumer ranges, capability set, canonicalization version, adapter or
upcaster identity, deprecation window, predecessor/successor, rollback target
and evidence digest. Aliases, file paths and provider labels are not identity.

Lineage is append-only. Additive evolution preserves meaning; constrained or
deprecated use is explicit and expiring; breaking evolution requires separate
authority and migration/rollback. Upcasters cannot invent semantics.

## Compatibility States

| State | Meaning |
|---|---|
| compatible | All exact claims and evidence pass |
| compatibleWithConstraints | Named compatible limits are current |
| deprecatedCompatible | Supported only in an owned expiring window |
| incompatible | A required semantic or contract rule fails |
| unsupported | Capability/version pair is explicitly not supported |
| unknown | Identity, authority or evidence is incomplete |
| withdrawn | Previously supported combination is explicitly removed |
| superseded | A linked successor determination replaces this one |

Only the first three are supported states. `unknown` and conditional claims
fail closed; no state inherits across surface, direction or provider.

## Positive And Negative Evidence

Positive evidence proves exact supported version/capability, canonical result,
provenance, failure/degradation behavior and replay digest. Negative evidence
proves rejection of mixed major versions, stale/duplicate identity, unsupported
capability/direction, malformed input, private boundary, unknown provider
result, expired deprecation, trust/privacy conflict and unsafe rollback.

Evidence binds candidate/matrix row, source/custodian, inputs/results,
rule/tool versions, reviewer, validity and digest. Passing output cannot replace
negative evidence or owner authority.

## Deterministic Evaluation Ordering

Rows order by contract ID/version, producer ID, consumer ID, capability ID and
surface IDs; findings order by rule ID, severity and semantic evidence ID. Same
canonical candidate, rules and evidence yield the same matrix, supported and
unsupported sets, findings, status and digest.

There is no scoring, majority vote, timing, fallback or provider preference.
Duplicate semantic rows with conflicting content invalidate the evaluation.

## Ownership Boundaries

| Concern | Accountable owner |
|---|---|
| Contract meaning/version lineage | Contract owner |
| Producer output/capability | Producer owner |
| Consumer range/behavior | Consumer owner |
| Surface support | Surface owner plus contract owners |
| Knowledge identity | Knowledge publisher |
| Adapter/upcaster limits | Adapter and semantic owners |
| Evidence custody | Source custodian; Quality verifies |
| Matrix/rule governance | Architecture |
| Migration/rollback | Affected owners |
| Final acceptance | Product Owner |

Infrastructure and providers cannot declare semantic compatibility.

## Rollback And Supersession

Rollback restores a verified compatible last-known-good matrix identity and
retains rejected rows/evidence. Forward repair creates a versioned successor.
Supersession links immutable matrices, findings and decisions and rechecks every
affected row. Deprecation expiry cannot silently become permanent support.

## Fail-Closed Governance

Return incompatible/unsupported/unknown on mixed/stale/duplicate identity,
missing owner/evidence, empty capability intersection, private direction,
semantic/failure mismatch, expired window, nondeterministic result, unsafe
rollback or trust/privacy conflict. No fallback or technical success approves.

## Product Owner Acceptance Gates

Future implementation requires exact scope, accepted predecessors, complete
matrix/lineage/owners, canonical positive and negative evidence, migration and
rollback, trust/privacy review, protected freezes, Architecture Fitness 0 new,
clean diff and explicit PO acceptance. This plan grants no implementation.

## Definition Of Done

- Compatibility model, identity/version lineage and eight states are explicit.
- Positive/negative evidence and deterministic ordering are defined.
- Ten ownership boundaries, rollback, supersession and fail-closed gates are
  explicit.
- Exactly this milestone and `MEMORY.md` change; no prohibited change.

## Engineering Evidence

- Planning defines eight states and ten ownership boundaries.
- App 953/953; Knowledge 75/75; protected freezes 60/60.
- Architecture Fitness: 133 existing / 0 new; generated health restored.
- `git diff --check` clean; exact milestone and `MEMORY.md` scope.
