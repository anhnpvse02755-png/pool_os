# M13 Behavior Layer Map

```text
External mechanisms
  Configuration | Storage | Network | AI Provider | Flutter
                         |
                  M13 behavior adapters
                         |
              Frozen M12 adapter plans/ports
                         |
        Frozen M11 application composition and host plans
                         |
         Frozen M3-M10 domain/runtime/product contracts
```

| Layer | May do | Must not do |
|---|---|---|
| External mechanism adapter | Translate SDK/protocol/storage events and perform authorized effects | Export SDK types, own business truth, bypass compatibility gates |
| Composition Root | Construct explicit implementations, bind ports, manage lifetime | Service locator discovery, hidden globals, domain policy |
| Runtime Application | Orchestrate accepted state machines and public commands | Mutate frozen contracts, infer Knowledge/Learning/Coach semantics |
| Product Application | Render projections and send commands | Infer Mastery, decisions, recommendations, or runtime state |
| Release Governance | Approve evidence-backed rollout and rollback | Perform domain decisions or rewrite history |

Dependency direction remains inward toward frozen public ports. Mechanism code
may depend on contracts; frozen deterministic code never depends on mechanisms.
