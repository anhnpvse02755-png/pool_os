# M11 Application Layer Map

```text
Flutter / API / CLI / external delivery adapters
                         |
Product Feature Assembly (M11.5)
                         |
Application Services and Public Ports (M11.4)
                         |
Bootstrap / Composition / Host Initialization (M11.1-M11.3)
                         |
Observability and Startup Validation (M11.6-M11.7)
                         |
Frozen M3-M10 contracts and deterministic Runtime Core
```

## Layer Rules

- Delivery adapters translate input and render output; they own no policy.
- Product assembly references M9 projections through application services.
- Application services coordinate use cases through public ports only.
- Bootstrap validates explicit input; it does not infer configuration or state.
- Composition owns construction and lifetime only, never business behavior.
- Host initialization invokes only approved Runtime ports after validation.
- Observability projects structured signals and cannot become Runtime truth.
- Startup validation fails closed and cannot deploy or activate by itself.
