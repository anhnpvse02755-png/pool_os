# M6 Architecture Layer Map

```text
Experience / Product API adapters
            |
Application services and runtime composition
            |
Coach Runtime orchestration (public M3-M5 contracts)
            |
Deterministic projections and activation boundary
            |
Knowledge Runtime | Evidence Runtime | AI infrastructure ports
            |
Persistence and transport adapters (infrastructure only)
```

Dependencies point downward through public ports/contracts. No layer may reach
another domain's persistence or internal implementation. AI Provider remains an
infrastructure adapter below the application boundary.
