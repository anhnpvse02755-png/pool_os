# Reference Behavior Proposal 0.6

**Status:** Proposed - Pending Domain Review  
**Date:** 2026-07-20  
**Knowledge Release:** 0.2.1  
**Compiler:** 0.6.1  
**Revision:** 2 - Needs Changes implemented, pending re-review

## Scope

This proposal records the behavior observed and tested for the Sprint 0.6
executable slice. It is not an Accepted or Ratified reference behavior.

The proposed behavior covers:

- independent Stop Shot and Follow Shot mastery thresholds;
- recommendation changes after each Outcome is achieved;
- a Poor Speed Control lifecycle driven by detected/resolved observations;
- typed Decision reasons and policy provenance;
- replay from versioned, append-only Evidence.

The normative examples are encoded in `sprint_0_6_golden.json`. Test success is
implementation evidence only. Domain reviewers decide whether each expected
output is correct for billiards coaching.

## Review Decision

Record the per-case decisions, rationales, policy choices, reviewer identity, and
final outcome in `DOMAIN_REVIEW_0_6.md`. Select exactly one final outcome during
Domain Review:

- [ ] Accepted
- [ ] Rejected
- [ ] Needs Changes

Reviewer:  
Review date:  
Notes:

## Explicit Non-Ratification

No implementation, test, compiler output, or ADR may change this proposal to
Accepted automatically. Acceptance requires a named Domain reviewer and a
recorded review decision.
