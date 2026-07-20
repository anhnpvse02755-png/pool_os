# Reference Behavior Proposal 0.6

**Status:** Accepted  
**Date:** 2026-07-20  
**Knowledge Release:** 0.2.1  
**Compiler:** 0.6.1  
**Revision:** 2  
**Effective Reference Behavior:** 0.6.0 Revision 2  
**Accepted by:** Nguyễn Phú Việt Anh, Product Owner  
**Decision date:** 2026-07-20

## Scope

This document records the behavior observed and tested for the Sprint 0.6
executable slice and its subsequent Domain acceptance. The accepted behavior is
limited to the explicit scope below.

The proposed behavior covers:

- independent Stop Shot and Follow Shot mastery thresholds;
- recommendation changes after each Outcome is achieved;
- a Poor Speed Control lifecycle driven by detected/resolved observations;
- typed Decision reasons and policy provenance;
- replay from versioned, append-only Evidence.

The proposal examples remain in `sprint_0_6_golden.json` as review history. The
accepted examples are published in `canonical_golden_0_6.json` with an external
SHA-256 digest in `canonical_golden_0_6.sha256`.

## Review Decision

`DOMAIN_REVIEW_0_6.md` records the initial `Needs Changes` decision and the
subsequent Revision 2 re-review. The Product Owner accepted all six cases and
all required policy decisions on 2026-07-20.

## Governance Record

Implementation and passing tests did not accept this behavior. Acceptance was
recorded only after a named Domain reviewer supplied the decision, rationale,
role, acknowledgement, and decision date. This document records Domain
acceptance; it does not amend or ratify the Architecture Constitution.
