# M19.4 Platform Constitutional Compliance Validation Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define deterministic governance for validating platform claims against the Pool
OS Architecture Constitution. M19.4 is planning only. It introduces no runtime
contract, implementation, production code, Flutter behavior, infrastructure,
deployment, CI/CD, monitoring, tooling, Product, ADR or frozen-artifact change.

## Authority And Protected Inputs

Constitution v1.4.0, M18 Foundation Freeze and accepted M19.0-M19.3 identity,
surface and compatibility governance remain protected. Architecture interprets
constitutional scope; domain/contract owners own affected claims; independent
Quality verifies evidence; Product Owner accepts the planning milestone. A
validation report cannot create normative authority.

## Normative Authority Hierarchy

Conflicts are resolved in this exact order from Constitution Section 20.1:

1. Architecture Constitution;
2. ratified Architecture Decision Records;
3. versioned domain contracts;
4. Product RFCs and feature specifications;
5. implementation documentation;
6. generated reports and comments.

Only ratified ADRs participate at level two; Proposed ADRs are planning evidence,
not authority. Observed production behavior and executable checks describe
implementation reality but cannot amend a higher authority. Conflict with a
higher authority is drift/noncompliance until remediation or the Section 20.3
amendment process completes.

## Constitutional Compliance Validation Model

One immutable evaluation binds candidate/scope/M18 Freeze, claim IDs, affected
domains/boundaries/contracts/surfaces, cited authority versions and sections,
applicable prohibitions/invariants, evidence references, owners/reviewers,
exceptions, findings, validity, predecessor/successor and digest.

Every in-scope claim has an applicability determination and one or more cited
rules. `notApplicable` requires owner reason and independent review; omission is
unknown and blocks the candidate. Compliance is conjunctive across applicable
rules, never scored or inferred from document completeness.

## Compliance Identity And Lineage

Compliance identity includes evaluation schema, candidate and scope digests,
Constitution version, ratified ADR/contract identities, claim-rule mappings,
evidence-package and rule-set digests, reviewer authority, exception identity,
determination, validity and predecessor/successor links.

Changing a claim, authority version, applicability, rule mapping, evidence,
exception or reviewer creates a successor identity and repeats affected review.
Historical compliant/noncompliant findings remain immutable. A Constitution
amendment links old/new versions; it never retroactively rewrites the old result.

## Required Compliance Coverage

| Coverage area | Minimum validation claim |
|---|---|
| Architecture style/maturity | Modular-monolith boundaries and evidence maturity remain distinct from vision |
| Domain ownership/dependencies | Five domains, control plane and public dependency directions are preserved |
| Evidence/Intelligence | Facts are append-only/corrected and remain distinct from inference/decisions |
| Knowledge | Authoring is source truth; publication, IDs, versions and provenance are protected |
| Experience | Renders projections/submits commands; does not infer Mastery/recommendations |
| Simulation | Physics remains independent of player, tactics, Coach policy and UI |
| AI/content | AI cannot self-review/publish; prose is grounded in structured Decision Trace |
| Contracts/evolution | Compatibility, unknown rejection, migration and provenance remain explicit |
| Privacy/security | Erasure, minimization, access purpose, custody and audit remain owned |
| Enforcement/governance | Prohibitions, tests, fitness gates, authority, amendments and exceptions are honored |

Coverage adds no new constitutional rule. A missing applicable area blocks
completeness; an implementation mechanism is not compliant merely because its
architecture document describes the intended destination.

## Constitutional Evidence Requirements

Each evidence reference binds candidate/claim/rule, source and custodian,
observed input/result, contract/tool/rule versions, positive or negative status,
reviewer, verification time/validity, lineage and digest. Required classes are:

- normative citation and applicability evidence;
- public dependency and domain-ownership evidence;
- contract/freeze/semantic-ID compatibility evidence;
- deterministic replay/provenance and negative rejection evidence;
- Knowledge/Evidence/Intelligence/Experience/Simulation boundary evidence;
- AI review/publication and Decision Trace grounding evidence where applicable;
- privacy/security/retention/erasure evidence;
- enforcement, exception, rollback and amendment evidence.

Absent operational evidence is explicitly `notAvailable` with owner and plan;
it is never counted as compliance. Generated health reports support evidence but
remain below authority and cannot self-verify their producing mechanism.

## Independent Compliance Review Governance

The reviewer must be independent of claim implementation and evidence assembly.
Architecture validates authority/applicability; domain and contract owners attest
owned semantics; Quality verifies evidence and replay; Security/Privacy reviews
owned concerns; PO accepts scope/closure. No participant approves beyond its
authority or self-approves remediation.

Review is append-only: proposed, evidenceComplete, independentlyReviewed,
compliant, noncompliant, held, exceptionBound, superseded and retained. Each
transition records actor/authority, inputs, findings, reason and digest.

## Deterministic Compliance Evaluation

Canonical evaluation orders authority level, Constitution section/rule ID,
domain ID, boundary/contract ID, claim ID and evidence ID. Same canonical
candidate, authority set, applicability, evidence and rules yield the same
ordered findings, coverage set, blocking set, determination and digest.

Determinations are `compliant`, `noncompliant`, `incomplete` or
`exceptionBound`. There is no majority vote, score, fallback, timeout approval
or lower-authority override. Duplicate semantic mappings with conflicting
content invalidate the evaluation.

## Exceptions And Amendments

An exception follows Section 20.4: explicit, narrow, named owner, time-bounded,
rationale-bound, removal-planned and prevented from becoming precedent. It binds
the exact candidate/claim/rule/evidence and cannot waive an immutable boundary,
ownership or dependency rule beyond constitutional authority. Expiry returns the
claim to noncompliant/held; renewal is a new independently reviewed identity.

An amendment requires Section 20.3 problem, affected rules/domains, alternatives,
compatibility/migration, data/provenance, security/privacy, test/enforcement,
explicit approval and version increment. Planning or repeated behavior cannot
substitute for that process.

## Rollback And Supersession

Rollback restores a verified prior compliance candidate under its still-current
authority and retains the rejected evaluation. Forward repair creates a new
claim/evidence revision. Supersession links immutable evaluations and reruns all
affected mappings. Authority version change cannot silently reuse an old result.

## Fail-Closed Governance

Return noncompliant/incomplete/held on missing or conflicting authority,
Proposed-as-ratified ADR, mixed/stale identity, uncited or omitted claim, broken
domain boundary, explicit prohibition, incompatible contract, missing negative
evidence, self-review, nondeterministic evaluation, invalid/expired exception,
unapproved amendment, unsafe rollback or any blocking finding.

## Product Owner Acceptance Gates

Future implementation requires exact scope, accepted predecessors, complete
claim-rule map, current authority/owners, positive and negative evidence,
independent review, valid exceptions/amendments, rollback/supersession,
protected freezes, Architecture Fitness 0 new, clean diff and explicit PO
acceptance before closure. This plan grants no implementation authority.

## Definition Of Done

- Six-level authority hierarchy and immutable compliance identity are explicit.
- Ten coverage areas and eight evidence classes are defined.
- Independent review and deterministic four-state evaluation are explicit.
- Exceptions/amendments, rollback, supersession and fail-closed gates are
  explicit.
- Exactly this milestone and `MEMORY.md` change; no prohibited change.

## Engineering Evidence

- Planning defines six authority levels, ten coverage areas, eight evidence
  classes, nine review states and four determinations.
- Full app regression: 953/953 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M18 freeze regression: 60/60 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly this milestone and
  `MEMORY.md`.
