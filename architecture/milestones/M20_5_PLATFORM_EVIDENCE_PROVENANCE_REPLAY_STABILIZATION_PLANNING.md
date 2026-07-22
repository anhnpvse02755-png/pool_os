# M20.5 Platform Evidence, Provenance & Replay Stabilization Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define governance for stabilizing evidence references, provenance lineage and
deterministic replay across accepted M20 convergence claims. M20.5 is planning
only. It introduces no replay execution, runtime contract, implementation,
production code, Flutter/UI, Product, infrastructure, deployment, CI/CD,
monitoring, tooling, ADR, freeze or generated protected-artifact change.

## Authority And Accepted Inputs

Constitution v1.4.0, accepted M20.0-M20.4 and M19 Foundation Freeze remain
authoritative/protected. M20.1 supplies candidate/scope identity, M20.2 public
boundaries, M20.3 compatible versions and M20.4 stable semantic meanings.
Evidence/source owners retain fact and custody authority; contract owners own
canonicalization; Architecture/Platform owns stabilization governance; Quality
independently verifies replay; Product Owner accepts.

## Evidence Stabilization Model

An immutable evidence-stabilization entry binds entry/schema version, M20
candidate/scope and claim IDs, authoritative source and evidence IDs, evidence
type/schema/status, public boundary/contract/version, canonical input/result/
failure digests, semantic and compatibility determinations, provenance/custody,
correction lineage, positive/negative classification, reviewer authority,
validity/retention/redaction, predecessor/successor and deterministic digest.

Stabilization references authoritative evidence; it cannot copy source truth,
rewrite a fact, promote a projection/report to source, infer missing evidence or
turn an implementation observation into normative authority.

## Immutable Evidence Lineage

Evidence lineage is an append-only acyclic chain containing original evidence,
correction/supersession records, source-range identity, producer and schema
versions, custody transfers, redaction/retention decisions, claim bindings,
review decisions and digests. Correction creates a new record that cites the
superseded record; deletion, in-place mutation and identity reuse are invalid.

Every successor explicitly binds predecessor digest, reason, changed fields,
owner authority, affected claims and replay scope. Missing, mixed, cyclic,
ambiguous or content-conflicting lineage blocks all dependent claims.

## Provenance Stabilization Model

Stable provenance binds:

1. semantic evidence and source IDs;
2. source domain, producer and accountable custodian;
3. capture/creation method and schema/contract versions;
4. canonical source range, order and content digest;
5. Knowledge/model/policy/rule/tool identities when applicable;
6. boundary, consumer, purpose and authorized claim;
7. correction, redaction, retention and custody lineage;
8. external/provider request-result envelope identities;
9. reviewer/acceptance authority and validity;
10. deterministic provenance digest and predecessor/successor.

Paths, timestamps, display labels, provider names or transport metadata cannot
replace semantic provenance. Provenance describes origin and custody; it does
not prove correctness or grant semantic authority.

## Cross-Domain Evidence Consistency

| Evidence class | Required stable consistency | Prohibited substitution |
|---|---|---|
| Knowledge publication | version/digest/public snapshot and publisher | authoring/compiler/generated mutation |
| Evidence events | IDs/schema/order/corrections/source custody | projection or inference as fact |
| Player/Experience projections | builder/version/source range/digest | projection as authoritative source |
| Intelligence decisions | inputs/policy/model/alternatives/Decision Trace | decision recast as Evidence |
| Coach lifecycle | context through execution IDs/digests/transitions | history mutation or transition synthesis |
| AI boundary | session/request/result/response/capability envelopes | generated content as self-verification |
| Simulation | request/result/model/units/uncertainty | result as player or strategy truth |
| Compatibility/semantics | exact M20.3/M20.4 determination identities | report as owner decision |
| External effects | correlation/idempotency/outcome/evidence identity | effect replay or assumed outcome |
| Audit/acceptance | candidate/evidence set/auditor/PO decision digest | assembly self-audit or implicit approval |

The same evidence may support multiple claims only through distinct explicit
claim bindings. Cross-domain aggregation never transfers source ownership.

## Replay Stabilization Governance

One immutable replay package binds candidate/scope, evidence/provenance set,
source ranges, canonical ordering, contract/Knowledge/model/policy/rule/tool
versions, accepted external-result envelopes, expected deterministic outputs,
failure/unknown states, findings, reviewer authority, validity and digest.

Same complete canonical bindings must yield the same normalized structured
outputs, ordered findings, determination and digest. Replay does not recreate
missing facts, contact providers, execute effects or claim that external/
generated payload bytes are deterministic. Only their immutable envelopes,
bindings, acceptance and failure semantics participate deterministically.

## Canonical Ordering And Output Boundaries

- Evidence records: semantic source sequence/time, then evidence ID.
- Corrections/transitions: sequence, then correction/transition ID.
- Graph entities: semantic ID and declared acyclic dependency order.
- Claims/findings: authority, rule, claim and evidence IDs.
- Matrices: contract, producer, consumer, capability and boundary IDs.
- External envelopes: correlation, request and result IDs.

Locale, filesystem order, map/set iteration, wall clock, scheduling, provider
preference and insertion order cannot decide output. Duplicate semantic IDs
with conflicting content fail closed.

## Stabilization Determinations

| Determination | Meaning | Gate effect |
|---|---|---|
| `stableReplayable` | Evidence/provenance complete and deterministic replay passes | Eligible |
| `stableExternalEnvelope` | Envelope replay passes; external content is outside equality | Eligible for exact scoped claim |
| `incomplete` | Required evidence, provenance or source identity is absent | Blocked |
| `inconsistent` | Cross-domain bindings or owner meanings conflict | Blocked |
| `nondeterministic` | Same bindings produce different deterministic output | Blocked |
| `custodyInvalid` | Custody, correction, retention or redaction lineage is invalid | Blocked |
| `stale` | Source/version/evidence/authority/validity changed | Blocked |
| `superseded` | A linked successor replaces the determination | Historical only |

Only the first two can satisfy their exact claims. No retry, majority, score,
fallback or passing implementation converts a blocked determination.

## Ownership Boundaries

| Responsibility | Accountable owner |
|---|---|
| Stabilization candidate/package composition | Architecture/Platform |
| Authoritative facts and source inventory | Source/Evidence owner |
| Evidence corrections, custody and retention | Evidence custodian/data owner |
| Boundary contract and canonicalization | Producer/consumer contract owners |
| Knowledge publication identity | Knowledge publisher |
| Intelligence decision/trace provenance | Intelligence contract owner |
| Simulation request/result provenance | Simulation owner |
| AI/external envelope and outcome identity | Adapter/provider owner plus contract owner |
| Independent replay/negative evidence | Quality |
| Final acceptance | Product Owner |

Assemblers, providers and generated outputs cannot approve their own evidence
or redefine semantic order, source truth or expected result.

## Rollback, Repair And Supersession

Rollback selects only a verified compatible last-known-good evidence/replay
package and retains failed, corrected and rejected records. Repair occurs at the
accountable source through an append-only correction or as a versioned rule/
package successor. Supersession links immutable predecessor/successor packages,
changed evidence, affected claims, owners and rerun gates.

## Fail-Closed Governance

Reject on wrong M19/M20 predecessor, missing/mixed/stale/duplicate evidence,
private source, fact/inference confusion, broken/cyclic correction or custody
lineage, provenance mismatch, orphan external result, unknown effect outcome,
semantic/compatibility drift, self-review, output digest mismatch, invalid
retention/redaction, unsafe rollback or nondeterministic canonicalization.

## Product Owner Implementation Acceptance Gates

Future implementation requires separately authorized exact scope/files,
accepted predecessors, complete evidence/provenance/replay identities, source
and custody owners, positive/negative cases, canonical ordering, external-effect
governance, recovery/supersession, protected regressions, Architecture Fitness
0 new, clean diff and explicit PO acceptance. M20.5 grants planning authority
only.

## Definition Of Done

- Evidence stabilization, ten-part provenance and immutable lineage are defined.
- Ten cross-domain evidence classes and ten owners are explicit.
- Replay boundaries, canonical ordering and eight determinations are defined.
- Rollback/repair/supersession and fail-closed PO gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No implementation, runtime contract, Product, ADR, tooling or freeze change.

## Engineering Evidence

- Planning defines ten provenance bindings, ten evidence classes, eight
  determinations and ten ownership responsibilities.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
