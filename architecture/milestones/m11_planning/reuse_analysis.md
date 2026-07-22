# M3-M10 Reuse Analysis For M11

| M11 capability | Reused frozen foundation | New bounded implementation concern |
|---|---|---|
| M11.1 | M10.1 Bootstrap, M10.7 Readiness | application startup adapter coordination |
| M11.2 | M10.2 Composition Root | concrete construction and lifetime mechanism |
| M11.3 | M10.3 Activation, M10.4 Lifecycle Host | host initialization through public ports |
| M11.4 | M3-M10 public ports/contracts | application service bindings |
| M11.5 | M9 Product projections | feature-to-service assembly |
| M11.6 | M10.5 Health Diagnostics | logs/metrics/traces adapter integration |
| M11.7 | M10.7 Readiness, M10.8 Delivery Gate | startup authorization coordination |
| M11.8 | Complete frozen contract set | end-to-end composition proof |

## Reuse Decisions

- No frozen contract is redesigned, copied, widened, or bypassed.
- Existing IDs, versions, digests, provenance, and compatibility remain
  authoritative.
- Missing behavior requires a separately approved capability or adapter, not
  inference from IDs or direct access to internals.
- Existing Flutter, persistence, transport, provider, and configuration code
  may be adapted only behind public application ports.
- Modular-monolith extraction is not part of M11.
