# M12 Adapter Layer Map

```text
Flutter / Environment / Storage / Network / AI SDK / Telemetry / Packaging
                                  |
                    M12 infrastructure adapters
                                  |
        Frozen public application contracts, ports, and M11 plans
                                  |
          Product projections and deterministic Runtime boundaries
                                  |
       Frozen Knowledge, Evidence, Learning, Coach, and AI owners
```

## Layer Rules

- External mechanisms enter only through their owning adapter.
- Adapters translate identities, values, commands, results, and failures; they
  do not reinterpret domain semantics.
- Flutter reads Product/Application projections and sends commands through
  application ports. It does not infer mastery, decisions, or recommendations.
- Persistence implements public repository ports and keeps schemas private.
- Transport owns protocol concerns, not use-case or domain policy.
- AI provider integration implements the frozen provider port; AI receives only
  approved AI boundary contracts.
- Observability exports structured records and never becomes canonical state.
- Packaging and deployment act only after accepted readiness/delivery gates.
- M12.8 validates the assembled boundary but performs no production effect.

