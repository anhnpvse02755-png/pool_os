# M8 Ownership Map

| Concern | Owner | Mutates Runtime | Observes |
|---|---|---:|---:|
| Service descriptors/registry | Application | No | Yes |
| Dependency resolution | Application | No | Yes |
| Activation intent | Runtime Core | Via explicit command port | Yes |
| Health/diagnostics | Operations | No | Yes |
| Delivery readiness | Operations | No | Yes |
| Release gate | Operations | No | Yes |
| Persistence/API/transport | Adapters | No direct state mutation | Yes |
| AI | Consumer | No | Public projections only |
