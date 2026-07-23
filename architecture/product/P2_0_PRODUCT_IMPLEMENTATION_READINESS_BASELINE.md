# P2.0 Product Implementation Readiness Baseline Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Establish the final Product planning baseline and readiness gate for future
runtime implementation without authorizing or creating implementation. P2.0 is
rooted in accepted P1.0-P1.8 and the immutable M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Baseline Scope

The Product planning baseline consists of:

- P1.0 implementation program governance and P1-P8 roadmap;
- P1.1 runtime module architecture;
- P1.2 domain capability ownership/dependency map;
- P1.3 logical data, aggregate and state ownership;
- P1.4 public application service/use-case boundaries;
- P1.5 domain workflow/transition planning;
- P1.6 Experience flow/navigation planning;
- P1.7 user interaction/command model;
- P1.8 error, recovery and resilience model;
- Proposed ADR-022 through ADR-030 and their evidence plans.

P2.0 records completion/readiness of planning only. Proposed ADR status and
accepted planning do not independently grant runtime implementation authority.

## Meaning Of Implementation-Ready

A Product slice is implementation-ready only when all of the following are
explicit and mutually compatible:

1. Product capability/use-case identity and accountable owners.
2. Accepted upstream Platform contract IDs/versions/digests and provenance.
3. Public Product contract identities, immutable inputs/outputs and failures.
4. Aggregate/state writer, lifecycle, transition and idempotency rules.
5. Application/Experience boundaries and dependency direction.
6. Security/privacy/accessibility/evidence obligations.
7. Exact authorized source/test/document files and prohibited files.
8. Focused/full/protected verification, rollback and acceptance criteria.
9. Migration/compatibility handling for every changed contract/state.
10. Product Owner authorization for that exact implementation milestone.

P1 planning is sufficiently complete to decompose such slices. No slice is
authorized merely by appearing in this baseline or roadmap.

## What Remains Planning-Only

All logical modules, capabilities, entity names, lifecycle states, service/use-
case names, route IDs, interaction/error categories, contracts marked planned and
evidence paths marked planned remain planning vocabulary until separately
authorized and implemented. No package/class/schema/API/route/widget/provider or
runtime mechanism is implied.

P2.0 does not resolve provider technology, persistence, process/deployment
topology, state-management framework, network protocol, UI layout, retry
mechanism, telemetry or operational configuration.

## Planning-To-Implementation Traceability

| Planning authority | Implementation responsibility | Accountable implementation owner | Required proof class |
|---|---|---|---|
| P1.1 Runtime Architecture | module shell/public-port placement and dependency direction | Product Architecture + module owner | import/dependency/acyclic architecture tests |
| P1.2 Capabilities | one bounded capability slice and owner contract | capability owner | ownership, public contract and dependency tests |
| P1.3 Data/State | identity, aggregate, single writer and projection contract | aggregate/data owner | identity/version/mutation/projection rebuild tests |
| P1.4 Application Services | command/query envelopes and deterministic orchestration | Application owner | use-case, idempotency, ordering and failure tests |
| P1.5 Workflows | valid transition/replay semantics | aggregate capability owner | transition matrix, terminal, concurrency and replay tests |
| P1.6 Experience | logical route/view state over public queries/commands | Experience owner | navigation/access/deep-link/recovery tests |
| P1.7 Interaction | intent/confirmation/cancellation/accessibility/audit | Experience + Application owners | lifecycle, duplicate activation and accessibility tests |
| P1.8 Error/Recovery | source-preserving errors/recovery/degradation | Application + source capability owners | taxonomy, outcome, partial and degradation tests |

Every implementation artifact and test must cite its Product milestone, planning
authority and Platform root. A row maps responsibility; it does not authorize code.

## Ownership Transition To Engineering

Planning authority produces an implementation work packet. Product Owner approves
scope/priority. Product Architecture validates dependency and contract placement.
Platform/domain owners approve use/interpretation of their contracts. Engineering
owns code and focused tests within exact scope. Quality independently verifies
contracts, regression and protected artifacts. Security/Privacy/Accessibility/
Operations owners verify their respective obligations. Product Owner accepts
Product outcome; Repository Authority closes only after acceptance.

Ownership does not transfer semantic truth: capability/domain owners retain
contract/invariant authority throughout implementation. Engineering cannot self-
approve evidence, broaden scope or promote a Proposed ADR.

## Required Implementation Sequencing

1. **Implementation work-packet governance:** exact first slice, contracts, files,
   owners, evidence and rollback are authorized.
2. **Product contract/primitives:** only domain-neutral identities, versions,
   canonical envelopes and public ports required by that slice.
3. **Single capability core:** aggregate/state/transition behavior behind its own
   public contract, with no external adapter.
4. **Application slice:** one command/query use case with deterministic failures
   and idempotency against the capability port.
5. **Read model/Experience slice:** projection and logical interaction/navigation
   only after command/query contracts are stable.
6. **Platform integration adapter:** separately authorized adapter consuming
   accepted public Platform contract; no Platform internal import.
7. **External/persistence adapter:** separately authorized after port contracts,
   security/privacy and migration evidence are accepted.
8. **Cross-capability workflow:** only after each owner slice is independently
   accepted; orchestrate committed references without distributed ownership.
9. **Operational/release readiness:** resilience, observability, deployment and
   recovery mechanisms require later exact implementation authority.

Within each level, only dependency-disjoint slices may proceed in parallel.
Downstream code cannot be used to define an unsettled upstream contract.

## Initial Slice Selection Criteria

The first runtime slice should have one Product-owned aggregate, one command,
one query/projection, no required external provider/persistence choice, limited
Platform dependencies, deterministic behavior and complete focused proof. Slice
selection is a future Product Owner decision; P2.0 does not choose or implement it.

## Implementation Governance

Each implementation milestone must state objective, exact files, owning module/
capability/aggregate, affected public contracts, Platform dependencies,
prohibitions, deterministic behavior, security/privacy/accessibility impact,
migration, rollback, evidence plan and Definition of Done before editing.

Implementation uses public ports, preserves semantic IDs/versions/provenance,
keeps Platform frozen, maintains modular-monolith boundaries and fails closed on
missing ownership, mixed versions, unsupported dependency or evidence gaps.

No accepted planning artifact is edited by an implementation slice. Corrections
require a separately authorized planning successor or ADR governance process.

## Change Control

Every change request binds Product milestone and planning authority, exact diff,
contract impact, compatibility classification, affected owners/consumers,
migration/rollback, evidence and PO decision. Scope change suspends implementation
until reauthorized. Breaking Platform changes use Platform successor governance,
not Product workarounds.

Defects are repaired at the accountable source. Temporary exceptions require
explicit authority, bounded scope/time, risk/evidence and removal condition; no
exception may bypass Constitution, freezes or ownership.

## Traceability Requirements

Implementation evidence must form the chain:

```text
M22 terminal digest
  -> P1 planning artifact/section
  -> Proposed/accepted Product ADR decision
  -> implementation milestone authorization
  -> public contract/version and source files
  -> focused tests/analyzer/architecture rules
  -> regression/protected-artifact evidence
  -> independent verification
  -> Product acceptance
  -> commit/push/repository closure
```

Trace links use immutable IDs/digests/commits where available. Branch, code
existence, green CI or deployment cannot substitute for a missing authority link.

## Evidence Requirements

Every implementation milestone requires, proportional to scope:

- focused contract/unit/integration tests for success, rejection, determinism,
  replay/idempotency, ownership and immutability;
- focused static analysis for changed runtime code;
- full app and affected package regression;
- protected M3-M22 Foundation Freeze chain;
- Architecture Fitness with zero new violation;
- exact authorized-file and `git diff --check` audit;
- unchanged Golden Fixtures, M2 proofs, production, Knowledge/publication and
  generated protected artifacts unless explicitly authorized;
- compatibility/migration/rollback evidence for state/contract changes;
- security/privacy/accessibility verification where relevant;
- independent Quality assessment and PO acceptance before commit/push closure.

Evidence records name tool/version, inputs, result, limitations, owner, timestamp
and relevant digest. Self-generated content cannot self-review or self-publish.

## Readiness Gates By Planning Area

| Area | Planning readiness | Required implementation gate |
|---|---|---|
| Runtime architecture | boundaries/edges defined | exact module/port files and architecture tests |
| Capabilities | owners/dependencies defined | one capability contract and focused ownership proof |
| Data model | logical aggregates/writers defined | versioned runtime types/state contract and migration plan |
| Application services | use cases/order defined | one public service contract and idempotency/failure proof |
| Workflows | transitions/invariants defined | executable transition/replay tests |
| Experience | journeys/routes/states defined | authorized UI contract and accessibility/navigation proof |
| Interaction | intent/confirmation/audit defined | input-modality and duplicate/cancel tests |
| Error/recovery | taxonomy/recovery defined | error contract and failure/reconciliation tests |

Planning is complete for decomposition; every implementation gate remains closed
until its exact successor milestone is authorized.

## Fail-Closed Readiness Decision

Not ready if any owner, contract/version, dependency edge, state writer,
transition, failure, migration, rollback, exact file, evidence or authorization
is missing/ambiguous; if implementation requires Platform internal access; or if
the requested slice changes accepted planning without successor authority.

Ready means eligible for PO authorization, not permission to start code.

## Definition Of Done

- P1.0-P1.8 planning completion baseline is explicit.
- Readiness versus planning-only status is unambiguous.
- Planning-to-implementation responsibility/traceability is defined.
- Ownership transition, sequencing, governance and change control are documented.
- Evidence and fail-closed readiness requirements are complete.
- ADR-031 remains Proposed; no runtime implementation exists.
- Exactly the four authorized P2.0 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P2.0 files change and `git diff --check` is clean.
- Platform, freeze, production, Knowledge/publication, Golden Fixture and M2
  proof artifacts remain unchanged.
