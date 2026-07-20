# Sprint 0.6 Domain Review Notes

**Status:** Review Completed - Accepted

## Decision

The Product Owner accepted Revision 2 on 2026-07-20 after reviewing all six
golden cases and the required policy decisions. See `DOMAIN_REVIEW_0_6.md` for
the signed decision and `canonical_golden_0_6.json` for the accepted dataset.

## Questions Reviewed

1. Foundation Technique mastery uses the approved practical threshold `23/25`.
2. Stop Shot and Follow Shot use the same Foundation policy.
3. Should the best completed run determine mastery, or should recent-window
   consistency be required?
4. Poor Speed Control resolves after three consecutive clean observations.
5. Human confidence `1.0` applies only to the current review workflow.
6. Recommendations change only after a completed measurement or observation
   batch, and an active Foundation correction gates Position Control.

## Evidence Available

- deterministic compiler pack and digest;
- compiler duplicate/dangling/tamper tests;
- Technique and Mistake runtime tests;
- Evidence legacy-upcast and replay tests;
- Stop Shot and Follow Shot consumer tests;
- architecture fitness report.

## Out of Scope

Vision, Simulation, shot-level tracking, Knowledge Graph, corpus migration,
Player Model V2, Learning Planner, and capability negotiation are not evidence
for this proposal.
