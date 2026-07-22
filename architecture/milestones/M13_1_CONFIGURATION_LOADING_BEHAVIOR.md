# M13.1 Configuration Loading Behavior

**Status:** Accepted; Closed
**Date:** 2026-07-22

M13.1 implements the first production behavior above the frozen M3-M12
foundation. Configuration loading is owned by the Application configuration
boundary. Its only Pool OS inputs are the public
`RuntimeConfigurationEnvironmentProjectionContract` from M10.6 and
`ConfigurationAdapterPlan` from M12.2.

`ConfigurationLoader` validates the plan's exact configuration projection
binding, projects canonical configuration ownership requests, delegates value
acquisition through the replaceable `ConfigurationValueProvider` port, and
returns an immutable `RuntimeConfiguration`. Requests, entries, values,
provenance, and result identity are deterministic and digest-bound.

The frozen inputs do not define a feature-to-configuration mapping. The loader
therefore treats the Configuration Adapter Plan as aggregate authorization and
provenance and does not infer such a mapping. Configuration ownership remains
exactly the ownership already projected by M10.6.

Missing coverage, foreign ownership, duplicate entry identity, duplicate value
identity, empty required configuration, stale projection binding, and invalid
canonical ownership fail closed. There is no fallback.

## Scope Boundaries

- No frozen contract was changed.
- No direct environment, `.env`, filesystem, persistence, or network access.
- No Flutter, Provider/Riverpod/Bloc, DI container, startup, service
  activation, scheduler, or runtime lifecycle behavior.
- No Knowledge, Evidence, Learning, Player, Coach, Recommendation, or AI logic.
- Provider implementations remain replaceable infrastructure and receive only
  immutable ownership requests.

## Engineering Evidence

- Focused M13.1 tests: 7/7.
- Focused analyzer: no issues.
- Full app regression: 821/821.
- Knowledge package regression: 75/75.
- Protected M3-M12 freeze suites: 40/40.
- Architecture Fitness: 133 known violations / 0 new.
- `git diff --check`: clean.
- Frozen M3-M12 sources/artifacts, Golden Fixtures, production Knowledge,
  publication artifacts, and generated plugin artifacts remain unchanged.

No M13.2 persistence behavior or later M13 capability is implemented or
authorized by this milestone.

Product Owner accepted and closed M13.1 on 2026-07-22 and authorized M13.2
Persistence Implementation with only `PersistenceAdapterPlan` and
`RuntimeConfiguration` as Pool OS inputs.
