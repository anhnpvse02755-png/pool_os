# M11 Mutation Boundaries

M11.0 introduces no mutation. The table constrains later implementation.

| Capability | May read | Future effect through public port | Must not mutate directly |
|---|---|---|---|
| M11.1 | explicit startup input, M10 bootstrap/readiness | emit bootstrap outcome | environment, Runtime, projections |
| M11.2 | bootstrap outcome, composition declarations | construct/dispose owned instances | contracts, domain state, global service locator |
| M11.3 | composition result, activation/lifecycle contracts | request host initialization | runtime tables, historical transitions |
| M11.4 | public service ports and projections | dispatch application commands | domain persistence or internals |
| M11.5 | application projections and commands | update adapter-local presentation state | Coach/Learning/Runtime truth |
| M11.6 | health/diagnostic projections | emit logs, metrics, traces through adapters | source projections or runtime state |
| M11.7 | readiness and delivery gates | emit immutable startup authorization | deployment target or inputs |
| M11.8 | approved results from M11.1-M11.7 | coordinate bounded end-to-end flow | bypassed stores, hidden singleton state |

All future effects require explicit ports, ownership, lifecycle, failure
semantics, and focused tests. M11.0 itself creates no executable effect.
