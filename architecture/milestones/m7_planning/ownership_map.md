# M7 Runtime Ownership Map

| Concern | Owner | May mutate runtime? | May observe? |
|---|---|---:|---:|
| Runtime state/lifecycle | Runtime Core | Through commands | Yes |
| Coordination | Application Coordinator | Via core ports | Yes |
| Dispatch | Application Dispatcher | Via explicit ports | Yes |
| Persistence | Infrastructure adapter | Projection storage only | Yes |
| API transport | Application adapter | No direct state writes | Yes |
| Product activation | Operations | Through activation port | Yes |
| AI/Coach | Existing M3-M5 consumers | No | Yes |
