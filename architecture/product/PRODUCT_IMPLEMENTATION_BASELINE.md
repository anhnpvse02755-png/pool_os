# Product Implementation Baseline

**Status:** Accepted Planning Baseline; Closed
**Version:** Planning baseline v1
**Date:** 2026-07-23

## Baseline Identity

Platform root: M22 digest
`2086946d208e96093ae6699e36ab82bf174e9ec9630727abbce4691ec8c902fb`.

Product planning chain: P1.0 through P1.8, with Proposed ADR-022 through ADR-030.
This document is a readiness map, not an implementation authorization.

## Planning Completion Matrix

| Product planning milestone | Accepted planning output | Implementation question answered |
|---|---|---|
| P1.0 | governance and roadmap | who authorizes and how Product remains subordinate to Platform |
| P1.1 | runtime architecture | where code may live and which dependencies are allowed |
| P1.2 | capabilities | who owns each business responsibility and dependency |
| P1.3 | data/state | who owns identity, aggregate mutation and projections |
| P1.4 | application services | how public commands/queries are orchestrated |
| P1.5 | workflows | which logical state transitions are valid |
| P1.6 | Experience flows | how journeys/navigation consume public boundaries |
| P1.7 | interaction model | how intent/confirmation/cancellation reaches commands |
| P1.8 | errors/recovery | how failure, partial state and degradation remain safe |

## Work Packet Template

Every future implementation authorization must contain:

```yaml
milestoneId: product implementation milestone identity
objective: one bounded executable outcome
planningAuthorities: P1 artifact sections and Product ADRs
platformRoot: exact M22 digest
owners: product architecture, capability, aggregate, application, quality
authorizedFiles: exact source, test and evidence files
contracts: semantic IDs, versions, compatibility and provenance
dependencies: accepted public ports only
stateImpact: identity, writer, transitions, migration and rollback
prohibitions: explicit excluded behavior/files
evidence: focused, regression, freeze, architecture and independent gates
definitionOfDone: measurable completion and PO acceptance
```

An incomplete work packet fails readiness and grants no editing authority.

## Implementation Order

```text
authorized work packet
 -> minimal public contract/primitives
 -> one capability aggregate/behavior
 -> one Application command/query slice
 -> projection and Experience interaction
 -> Platform public-contract adapter
 -> external/persistence adapter (separate authority)
 -> cross-capability orchestration after owner slices close
 -> operational/release mechanisms (separate authority)
```

## Evidence Gate

Focused deterministic/negative/ownership tests and analysis precede full app/
package regression, protected freezes, Architecture Fitness, protected diff and
independent review. PO acceptance precedes repository closure. Evidence must bind
exact code/contracts/versions/digests and cannot be self-approved.

## Change Gate

Implementation cannot edit accepted planning, Platform artifacts, freezes,
Constitution or prior ADRs. Any needed correction pauses the slice and requires a
separately authorized successor/change process. Consumers cannot create local
compatibility by reinterpreting upstream contracts.

## Current Disposition

The Product planning baseline is complete enough to propose bounded runtime
implementation work packets. Runtime implementation remains prohibited until the
Product Owner grants exact milestone authority.
