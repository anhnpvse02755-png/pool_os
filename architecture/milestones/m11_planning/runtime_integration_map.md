# M11 Runtime Integration Map

| Application capability | Runtime boundary | Allowed interaction | Forbidden interaction |
|---|---|---|---|
| M11.1 Bootstrap | M10.1, M10.7 | Validate explicit startup identity and readiness | Read environment or mutate Runtime |
| M11.2 Composition | M10.2 | Construct declared dependencies and lifetimes | Resolve business policy or import internals |
| M11.3 Host Initialization | M10.3, M10.4 | Invoke approved activation/lifecycle ports | Write runtime state or transitions directly |
| M11.4 Service Wiring | Public M3-M10 ports | Bind application use cases to ports | Import persistence or domain internals |
| M11.5 Product Assembly | M9 projections | Observe projections and submit commands | Infer Coach/Learning/Runtime state |
| M11.6 Observability | M10.5 | Emit structured operational signals | Replace canonical Runtime state |
| M11.7 Startup Validation | M10.7, M10.8 | Evaluate readiness and delivery authorization | Deploy, activate, or fallback |
| M11.8 E2E Composition | All approved public boundaries | Prove complete deterministic wiring | Bypass any boundary for convenience |

Adapter mechanisms may change independently. Runtime identity, lifecycle,
readiness, and delivery semantics remain defined by frozen contracts.
