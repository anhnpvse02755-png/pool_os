# M19.5 Platform Deterministic Replay Validation Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define governance for validating deterministic replay across frozen platform
claims. M19.5 is planning only. It introduces no replay execution, runtime
contract, implementation, production code, Flutter, infrastructure, deployment,
CI/CD, monitoring, tooling, Product, ADR or frozen-artifact change.

## Authority And Protected Inputs

Constitution v1.4.0, M18 Foundation Freeze and accepted M19.0-M19.4 identity,
surface, compatibility and compliance governance remain protected. Source/domain
owners own authoritative inputs and semantics; contract owners own boundary
canonicalization; Architecture owns replay-validation rules; Quality verifies;
PO accepts.

## Deterministic Replay Validation Model

One immutable replay-validation candidate binds M19 candidate/scope and M18
Freeze, replay claim and source identities, input/output boundaries, contract,
Knowledge/model/policy/rule/canonicalization versions, canonical ordering,
accepted external-result envelopes, expected results/findings, evidence,
owners/reviewers, validity, predecessor/successor and digest.

Validation answers whether the same complete bindings must reproduce the same
deterministic outputs, ordered findings, acceptance/denial and digest. It does
not execute replay, recreate missing inputs, re-contact providers or infer that
two externally generated payloads must be equal.

## Replay Identity And Lineage

Replay identity includes schema and claim ID, candidate/scope/freeze digests,
authoritative source ranges, input-set and ordering digests, boundary/contract
versions, deterministic component identities, accepted external-envelope IDs,
expected-output and rule-set digests, owner/reviewer authority, determination,
validity and predecessor/successor links.

Any input range, order rule, contract, Knowledge/model/policy, external envelope,
expected output, authority or rule change creates a successor. Lineage is
append-only and retains failed/nondeterministic attempts. A projection/cache
cannot replace source identity; a timestamp/path cannot replace semantic ID.

## Replay Input Boundaries

| Input class | Required binding | Prohibition |
|---|---|---|
| Knowledge | Published version/digest and public snapshot | No authoring/compiler/generated mutation |
| Evidence | Immutable event IDs/schema/order/corrections and provenance | No fact rewrite or projection as source |
| Player/Experience projections | Builder/version/source-range/digest | No UI inference or projection authority |
| Coach lifecycle | Context/decision/transition/history/plan/recommendation/execution digests | No history mutation or missing transition synthesis |
| AI boundary | AISession/request/provider-result/response envelope identities | No direct internals or assumed generated equality |
| Simulation | Request/result/units/uncertainty/version | No player/tactic/Coach semantics |
| Configuration/policy | Semantic policy/rule/canonicalization versions | No ambient process defaults |
| External effects | Correlation/idempotency/outcome/evidence identity | No replay absent separate authority |

Only declared public contracts and immutable evidence cross replay-validation
boundaries. Missing or unknown input identity makes the claim incomplete.

## Replay Output Boundaries

Deterministic outputs are structured projections, state/status, ordered
decisions/findings, alternatives/Decision Trace, eligibility/compatibility
matrices, manifest/proof objects and canonical digests whose contracts declare
determinism. Each output binds input-set, producer/version, contract, provenance,
acceptance and digest.

External/generated payloads, wall-clock latency and infrastructure placement are
not deterministic outputs. Their immutable envelopes, request/result bindings,
structured acceptance and failure semantics can be deterministic. Validation
must report the boundary explicitly instead of normalizing away variation.

## Replay Evidence Governance

Required evidence references include authoritative input inventory, canonical
order, contract/version set, deterministic builder/rule identity, expected and
actual structured result digests, ordered findings, negative perturbation cases,
external-envelope custody, failure/unknown outcomes, reviewer authority,
lineage, retention/redaction and digest.

Positive evidence proves same complete bindings yield the same deterministic
result. Negative evidence proves rejection of missing/reordered inputs where
order is semantic, duplicate IDs, mixed/stale versions, changed policy/rule,
orphan external results, corrupted digest, private input and unknown outcome.
Evidence is immutable or superseding and cannot self-verify its producer.

## Deterministic Ordering Requirements

Canonical order is defined per collection before validation: Evidence uses
semantic sequence/time plus event ID tie-break; transitions use sequence then
transition ID; graph entities use semantic ID and declared dependency order;
claims/findings use authority/rule/claim/evidence IDs; matrices use contract,
producer, consumer, capability and surface IDs.

Locale, map/set iteration, filesystem order, wall clock, process scheduling,
provider preference and insertion order cannot decide output. Same canonical
bindings and rules yield the same normalized JSON, output/finding order,
determination and digest. Duplicate semantic IDs with conflicting content fail.

## Replay Determinations

| State | Meaning |
|---|---|
| deterministic | Complete equivalent bindings reproduce the declared result |
| nondeterministic | Same bindings yield a different deterministic result |
| incomplete | Required identity, input, output or evidence is missing |
| incompatible | Bound contracts/versions/capabilities cannot be compared |
| externalVariation | Deterministic envelope passes; external content is outside equality claim |
| held | Authority, trust, privacy, outcome or blocking finding is unresolved |
| superseded | A linked successor replaces this determination |

Only `deterministic` and correctly scoped `externalVariation` pass their exact
claims. No retries, scoring or majority outcomes convert another state.

## Replay Ownership Responsibilities

| Responsibility | Accountable owner |
|---|---|
| Replay claim/candidate composition | Architecture/Validation owner |
| Authoritative source inventory | Source/domain owner |
| Boundary contract/canonicalization | Producer/consumer contract owners |
| Knowledge publication identity | Knowledge publisher |
| Evidence ordering/corrections | Evidence owner |
| Intelligence policy/model output | Intelligence contract owner |
| Simulation result contract | Simulation owner |
| External envelope/outcome | Adapter/provider owner |
| Independent replay evidence | Quality |
| Final acceptance | Product Owner |

Infrastructure cannot redefine semantic order, expected results or source truth.

## Rollback And Supersession

Rollback restores a verified compatible replay-validation identity and retains
all failed evidence. Forward repair creates a versioned successor input/rule or
expected-output set. Supersession links immutable candidates, determinations and
evidence and repeats affected claims. It cannot overwrite history to manufacture
determinism.

## Fail-Closed Governance

Return incomplete/incompatible/nondeterministic/held on mixed/stale identity,
missing source/order/version, duplicate conflict, private input, orphan external
result, unknown effect outcome, output/provenance mismatch, nondeterministic
canonicalization, self-review, expired authority, unsafe rollback or any
blocking compliance/trust/privacy finding.

## Product Owner Acceptance Gates

Future implementation requires exact scope, accepted predecessors, complete
replay identity/input/output boundaries, owners, positive/negative evidence,
canonical order, external-effect governance, rollback/supersession, protected
freezes, Architecture Fitness 0 new, clean diff and explicit PO acceptance.
M19.5 grants no replay execution or implementation authority.

## Definition Of Done

- Immutable replay model/lineage and eight input classes are explicit.
- Output determinism boundary, evidence and canonical ordering are defined.
- Seven determinations and ten ownership responsibilities are explicit.
- Rollback, supersession and fail-closed gates are explicit.
- Exactly this milestone and `MEMORY.md` change; no prohibited change.

## Engineering Evidence

- Planning defines eight input classes, seven determinations and ten ownership
  responsibilities.
- Full app regression: 953/953 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M18 freeze regression: 60/60 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
