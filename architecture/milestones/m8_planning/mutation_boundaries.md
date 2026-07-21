# M8 Mutation Boundaries

- Only Runtime Core command ports may request runtime mutation.
- Registry, resolution, health, diagnostics, delivery, and release projections
  are read models and cannot mutate Runtime Core.
- Persistence adapters may store/rebuild projections but cannot redefine truth.
- API/UI/AI consume projections and cannot write state directly.
- Release gates can reject activation; they cannot silently repair or mutate
  runtime artifacts.
