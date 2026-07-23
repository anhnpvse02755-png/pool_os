# P5.2 Experience ViewModel Contract Implementation

**Status:** Accepted; Closed
**Date:** 2026-07-23

## Objective

Define immutable ViewModel, view-state, projection and refresh contracts without
implementing Flutter state, controllers, listeners, data access or rendering.

## Implemented Contracts

- Interface-only generic Experience, ReadOnly and Editable ViewModel contracts.
- Immutable value-equal View State identity/metadata/version/compatibility.
- Immutable View Projection metadata/capability and Refresh context/result.
- Immutable ViewModel provenance and Shared/Core-only dependency boundary.

## Scope Guard

No Flutter Widget/State/BuildContext/setState/render object, state-management
framework, ViewModel implementation/notifier/controller/presenter/observable/
stream/listener/update/lifecycle/binding, Repository/Application/Infrastructure/
API/persistence/cache/mapper runtime, screen/page/dialog/layout/rendering,
DI/registration/reflection/plugin/composition or runtime behavior exists.

## Engineering Evidence

- Focused ViewModel contract tests pass 2/2.
- Focused analyzer and formatter are clean.
- Full app regression passes 1054/1054.
- Knowledge package regression passes 75/75.
- Protected M3-M22 freeze chain passes 76/76.
- Architecture Fitness remains 133 existing violations with 0 new.
- Prohibited Flutter/state/runtime/dependency scan is clean.
- Generated architecture health was restored; protected artifacts unchanged.
- Git scope and `git diff --check` confirm the exact authorized allowlist.

## Product Owner Decision

Accepted and closed on 2026-07-23. The Product Owner confirmed that P5.2 is
contract-only, Shared/Core-only and contains no ViewModel, Flutter, state
management or business runtime behavior.
