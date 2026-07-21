# M9 Feature Layer Map

```text
Experience / UI adapters
        |
Product Feature Application (M9.1-M9.8)
        |
Public product ports and frozen projections
        |
M3-M8 deterministic framework
        |
Knowledge / Runtime / Coach / AI boundaries
```

Product features compose views and commands. They do not own player state,
knowledge, decisions, plans, recommendations, execution, AI sessions, or
runtime delivery state.

External persistence, API, authentication, and transport remain adapters at the
edge and cannot become product-domain sources of truth.
