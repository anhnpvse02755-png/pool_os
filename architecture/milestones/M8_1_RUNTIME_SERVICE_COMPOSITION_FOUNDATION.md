# M8.1 Runtime Service Composition Foundation

**Status:** Accepted; Closed
**Date:** 2026-07-22

Adds immutable deterministic service composition metadata from M6 Runtime
Composition. It does not instantiate services, provide DI, register a runtime
registry, resolve dependencies, activate, execute, persist, or mutate state.

## Evidence

- Focused tests: 7/7.
- Analyzer: clean.
- Full app regression: 529/529.
- Knowledge package regression: 75/75.
- Protected M3-M7 freeze: 16/16.
- Architecture Fitness: 133 existing / 0 new.
- Protected artifacts and generated production artifacts unchanged.
