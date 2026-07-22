# M21.0 Platform Readiness & Product Transition Planning

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define the governed M21 roadmap for proving platform readiness and preparing,
but not authorizing, transition to Product development after M22. M21.0 is
planning only and adds no runtime contract, implementation, Product feature,
UI, infrastructure, deployment, CI/CD, monitoring, tooling or freeze change.

## Authority And Readiness Root

Constitution v1.4.0, accepted M3-M20 freezes and accepted M20 convergence remain
protected. M20 Freeze digest
`f1d73a9eed35dc64fbfdfa0592850e2f46aacd0f9ae421330c43f0237a46253b`
is the direct root. ADR-020 remains Proposed. Architecture/Platform owns
readiness governance; domain/contract/operations owners retain their truth;
Quality audits; Product Owner accepts. Product remains locked through M22 Freeze.

## Readiness Model

An immutable readiness candidate binds M20 Freeze, target/scope, public
contracts and owners, completion criteria, compatibility/semantic/evidence/
operational determinations, residual gaps/exceptions, Product-transition
boundary, audit, recovery, lineage, validity and deterministic digest. Technical
completion or document maturity cannot imply readiness.

## M21 Capability Roadmap

| Capability | Planning responsibility | Depends on |
|---|---|---|
| M21.1 Readiness Identity & Scope | Candidate, claims, boundaries, owners and exclusions | M20 Freeze |
| M21.2 Platform Completion Criteria | Conjunctive architecture/contract/enforcement/operations criteria | M21.1 |
| M21.3 Contract & Freeze Readiness | Public compatibility and transitive freeze integrity | M21.1, M21.2 |
| M21.4 Operational, Security & Recovery Readiness | Failure, trust, continuity and capacity claim readiness | M21.2, M21.3 |
| M21.5 Evidence & Independent Audit Readiness | Provenance, replay, negative evidence and audit independence | M21.2, M21.3, M21.4 |
| M21.6 Product Transition Boundary Preparation | Allowed future Product inputs/commands and prohibited bypasses | M21.3, M21.4, M21.5 |
| M21.7 Residual Gap & Exception Closure | Close or explicitly block every remaining item | M21.4, M21.5, M21.6 |
| M21.8 Final M22 Entry Gate | Independent binary eligibility for M22 planning only | M21.5, M21.6, M21.7 |

The graph has eight nodes, seventeen internal edges and zero cycles.

## Platform Completion Criteria Prior To M22

Completion is conjunctive across constitutional ownership/dependencies, public
contract compatibility, Knowledge/publication integrity, Evidence provenance,
deterministic replay, Decision Trace grounding, Simulation/Experience/AI
boundaries, security/privacy, operational/recovery/capacity claims, freeze
continuity, current owners, independent audit and zero unowned gaps.

## Product Transition Preparation Boundary

Preparation may inventory future Product-facing public queries, commands,
projections, capabilities, acceptance evidence and ownership. It cannot define
features, UI, roadmap priority, Product data, runtime behavior or implementation.
Product may consume only accepted public contracts after M22 Freeze; it may not
read persistence/domain internals or own Intelligence/Learning policy.

## Ownership And Evidence

| Concern | Accountable authority |
|---|---|
| Candidate and graph | Architecture/Platform |
| Domain semantics/public ports | Domain and contract owners |
| Knowledge/Evidence provenance | Publisher/source owners |
| Compatibility/replay | Contract owners/Quality |
| Security/privacy | Security/Privacy/data owners |
| Operations/recovery/capacity | Respective operational owners |
| Product transition boundary | Architecture plus Product Owner |
| Gap/exception lifecycle | Accountable source/constitutional authority |
| Independent audit | Independent auditor |
| Final acceptance | Product Owner |

Evidence is immutable or superseding, candidate-bound and source-owned. Reports
and generated/provider output cannot self-review or replace authoritative truth.

## Rollback, Repair, Supersession And Fail-Closed Gates

Rollback selects a verified last-known-good candidate without editing history.
Repair occurs at the accountable source under separate authority. Supersession
links immutable candidates, evidence, audits and decisions. Fail closed on
mixed/stale identity, private coupling, incompatibility, semantic conflict,
invalid evidence/replay, unsafe operations/security/recovery, unowned gap,
invalid exception, broken freeze, conflicted audit or missing PO authority.

## Definition Of Done

- Eight capabilities, seventeen acyclic edges and M22 entry ordering are explicit.
- Completion, transition boundary, ownership, evidence and recovery are defined.
- Product remains locked until accepted/closed/committed/pushed M22 Freeze.
- ADR-020 remains Proposed; exactly four authorized files change.
- No implementation or protected-artifact change exists.

## Engineering Evidence

- Planned graph: 8 nodes, 17 edges, 0 cycles, rooted in M20 Freeze.
- App 961/961, Knowledge 75/75 and protected M3-M20 freezes 68/68 passed.
- Architecture Fitness: 133 existing violations, 0 new.
- Generated health restored; exact four-file scope and clean diff confirmed.
