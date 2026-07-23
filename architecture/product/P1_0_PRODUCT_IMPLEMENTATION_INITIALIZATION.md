# P1.0 Product Implementation Program Initialization

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Establish governance for the Product Implementation Program without implementing
Product functionality or runtime behavior. The immutable root is the accepted
M22 Foundation Freeze digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

## Platform And Product Boundary

Platform M1-M22, Foundation Freezes M3-M22, Constitution v1.4.0 and accepted
Platform ADRs are protected upstream authority. Product depends on public
Platform contracts and may not modify, reinterpret, supersede or bypass Platform
ownership, evidence, freezes or constitutional rules.

Platform owns domain semantics, contracts and governance baselines. Product owns
authorized composition, delivery behavior and user-facing implementation only
after separate milestone authorization. Product is a consumer, never a new
source of Platform truth.

## Product Implementation Lifecycle

The governed lifecycle is `proposed`, `scoped`, `authorized`, `implementing`,
`engineeringComplete`, `independentlyVerified`, `productAccepted`,
`repositoryClosed`, `superseded` or `rolledBack`. Every state transition is
append-only, actor-bound and evidence-linked. No stage may be inferred from code,
test, branch or deployment state.

Each Product milestone requires exact files, scope, prohibitions, Definition of
Done, owners, dependencies, evidence and PO authorization before editing.

## Implementation Ownership Model

| Responsibility | Accountable authority |
|---|---|
| Product program and priorities | Product Owner |
| Product architecture/composition | Product Architecture |
| Platform semantics/contracts | Existing Platform/domain owners |
| Runtime implementation | Authorized implementation owner |
| UX behavior/accessibility | Experience/Product UX owner |
| Evidence/provenance/custody | Existing source owners |
| Security/privacy/operations | Respective Platform authorities |
| Independent verification | Quality |
| Repository closure | Repository Authority after PO acceptance |

Product implementers cannot approve their own evidence or redefine upstream
contracts. Platform and Product ownership remain distinct.

## Runtime Implementation Boundaries

Future authorized Product runtime may compose public ports, adapters and
experiences. It may not import domain persistence/internals, duplicate Knowledge
or Learning ownership, make Evidence facts into Intelligence decisions, place
policy in Experience, place strategy in Simulation, bypass AISession boundaries,
or let generated content self-review/self-publish.

Runtime, API, schema, Flutter, infrastructure, deployment and operational changes
require explicit later milestone scope. P1.0 authorizes none of them.

## Platform To Product Dependency

Dependency direction is `Platform public contracts -> Product composition`.
Product-to-Platform feedback is a governed change request, not a reverse import
or silent contract edit. A requested Platform change requires its own authority,
compatibility analysis, evidence, successor baseline and constitutional process.

## Evidence Inheritance

Product evidence references immutable Platform evidence IDs/digests, M22 root,
contract/rule versions, source/custodian, validity, limitations and correction
lineage. Product cannot copy evidence into a new source of truth or inherit
acceptance across changed scope/version. Product-specific evidence is separately
owned, append-only, independently verified and provenance-bound.

## Change Control

Every change binds milestone ID, exact files, purpose, dependency/contract
impact, risk, evidence plan, owners, approval, rollback and successor lineage.
Unscoped files, protected changes, mixed baselines, unsupported compatibility,
missing evidence/owner, self-review or scope drift fail closed.

Breaking Platform contract or constitutional changes are outside normal Product
change control. Product ADRs may extend Product decisions but cannot supersede
Platform ADRs or grant themselves broader authority.

## Product Milestone Roadmap

| Program | Purpose | Depends on |
|---|---|---|
| P1 Core Runtime Foundation | Authorized composition/runtime shell and lifecycle | P1.0 |
| P2 Domain Runtime | Implement domain runtime through public contracts | P1 |
| P3 Cross-domain Runtime | Compose governed cross-domain flows | P1, P2 |
| P4 User Experience | Build accessible user-facing experiences | P1, P3 |
| P5 Intelligence | Integrate deterministic Intelligence and Coach flows | P2, P3 |
| P6 Knowledge Integration | Integrate published Knowledge through public ports | P2, P3, P5 |
| P7 Simulation | Integrate pure physics capabilities without strategy leakage | P3, P4, P6 |
| P8 Release Readiness | Validate Product evidence, operations and release gates | P4, P5, P6, P7 |

These are roadmap definitions only. Each program must be decomposed and
separately authorized; no feature or implementation begins here.

## Rollback Supersession And Fail-Closed Governance

Rollback selects a verified compatible Product predecessor without editing
history or Platform baselines. Repair occurs at the accountable source.
Supersession links Product decisions, code, evidence and acceptance digests.
Reject protected changes, reverse dependencies, internal imports, semantic
redefinition, evidence laundering, self-review or missing PO authority.

## Definition Of Done

- Product governance is rooted at the exact M22 terminal digest.
- Lifecycle, ownership, runtime boundaries and dependency direction are explicit.
- Evidence inheritance and change control are defined.
- P1-P8 roadmap exists without runtime or Product implementation.
- ADR-022 remains Proposed and Platform artifacts remain unchanged.
- Exactly the four authorized P1.0 files change.

## Engineering Evidence

- Full app regression passes 969/969.
- Knowledge package regression passes 75/75.
- Protected M3-M22 Foundation Freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Generated architecture health was restored to its protected baseline.
- Exactly the four authorized P1.0 files change and `git diff --check` is clean.
- Platform M1-M22, freezes M3-M22, production artifacts, Knowledge/publication
  artifacts, Golden Fixtures and M2 proofs remain unchanged.
