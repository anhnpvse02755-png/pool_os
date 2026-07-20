# M1 - Executable Learning Platform Foundation

**Status:** Domain Accepted  
**Reference Behavior:** 0.6.0 Revision 2  
**Accepted by:** Nguyễn Phú Việt Anh, Product Owner  
**Decision date:** 2026-07-20

## Accepted Scope

- Compiler v0.6.1 over the four-entry Sprint 0.6 corpus.
- Knowledge polymorphism across Technique, Mistake, and Concept.
- Observation Contract v1.
- Batch-level local JSONL Evidence and deterministic replay v1.
- Category-based deterministic mastery for Stop Shot and Follow Shot.
- Independent Poor Speed Control Mistake lifecycle.
- Typed Decision records and reason codes rendered by Experience.
- Architecture fitness ratchet with no new boundary violations.

The accepted behavior is defined by
`architecture/reference_behavior/canonical_golden_0_6.json` and its published
SHA-256 digest. The signed decision is recorded in
`architecture/reference_behavior/DOMAIN_REVIEW_0_6.md`.

## Transitional or Not Included

- Physical architecture remains transitional, with 143 known violations under
  the ratchet baseline.
- Dynamic mastery categories are not defined.
- Probabilistic mastery is not implemented.
- Attempt-level Evidence and true rolling windows are not implemented.
- Multi-technique prerequisite expressions are not implemented.
- Canonical Knowledge Package v1 is not yet published.
- Simulation and Vision are outside this milestone.

## Interpretation

M1 is Engineering Complete and Domain Accepted within the scope above. This
status does not claim production readiness or support beyond the reviewed
Reference Behavior.
