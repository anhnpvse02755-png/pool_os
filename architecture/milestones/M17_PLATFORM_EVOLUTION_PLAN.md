# M17-M22 Platform Evolution Plan

**Status:** Accepted Planning Baseline; Closed  
**Date:** 2026-07-22

## Program Contract

M17-M22 complete the Platform phase on top of the accepted M16 Foundation
Freeze. They may govern and verify evolution of frozen architecture, but no
planning artifact directly authorizes implementation. Product capability
planning begins only after M22 is Accepted, Closed and repository-pushed.

## Dependency Graph

| From | To | Required evidence |
|---|---|---|
| M16 Freeze | M17 | Exact freeze identity and protected proof |
| M17 | M18 | Accepted evolution and compatibility rules |
| M17 | M19 | Accepted contract migration rules |
| M18 | M19 | Accepted extension ownership boundaries |
| M17 | M20 | Contract conformance criteria |
| M18 | M20 | Extension isolation criteria |
| M19 | M20 | Migration/portability criteria |
| M20 | M21 | Candidate-bound conformance evidence |
| M21 | M22 | Closed gaps, exceptions and evidence index |

The six-node internal graph is acyclic. Parallel execution is prohibited unless
the graph proves independence and the Product Owner separately authorizes each
scope.

## M17 Contract Evolution

Purpose: define how frozen contracts may gain compatible extensions without
losing identity, provenance, digest determinism or ownership.

- Owner: Architecture with every affected contract/domain owner.
- Gate: Constitution v1.4.0 and exact M16 freeze compatibility.
- Evidence: compatibility matrices, negative cases and amendment triggers.
- Rollback: retain the frozen version and reject the proposed evolution.

## M18 Extension Boundaries

Purpose: govern replaceable extensions and plugins through public ports while
keeping business semantics in their owning domains.

- Owner: Architecture and Platform; contract owners approve capabilities.
- Gate: accepted M17 evolution policy and dependency isolation.
- Evidence: declared capabilities/import graph, failure and revocation cases.
- Rollback: disable or remove an extension without changing domain history.

## M19 Migration And Portability

Purpose: govern version migration and provider portability without treating
derived artifacts, infrastructure or deployed behavior as normative truth.

- Owner: Architecture, Data and affected domain owners.
- Gate: accepted M17-M18 identity, compatibility and extension rules.
- Evidence: upcast/export/import replay, mixed-version denial and provenance.
- Rollback: last-known-good identity or owned forward repair; never history
  rewrite.

## M20 Conformance And Certification

Purpose: define executable certification of a platform candidate against its
public contracts and constitutional boundaries.

- Owner: Architecture and Quality with independent review.
- Gate: accepted M17-M19 criteria and exact candidate identity.
- Evidence: positive/negative conformance, replay, dependency and provenance
  proofs.
- Rollback: reject certification; certification never repairs a candidate.

## M21 Stabilization And Amendment Closure

Purpose: close gaps and exceptions before final freeze, with no silent
reinterpretation of contracts or operational behavior.

- Owner: Architecture, Security, Operations and affected domain owners.
- Gate: accepted M20 certification evidence.
- Evidence: gap register, exception expiry, amendment status and final evidence
  index.
- Rollback: return the candidate to its last accepted milestone and preserve
  findings.

## M22 Final Platform Freeze

Purpose: validate and freeze the complete platform architecture before Product
work begins.

- Owner: Product Owner and independent Final Architecture Auditor.
- Gate: accepted M21 closure package and transitive M3-M20 proofs.
- Evidence: deterministic manifest, hashes, public symbols, versions, import
  graph, replay, compatibility and protected regression.
- Rollback: reject the freeze; an accepted freeze is superseded only through
  governed amendment and a new proof identity.

## Cross-Milestone Invariants

- Constitution v1.4.0, accepted ADRs and M3-M16 freezes remain protected.
- Semantic IDs, versions, provenance, compatibility and deterministic replay
  remain explicit.
- Knowledge authoring remains source of truth; generated artifacts are not
  edited by hand.
- Evidence facts remain separate from Intelligence inference and decisions.
- Public ports/contracts are mandatory; private persistence and implementation
  imports are prohibited.
- AI output cannot self-review, self-verify or self-publish.
- Provider neutrality and the modular-monolith default remain intact.
- No Product capability, UI flow or business behavior begins before M22 closes.

## Program Completion Gate

The Platform phase closes only when M17-M22 are separately planned,
authorized, implemented where applicable, verified, Product Owner accepted and
repository-closed; M22 supplies the final machine-verifiable freeze. This plan
does not authorize any implementation or Product phase work.
