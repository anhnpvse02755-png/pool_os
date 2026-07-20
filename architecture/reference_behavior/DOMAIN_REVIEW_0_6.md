# Domain Review 0.6

**Status:** Accepted - Revision 2  
**Reference Behavior Proposal:** `REFERENCE_BEHAVIOR_PROPOSAL_0_6.md`  
**Proposed Golden Fixtures:** `sprint_0_6_golden.json`  
**Canonical Golden Dataset:** `canonical_golden_0_6.json`

This document records domain decisions. Passing tests prove implementation
conformance; they do not authorize any decision below.

## Reviewer

**Name:** Nguyễn Phú Việt Anh  
**Domain role:** Product Owner  
**Review date:** 2026-07-20  
**Clarification date:** 2026-07-20  
**Revision under re-review:** Revision 2

## Revision 2 Scope Clarification

Engineering evidence is complete for the deterministic, category-based learning
pipeline implemented in Revision 2. This evidence is scoped to the categories,
policies, Knowledge kinds, and batch-level Evidence contracts currently defined.
It does not imply support for arbitrary categories or other mastery models.

### Verified within the current scope

- Knowledge-driven mastery policy: thresholds are resolved through the policy
  registry rather than branches on Technique IDs.
- Category-based deterministic evaluation for versioned categories already
  defined by the Knowledge contract.
- Two Techniques use the same compiler, Evidence, Mastery, Decision, and
  Experience pipeline.
- Mistake lifecycle is independent from Technique mastery.
- Decision selection contains no Knowledge-ID special case.
- Compiler validation checks consistency between Knowledge entries, mastery
  policies, generated pack, and runtime contracts.

### Explicitly not proven

- Dynamic mastery categories discovered from arbitrary strings.
- Probabilistic mastery or posterior estimation for Elite skills.
- Attempt-level Evidence, cross-batch rolling windows, fatigue analysis, or
  shot-level confidence estimation.
- Expression-based prerequisites such as `Stop AND Follow AND Draw`.

The current category model is a versioned closed set:

```text
Knowledge -> MasteryCategory enum -> Policy Registry -> Policy
```

Unknown categories fail validation. They do not warn, fall back, or silently map
to another category.

## Foundation Business Exception

Foundation skills target approximately `95%` mastery. For the current
Measurement Protocol B002, which uses a 25-attempt batch, the Product Owner
approved `23/25` (`92%`) as the practical mastery threshold. `24/25` (`96%`)
was judged unnecessarily strict. This is an intentional, documented, and
reviewable business exception and shall not be interpreted as a mathematical
conversion of `95%`.

## Golden Case Decisions

Every case requires exactly one status and a rationale. A blank rationale is not
a valid review decision.

### 1. stop-shot-below-threshold

**Proposed behavior:** Stop Shot at `19/25` remains the selected recommendation.  
**Status:** [x] Accepted  [ ] Rejected  [ ] Needs Changes  
**Rationale:** `19/25` remains below the reviewed Foundation threshold of `23/25`.

### 2. stop-shot-unlocks-follow

**Proposed behavior:** Stop Shot at `20/25` unlocks and selects Follow Shot.  
**Status:** [ ] Accepted  [ ] Rejected  [x] Needs Changes  
**Rationale:** Stop Shot is a Foundation skill and must reach `23/25` before Follow Shot unlocks.

### 3. follow-shot-below-threshold

**Proposed behavior:** Follow Shot at `17/25` remains selected.  
**Status:** [x] Accepted  [ ] Rejected  [ ] Needs Changes  
**Rationale:** `17/25` remains below the reviewed Foundation threshold of `23/25`.

### 4. follow-shot-achieved

**Proposed behavior:** Follow Shot at `18/25` selects the Position Control placeholder.  
**Status:** [ ] Accepted  [ ] Rejected  [x] Needs Changes  
**Rationale:** Follow Shot requires `23/25`, and Position Control must remain locked while a Foundation correction is active.

### 5. mistake-persists

**Proposed behavior:** A detected Poor Speed Control observation keeps its
correction active.  
**Status:** [x] Accepted  [ ] Rejected  [ ] Needs Changes  
**Rationale:** A detected mistake must keep its correction active until the configured resolution policy is satisfied.

### 6. mistake-resolves

**Proposed behavior:** One resolved observation closes the Poor Speed Control
correction.  
**Status:** [ ] Accepted  [ ] Rejected  [x] Needs Changes  
**Rationale:** One clean observation may be accidental; Foundation mistakes require three consecutive clean observations.

## Required Policy Decisions

These questions must be answered before the proposal can become Accepted.

### Mastery aggregation

**Decision:** Completed Measurement Window  
**Window definition:** The latest completed measurement containing 25 attempts.  
**Rationale:** The current batch-level Evidence cannot construct a true rolling
window across individual attempts. “Rolling Window” is reserved for a future
attempt-level Evidence capability. Best-run aggregation is rejected because it
hides current instability.

### Mistake resolution

**Required clean observations:** 3 consecutive clean observations.  
**Required time/window:** No additional time requirement in Revision 2.  
**Rationale:** One clean observation is insufficient to conclude that the
player has corrected the mistake. Three consecutive clean observations provide
a reasonable balance between stability and learning speed. Future non-Foundation
policies may define a different requirement through Knowledge.

### Observation confidence

**Decision:** Human review defaults to confidence `1.0`.  
**Human review:** `1.0`.  
**Vision:** Confidence reported by the model.  
**Other producers:** Defined by the versioned producer contract.  
**Rationale:** Human review is authoritative. Model-generated observations must
retain their reported confidence.

### Unlock and recommendation timing

**Position Control unlock condition:** Follow Shot reaches `23/25` and no Foundation correction is active.  
**When recommendations may change:** Only after a completed measurement or
completed observation batch.  
**When corrections must close:** After the configured consecutive-clean requirement is met.  
**Rationale:** Unlock decisions never occur during an unfinished drill. This
prevents unstable recommendations and propagation of unresolved core execution
errors.

## Initial Review Outcome

Select only after all six cases and required policy decisions are complete.

**Outcome:** [ ] Accepted  [ ] Rejected  [x] Needs Changes  
**Effective behavior version, if Accepted:**  
**Reviewer signature/name:** Nguyễn Phú Việt Anh  
**Decision date:** 2026-07-20  
**Reason:** Revision 2 successfully implements the requested engineering
changes. Business review remains open until all revised policy behaviors are
accepted. Reference Behavior therefore remains Proposed.

Acceptance is valid only when every required field is complete. Implementation
must not populate or infer this section automatically.

Revision 2 implements the requested changes and has complete engineering
evidence, but this outcome remains `Needs Changes` until Product Owner re-review
accepts, rejects, or requests further changes to the revised golden behavior.

## Revision 2 Re-review Decision

**Reviewer:** Nguyễn Phú Việt Anh  
**Domain role:** Product Owner  
**Review date:** 2026-07-20

### 1. Stop Shot 22/25 continues Stop Shot

**Status:** Accepted  
**Rationale:** `22/25` is below the Product Owner-approved Foundation threshold
of `23/25`. The learner continues Stop Shot before the next skill is unlocked.

### 2. Stop Shot 23/25 unlocks Follow Shot

**Status:** Accepted  
**Rationale:** `23/25` is the approved Foundation business exception for
Measurement Protocol B002. Reaching it unlocks Follow Shot in the learning path.

### 3. Follow Shot 22/25 continues Follow Shot

**Status:** Accepted  
**Rationale:** Follow Shot is a Foundation skill governed by the same `23/25`
threshold. The learner continues Follow Shot before Position Control.

### 4. Follow Shot 23/25 with no Foundation correction unlocks Position Control

**Status:** Accepted  
**Rationale:** Follow Shot mastery and the absence of an active Foundation
correction prevent the learner from bypassing a foundational mistake.

### 5. Poor Speed Control detected keeps the correction active

**Status:** Accepted  
**Rationale:** A detected observation keeps the correction active until the
Mistake Resolution policy is satisfied.

### 6. Poor Speed Control with three consecutive clean observations resolves

**Status:** Accepted  
**Rationale:** Three consecutive clean observations balance protection against
premature resolution with reasonable learning progress and deterministic replay.

### Accepted Policy Decisions

- **Foundation exception `23/25`:** Foundation targets approximately `95%`, but
  `23/25` is the approved practical threshold for the current 25-attempt B002
  protocol. It is an intentional business exception, not a mathematical
  conversion of `95%`.
- **Completed Measurement Window:** Mastery uses the latest completed
  25-attempt measurement. A true rolling window remains deferred until
  attempt-level Evidence exists.
- **Human review confidence `1.0`:** Accepted for the current review workflow
  only; it does not establish a universal rule for future human producers.
- **Recommendation timing:** Recommendations may change only after a completed
  measurement or completed observation batch. No intermediate recommendation
  change may be emitted while a batch is in progress.

### Final Outcome

**Outcome:** Accepted  
**Effective Reference Behavior:** `0.6.0 Revision 2`  
**Rationale:** Revision 2 implements the requested business decisions and has
complete engineering evidence within the reviewed scope.  
**Reviewer acknowledgement:** Nguyễn Phú Việt Anh - Product Owner  
**Decision date:** 2026-07-20

This acceptance is a Domain decision. It does not broaden the proven scope or
claim support for capabilities listed as not implemented below.

## Capability Matrix

| Capability | Status |
| --- | --- |
| Compiler v0.6.1 | Verified |
| Knowledge polymorphism | Verified |
| Category-based deterministic mastery | Verified |
| Dynamic mastery categories | Not Defined |
| Probabilistic mastery | Not Implemented |
| Observation Contract v1 | Verified |
| Batch-level Evidence Runtime | Verified |
| Attempt-level Evidence Runtime | Not Implemented |
| Mistake Lifecycle | Verified |
| Multi-technique prerequisite expressions | Not Implemented |
| Reference Behavior 0.6.0 Revision 2 | Accepted |

## Candidate Phase B Capabilities

These are separate future capabilities. They are not implied by Revision 2 and
must each receive their own contract, tests, and governance decision if pursued:

1. Evidence V2 - Attempt-level.
2. Knowledge Dependency / Unlock Expression Contract.
3. Probabilistic Mastery Contract.
4. Dynamic Category Registry, only if a concrete need is demonstrated.

## Reviewer Acknowledgement

**Reviewer:** Nguyễn Phú Việt Anh  
**Role:** Product Owner  
**Date:** 2026-07-20
