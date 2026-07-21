# M9 Mutation Boundaries

| Product capability | Reads | May issue | Must not mutate |
|---|---|---|---|
| Shell/navigation | feature availability projections | navigation intent | any domain state |
| Player/progress | Player and Experience projections | user commands through public ports | Player Model or raw events |
| Training workspace | session/execution projections | session commands through ports | execution history directly |
| Coach view | Context, Decision, Trace | acknowledge/open commands | decision/history directly |
| Recommendation inbox | Plan, Recommendation, Execution | accept/defer/complete commands through ports | Recommendation/Execution records |
| AI surface | AISession, CoachResponse, orchestration proofs | structured request intent | Evidence, Runtime, internal Coach state |
| Analytics/feedback | public projections and adapter telemetry | feedback envelope | knowledge/runtime contracts |

Every mutation crosses an existing public command/port. M9 planning does not
add a new mutation mechanism.
