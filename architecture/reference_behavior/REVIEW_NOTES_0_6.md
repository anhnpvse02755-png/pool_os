# Sprint 0.6 Domain Review Notes

**Status:** Needs Changes Implemented - Awaiting Re-review

## Questions for the Reviewer

1. Is `20/25` appropriate for Stop Shot mastery under the stated 20 cm outcome?
2. Is `18/25` appropriate for Follow Shot in the 30-50 cm target zone?
3. Should the best completed run determine mastery, or should recent-window
   consistency be required?
4. Does one `mistake.resolved` observation close Poor Speed Control, or should
   resolution require repeated clean measurements?
5. Is a human observation with confidence `1.0` acceptable, or should confidence
   be calibrated by source type?
6. Should Poor Speed Control outrank repeating the Technique when both are
   available recommendations?

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
