# M19.2 Platform Cross-Surface Validation Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define semantic equivalence, permitted variation, ownership and evidence
governance across declared Pool OS surfaces. M19.2 is planning only. It
introduces no runtime contract, implementation, production code, Flutter/UI
behavior, infrastructure, deployment, CI/CD, monitoring, tooling, Product, ADR
or frozen-artifact change.

## Authority And Identity Root

Constitution v1.4.0, M18 Foundation Freeze, accepted M19.0 and M19.1
candidate/scope identity governance remain protected. Surface owners own their
mechanism claims; domain/contract owners own semantics; Architecture owns
cross-surface comparison rules; Quality independently verifies; PO accepts.

## Cross-Surface Validation Model

One comparison candidate binds the M19.1 candidate/scope, exact surface IDs and
classes, shared claims, permitted variations, domains/boundaries/contracts,
Knowledge/rule identities, canonical input set, normalized results, evidence,
owners/reviewers, unsupported declarations, validity, predecessor and digest.

Declared surface classes are mobile, web, desktop, capture device, wearable,
simulation tool, external provider and future delivery surface. A class does
not assert that an implementation exists. Each concrete surface is independently
identified and validated; class membership cannot supply evidence.

## Semantic Equivalence

For the same canonical claim and input, supported surfaces must preserve:

1. semantic IDs, versions and candidate/freeze binding;
2. public command/query intent and domain meaning;
3. contract-valid normalized outcome or projection;
4. ordering, idempotency/correlation and duplicate semantics;
5. explicit failure, denial, degraded and unknown-outcome meaning;
6. provenance, evidence lineage and deterministic digest rules;
7. security/privacy/data-purpose and authority constraints;
8. structured Decision Trace/alternatives grounding where applicable.

Equivalence means semantically indistinguishable accepted claims, not identical
pixels, timing, transport bytes, provider content or implementation structure.
A single mismatch yields `notEquivalent` for that claim/surface pair.

## Permitted Surface-Specific Variation

| Variation | Permitted only when | Never permitted to change |
|---|---|---|
| Layout/input modality | Experience owns presentation and command intent is preserved | Domain semantics or inference ownership |
| Localization/accessibility | Canonical IDs/values remain bound and meaning is preserved | Contract identity or factual content |
| Transport/serialization | Accepted adapter and canonical decoding are verified | Public contract meaning or provenance |
| Offline/degraded availability | Capability/state is explicit, compatible and expiring | Silent fallback or fabricated success |
| Device/camera acquisition | Evidence source/uncertainty/custody stay attributable | Observation fact or validation authority |
| Simulation rendering | Physics result contract remains authoritative | Player/tactic/Coach semantics |
| Provider-generated output | Deterministic envelope/binding and accepted output contract hold | Self-review, compatibility or domain truth |
| Performance/resource mechanism | Same workload claim and accepted outcome/failure semantics hold | Correctness, privacy, security or ordering |

Variation must be declared before evidence collection. An undeclared variation
is scope drift and blocks comparison.

## Unsupported-Surface Handling

Unsupported states are `notImplemented`, `notApplicable`, `incompatible`,
`unavailable`, `notValidated` or `withdrawn`, each bound to claim, surface,
reason, owner, evidence, validity and successor path. They are not failures to
be hidden and do not inherit support from another surface, class or provider.

Unknown, missing, conditionally supported or expired evidence resolves to
`notValidated`. Product or operational pressure cannot turn unsupported into
supported. Re-entry requires a new candidate/evidence revision.

## Validation Ownership By Surface

| Concern | Accountable authority |
|---|---|
| Surface identity/capability inventory | Surface owner |
| Shared semantic claim | Owning domain |
| Boundary/contract equivalence | Producer/consumer contract owners |
| Presentation/input variation | Experience owner |
| Capture Evidence/uncertainty | Evidence and capture-adapter owners |
| Simulation claim | Simulation contract owner |
| Provider envelope/result | AI/adapter/provider contract owners |
| Privacy/trust variation | Data owner and Security/Privacy |
| Comparison rules/audit | Architecture and independent Quality |
| Final accepted matrix | Product Owner |

No surface self-certifies equivalence. A surface owner can declare support or
withdrawal, but domain/contract owners and independent evidence remain required.

## Cross-Surface Evidence Aggregation

Evidence references are indexed by candidate/scope, claim ID, source/target
surface IDs, input-set digest, contract/Knowledge/rule versions, normalized
result/failure, permitted-variation ID, custodian/reviewer, validity and digest.
Aggregation references immutable evidence; it cannot copy or reclassify source
truth.

Required evidence includes single-surface conformance, pairwise semantic
comparison, declared variation verification, negative/unsupported cases,
failure/degraded behavior, provenance/trust/privacy and rollback. Each finding
has one accountable owner and retains denials/conflicts.

## Deterministic Comparison Rules

Canonical comparison orders claim ID, source surface ID, target surface ID,
input ID and evidence ID. It normalizes only contract-declared representation
variation. Same candidate, rules and evidence yield the same ordered findings,
equivalence matrix, unsupported set, status and digest.

No fuzzy score, majority surface, runtime timing, provider preference or
presentation similarity decides semantic equivalence. Generated/external
content is compared by accepted envelope, bindings and structured contract, not
by assumed text equality.

## Rollback And Supersession

Rollback restores a verified prior surface-claim matrix and retains the rejected
candidate/evidence. A corrected or newly supported surface creates a successor.
Supersession links immutable candidate, scope, matrix, unsupported declarations
and decisions, then revalidates every affected pair. Withdrawal does not erase
historical support evidence.

## Fail-Closed Governance

Return `notEquivalent`/`notValidated` on mixed/stale identity, undeclared
variation, missing owner/input/evidence, unsupported contract/capability,
semantic/failure/provenance mismatch, private access, trust/privacy conflict,
nondeterministic comparison, unsafe rollback or expired authority. No fallback,
inference, score, timeout or success on another surface grants validation.

## Product Owner Acceptance Gates

Future implementation requires exact files/mechanism and surfaces/claims,
accepted M19.1 identity, complete supported/unsupported inventory, owners,
declared variations, canonical positive/negative comparisons, trust/privacy,
rollback/supersession, protected freezes, Architecture Fitness 0 new, clean diff
and explicit PO acceptance before closure. This plan grants no implementation.

## Definition Of Done

- Eight surface classes and eight semantic-equivalence dimensions are explicit.
- Eight permitted variation classes and six unsupported states are defined.
- Ten ownership concerns and deterministic evidence aggregation are explicit.
- Rollback, supersession and fail-closed PO gates are explicit.
- Exactly this milestone and `MEMORY.md` change.
- No runtime contract, Flutter/UI behavior, implementation, Product, ADR,
  tooling or frozen change.
- Architecture Fitness, protected freezes, generated health and clean diff are
  verified.

## Engineering Evidence

- Planning defines eight surface classes, eight equivalence dimensions, eight
  variation classes, six unsupported states and ten ownership concerns.
- Full app regression: 953/953 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M18 freeze regression: 60/60 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
