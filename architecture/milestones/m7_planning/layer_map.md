# M7 Layer Map

```text
Frozen M3-M6 Contracts
        |
Runtime Core (state, lifecycle, validation ports)
        |
Application (Coordinator, Dispatcher, use-case ports)
        |
Adapters (Persistence, API, infrastructure)
        |
Product Activation / Operations
```

Persistence and transport are adapters. They never become sources of truth.
AI and Coach contracts remain consumers of the deterministic runtime boundary.
