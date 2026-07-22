# M13.5 Dependency Activation

**Status:** Accepted; Closed
**Date:** 2026-07-22

M13.5 implements the dependency activation boundary above the frozen M11.2
`DependencyRegistrationPlan` and accepted M13.4 `RuntimeAIProviderState`.
These are the only Pool OS inputs imported by
`dependency_activation_runtime.dart`.

The originally proposed `DependencyCompositionRootContract` and
`RuntimeAIProviderState` pair had no shared public provenance. The Product
Owner superseded that input pair and authorized an M13-owned immutable
`DependencyActivationAuthorization`. The authorization binds the exact
Registration Plan ID/digest and AI Provider State ID/digest without asserting
historical ancestry between them.

`DependencyActivationRuntime` validates that authorization and the canonical
registration sequence, projects immutable activation targets, delegates only
through the replaceable `DependencyActivator` port, validates exact result
coverage, and returns an immutable deterministic
`RuntimeDependencyActivationState`. Reordered source registrations and
activation results replay to identical JSON and digest.

Stale authorization, stale plan/state bindings, duplicate or gapped
registrations, malformed ownership, missing or orphan activation coverage,
duplicate result identity or handle, and stale result bindings fail closed
without fallback.

## Scope Boundaries

- No frozen M3-M12 or accepted M13.1-M13.4 contract was changed.
- No GetIt, service locator, DI container, object construction, singleton,
  lazy injection, global registry, or post-activation mutation.
- No Flutter, routing, state management, scheduler, lifecycle execution,
  business logic, AI inference, persistence, or networking.
- The authorization is production-local M13 provenance, not a new frozen Pool
  OS cross-domain contract.

## Engineering Evidence

- Focused M13.5 tests: 8/8.
- Focused analyzer: no issues.
- Full app regression: 853/853.
- Knowledge package regression: 75/75.
- Protected M3-M12 freeze suites: 40/40.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen M3-M12 sources/artifacts, accepted M13.1-M13.4 contracts, Golden
  Fixtures, production Knowledge/publication, and generated plugin artifacts
  remain unchanged.

Product Owner accepted and closed M13.5 on 2026-07-22. M13.6 Runtime Execution
Orchestration is authorized next and may consume only
`RuntimeDependencyActivationState` and
`RuntimeLifecycleHostProjectionContract`. No M13.6 production source is
included in this milestone.
