# M20.0 Platform Convergence & Stabilization Planning

**Status:** Accepted; Closed
**Date:** 2026-07-22

## Objective

Define the governed M20 roadmap for converging the M19-validated platform and
stabilizing its public architecture before M21. M20.0 is planning only. It
introduces no runtime contract, implementation, production code, Flutter/UI
behavior, infrastructure, CI/CD, deployment, monitoring, tooling, Product
functionality or frozen-artifact change.

## Authority And Convergence Root

- Constitution v1.4.0 remains normative authority.
- Accepted ADRs and M3-M19 freezes remain protected.
- M19 Foundation Freeze digest
  `e6628bbdaaf2a06e7bf2bb2ab4e60603c401c0188e1150cccaf95f2cf304a49e`
  is the direct convergence root.
- ADR-019 is Proposed and grants no implementation authority.
- Each M20.x capability requires separate exact-file authorization, evidence,
  Product Owner acceptance, commit and push.

Architecture/Platform owns convergence governance. Domain and contract owners
retain semantic, version and compatibility authority. Quality independently
verifies evidence. Product Owner owns acceptance. No cross-domain runtime
contract is changed by this plan.

## Convergence Model

A convergence candidate binds the exact M19 Freeze, declared platform target,
public contracts and boundaries, domain owners, compatibility requirements,
accepted validation findings, gaps/exceptions, canonical evidence, audit,
rollback/repair path, predecessor/successor and deterministic digest.

Convergence removes ambiguity and reconciles accepted platform declarations; it
does not centralize domain semantics or reinterpret frozen truth. Stabilization
is claim-bound and fail-closed. Documentation maturity, passing tests or an
implementation outcome cannot imply convergence acceptance.

## M20 Capability Roadmap

| Capability | Planning responsibility | Depends on |
|---|---|---|
| M20.1 Convergence Identity & Scope | Candidate, target, claims, boundaries, owners and exclusions | M19 Freeze |
| M20.2 Public Contract & Boundary Convergence | Reconcile public ports, ownership and dependency direction | M20.1 |
| M20.3 Compatibility & Version Stabilization | Version matrices, additive/breaking change and migration constraints | M20.1, M20.2 |
| M20.4 Cross-Domain Semantic Stabilization | Preserve domain meaning across composed platform flows | M20.2, M20.3 |
| M20.5 Evidence, Provenance & Replay Stabilization | Canonical evidence, custody, trace and deterministic replay | M20.2, M20.3, M20.4 |
| M20.6 Operational & Failure-Mode Stabilization | Security, privacy, recovery, performance and operations boundaries | M20.3, M20.4, M20.5 |
| M20.7 Gap, Exception & Amendment Closure | Resolve or explicitly retain owned, expiring gaps and exceptions | M20.4, M20.5, M20.6 |
| M20.8 Final Convergence Gate | Independent audit and binary M21 entry decision | M20.5, M20.6, M20.7 |

The internal graph has eight nodes, seventeen edges and zero cycles. M19 Freeze
is the external root. This roadmap assigns planning responsibility only.

## Convergence Boundaries

- Domain semantics remain owned by their constitutional domains.
- Public contracts and ports are the only cross-domain convergence surfaces.
- Persistence, provider, compiler and runtime internals remain private.
- Evidence facts remain distinct from Intelligence inference and decisions.
- Knowledge authoring remains source of truth; publication artifacts are not
  edited or reinterpreted.
- Experience remains projection/command oriented; Simulation remains physics;
  AI remains bounded by accepted session/output/capability contracts.
- Convergence cannot create Product behavior or authorize M21 execution.

## Compatibility Preservation

Every candidate records producer/consumer versions, supported capability
intersection, semantic IDs, Knowledge/runtime identities, canonicalization,
failure behavior and rollback target. Unchanged or additive compatible
evolution is preferred. Breaking evolution requires separate authority,
explicit migration window, last-known-good identity, forward repair or
rollback and new evidence.

Mixed, stale, duplicate, unsupported or privately coupled bindings fail closed.
No provider or infrastructure mechanism may own compatibility policy.

## Cross-Domain Stabilization Governance

Each composed flow maps source owner, consumer, public contract, allowed
dependency direction, semantic invariant, compatibility class, evidence,
failure owner and recovery boundary. Cross-domain agreement cannot transfer
source-of-truth ownership. A projection, report or audit cannot replace its
authoritative domain artifact.

Stabilization decisions are immutable and append-only through supersession.
Independent review must be separated from candidate assembly and claim
ownership. A change in source, contract, rule, evidence or exception identity
invalidates dependent determinations.

## Ownership And Evidence

| Concern | Accountable authority |
|---|---|
| Candidate identity and capability graph | Architecture/Platform |
| Domain semantics and public ports | Owning domain |
| Contract versions and compatibility | Producer/consumer contract owners |
| Cross-domain flow composition | Architecture plus affected owners |
| Evidence facts, custody and provenance | Evidence/source owner |
| Replay and negative verification | Quality/source owners |
| Security and privacy boundaries | Security/Privacy owners |
| Operations, recovery and capacity claims | Operations/Recovery/Capacity owners |
| Gap, exception and amendment lifecycle | Architecture plus accountable owner |
| Independent gate and acceptance | Independent auditor/Product Owner |

Evidence is immutable or superseding, candidate-bound, attributable, minimized
and references exact source identities/digests. Positive and negative evidence
are required. Generated or provider output cannot self-review, self-verify or
self-publish.

## Rollback, Supersession And Fail-Closed Gates

Rejected candidates retain identity, findings and attempts. Rollback restores
only a verified compatible last-known-good candidate and never edits frozen,
domain, evidence or audit history. Forward repair is versioned. Supersession
links immutable predecessor/successor packages and reruns every affected gate.

Fail closed on mixed/stale identity, missing authority/owner, private coupling,
semantic ownership conflict, unsupported contract/version, incomplete or
conflicting evidence, nondeterministic replay, constitutional conflict, broken
freeze link, unsafe recovery, expired exception or failed independent audit.
No score, fallback, timeout or technical completion grants acceptance.

## Entry Criteria For M21

M21 planning is eligible only when M20.1-M20.8 and an M20 Foundation Freeze are
separately accepted, closed, committed and pushed; all declared gaps are closed
or explicitly accepted with owner/expiry; compatibility and replay are current;
the M3-M19 chain remains intact; and an independent final audit plus explicit PO
decision authorizes exact M21 planning files. Eligibility grants no runtime,
Product or implementation authority.

## Product Owner Acceptance Gates

Each future M20.x scope requires accepted predecessors, exact files and claim,
public-boundary/ownership map, compatibility and constitutional checks,
canonical replay, positive/negative evidence, rollback/supersession, protected
freeze regressions, Architecture Fitness 0 new, clean diff and explicit PO
acceptance before repository closure.

## Definition Of Done

- Eight dependency-ordered M20 capabilities and seventeen acyclic edges are
  explicit.
- Convergence boundaries, compatibility preservation and cross-domain
  stabilization governance are defined.
- Ownership, evidence, rollback, supersession, fail-closed gates and M21 entry
  criteria are explicit.
- ADR-019 remains Proposed.
- Exactly four authorized M20.0 planning artifacts change.
- No implementation authority, runtime/Product behavior or freeze change exists.

## Engineering Evidence

- Planned graph: eight M20 nodes, seventeen internal edges, zero cycles, rooted
  in accepted M19 Foundation Freeze.
- Full app regression: 957/957 passed.
- Knowledge package regression: 75/75 passed.
- Protected M3-M19 freeze regression: 64/64 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated architecture health restored to its protected baseline.
- `git diff --check` is clean and the diff contains exactly the four authorized
  M20.0 planning artifacts.
