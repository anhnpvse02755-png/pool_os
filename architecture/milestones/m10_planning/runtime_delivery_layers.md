# M10 Runtime Delivery Layers

```text
UI / API / CLI / configuration / persistence / provider adapters
                           |
Application Bootstrap and Lifecycle Host (M10.1, M10.4)
                           |
Composition Root and Activation Coordination (M10.2, M10.3)
                           |
Health, Configuration, Readiness, Delivery Gate (M10.5-M10.8)
                           |
Frozen public M6-M9 contracts and ports
                           |
Deterministic Runtime Core and domain owners
```

## Layer Rules

- Adapters translate external mechanisms into public contract inputs. They do
  not own runtime or business truth.
- Bootstrap identifies and validates an application start request; it does not
  perform domain decisions.
- The Composition Root constructs the approved dependency graph and lifetimes.
  It contains no Coach, Learning, Product, or AI policy.
- Activation and lifecycle call Runtime Core only through public ports.
- Health and diagnostics are projections of structured runtime state, not an
  alternative state store.
- Configuration is normalized adapter input with version and provenance; raw
  environment access cannot leak into deterministic domains.
- Readiness and delivery gates fail closed. They authorize delivery but do not
  mutate the frozen inputs used to decide it.
- Product surfaces observe public projections. AI continues to receive only its
  approved public session and response boundaries.
